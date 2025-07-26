import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('About Farmer Friends'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.agriculture,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 24),
            Center(
              child: Text(
                'Farmer Friends',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            SizedBox(height: 8),
            Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            SizedBox(height: 32),
            _buildSection(
              'Our Mission',
              'Farmer Friends is dedicated to connecting farmers with customers, providing fresh, quality agricultural products directly from farm to table. We believe in supporting local farmers and sustainable agriculture.',
            ),
            _buildSection(
              'What We Offer',
              '• Fresh fruits and vegetables\n• Quality seeds and fertilizers\n• Farm equipment and tools\n• Direct farmer-to-customer connection\n• Sustainable farming practices',
            ),
            _buildSection(
              'Contact Us',
              'Email: support@farmerfriends.com\nPhone: +233 123 456 789\nAddress: Accra, Ghana',
            ),
            _buildSection(
              'Follow Us',
              'Stay connected with us on social media for the latest updates and farming tips.',
            ),
            SizedBox(height: 32),
            Center(
              child: Text(
                '© 2024 Farmer Friends. All rights reserved.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Container(
      margin: EdgeInsets.only(bottom: 24),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}