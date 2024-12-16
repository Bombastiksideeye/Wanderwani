import 'package:flutter/material.dart';

class LearnScreen2 extends StatelessWidget {
  const LearnScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context, screenWidth),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildSectionTitle('Get your own reusable bottle', screenWidth),
                      SizedBox(height: screenHeight * 0.03),
                      _buildImageRow(screenWidth, screenHeight),
                      SizedBox(height: screenHeight * 0.02),
                      _buildSymbolRow(screenWidth, screenHeight),
                      SizedBox(height: screenHeight * 0.03),
                      _buildCaption(
                        description:
                            '• You can put that reusable bottle to use, save money, and reduce waste',
                        screenWidth: screenWidth,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      _buildCaption(
                        description:
                            '• Reduce your chances of purchasing more expensive beverages on-the-go.',
                        screenWidth: screenWidth,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      _buildCaption(
                        description:
                            '• This will eliminate the one-time use containers they come in.',
                        screenWidth: screenWidth,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.06),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF34A853),
            Color(0xFF144221),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            spreadRadius: 4,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 50,
                    width: 50,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
              Text(
                'Learn',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: screenWidth * 0.04),
           Text(
            'Ways to reduce waste',
            style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
           Text(
            'Learn how you can make small changes that are eco-friendly and will have a lasting impact.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth * 0.035,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, double screenWidth) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: screenWidth * 0.05,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildImageRow(double screenWidth, double screenHeight) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: screenWidth * 0.25,
          child: Image.asset(
            'assets/images/image 37.png',
            height: screenHeight * 0.2,
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(width: screenWidth * 0.1),
        SizedBox(
          width: screenWidth * 0.25,
          child: Image.asset(
            'assets/images/image 38.png',
            height: screenHeight * 0.2,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  Widget _buildSymbolRow(double screenWidth, double screenHeight) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: screenWidth * 0.2,
          child: Center(
            child: Icon(
              Icons.close,
              color: Colors.red,
              size: screenHeight * 0.05,
            ),
          ),
        ),
        SizedBox(width: screenWidth * 0.1),
        SizedBox(
          width: screenWidth * 0.2,
          child: Center(
            child: Icon(
              Icons.check,
              color: const Color(0xFF2E7D32),
              size: screenHeight * 0.05,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCaption({
    required String description,
    required double screenWidth,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description,
            style: TextStyle(
              color: const Color(0xFF2E7D32),
              fontWeight: FontWeight.bold,
              fontSize: screenWidth * 0.033, 
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
