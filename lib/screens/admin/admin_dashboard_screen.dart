// lib/screens/admin/admin_dashboard_screen.dart
import 'package:agroconnect/models/order_model.dart';
import 'package:agroconnect/models/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';
import 'admin_products_screen.dart';
import 'admin_orders_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      adminProvider.loadAllProducts();
      adminProvider.loadAllOrders();
      adminProvider.loadAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Farmer Friends Admin'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              final adminProvider =
                  Provider.of<AdminProvider>(context, listen: false);
              adminProvider.loadAllProducts();
              adminProvider.loadAllOrders();
              adminProvider.loadAnalytics();
            },
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          if (adminProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeCard(adminProvider),
                SizedBox(height: 16),
                _buildAnalyticsCards(adminProvider),
                SizedBox(height: 16),
                _buildNotificationPanel(), // 🆕 Add this
                SizedBox(height: 16),
                _buildQuickActions(),
                SizedBox(height: 16),
                _buildRecentOrders(adminProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeCard(AdminProvider adminProvider) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, ${adminProvider.admin?.name ?? 'Admin'}!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Manage your Farmer Friends store',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.admin_panel_settings,
            color: Colors.white,
            size: 40,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCards(AdminProvider adminProvider) {
    final analytics = adminProvider.analytics;

    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _buildAnalyticsCard(
          'Total Revenue',
          'GH¢${(analytics['totalRevenue'] ?? 0).toStringAsFixed(2)}',
          Icons.attach_money,
          AppColors.success,
        ),
        _buildAnalyticsCard(
          'Total Orders',
          '${analytics['totalOrders'] ?? 0}',
          Icons.shopping_bag,
          AppColors.primary,
        ),
        _buildAnalyticsCard(
          'Pending Orders',
          '${analytics['pendingOrders'] ?? 0}',
          Icons.pending,
          AppColors.warning,
        ),
        _buildAnalyticsCard(
          'Total Products',
          '${analytics['totalProducts'] ?? 0}',
          Icons.inventory,
          AppColors.secondary,
        ),
      ],
    );
  }

  Widget _buildAnalyticsCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Manage Products',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminProductsScreen(),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: 'View Orders',
                  color: AppColors.secondary,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminOrdersScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrders(AdminProvider adminProvider) {
    final recentOrders = adminProvider.orders.take(5).toList();

    return Container(
      padding: EdgeInsets.all(20),
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
              Text(
                'Recent Orders',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminOrdersScreen(),
                    ),
                  );
                },
                child: Text('View All'),
              ),
            ],
          ),
          SizedBox(height: 12),
          ...recentOrders
              .map((order) => Container(
                    margin: EdgeInsets.only(bottom: 8),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order #${order.id.substring(0, 8)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'GH¢${order.totalAmount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color:
                                _getStatusColor(order.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            order.status
                                .toString()
                                .split('.')
                                .last
                                .toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _getStatusColor(order.status),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
          if (recentOrders.isEmpty)
            Center(
              child: Text(
                'No recent orders',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
        ],
      ),
    );
  }

  void _showPromotionDialog() {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    String selectedCategory = 'All';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.campaign, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Send Promotion'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title *',
                  hintText: 'e.g., Special Weekend Offer!',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: messageController,
                decoration: InputDecoration(
                  labelText: 'Message *',
                  hintText: 'e.g., Get 20% off on all seeds this weekend!',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Target Audience',
                  border: OutlineInputBorder(),
                ),
                items: [
                  'All',
                  'Equipment',
                  'Seeds',
                  'Fertilizers',
                  'Animal Feed'
                ]
                    .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (value) => setState(() => selectedCategory = value!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: titleController.text.isNotEmpty &&
                      messageController.text.isNotEmpty
                  ? () async {
                      Navigator.pop(context);

                      // Show sending dialog
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => AlertDialog(
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Sending promotion to users...'),
                            ],
                          ),
                        ),
                      );

                      final adminProvider =
                          Provider.of<AdminProvider>(context, listen: false);
                      int sentCount =
                          await adminProvider.sendPromotionalNotification(
                        title: titleController.text,
                        message: messageController.text,
                        category:
                            selectedCategory == 'All' ? null : selectedCategory,
                      );

                      Navigator.pop(context); // Close loading dialog

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('🎉 Promotion sent to $sentCount users!'),
                          backgroundColor: AppColors.success,
                          duration: Duration(seconds: 4),
                        ),
                      );
                    }
                  : null,
              child: Text('Send'),
            ),
          ],
        ),
      ),
    );
  }

