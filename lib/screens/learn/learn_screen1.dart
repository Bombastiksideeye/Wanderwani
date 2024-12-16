import 'package:flutter/material.dart';

class LearnScreen1 extends StatelessWidget {
  const LearnScreen1({super.key});

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
                      horizontal: screenWidth * 0.06, vertical: screenHeight * 0.03),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildSectionTitle('Plastics can be recycled', screenWidth),
                      SizedBox(height: screenHeight * 0.03),

                     
                      _buildImageRow(screenWidth, screenHeight),
                      SizedBox(height: screenHeight * 0.02),
                      _buildSymbolRow(screenWidth, screenHeight),
                      SizedBox(height: screenHeight * 0.03),

                      
                      _buildCaption(
                        title: 'Plastic Bags (Non-Recyclable)',
                        description:
                            '• Plastic bags often get tangled in recycling machinery.\n• Return them to designated bins at local grocery stores for proper recycling.',
                        screenWidth: screenWidth,
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      _buildCaption(
                        title: 'Plastic Bottles & Containers (Recyclable)',
                        description:
                            '• Most plastic bottles and containers, like water bottles, milk jugs, and detergent containers, are recyclable.\n• Make sure to rinse them out and remove any lids before recycling.',
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

  // Header section with gradient background
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
            'Learn to recycle plastics',
            style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth * 0.04, 
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: screenWidth * 0.02),
          Text(
            'Discover which types of plastic can be recycled to help reduce waste and keep our planet clean. With informed choices, each of us can make a difference for the environment.',
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
            'assets/images/image 39.png',
            height: screenHeight * 0.2,
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(width: screenWidth * 0.1),
        SizedBox(
          width: screenWidth * 0.25, 
          child: Image.asset(
            'assets/images/image 37.png',
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
    required String title,
    required String description,
    required double screenWidth,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2E7D32),
            ),
          ),
          SizedBox(height: screenWidth * 0.02),
          Text(
            description,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: screenWidth * 0.033, 
              color: const Color(0xFF2E7D32),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
