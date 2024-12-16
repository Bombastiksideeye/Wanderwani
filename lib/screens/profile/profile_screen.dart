import 'dart:developer';

import 'package:ecoearn/screens/onboarding_screen.dart';
import 'package:ecoearn/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/profile_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final ProfileService _profileService = ProfileService();

  Future<void> _redeemPoints(BuildContext context, int currentPoints) async {
    int? pointsToRedeem;
    final pointsController = TextEditingController();

    // Display dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  // Star/coin icon at the top
                  Image.asset(
                    'assets/images/Group 36706.png',
                    height: 100,
                  ),

                  // "Points earned" title
                  const SizedBox(height: 16),
                  Text(
                    'Redeem Your Points',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),

                  // Description text
                  const SizedBox(height: 8),
                  const Text(
                    'Enter the number of points you want to redeem. Points must be a multiple of 10.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color.fromARGB(255, 95, 94, 94)),
                  ),

                  // Points input field
                  const SizedBox(height: 16),
                  TextField(
                    controller: pointsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.monetization_on),
                      hintText: 'Points (e.g., 10, 20)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      final int? points = int.tryParse(value);

                      if (points != null && points > 10000) {
                        // Reset to 10,000 if input exceeds the limit
                        pointsController.text = '10000';
                        pointsController.selection = TextSelection.fromPosition(
                          TextPosition(offset: pointsController.text.length),
                        );
                        setState(() => pointsToRedeem = 10000);
                      } else {
                        setState(() => pointsToRedeem = points);
                      }
                    },
                  ),

                  // "You will receive X TrashCoins" feedback
                  const SizedBox(height: 8),
                  Text(
                    pointsToRedeem != null && pointsToRedeem! % 10 == 0
                        ? 'You will receive ${pointsToRedeem! ~/ 10} TrashCoins'
                        : 'Invalid points entered',
                    style: TextStyle(
                      color: pointsToRedeem != null && pointsToRedeem! % 10 == 0
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              );
            },
          ),
          actions: [
            // Cancel Button
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Colors.green,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Container(
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextButton(
                      onPressed: () {
                        final points = int.tryParse(pointsController.text);
                        if (points != null &&
                            points <= currentPoints &&
                            points % 10 == 0) {
                          Navigator.pop(context, points);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Invalid points amount')),
                          );
                        }
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Redeem'),
                    ),
                  ),
                ],
              ),
            ),

            // Confirm Button
          ],
        );
      },
    ).then((redeemedPoints) async {
      if (redeemedPoints == null) return;

      // Confirm redemption
      final confirmed = await showDialog<bool>(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Redemption'),
            content: Text(
              'Are you sure you want to redeem $redeemedPoints points for ${redeemedPoints ~/ 10} TrashCoins?',
            ),
            actions: [
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: Colors.green,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Container(
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Confirm'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );

      if (confirmed != true) return;

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return;

        final tcToAdd = redeemedPoints ~/ 10;

        // Update Firestore data
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'totalPoints': FieldValue.increment(-redeemedPoints),
          'trashCoins': FieldValue.increment(tcToAdd),
        });

        // Add notification
        await FirebaseFirestore.instance.collection('notifications').add({
          'userId': user.uid,
          'type': 'redeem',
          'message':
              'Successfully redeemed $redeemedPoints points for  $tcToAdd TrashCoins',
          'timestamp': FieldValue.serverTimestamp(),
          'read': false,
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Successfully redeemed $tcToAdd TrashCoins!')),
          );
        }
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to redeem points')),
        );
      }
    });
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('No'),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Container(
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextButton(
                      onPressed: () async {
                        // Perform logout logic here
                        await _logoutUser();

                        // Navigate to the login or onboarding screen
                        Navigator.pushAndRemoveUntil(
                          // ignore: use_build_context_synchronously
                          context,
                          MaterialPageRoute(
                              builder: (context) => const OnboardingScreen()),
                          (Route<dynamic> route) =>
                              false, // Remove all previous routes
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Yes'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logoutUser() async {
    await AuthService().signOut();
    await Future.delayed(
        const Duration(milliseconds: 500)); // Simulate logout delay
    log('User logged out');
  }

  Future<void> _changeProfilePicture(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    // Convert image to Base64
    final bytes = File(image.path).readAsBytesSync();
    String base64Image = base64Encode(bytes);

    // Update Firestore with the new Base64 image
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'profilePicture': base64Image,
      });

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () => _showLogoutDialog(context),
            child: const Icon(
              Icons.logout_outlined,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: StreamBuilder<Map<String, dynamic>>(
              stream: _profileService.getProfileStats(),
              builder: (context, profileSnapshot) {
                return StreamBuilder<Map<String, dynamic>>(
                  stream: _profileService.getRecyclingStats(),
                  builder: (context, recyclingSnapshot) {
                    final profileData = profileSnapshot.data ?? {};
                    final recyclingData = recyclingSnapshot.data ?? {};

                    final totalPoints = profileData['totalPoints'] ?? 0;

                    final monthlyData = {
                      'plastic_weight':
                          recyclingData['plastic_weight_month'] ?? 0.0,
                      'glass': recyclingData['glass_items_month'] ?? 0,
                      'metal_weight':
                          recyclingData['metal_weight_month'] ?? 0.0,
                      'electronics_weight':
                          recyclingData['electronics_weight_month'] ?? 0.0,
                    };

                    final totalData = {
                      'plastic_weight':
                          recyclingData['plastic_weight_total'] ?? 0.0,
                      'glass': recyclingData['glass_items_total'] ?? 0,
                      'metal_weight':
                          recyclingData['metal_weight_total'] ?? 0.0,
                      'electronics_weight':
                          recyclingData['electronics_weight_total'] ?? 0.0,
                    };

                    return Column(
                      children: [
                        const SizedBox(height: 20),
                        // Profile Image and Name
                        GestureDetector(
                          onTap: () => _changeProfilePicture(context),
                          child: Container(
                            width: double.infinity,
                            color: Colors.green[100]?.withOpacity(0.3),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 30),
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 50,
                                    backgroundColor: Colors.grey[200],
                                    backgroundImage:
                                        profileData['profilePicture'] != null
                                            ? MemoryImage(base64Decode(
                                                profileData['profilePicture']))
                                            : null,
                                    child: profileData['profilePicture'] == null
                                        ? const Icon(Icons.person,
                                            size: 50, color: Colors.grey)
                                        : null,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    user?.displayName ?? 'User',
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Points Section
                        Container(
                          color: Colors.green[100]?.withOpacity(0.3),
                          width: double.infinity,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical:
                                  MediaQuery.of(context).size.height * 0.01,
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.025,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Earned Total Points: ',
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.018,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.02),
                                Text(
                                  '$totalPoints',
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.02,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                ElevatedButton(
                                  onPressed: () =>
                                      _redeemPoints(context, totalPoints),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF34A853),
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                              0.05,
                                      vertical:
                                          MediaQuery.of(context).size.height *
                                              0.01,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  child: Text(
                                    'Redeem',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          MediaQuery.of(context).size.height *
                                              0.018,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),
                        // Recycled Materials Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 5,
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Title
                              const Text(
                                'Recycled Materials',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Glass Items Pie Chart
                              Column(
                                children: [
                                  SizedBox(
                                    height: 160,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        PieChart(
                                          PieChartData(
                                            sectionsSpace: 4,
                                            centerSpaceRadius: 55,
                                            sections: [
                                              PieChartSectionData(
                                                value: monthlyData['glass']!
                                                    .toDouble(),
                                                color: Colors.blue,
                                                title: '',
                                                radius: 20,
                                              ),
                                              // Add a dummy section if glass items is 0
                                              if (monthlyData['glass'] == 0)
                                                PieChartSectionData(
                                                  value: 1,
                                                  color: Colors.grey
                                                      .withOpacity(0.2),
                                                  title: '',
                                                  radius: 20,
                                                ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '${monthlyData['glass']} items',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Text(
                                    'Glass this month',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  // Weight Bar Graph
                                  Container(
                                    height: 200,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: BarChart(
                                      BarChartData(
                                        alignment:
                                            BarChartAlignment.spaceAround,
                                        maxY: [
                                              monthlyData['plastic_weight']!,
                                              monthlyData['metal_weight']!,
                                              monthlyData[
                                                  'electronics_weight']!,
                                            ].reduce((max, value) =>
                                                value > max ? value : max) *
                                            1.2,
                                        gridData: FlGridData(
                                          show: true,
                                          drawVerticalLine: false,
                                          horizontalInterval: 1,
                                          getDrawingHorizontalLine: (value) {
                                            return const FlLine(
                                              color: Colors.white,
                                              strokeWidth: 1,
                                            );
                                          },
                                        ),
                                        titlesData: FlTitlesData(
                                          show: true,
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 30,
                                              getTitlesWidget: (value, meta) {
                                                IconData icon;
                                                Color color;
                                                switch (value.toInt()) {
                                                  case 0:
                                                    icon = Icons
                                                        .local_drink_outlined; // Plastic icon
                                                    color = Colors.green;
                                                    break;
                                                  case 1:
                                                    icon = Icons
                                                        .settings; // Metal icon
                                                    color = Colors.yellow;
                                                    break;
                                                  case 2:
                                                    icon = Icons
                                                        .devices; // Electronics icon
                                                    color = Colors.orange;
                                                    break;
                                                  default:
                                                    return const Text('');
                                                }
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 8.0),
                                                  child:
                                                      Icon(icon, color: color),
                                                );
                                              },
                                            ),
                                          ),
                                          leftTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 40,
                                              getTitlesWidget: (value, meta) {
                                                return Text(
                                                  value.toStringAsFixed(1),
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 12,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          topTitles: const AxisTitles(
                                              sideTitles: SideTitles(
                                                  showTitles: false)),
                                          rightTitles: const AxisTitles(
                                              sideTitles: SideTitles(
                                                  showTitles: false)),
                                        ),
                                        borderData: FlBorderData(show: false),
                                        barGroups: [
                                          BarChartGroupData(
                                            x: 0,
                                            barRods: [
                                              BarChartRodData(
                                                toY: monthlyData[
                                                        'plastic_weight']!
                                                    .toDouble(),
                                                color: Colors.green,
                                                width: 20,
                                                borderRadius:
                                                    const BorderRadius.vertical(
                                                        top:
                                                            Radius.circular(6)),
                                                backDrawRodData:
                                                    BackgroundBarChartRodData(
                                                  show: true,
                                                  toY: [
                                                        monthlyData[
                                                            'plastic_weight']!,
                                                        monthlyData[
                                                            'metal_weight']!,
                                                        monthlyData[
                                                            'electronics_weight']!,
                                                      ].reduce((max, value) =>
                                                          value > max
                                                              ? value
                                                              : max) *
                                                      1.2,
                                                  color: Colors.grey
                                                      .withOpacity(0.1),
                                                ),
                                              ),
                                            ],
                                          ),
                                          BarChartGroupData(
                                            x: 1,
                                            barRods: [
                                              BarChartRodData(
                                                toY:
                                                    monthlyData['metal_weight']!
                                                        .toDouble(),
                                                color: Colors.yellow,
                                                width: 20,
                                                borderRadius:
                                                    const BorderRadius.vertical(
                                                        top:
                                                            Radius.circular(6)),
                                                backDrawRodData:
                                                    BackgroundBarChartRodData(
                                                  show: true,
                                                  toY: [
                                                        monthlyData[
                                                            'plastic_weight']!,
                                                        monthlyData[
                                                            'metal_weight']!,
                                                        monthlyData[
                                                            'electronics_weight']!,
                                                      ].reduce((max, value) =>
                                                          value > max
                                                              ? value
                                                              : max) *
                                                      1.2,
                                                  color: Colors.grey
                                                      .withOpacity(0.1),
                                                ),
                                              ),
                                            ],
                                          ),
                                          BarChartGroupData(
                                            x: 2,
                                            barRods: [
                                              BarChartRodData(
                                                toY: monthlyData[
                                                        'electronics_weight']!
                                                    .toDouble(),
                                                color: Colors.orange,
                                                width: 20,
                                                borderRadius:
                                                    const BorderRadius.vertical(
                                                        top:
                                                            Radius.circular(6)),
                                                backDrawRodData:
                                                    BackgroundBarChartRodData(
                                                  show: true,
                                                  toY: [
                                                        monthlyData[
                                                            'plastic_weight']!,
                                                        monthlyData[
                                                            'metal_weight']!,
                                                        monthlyData[
                                                            'electronics_weight']!,
                                                      ].reduce((max, value) =>
                                                          value > max
                                                              ? value
                                                              : max) *
                                                      1.2,
                                                  color: Colors.grey
                                                      .withOpacity(0.1),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              // Table Legend
                              Divider(
                                  color: Colors.grey.shade300, thickness: 1),
                              Table(
                                columnWidths: const {
                                  0: FlexColumnWidth(1),
                                  1: FlexColumnWidth(1),
                                  2: FlexColumnWidth(1),
                                },
                                children: [
                                  const TableRow(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 0),
                                        child: Text(
                                          'MATERIAL',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 0),
                                        child: Text(
                                          'THIS MONTH',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(right: 35),
                                        child: Text(
                                          'TOTAL',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                  _buildTableRow(
                                    'Plastic',
                                    '${monthlyData['plastic_weight']} kg',
                                    '${totalData['plastic_weight']} kg',
                                    Colors.green,
                                  ),
                                  _buildTableRow(
                                    'Glass',
                                    '${monthlyData['glass']} items',
                                    '${totalData['glass']} items',
                                    Colors.blue,
                                  ),
                                  _buildTableRow(
                                    'Metal',
                                    '${monthlyData['metal_weight']} kg',
                                    '${totalData['metal_weight']} kg',
                                    Colors.yellow,
                                  ),
                                  _buildTableRow(
                                    'Electronics',
                                    '${monthlyData['electronics_weight']} kg',
                                    '${totalData['electronics_weight']} kg',
                                    Colors.orange,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
      // Bottom navigation bar
    );
  }

  TableRow _buildTableRow(
      String material, String month, String total, Color color) {
    String monthValue, totalValue;
    if (material == 'Glass') {
      monthValue = month;
      totalValue = total;
    } else {
      // For non-glass materials, show weight in kg
      monthValue = '${double.parse(month.split(' ')[0]).toStringAsFixed(1)} kg';
      totalValue = '${double.parse(total.split(' ')[0]).toStringAsFixed(1)} kg';
    }

    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(material),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 35, top: 10),
          child: Text(monthValue),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 35, top: 10),
          child: Text(totalValue),
        ),
      ],
    );
  }
}
