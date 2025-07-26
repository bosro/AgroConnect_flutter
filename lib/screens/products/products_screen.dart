import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/product_card.dart';

class ProductsScreen extends StatefulWidget {
  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Products'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          _buildCategoryTabs(),
          Expanded(child: _buildProductGrid()),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.background,
              ),
              onChanged: (value) {
                Provider.of<ProductProvider>(context, listen: false)
                    .searchProducts(value);
              },
            ),
          ),
          SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.tune, color: Colors.white),
              onPressed: () => _showFilterDialog(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        return Container(
          height: 50,
          color: Colors.white,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: productProvider.categories.length,
            itemBuilder: (context, index) {
              final category = productProvider.categories[index];
              final isSelected = productProvider.selectedCategory == category;
              
              return GestureDetector(
                onTap: () {
                  productProvider.filterByCategory(category);
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.divider,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildProductGrid() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        if (productProvider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (productProvider.products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 64,
                  color: AppColors.textSecondary,
                ),
                SizedBox(height: 16),
                Text(
                  'No products found',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: productProvider.products.length,
          itemBuilder: (context, index) {
            final product = productProvider.products[index];
            return ProductCard(product: product);
          },
        );
      },
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => FilterDialog(),
    );
  }
}

// Filter Dialog Widget
class FilterDialog extends StatefulWidget {
  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  RangeValues _priceRange = RangeValues(0, 100);
  bool _organicOnly = false;
  bool _inStockOnly = true;
  String _sortBy = 'name';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Filter Products'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Price Range',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            RangeSlider(
              values: _priceRange,
              min: 0,
              max: 200,
              divisions: 20,
              labels: RangeLabels(
                'GH¢${_priceRange.start.round()}',
                'GH¢${_priceRange.end.round()}',
              ),
              onChanged: (values) {
                setState(() {
                  _priceRange = values;
                });
              },
            ),
            Text(
              'GH¢${_priceRange.start.round()} - GH¢${_priceRange.end.round()}',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 16),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Organic Only'),
              value: _organicOnly,
              onChanged: (value) {
                setState(() {
                  _organicOnly = value ?? false;
                });
              },
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('In Stock Only'),
              value: _inStockOnly,
              onChanged: (value) {
                setState(() {
                  _inStockOnly = value ?? true;
                });
              },
            ),
            SizedBox(height: 16),
            Text(
              'Sort By',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _sortBy,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: [
                DropdownMenuItem(value: 'name', child: Text('Name A-Z')),
                DropdownMenuItem(value: 'price_low', child: Text('Price: Low to High')),
                DropdownMenuItem(value: 'price_high', child: Text('Price: High to Low')),
                DropdownMenuItem(value: 'rating', child: Text('Highest Rated')),
                DropdownMenuItem(value: 'newest', child: Text('Newest First')),
              ],
              onChanged: (value) {
                setState(() {
                  _sortBy = value ?? 'name';
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _priceRange = RangeValues(0, 100);
              _organicOnly = false;
              _inStockOnly = true;
              _sortBy = 'name';
            });
            final productProvider = Provider.of<ProductProvider>(context, listen: false);
            productProvider.clearFilters();
          },
          child: Text('Reset'),
        ),
        ElevatedButton(
          onPressed: () {
            final productProvider = Provider.of<ProductProvider>(context, listen: false);
            productProvider.applyFilters(
              minPrice: _priceRange.start,
              maxPrice: _priceRange.end,
              organicOnly: _organicOnly,
              inStockOnly: _inStockOnly,
              sortBy: _sortBy,
            );
            Navigator.pop(context);
          },
          child: Text('Apply'),
        ),
      ],
    );
  }
}