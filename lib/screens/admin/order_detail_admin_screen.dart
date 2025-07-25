// lib/screens/admin/order_detail_admin_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../providers/admin_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';

class OrderDetailAdminScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailAdminScreen({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Order #${order.id.substring(0, 8)}'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value, context),
            itemBuilder: (context) => [
              PopupMenuItem(value: 'print', child: Text('Print Order')),
              PopupMenuItem(value: 'export', child: Text('Export PDF')),
              PopupMenuItem(value: 'contact', child: Text('Contact Customer')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderHeader(),
            SizedBox(height: 16),
            _buildCustomerInfo(),
            SizedBox(height: 16),
            _buildOrderItems(),
            SizedBox(height: 16),
            _buildDeliveryInfo(),
            SizedBox(height: 16),
            _buildPaymentInfo(),
            SizedBox(height: 16),
            _buildOrderSummary(),
            SizedBox(height: 16),
            _buildStatusHistory(),
            SizedBox(height: 20),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order #${order.id.substring(0, 8)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Placed on ${_formatDate(order.createdAt)}',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          _buildStatusChip(order.status),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo() {
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
            'Customer Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: AppColors.primary,
                child: Text(
                  'C', // You can get actual customer name from user ID
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customer ID: ${order.userId.substring(0, 8)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Total Orders: -', // You can add customer stats
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  // View customer details
                },
                child: Text('View Profile'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItems() {
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
            'Order Items (${order.items.length})',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16),
          ...order.items.map((item) => Container(
            margin: EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: item.productImage.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item.productImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.image,
                                color: AppColors.textSecondary,
                              );
                            },
                          ),
                        )
                      : Icon(
                          Icons.image,
                          color: AppColors.textSecondary,
                        ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'GH₵${item.price.toStringAsFixed(2)}/${item.unit}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Qty: ${item.quantity} ${item.unit}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'GH₵${item.totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfo() {
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
            'Delivery Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on,
                color: AppColors.primary,
                size: 20,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery Address',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      order.deliveryAddress,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  // Open in maps
                },
                child: Text('View Map'),
              ),
            ],
          ),
          if (order.deliveryDate != null) ...[
            SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: AppColors.primary,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Expected Delivery: ${_formatDate(order.deliveryDate!)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentInfo() {
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
            'Payment Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(
                _getPaymentIcon(),
                color: AppColors.primary,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                order.paymentMethod,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Paid', // You can track payment status
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    final subtotal = order.totalAmount - 5.0; // Subtract delivery fee
    final deliveryFee = 5.0;

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
            'Order Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal'),
              Text('GH₵${subtotal.toStringAsFixed(2)}'),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Delivery Fee'),
              Text('GH₵${deliveryFee.toStringAsFixed(2)}'),
            ],
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'GH₵${order.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusHistory() {
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
            'Order Timeline',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16),
          _buildTimelineItem(
            'Order Placed',
            _formatDate(order.createdAt),
            true,
            Icons.shopping_cart,
          ),
          if (order.status.index >= OrderStatus.confirmed.index)
            _buildTimelineItem(
              'Order Confirmed',
              _formatDate(order.createdAt.add(Duration(hours: 1))), // Mock time
              true,
              Icons.check_circle,
            ),
          if (order.status.index >= OrderStatus.shipped.index)
            _buildTimelineItem(
              'Order Shipped',
              _formatDate(order.createdAt.add(Duration(days: 1))), // Mock time
              true,
              Icons.local_shipping,
            ),
          if (order.status.index >= OrderStatus.delivered.index)
            _buildTimelineItem(
              'Order Delivered',
              _formatDate(order.createdAt.add(Duration(days: 2))), // Mock time
              true,
              Icons.home,
            ),
          if (order.status == OrderStatus.cancelled)
            _buildTimelineItem(
              'Order Cancelled',
              _formatDate(DateTime.now()), // Mock time
              true,
              Icons.cancel,
              isError: true,
            ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, String time, bool isCompleted, IconData icon, {bool isError = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isError ? AppColors.error : (isCompleted ? AppColors.success : AppColors.textSecondary),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 16,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        return Column(
          children: [
            if (order.status == OrderStatus.pending) ...[
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Confirm Order',
                      onPressed: () => _updateOrderStatus(context, OrderStatus.confirmed, adminProvider),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Cancel Order',
                      color: AppColors.error,
                      onPressed: () => _updateOrderStatus(context, OrderStatus.cancelled, adminProvider),
                    ),
                  ),
                ],
              ),
            ],
            if (order.status == OrderStatus.confirmed) ...[
              CustomButton(
                text: 'Mark as Shipped',
                onPressed: () => _updateOrderStatus(context, OrderStatus.shipped, adminProvider),
              ),
            ],
            if (order.status == OrderStatus.shipped) ...[
              CustomButton(
                text: 'Mark as Delivered',
                onPressed: () => _updateOrderStatus(context, OrderStatus.delivered, adminProvider),
              ),
            ],
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Print order
                    },
                    icon: Icon(Icons.print),
                    label: Text('Print'),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Contact customer
                    },
                    icon: Icon(Icons.phone),
                    label: Text('Contact'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
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
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  IconData _getPaymentIcon() {
    switch (order.paymentMethod.toLowerCase()) {
      case 'credit card':
        return Icons.credit_card;
      case 'mobile money':
        return Icons.phone_android;
      case 'bank transfer':
        return Icons.account_balance;
      default:
        return Icons.money;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _handleMenuAction(String action, BuildContext context) {
    switch (action) {
      case 'print':
        // Implement print functionality
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Print functionality not implemented yet')),
        );
        break;
      case 'export':
        // Implement export to PDF
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export functionality not implemented yet')),
        );
        break;
      case 'contact':
        // Implement contact customer
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Contact functionality not implemented yet')),
        );
        break;
    }
  }

  Future<void> _updateOrderStatus(BuildContext context, OrderStatus newStatus, AdminProvider adminProvider) async {
    final success = await adminProvider.updateOrderStatus(order.id, newStatus);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order status updated to ${newStatus.toString().split('.').last}'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context); // Go back to orders list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update order status'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}