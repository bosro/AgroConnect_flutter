// lib/widgets/lazy_product_grid.dart
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../widgets/product_card.dart';

class LazyProductGrid extends StatefulWidget {
  final List<ProductModel> products;
  final Function()? onLoadMore;
  final bool hasMore;
  final bool isLoading;

  const LazyProductGrid({
    Key? key,
    required this.products,
    this.onLoadMore,
    this.hasMore = false,
    this.isLoading = false,
  }) : super(key: key);

  @override
  _LazyProductGridState createState() => _LazyProductGridState();
}

class _LazyProductGridState extends State<LazyProductGrid> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      if (widget.hasMore && !widget.isLoading && widget.onLoadMore != null) {
        widget.onLoadMore!();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: widget.products.length + (widget.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= widget.products.length) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        return ProductCard(
          product: widget.products[index],
          key: Key(widget.products[index].id),
        );
      },
    );
  }
}