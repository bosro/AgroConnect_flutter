// lib/screens/search/search_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/search_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/product_card.dart';
import '../../widgets/custom_text_field.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  List<String> _suggestions = [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onSearchChanged() async {
    final query = _searchController.text;
    
    if (query.length >= 2) {
      final searchProvider = Provider.of<SearchProvider>(context, listen: false);
      final suggestions = await searchProvider.getSearchSuggestions(query);
      setState(() {
        _suggestions = suggestions;
        _showSuggestions = true;
      });
    } else {
      setState(() {
        _showSuggestions = false;
      });
    }
  }

  void _performSearch(String query) {
    Provider.of<SearchProvider>(context, listen: false).searchProducts(query);
    setState(() {
      _showSuggestions = false;
    });
    _searchFocus.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Search Products'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          if (_showSuggestions) _buildSuggestions(),
          _buildActiveFilters(),
          Expanded(child: _buildSearchResults()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: CustomTextField(
        controller: _searchController,
        focusNode: _searchFocus,
        label: 'Search products...',
        prefixIcon: Icons.search,
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  Provider.of<SearchProvider>(context, listen: false)
                      .searchProducts('');
                },
              )
            : null,
        onSubmitted: _performSearch,
      ),
    );
  }

  Widget _buildSuggestions() {
    return Container(
      color: Colors.white,
      child: Column(
        children: _suggestions.map((suggestion) => ListTile(
          leading: Icon(Icons.search, color: AppColors.textSecondary),
          title: Text(suggestion),
          onTap: () {
            _searchController.text = suggestion;
            _performSearch(suggestion);
          },
        )).toList(),
      ),
    );
  }

  Widget _buildActiveFilters() {
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, child) {
        final filters = searchProvider.filters;
        List<Widget> activeFilters = [];

        if (filters['category'] != null) {
          activeFilters.add(_buildFilterChip(
            'Category: ${filters['category']}',
            () => searchProvider.updateFilter('category', null),
          ));
        }

        if (filters['isOrganic'] != null) {
          activeFilters.add(_buildFilterChip(
            'Organic Only',
            () => searchProvider.updateFilter('isOrganic', null),
          ));
        }

        if (filters['minPrice'] != null || filters['maxPrice'] != null) {
          String priceText = 'Price: ';
          if (filters['minPrice'] != null) priceText += 'GH₵${filters['minPrice']}';
          if (filters['minPrice'] != null && filters['maxPrice'] != null) priceText += ' - ';
          if (filters['maxPrice'] != null) priceText += 'GH₵${filters['maxPrice']}';
          
          activeFilters.add(_buildFilterChip(
            priceText,
            () {
              searchProvider.updateFilter('minPrice', null);
              searchProvider.updateFilter('maxPrice', null);
            },
          ));
        }

        if (activeFilters.isEmpty) return SizedBox.shrink();

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Active Filters:',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  TextButton(
                    onPressed: () => searchProvider.clearFilters(),
                    child: Text('Clear All'),
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                children: activeFilters,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Chip(
      label: Text(label),
      deleteIcon: Icon(Icons.close, size: 16),
      onDeleted: onRemove,
      backgroundColor: AppColors.primary.withOpacity(0.1),
      deleteIconColor: AppColors.primary,
    );
  }

  Widget _buildSearchResults() {
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, child) {
        if (searchProvider.isSearching) {
          return Center(child: CircularProgressIndicator());
        }

        if (searchProvider.searchResults.isEmpty && searchProvider.currentQuery.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
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
                SizedBox(height: 8),
                Text(
                  'Try adjusting your search or filters',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        if (searchProvider.searchResults.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search,
                  size: 64,
                  color: AppColors.textSecondary,
                ),
                SizedBox(height: 16),
                Text(
                  'Search for products',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Find equipment, feed, and poultry supplies',
                  style: TextStyle(
                    fontSize: 14,
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
          itemCount: searchProvider.searchResults.length,
          itemBuilder: (context, index) {
            final product = searchProvider.searchResults[index];
            return ProductCard(product: product);
          },
        );
      },
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildFilterSheet(),
    );
  }

  Widget _buildFilterSheet() {
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, child) {
        return Container(
          padding: EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Products',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCategoryFilter(searchProvider),
                      SizedBox(height: 20),
                      _buildPriceFilter(searchProvider),
                      SizedBox(height: 20),
                      _buildOrganicFilter(searchProvider),
                      SizedBox(height: 20),
                      _buildStockFilter(searchProvider),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        searchProvider.clearFilters();
                        Navigator.pop(context);
                      },
                      child: Text('Clear All'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryFilter(SearchProvider searchProvider) {
    final categories = ['Equipment', 'Animal Feed', 'Poultry', 'Seeds', 'Fertilizers'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: categories.map((category) => FilterChip(
            label: Text(category),
            selected: searchProvider.filters['category'] == category,
            onSelected: (selected) {
              searchProvider.updateFilter('category', selected ? category : null);
            },
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildPriceFilter(SearchProvider searchProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Range',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Min Price',
                  prefixText: 'GH₵',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  double? price = double.tryParse(value);
                  searchProvider.updateFilter('minPrice', price);
                },
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Max Price',
                  prefixText: 'GH₵',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  double? price = double.tryParse(value);
                  searchProvider.updateFilter('maxPrice', price);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrganicFilter(SearchProvider searchProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        CheckboxListTile(
          title: Text('Organic Products Only'),
          value: searchProvider.filters['isOrganic'] == true,
          onChanged: (value) {
            searchProvider.updateFilter('isOrganic', value == true ? true : null);
          },
        ),
      ],
    );
  }

  Widget _buildStockFilter(SearchProvider searchProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Availability',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        CheckboxListTile(
          title: Text('In Stock Only'),
          value: searchProvider.filters['inStock'] == true,
          onChanged: (value) {
            searchProvider.updateFilter('inStock', value == true ? true : false);
          },
        ),
      ],
    );
  }
}