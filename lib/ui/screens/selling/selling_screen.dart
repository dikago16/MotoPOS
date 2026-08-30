import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/app_localizations.dart';
import '../../../core/services/trial_service.dart';
import '../../../data/database_service.dart';
import '../activation/activation_screen.dart';

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
  bool _isTrial = false;
  int _itemCount = 0;
  int _remainingChats = 0;

  @override
  void initState() {
    super.initState();
    _checkTrialStatus();
  }

  Future<void> _checkTrialStatus() async {
    final isTrial = await TrialService.isTrialActive();
    if (!mounted) return;
    if (isTrial) {
      final db = context.read<DatabaseService>();
      final count = await db.getProductCount();
      final chats = await TrialService.getRemainingAiChats();
      if (mounted) {
        setState(() {
          _isTrial = isTrial;
          _itemCount = count;
          _remainingChats = chats;
        });
      }
    }
  }

  void _refreshProducts() {
    setState(() {
      _refreshCount++;
    });
    _checkTrialStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: SellingAppBar(onProductsChanged: _refreshProducts),
      body: SafeArea(
        child: Column(
          children: [
            if (_isTrial)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                color: AppColors.accent.withValues(alpha: 0.1),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        AppLocalizations.get('trial_mode'),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${AppLocalizations.get('trial_items_count')}: $_itemCount/3 · ${AppLocalizations.get('trial_ai_count')}: $_remainingChats/3',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.txtHigh,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ActivationScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.accent),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          AppLocalizations.get('trial_upgrade'),
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
