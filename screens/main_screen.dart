import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../utils/app_colors.dart';
import 'home/home_screen.dart';
import 'products/products_screen.dart';
import 'cart/cart_screen.dart';
import 'orders/orders_screen.dart';
import 'profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  final List<Widget> _screens = [
    HomeScreen(),
    ProductsScreen(),
    CartScreen(),
    OrdersScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).loadProducts();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: _screens,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
              _pageController.animateToPage(
                index,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary,
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.home_outlined, Icons.home, 0),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.storefront_outlined, Icons.storefront, 1),
                label: 'Products',
              ),
              BottomNavigationBarItem(
                icon: Consumer<CartProvider>(
                  builder: (context, cart, child) {
                    return badges.Badge(
                      badgeContent: Text(
                        cart.itemCount.toString(),
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      showBadge: cart.itemCount > 0,
                      child: _buildNavIcon(
                        Icons.shopping_cart_outlined,
                        Icons.shopping_cart,
                        2,
                      ),
                    );
                  },
                ),
                label: 'Cart',
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(
                  Icons.receipt_long_outlined,
                  Icons.receipt_long,
                  3,
                ),
                label: 'Orders',
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(
                  Icons.person_outline,
                  Icons.person,
                  4,
                ),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData outlined, IconData filled, int index) {
    bool isSelected = _currentIndex == index;
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        isSelected ? filled : outlined,
        size: 24,
      ),
    );
  }
}