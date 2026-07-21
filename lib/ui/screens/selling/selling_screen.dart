import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

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
  int _refreshCount = 0;

  void _refreshProducts() {
    setState(() {
      _refreshCount++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: SellingAppBar(onProductsChanged: _refreshProducts),
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
                    ProductFormCard(key: ValueKey(_refreshCount)),
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
