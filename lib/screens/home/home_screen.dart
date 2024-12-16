// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:ecoearn/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/waste_service.dart';
import '../../screens/general/general_screen.dart';
import '../../screens/notifications/notifications_screen.dart';

class CustomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 80);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint = Offset(size.width - (size.width / 4), size.height);
    var secondEndPoint = Offset(size.width, size.height - 80);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WasteService _wasteService = WasteService();
  Timer? _timer;
  int _currentInfoIndex = 0;
  bool _hasUnreadNotifications = false;

  final List<Map<String, String>> _infoItems = [
    {
      'image': 'assets/images/image.png',
      'text': 'REDUCE\nMinimize your waste',
    },
    {
      'image': 'assets/images/image 2.png',
      'text': 'REUSE\nGive items a second life',
    },
    {
      'image': 'assets/images/image 1.png',
      'text': 'RECYCLE\nTransform waste to new',
    },
  ];

  @override
  void initState() {
    super.initState();
    _wasteService.initializeUserStats();
    _startAutoChange();
    _checkNotifications();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startAutoChange() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        _currentInfoIndex = (_currentInfoIndex + 1) % _infoItems.length;
      });
    });
  }

  void _checkNotifications() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .where('read', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          _hasUnreadNotifications = snapshot.docs.isNotEmpty;
        });
      }
    });
  }

  Widget _buildInfoSection() {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.only(top: size.height * 0.05),
      child: Center(
        child: Container(
          height: size.height * 0.3,
          width: size.width * 0.8,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(size.width * 0.05),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: size.width * 0.02,
                offset: Offset(0, size.height * 0.005),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(size.width * 0.05),
            child: Image.asset(
              _infoItems[_currentInfoIndex]['image']!,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }


  Future<bool> onWillPop() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              Row(
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
                      child: const Text(
                        'No',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Container(
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextButton(
                      onPressed: () async {
                        await AuthService().signOut();
                        if (mounted) {
                          Navigator.of(context).pop(true);
                          Navigator.of(context).pushReplacementNamed('/signin');
                        }
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: const Text(
                        'Yes',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final firstName = user?.displayName?.split(' ')[0] ?? 'User';

    return PopScope(
      canPop: true,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  children: [
                    ClipPath(
                      clipper: CustomCurveClipper(),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.32,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.05),
                        ),
                      ),
                    ),
                    ClipPath(
                      clipper: CustomCurveClipper(),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.30,
                        width: double.infinity,
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
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.05,
                            vertical: MediaQuery.of(context).size.height * 0.03,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      StreamBuilder<DocumentSnapshot>(
                                        stream: FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(user?.uid)
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          final userData = snapshot.data?.data()
                                              as Map<String, dynamic>?;
                                          final profilePicture =
                                              userData?['profilePicture'];

                                          return ClipOval(
                                            child: profilePicture != null
                                                ? Image.memory(
                                                    base64Decode(
                                                        profilePicture),
                                                    height: 50,
                                                    width: 50,
                                                    fit: BoxFit.cover,
                                                    gaplessPlayback: true,
                                                  )
                                                : const Icon(Icons.person,
                                                    size: 50,
                                                    color: Color(0xFF2E7D32)),
                                          );
                                        },
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Hi, $firstName!',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const Text(
                                            'Start Recycling Today!',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                          ),
                                          
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      // _buildTrashCoinsBalance(),
                                      const SizedBox(width: 10),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const NotificationsScreen(),
                                            ),
                                          );

                                          // Mark notifications as read
                                          if (_hasUnreadNotifications) {
                                            if (user != null) {
                                              FirebaseFirestore.instance
                                                  .collection('notifications')
                                                  .where('userId',
                                                      isEqualTo: user.uid)
                                                  .where('read',
                                                      isEqualTo: false)
                                                  .get()
                                                  .then((notifications) {
                                                final batch = FirebaseFirestore
                                                    .instance
                                                    .batch();
                                                for (var doc
                                                    in notifications.docs) {
                                                  batch.update(doc.reference,
                                                      {'read': true});
                                                }
                                                return batch.commit();
                                              });
                                            }
                                          }
                                        },
                                        child: Stack(
                                          children: [
                                            const Icon(
                                              Icons.notifications_outlined,
                                              color: Colors.white,
                                            ),
                                            if (_hasUnreadNotifications)
                                              Positioned(
                                                right: 0,
                                                top: 0,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(4),
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.red,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  constraints:
                                                      const BoxConstraints(
                                                    minWidth: 8,
                                                    minHeight: 8,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              
                              _buildStatsContainer(), // Points section
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                _buildInfoSection(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      const Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildCategoryItem('Glass', Icons.wine_bar,
                              'assets/images/glass_bottle.png'),const SizedBox(width: 5,),
                          _buildCategoryItem('Metal', Icons.architecture,
                              'assets/images/metal_can.png'),const SizedBox(width: 5,),
                          _buildCategoryItem('Plastic', Icons.local_drink,
                              'assets/images/plastic_bottle.png'),
                          _buildCategoryItem('Electronics', Icons.devices,
                              'assets/images/electronics.png'),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                // Bottom Navigation Bar
              ],
            ),
          ),
        ),
      ),
    );
  }

Widget _buildCategoryItem(String title, IconData icon, [String? imagePath]) {
  final size = MediaQuery.of(context).size;
  final isLargeScreen = size.width > 600;

  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GeneralScreen(materialType: title),
        ),
      );
    },
    child: Column(
      children: [
        Container(
          height: isLargeScreen ? size.height * 0.15 : size.height * 0.1,
          width: size.width * 0.2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white, // Background color
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15), // Matches container radius
            child: imagePath != null
                ? Image.asset(
                    imagePath,
                    fit: BoxFit.cover, // Ensures the image covers the container
                  )
                : Icon(
                    icon,
                    color: const Color(0xFF2E7D32),
                    size: size.height * 0.05,
                  ),
          ),
        ),
        SizedBox(height: size.height * 0.01),
        Text(
          title,
          style: TextStyle(
            fontSize: size.height * 0.02,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    ),
  );
}


  Widget _buildStatsContainer() {
    return StreamBuilder<Map<String, dynamic>>(
      stream: _wasteService.getWasteStats(),
      builder: (context, snapshot) {
        // Show default values for any state (loading, error, or no data)
        final data = snapshot.data ??
            {
              'totalPoints': 0,
            };
        final points = data['totalPoints'];

        return Padding(
          padding: const EdgeInsets.all(30),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total points collected',
                      style: TextStyle(
                        color: Color.fromARGB(255, 116, 115, 115),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF34A853),
                            Color(0xFF144221),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$points pts',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
