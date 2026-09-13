import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/advertiser_provider.dart';
import '../../common/custom_card.dart';

class ManageProductsScreen extends StatelessWidget {
  const ManageProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final advertiser = context.watch<AdvertiserProvider>();
    final products = advertiser.myProducts;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('3D Product Assets'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        itemCount: products.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final p = products[index];
          return CustomCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.view_in_ar_rounded, size: 32, color: AppColors.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.category.toUpperCase(), style: AppTypography.labelSmall.copyWith(color: AppColors.primary)),
                      const SizedBox(height: 2),
                      Text(p.name, style: AppTypography.headlineSmall),
                      const SizedBox(height: 2),
                      Text('GLB Asset: ${p.modelAssetPath.split('/').last}', style: AppTypography.bodySmall),
                    ],
                  ),
                ),
                Text(Formatters.formatCurrency(p.price), style: AppTypography.headlineSmall),
              ],
            ),
          );
        },
      ),
    );
  }
}
