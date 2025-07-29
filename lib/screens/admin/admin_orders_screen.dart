// lib/screens/admin/admin_orders_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../models/order_model.dart';
import '../../utils/app_colors.dart';
import 'order_detail_admin_screen.dart';

class AdminOrdersScreen extends StatefulWidget {
  @override
  _AdminOrdersScreenState createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  String _selectedStatus = 'All';
  String _searchQuery = '';

  final List<String> _statusFilters = [
    'All',
    'Pending',
    'Confirmed',
    'Shipped',
    'Delivered',
    'Cancelled'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).loadAllOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Manage Orders'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              Provider.of<AdminProvider>(context, listen: false)
                  .loadAllOrders();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          _buildOrdersStats(),
          Expanded(child: _buildOrdersList()),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search orders by ID or customer name...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppColors.background,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _statusFilters
                  .map((status) => Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(status),
                          selected: _selectedStatus == status,
                          onSelected: (selected) {
                            setState(() {
                              _selectedStatus = status;
                            });
                          },
                          selectedColor: AppColors.primary.withOpacity(0.2),
                          checkmarkColor: AppColors.primary,
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersStats() {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        final orders = adminProvider.orders;
        final pendingCount =
            orders.where((o) => o.status == OrderStatus.pending).length;
        final confirmedCount =
            orders.where((o) => o.status == OrderStatus.confirmed).length;
        final shippedCount =
            orders.where((o) => o.status == OrderStatus.shipped).length;
        final deliveredCount =
            orders.where((o) => o.status == OrderStatus.delivered).length;

        return Container(
          padding: EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                  child: _buildStatCard(
                      'Pending', pendingCount, AppColors.warning)),
              Expanded(
                  child: _buildStatCard(
                      'Confirmed', confirmedCount, AppColors.primary)),
              Expanded(
                  child: _buildStatCard('Shipped', shippedCount, Colors.blue)),
              Expanded(
                  child: _buildStatCard(
                      'Delivered', deliveredCount, AppColors.success)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList() {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        if (adminProvider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        var filteredOrders = adminProvider.orders.where((order) {
          bool matchesSearch = _searchQuery.isEmpty ||
              order.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              order.deliveryAddress
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase());

          bool matchesStatus = _selectedStatus == 'All' ||
              order.status.toString().split('.').last.toLowerCase() ==
                  _selectedStatus.toLowerCase();

          return matchesSearch && matchesStatus;
        }).toList();

        if (filteredOrders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 64,
                  color: AppColors.textSecondary,
                ),
                SizedBox(height: 16),
                Text(
                  'No orders found',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  _searchQuery.isNotEmpty || _selectedStatus != 'All'
                      ? 'Try adjusting your filters'
                      : 'Orders will appear here when customers place them',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: filteredOrders.length,
          itemBuilder: (context, index) {
            final order = filteredOrders[index];
            return _buildOrderCard(order, adminProvider);
          },
        );
      },
    );
  }

  Widget _buildOrderCard(OrderModel order, AdminProvider adminProvider) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToOrderDetail(order),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.id.substring(0, 8)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  _buildStatusChip(order.status),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.attach_money,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'GH¢${order.totalAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 16),
                  Icon(
                    Icons.shopping_bag,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '${order.items.length} items',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      order.deliveryAddress,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 4),
                  Text(
                    _formatDate(order.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Spacer(),
                  if (order.status == OrderStatus.pending)
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => _updateOrderStatus(
                              order, OrderStatus.confirmed, adminProvider),
                          child:
                              Text('Confirm', style: TextStyle(fontSize: 12)),
                        ),
                        TextButton(
                          onPressed: () => _updateOrderStatus(
                              order, OrderStatus.cancelled, adminProvider),
                          child: Text('Cancel',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.error)),
                        ),
                      ],
                    ),
                  if (order.status == OrderStatus.confirmed)
                    TextButton(
                      onPressed: () => _updateOrderStatus(
                          order, OrderStatus.shipped, adminProvider),
                      child: Text('Ship', style: TextStyle(fontSize: 12)),
                    ),
                  if (order.status == OrderStatus.shipped)
                    TextButton(
                      onPressed: () => _updateOrderStatus(
                          order, OrderStatus.delivered, adminProvider),
                      child: Text('Deliver', style: TextStyle(fontSize: 12)),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    Color color;
    String text;

    switch (status) {
      case OrderStatus.pending:
        color = AppColors.warning;
        text = 'Pending';
        break;
      case OrderStatus.confirmed:
        color = AppColors.primary;
        text = 'Confirmed';
        break;
      case OrderStatus.shipped:
        color = Colors.blue;
        text = 'Shipped';
        break;
      case OrderStatus.delivered:
        color = AppColors.success;
        text = 'Delivered';
        break;
      case OrderStatus.cancelled:
        color = AppColors.error;
        text = 'Cancelled';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  void _navigateToOrderDetail(OrderModel order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailAdminScreen(order: order),
      ),
    );
  }

  Future<void> _updateOrderStatus(OrderModel order, OrderStatus newStatus, AdminProvider adminProvider) async {
  // Show loading dialog with notification info
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Updating order status...'),
          SizedBox(height: 8),
          Text(
            'Customer will be notified via push notification',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    ),
  );

  final success = await adminProvider.updateOrderStatus(order.id, newStatus);
  
  // Close loading dialog
  Navigator.pop(context);
  
  if (success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Order updated successfully! 🎉',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Customer has been notified',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 8),
            Text('Failed to update order status'),
          ],
        ),
        backgroundColor: AppColors.error,
      ),
    );
  }
}

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
