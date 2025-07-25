import 'package:agroconnect/screens/admin/admin_login_screen.dart';
import 'package:agroconnect/screens/feedback/feedback_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../auth/login_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          if (auth.user == null) {
            return _buildNotLoggedIn(context);
          }

          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(auth),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildProfileInfo(context, auth),
                    _buildMenuItems(context, auth),
                    SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotLoggedIn(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: 100,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 24),
            Text(
              'Please Login',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Login to access your profile and orders',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            CustomButton(
              text: 'Login',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(AuthProvider auth) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primaryLight,
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 60),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: auth.user?.profileImage.isNotEmpty == true
                      ? ClipOval(
                          child: Image.network(
                            auth.user!.profileImage,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Text(
                                auth.user!.name.substring(0, 1).toUpperCase(),
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              );
                            },
                          ),
                        )
                      : Text(
                          auth.user!.name.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                ),
                SizedBox(height: 16),
                Text(
                  auth.user!.name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  auth.user!.email,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfo(BuildContext context, AuthProvider auth) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16),
          _buildInfoRow(Icons.phone, 'Phone', auth.user!.phone.isEmpty ? 'Not provided' : auth.user!.phone),
          _buildInfoRow(Icons.location_on, 'Address', auth.user!.address.isEmpty ? 'Not provided' : auth.user!.address),
          _buildInfoRow(Icons.calendar_today, 'Member since', _formatDate(auth.user!.createdAt)),
          SizedBox(height: 16),
          CustomButton(
            text: 'Edit Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.primary,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context, AuthProvider auth) {
  final menuItems = [
    {'icon': Icons.receipt_long, 'title': 'My Orders', 'subtitle': 'View your order history'},
    {'icon': Icons.favorite, 'title': 'Wishlist', 'subtitle': 'Your favorite products'},
    {'icon': Icons.location_on, 'title': 'Addresses', 'subtitle': 'Manage delivery addresses'},
    {'icon': Icons.payment, 'title': 'Payment Methods', 'subtitle': 'Manage payment options'},
    {'icon': Icons.notifications, 'title': 'Notifications', 'subtitle': 'Notification preferences'},
    {'icon': Icons.feedback, 'title': 'Send Feedback', 'subtitle': 'Help us improve the app'},
    {'icon': Icons.help, 'title': 'Help & Support', 'subtitle': 'Get help and support'},
    {'icon': Icons.info, 'title': 'About', 'subtitle': 'About Farmer Friends'},
    // Add admin access
    {'icon': Icons.admin_panel_settings, 'title': 'Admin Portal', 'subtitle': 'For authorized personnel only'},
  ];

  return Container(
    margin: EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      children: [
        ...menuItems.map((item) => _buildMenuItem(
          context,
          item['icon'] as IconData,
          item['title'] as String,
          item['subtitle'] as String,
        )).toList(),
        Divider(height: 1),
        _buildMenuItem(
          context,
          Icons.logout,
          'Logout',
          'Sign out of your account',
          isLogout: true,
          onTap: () => _showLogoutDialog(context, auth),
        ),
      ],
    ),
  );
}

 Widget _buildMenuItem(
  BuildContext context,
  IconData icon,
  String title,
  String subtitle, {
  bool isLogout = false,
  VoidCallback? onTap,
}) {
  return ListTile(
    leading: Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: (isLogout ? AppColors.error : AppColors.primary).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: isLogout ? AppColors.error : AppColors.primary,
        size: 20,
      ),
    ),
    title: Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: isLogout ? AppColors.error : AppColors.textPrimary,
      ),
    ),
    subtitle: Text(
      subtitle,
      style: TextStyle(
        fontSize: 12,
        color: AppColors.textSecondary,
      ),
    ),
    trailing: Icon(
      Icons.arrow_forward_ios,
      size: 16,
      color: AppColors.textSecondary,
    ),
    onTap: onTap ?? () {
      // Handle navigation to different screens
      if (title == 'My Orders') {
        DefaultTabController.of(context)?.animateTo(3);
      } else if (title == 'Send Feedback') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FeedbackScreen()),
        );
      } else if (title == 'Admin Portal') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AdminLoginScreen()),
        );
      }
      // Add other navigation logic here
    },
  );
}

  void _showLogoutDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await auth.signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}