// Add this method too
  void _showProductAnnouncementDialog() {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);

    if (adminProvider.products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No products available to announce'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    ProductModel? selectedProduct;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.new_releases, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Announce New Product'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<ProductModel>(
                value: selectedProduct,
                decoration: InputDecoration(
                  labelText: 'Select Product',
                  border: OutlineInputBorder(),
                ),
                items: adminProvider.products
                    .map((product) => DropdownMenuItem(
                          value: product,
                          child: Text(product.name),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => selectedProduct = value),
              ),
              if (selectedProduct != null) ...[
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Preview:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'New ${selectedProduct!.category} Available! 🌾',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Check out ${selectedProduct!.name} now available in your area',
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedProduct != null
                  ? () async {
                      Navigator.pop(context);

                      bool success = await adminProvider
                          .announceNewProduct(selectedProduct!);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success
                              ? '📢 Product announcement sent!'
                              : 'Failed to send announcement'),
                          backgroundColor:
                              success ? AppColors.success : AppColors.error,
                        ),
                      );
                    }
                  : null,
              child: Text('Announce'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationPanel() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notifications_active, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Send Notifications',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Product Alert 📢',
                  onPressed: () => _showProductAnnouncementDialog(),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: 'Promotion 🎯',
                  color: AppColors.secondary,
                  onPressed: () => _showPromotionDialog(),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showNotificationHistory(),
                  icon: Icon(Icons.history, size: 16),
                  label: Text('History'),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showCustomNotificationDialog(),
                  icon: Icon(Icons.person_add, size: 16),
                  label: Text('Custom'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showNotificationHistory() async {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.7,
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notification History',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: Provider.of<AdminProvider>(context, listen: false)
                      .getNotificationHistory(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_off,
                              size: 64,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No notifications sent yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final notification = snapshot.data![index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getNotificationTypeColor(
                                  notification['type']),
                              child: Icon(
                                _getNotificationTypeIcon(notification['type']),
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              notification['title'] ?? 'No title',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(notification['message'] ?? 'No message'),
                                SizedBox(height: 4),
                                Text(
                                  _formatTimestamp(notification['sentAt']),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getNotificationTypeColor(
                                        notification['type'])
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                notification['type']
                                        ?.toString()
                                        .toUpperCase() ??
                                    'UNKNOWN',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: _getNotificationTypeColor(
                                      notification['type']),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCustomNotificationDialog() {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    final userIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.person_pin, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Send Custom Notification'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: userIdController,
                decoration: InputDecoration(
                  labelText: 'User ID *',
                  hintText: 'Enter customer user ID',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title *',
                  hintText: 'e.g., Personal Message',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: messageController,
                decoration: InputDecoration(
                  labelText: 'Message *',
                  hintText: 'Enter your custom message',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.message),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: AppColors.warning, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This will send a direct notification to the specified user.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (userIdController.text.isEmpty ||
                  titleController.text.isEmpty ||
                  messageController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please fill all required fields'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              Navigator.pop(context);

              // Show sending dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Sending custom notification...'),
                    ],
                  ),
                ),
              );

              final adminProvider =
                  Provider.of<AdminProvider>(context, listen: false);
              bool success = await adminProvider.sendCustomNotification(
                userId: userIdController.text.trim(),
                title: titleController.text,
                message: messageController.text,
                data: {
                  'type': 'custom',
                  'screen': 'home',
                },
              );

              Navigator.pop(context); // Close loading dialog

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success
                      ? '✅ Custom notification sent!'
                      : '❌ Failed to send notification'),
                  backgroundColor:
                      success ? AppColors.success : AppColors.error,
                ),
              );
            },
            child: Text('Send'),
          ),
        ],
      ),
    );
  }

// Helper methods for notification history
  Color _getNotificationTypeColor(String? type) {
    switch (type) {
      case 'order_update':
        return AppColors.primary;
      case 'new_product':
        return AppColors.success;
      case 'promotion':
        return AppColors.secondary;
      case 'custom':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getNotificationTypeIcon(String? type) {
    switch (type) {
      case 'order_update':
        return Icons.shopping_bag;
      case 'new_product':
        return Icons.new_releases;
      case 'promotion':
        return Icons.campaign;
      case 'custom':
        return Icons.person_pin;
      default:
        return Icons.notifications;
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';

    DateTime date;
    if (timestamp is Timestamp) {
      date = timestamp.toDate();
    } else if (timestamp is DateTime) {
      date = timestamp;
    } else {
      return 'Unknown';
    }

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.confirmed:
        return AppColors.primary;
      case OrderStatus.shipped:
        return Colors.blue;
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }
}
