import 'package:agroconnect/screens/agriculture/agriculture_fields_screen.dart';
import 'package:agroconnect/widgets/task_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/weather_card.dart';
import '../../widgets/category_card.dart';
import '../../widgets/product_card.dart';
import '../../widgets/task_card.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onNavigateToProducts;

  const HomeScreen({Key? key, this.onNavigateToProducts}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Equipment',
      'icon': Icons.agriculture,
      'color': AppColors.secondary,
      'description': 'Farming tools & machinery'
    },
    {
      'name': 'Animal Feed',
      'icon': Icons.grass,
      'color': AppColors.accent,
      'description': 'Quality feed for livestock'
    },
    {
      'name': 'Poultry',
      'icon': Icons.egg,
      'color': AppColors.primary,
      'description': 'Poultry supplies & products'
    },
    {
      'name': 'Seeds',
      'icon': Icons.eco,
      'color': Colors.brown,
      'description': 'High-quality seeds'
    },
    {
      'name': 'Fertilizers',
      'icon': Icons.scatter_plot,
      'color': Colors.green[700]!,
      'description': 'Organic & chemical fertilizers'
    },
  ];

  final List<Map<String, dynamic>> _todayTasks = [
    {
      'time': '7:30 AM',
      'title': 'Watering of\nfields CD5',
      'status': 'On-Progress',
      'isActive': true,
    },
    {
      'time': '8:00 AM',
      'title': 'Planting of\nfields CD5',
      'status': 'Not-Started',
      'isActive': false,
    },
    {
      'time': '8:30 AM',
      'title': 'Harvesting\nfields CD3',
      'status': 'Pending',
      'isActive': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/field_background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.1),
                  Colors.white.withOpacity(0.9),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
          // Content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  _buildWeatherSection(),
                  _buildTasksSection(),
                  _buildCategoriesSection(),
                  _buildFeaturedProductsSection(),
                  _buildAgricultureFieldSection(),
                  SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Yogyakarta, Indonesia',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary,
                child: Text(
                  auth.user?.name.substring(0, 1).toUpperCase() ?? 'U',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeatherSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Consumer<AuthProvider>(
            builder: (context, auth, child) {
              return Text(
                'Welcome to Farmer Friends, ${auth.user?.name.split(' ').first ?? 'Farmer'}!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              );
            },
          ),
          SizedBox(height: 4),
          Text(
            'Your trusted partner in agriculture',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          SizedBox(height: 8),
          WeatherCard(),
        ],
      ),
    );
  }

  Widget _buildTasksSection() {
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Today's Tasks",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 12),
          Container(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: _todayTasks.length,
              itemBuilder: (context, index) {
                final task = _todayTasks[index];
                return Container(
                  width: 140,
                  margin: EdgeInsets.only(right: 12),
                  child: TaskCard(
                    time: task['time'],
                    title: task['title'],
                    status: task['status'],
                    isActive: task['isActive'],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Container(
      margin: EdgeInsets.only(top: 30),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shop by Category',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              return CategoryCard(
                name: category['name'],
                icon: category['icon'],
                color: category['color'],
                onTap: () {
                  // Navigate to products with category filter
                  Provider.of<ProductProvider>(context, listen: false)
                      .filterByCategory(category['name']);
                  widget.onNavigateToProducts?.call();
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedProductsSection() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        if (productProvider.isLoading) {
          return Container(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final featuredProducts = productProvider.products.take(5).toList();

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Featured Products',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      widget.onNavigateToProducts?.call();
                    },
                    child: Text('View All'),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Container(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: featuredProducts.length,
                  itemBuilder: (context, index) {
                    final product = featuredProducts[index];
                    return Container(
                      width: 160,
                      margin: EdgeInsets.only(right: 12),
                      child: ProductCard(product: product),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAgricultureFieldSection() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Our Agriculture Fields',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AgricultureFieldScreen(),
                    ),
                  );
                },
                child: Text('View All'),
              ),
            ],
          ),
          SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AgricultureFieldScreen(),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 80,
                        height: 80,
                        color: AppColors.primaryLight.withOpacity(0.3),
                        child: Icon(
                          Icons.agriculture,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rice Field Premium Plot R8',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '7°47\'44.1"S, 110°22\'10.2"E',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Towards Harvest',
                              style: TextStyle(
                                color: AppColors.success,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.landscape,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '6.2 ha',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              SizedBox(width: 16),
                              Icon(
                                Icons.assignment,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '12 Activity',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
