import 'package:flutter/material.dart';
import 'learn_screen1.dart';
import 'learn_screen2.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(screenWidth),
                SizedBox(height: screenHeight * 0.02),
                _buildSectionTitle('Good to know', screenWidth),
                SizedBox(height: screenHeight * 0.03),
                _buildInfoCards(context, screenWidth, screenHeight),
                SizedBox(height: screenHeight * 0.03),
                _buildSectionTitle('Topic for you', screenWidth),
                SizedBox(height: screenHeight * 0.03),
                _buildTopicList(screenWidth, screenHeight),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double screenWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text.rich(
        TextSpan(
          text: 'Waste Less, ',
          style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold, color: Colors.black),
          children: const [
            TextSpan(text: 'Live More!', style: TextStyle(color: Colors.green)),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSectionTitle(String title, double screenWidth) {
    return Text(
      title,
      style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold, color: Colors.black87),
    );
  }

  Widget _buildInfoCards(BuildContext context, double screenWidth, double screenHeight) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildInfoCard(
          title: 'What plastics\ncan be recycled?',
          iconPath: 'assets/images/image 35.png',
          screenWidth: screenWidth,
          screenHeight: screenHeight,
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const LearnScreen1()));
          },
        ),
        _buildInfoCard(
          title: 'Ways to\nreduce waste',
          iconPath: 'assets/images/image 37 (1).png',
          screenWidth: screenWidth,
          screenHeight: screenHeight,
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const LearnScreen2()));
          },
        ),
      ],
    );
  }

  Widget _buildTopicList(double screenWidth, double screenHeight) {
    return Column(
      children: [
        _buildTopicCard(
          imagePath: 'assets/images/image (0).png',
          title: 'Waste to artwork',
          description: 'Artists use recycled or reused objects to make attractive pieces of contemporary art.',
          screenWidth: screenWidth,
          screenHeight: screenHeight,
        ),
        SizedBox(height: screenHeight * 0.02),
        _buildTopicCard(
          imagePath: 'assets/images/image (1).png',
          title: 'Become a volunteer',
          description: 'Join efforts to recycle and reduce waste through volunteering activities in your community.',
          screenWidth: screenWidth,
          screenHeight: screenHeight,
        ),
        SizedBox(height: screenHeight * 0.02),
        _buildTopicCard(
          imagePath: 'assets/images/image (2).png',
          title: 'Community Recycling',
          description: 'Learn how communities work together to promote recycling and sustainability.',
          screenWidth: screenWidth,
          screenHeight: screenHeight,
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String iconPath,
    required String title,
    required VoidCallback onTap,
    required double screenWidth,
    required double screenHeight,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: screenHeight * 0.22,
        width: screenWidth * 0.4,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: screenWidth * 0.030, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Image.asset(iconPath, height: screenHeight * 0.12, width: screenWidth * 0.15),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicCard({
    required String imagePath,
    required String title,
    required String description,
    required double screenWidth,
    required double screenHeight,
  }) {
    return Container(
      height: screenHeight * 0.20,
      width: screenWidth * 0.9,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.black.withOpacity(0.6), Colors.black.withOpacity(0.3)],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(color: Colors.white70, fontSize: screenWidth * 0.03),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: screenHeight * 0.03),
            ],
          ),
        ),
      ),
    );
  }
}
