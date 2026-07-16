import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/database_service.dart';
import '../../../data/models/product_model.dart';

// New Widget Imports
import 'widgets/selling_app_bar.dart';
import 'widgets/customer_selector.dart';
import 'widgets/product_form_card.dart';
import 'widgets/cart_items_table.dart';
import 'widgets/selling_bottom_bar.dart';

class SellingScreen extends StatefulWidget {
  const SellingScreen({super.key});

  @override
  State<SellingScreen> createState() => _SellingScreenState();
}

class _SellingScreenState extends State<SellingScreen> {
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);
    final products = await context.read<DatabaseService>().getProducts();
    if (mounted) {
      setState(() {
        _products = products;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.bgPage,
        appBar: SellingAppBar(onProductsChanged: () {}),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: SellingAppBar(
        onProductsChanged: _fetchProducts,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomerSelector(),
                    const SizedBox(height: 10),
                    ProductFormCard(products: _products),
                    const SizedBox(height: 10),
                    const CartItemsTable(),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            const SellingBottomBar(),
          ],
        ),
      ),
    );
  }
}
