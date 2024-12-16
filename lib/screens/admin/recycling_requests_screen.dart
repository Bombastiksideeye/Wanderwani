import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'admin_service.dart';

class RecyclingRequestsScreen extends StatelessWidget {
  const RecyclingRequestsScreen({super.key});

  Widget _buildImageWidget(BuildContext context, String? base64Image) {
    if (base64Image == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            child: Stack(
              children: [
                Image.memory(
                  base64Decode(base64Image),
                  fit: BoxFit.contain,
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: MemoryImage(base64Decode(base64Image)),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final timestamp = data['timestamp'] as Timestamp?;
    final dateStr = timestamp != null
        ? DateFormat('MMM dd, yyyy HH:mm').format(timestamp.toDate())
        : 'No date';
    
    final materialType = (data['materialType'] ?? 'Unknown').toString().toUpperCase();
    final quantity = data['quantity']?.toString() ?? '0';
    final weight = data['weight']?.toString() ?? '0';
    final metalType = data['metalType'];
    final adminService = AdminService();
    
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ExpansionTile(
        title: Text(data['userName'] ?? 'Unknown User'),
        subtitle: Text(
          materialType == 'METAL' 
              ? '$materialType - ${metalType ?? 'Unknown'} - $dateStr'
              : '$materialType - $dateStr',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status: ${(data['status'] ?? 'Unknown').toUpperCase()}'),
                if (materialType == 'GLASS')
                  Text('Quantity: $quantity items'),
                if (materialType == 'METAL')
                  Text('Metal Type: ${metalType ?? 'Unknown'}'),
                if (data['weight'] != null && materialType != 'GLASS') 
                  Text('Weight: ${data['weight']} kg'),
                const SizedBox(height: 8),
                if (data['imageData'] != null) ...[
                  const Text('Image:'),
                  const SizedBox(height: 8),
                  _buildImageWidget(context, data['imageData']),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        final shouldDelete = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirm Delete'),
                            content: const Text('Are you sure you want to delete this request?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (shouldDelete == true) {
                          try {
                            await adminService.deleteRequest(doc.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Request deleted successfully')),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error deleting request: $e')),
                              );
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(100, 40),
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      label: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    if (data['status'] == 'pending')
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            final userId = data['userId'];
                            if (userId == null) {
                              throw 'User ID not found';
                            }

                            // Calculate points based on material type and quantity/weight
                            final points = await adminService.calculatePoints(
                              materialType.toLowerCase(),
                              metalType,
                              double.tryParse(weight) ?? 0.0,
                              int.tryParse(quantity),
                            );

                            await adminService.approveRequest(doc.id, userId, points);

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Request approved successfully. Points awarded: $points'),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(100, 40),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          backgroundColor: const Color(0xFF2E7D32),
                          
                        ),
                        child: const Text(
                          'Approve',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminService = AdminService();

    return StreamBuilder<QuerySnapshot>(
      stream: adminService.getRecyclingRequests(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No recycling requests found'));
        }

        return Padding(
          padding: const EdgeInsets.all(30),
          child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 5,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
                   
            child: ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final doc = snapshot.data!.docs[index];
                return _buildRequestCard(context, doc);
              },
            ),
                  ),
          ),
        );
      },
    );
  }
}
