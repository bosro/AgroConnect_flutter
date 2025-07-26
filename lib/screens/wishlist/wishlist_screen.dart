import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/product_card.dart';
import '../../widgets/custom_button.dart';

class WishlistScreen extends StatefulWidget {
  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.user != null) {
        Provider.of<WishlistProvider>(context, listen: false)
            .loadWishlist(auth.user!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('My Wishlist'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer2<WishlistProvider, AuthProvider>(
        builder: (context, wishlist, auth, child) {
          if (auth.user == null) {
            return Center(
              child: Text('Please login to view wishlist'),
            );
          }

          if (wishlist.wishlistItems.isEmpty) {
            return _buildEmptyWishlist();
          }

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${wishlist.itemCount} items in wishlist',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => _showClearWishlistDialog(wishlist),
                      child: Text('Clear All'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: wishlist.wishlistItems.length,
                  itemBuilder: (context, index) {
                    final product = wishlist.wishlistItems[index];
                    return ProductCard(product: product);
                  },
                ),
              ),
              if (wishlist.wishlistItems.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(16),
                  child: CustomButton(
                    text: 'Add All to Cart',
                    onPressed: () => _addAllToCart(wishlist),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyWishlist() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 100,
            color: Colors.grey[400],
          ),
          SizedBox(height: 20),
          Text(
            'Your wishlist is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Add products you love to see them here',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 24),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: CustomButton(
              text: 'Start Shopping',
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _addAllToCart(WishlistProvider wishlist) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    
    for (final product in wishlist.wishlistItems) {
      cart.addToCart(product, 1);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added all items to cart'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showClearWishlistDialog(WishlistProvider wishlist) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear Wishlist'),
        content: Text('Are you sure you want to remove all items from your wishlist?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              wishlist.clearWishlist();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Wishlist cleared'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text('Clear'),
          ),
        ],
      ),
    );
  }
}