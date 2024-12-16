
import 'package:ecoearn/screens/admin/activity_log.dart';
import 'package:ecoearn/screens/admin/admin_login_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'admin_service.dart';
import 'recycling_requests_screen.dart';
import 'pricing_screen.dart';

class AdminScreen extends StatelessWidget {
  final AdminService _adminService = AdminService();

  AdminScreen({super.key});

  Widget _buildStatsCard(Map<String, int> data) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Recycled Materials',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

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
                        centerSpaceRadius: 50,
                        sections: [
                          PieChartSectionData(
                            value: data['glass']?.toDouble() ?? 0,
                            color: Colors.blue,
                            title: '',
                            radius: 15,
                          ),
                          if ((data['glass'] ?? 0) == 0)
                            PieChartSectionData(
                              value: 1,
                              color: Colors.grey.withOpacity(0.2),
                              title: '',
                              radius: 20,
                            ),
                        ],
                      ),
                    ),
                    Text(
                      '${data['glass'] ?? 0} items',
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
            ],
          ),
          const SizedBox(height: 24),

          // Weight Bar Graph
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('recycling_requests')
                  .where('status', isEqualTo: 'approved')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Calculate total weights for each material type
                double plasticWeight = 0;
                double metalWeight = 0;
                double electronicsWeight = 0;

                for (var doc in snapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final materialType =
                      data['materialType']?.toString().toLowerCase();
                  final weight = (data['weight'] ?? 0).toDouble();
                  if (kDebugMode) {
                    print('$materialType and $weight');
                  }
                  switch (materialType) {
                    case 'plastic':
                      plasticWeight += weight;
                      break;
                    case 'metal':
                      metalWeight += weight;
                      break;
                    case 'electronics':
                      electronicsWeight += weight;
                      break;
                  }
                }

                return BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: [plasticWeight, metalWeight, electronicsWeight]
                            .reduce((max, value) => value > max ? value : max) *
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
                                icon = Icons.local_drink_outlined;
                                color = Colors.green;
                                break;
                              case 1:
                                icon = Icons.settings;
                                color = Colors.yellow;
                                break;
                              case 2:
                                icon = Icons.devices;
                                color = Colors.orange;
                                break;
                              default:
                                return const Text('');
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Icon(icon, color: color),
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
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      BarChartGroupData(
                        x: 0,
                        barRods: [
                          BarChartRodData(
                            toY: plasticWeight,
                            color: Colors.green,
                            width: 20,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6)),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: [
                                    plasticWeight,
                                    metalWeight,
                                    electronicsWeight
                                  ].reduce((max, value) =>
                                      value > max ? value : max) *
                                  1.2,
                              color: Colors.grey.withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 1,
                        barRods: [
                          BarChartRodData(
                            toY: metalWeight,
                            color: Colors.yellow,
                            width: 20,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6)),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: [
                                    plasticWeight,
                                    metalWeight,
                                    electronicsWeight
                                  ].reduce((max, value) =>
                                      value > max ? value : max) *
                                  1.2,
                              color: Colors.grey.withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 2,
                        barRods: [
                          BarChartRodData(
                            toY: electronicsWeight,
                            color: Colors.orange,
                            width: 20,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6)),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: [
                                    plasticWeight,
                                    metalWeight,
                                    electronicsWeight
                                  ].reduce((max, value) =>
                                      value > max ? value : max) *
                                  1.2,
                              color: Colors.grey.withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.grey.shade300, thickness: 1),
          const SizedBox(height: 10),

          // Legend Table
          Table(
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(1),
            },
            children: [
              const TableRow(
                children: [
                  Text('MATERIAL', style: TextStyle(color: Colors.grey)),
                  Text('TOTAL', style: TextStyle(color: Colors.grey)),
                ],
              ),
              _buildTableRow(
                  'Plastic', '${data['plastic'] ?? 0} kg', Colors.green),
              _buildTableRow(
                  'Glass', '${data['glass'] ?? 0} items', Colors.blue),
              _buildTableRow(
                  'Metal', '${data['metal'] ?? 0} kg', Colors.yellow),
              _buildTableRow('Electronics', '${data['electronics'] ?? 0} kg',
                  Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  TableRow _buildTableRow(String material, String total, Color color) {
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
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(total),
        ),
      ],
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // "No" Button
                Container(
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                    child: const Text('No'),
                  ),
                ),
                const SizedBox(width: 15),
                // "Yes" Button
                Container(
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextButton(
                    onPressed: () async {
                      await _logoutUser();
                      Navigator.pushAndRemoveUntil(
                        // ignore: use_build_context_synchronously
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AdminLoginScreen()),
                        (Route<dynamic> route) => false,
                      );
                    },
                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                    child: const Text('Yes'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _logoutUser() async {
    // Simulate logout logic
    await Future.delayed(const Duration(milliseconds: 500));
    if (kDebugMode) {
      print('User logged out');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(120), // Adjust height as needed
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF34A853),
                      Color(0xFF144221),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              AppBar(
                title: const Text(
                  'Admin Panel',
                  style: TextStyle(color: Colors.white),
                ),
                centerTitle: true,
                backgroundColor:
                    Colors.transparent, // Transparent to show gradient
                elevation: 10,
                automaticallyImplyLeading: false, // Removes back arrow
                actions: [
                  IconButton(
                    icon:
                        const Icon(Icons.logout_outlined, color: Colors.white),
                    onPressed: () => _showLogoutDialog(context),
                  ),
                ],

                bottom: const TabBar(
                  tabs: [
                    Tab(
                      icon: Icon(Icons.analytics),
                      text: 'Statistics',
                    ),
                    Tab(
                      icon: Icon(Icons.list_alt),
                      text: 'Requests',
                    ),
                    Tab(
                      icon: Icon(Icons.attach_money),
                      text: 'Pricing',
                    ),
                    Tab(
                      icon: Icon(Icons.event_note_rounded),
                      text: 'Activity Log',
                    ),
                  ],
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Statistics Tab
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FutureBuilder<Map<String, int>>(
                  future: _adminService.getTotalRecyclingStats(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        height: 300,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (snapshot.hasError) {
                      return SizedBox(
                        height: 300,
                        child: Center(child: Text('Error: ${snapshot.error}')),
                      );
                    }
                    return _buildStatsCard(snapshot.data ?? {});
                  },
                ),
              ),
            ),

            // Requests Tab
            const RecyclingRequestsScreen(),

            // Pricing Tab
            const PricingScreen(),

            const ActivityLogScreen(),
          ],
        ),
      ),
    );
  }
}
