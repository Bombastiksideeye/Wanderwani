// ignore_for_file: library_private_types_in_public_api

import 'package:ecoearn/screens/admin/admin_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ActivityLogScreen extends StatefulWidget {
  const ActivityLogScreen({super.key});

  @override
  _ActivityLogScreenState createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  final AdminService _controller = Get.put(AdminService());
  String searchQuery = "";
  String filterType = "All";

  @override
  void initState() {
    super.initState();
    _controller.fetchActivityData();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.03,
          vertical: 50,
        ),
        child: Obx(() {
          final activityData = _controller.activityLogs;

          final filteredData = activityData
              .where((row) =>
                  (filterType == "All" || row['action'] == filterType) &&
                  row['email']
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase()))
              .toList();

          final totalUsers = activityData.length;
          final onlineUsers =
              activityData.where((row) => row['action'] == "Online").length;
          final offlineUsers =
              activityData.where((row) => row['action'] == "Offline").length;

          return Column(
            children: [
              Text(
                'Activity Log',
                style: TextStyle(
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 30),
              // Search Bar
              TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Search by email...",
                  hintStyle: const TextStyle(color: Colors.black45),
                  prefixIcon: const Icon(Icons.search, color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Summary Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSummaryCard(
                    title: "Total Users",
                    count: totalUsers,
                    color: Colors.grey.withOpacity(0.5),
                    onTap: () {
                      setState(() {
                        filterType = "All";
                      });
                    },
                  ),
                  _buildSummaryCard(
                    title: "Online Users",
                    count: onlineUsers,
                    color: Colors.green.withOpacity(0.8),
                    onTap: () {
                      setState(() {
                        filterType = "Online";
                      });
                    },
                  ),
                  _buildSummaryCard(
                    title: "Offline Users",
                    count: offlineUsers,
                    color: Colors.red.withOpacity(0.7),
                    onTap: () {
                      setState(() {
                        filterType = "Offline";
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Data Table
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      columnSpacing: screenWidth * 0.05,
                      columns: [
                        _buildDataColumn("Email", screenWidth),
                        _buildDataColumn("IP Address", screenWidth),
                        _buildDataColumn("Date", screenWidth),
                        _buildDataColumn("Time", screenWidth),
                        _buildDataColumn("Action", screenWidth),
                        _buildDataColumn("Description", screenWidth),
                      ],
                      rows: filteredData.map((row) {
                        return DataRow(cells: [
                          DataCell(Text(row['email'], style: _cellTextStyle())),
                          DataCell(Text(row['ip'], style: _cellTextStyle())),
                          DataCell(Text(row['date'], style: _cellTextStyle())),
                          DataCell(Text(row['time'], style: _cellTextStyle())),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                color: row['action'] == "Online"
                                    ? Colors.green.withOpacity(0.8)
                                    : Colors.red.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: Text(
                                row['action'],
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          DataCell(Text(row['description'],
                              style: _cellTextStyle())),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required int count,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "$count",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  DataColumn _buildDataColumn(String label, double screenWidth) {
    return DataColumn(
      label: Text(
        label,
        style: TextStyle(
          fontSize: screenWidth * 0.03,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  TextStyle _cellTextStyle() {
    return const TextStyle(color: Colors.black);
  }
}
