import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/campaign_provider.dart';
import '../../common/custom_card.dart';
import '../../common/pastel_chip.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final campaignProvider = context.watch<CampaignProvider>();
    final campaigns = campaignProvider.filteredCampaigns;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Explore AR Ads'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Search & Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, color: AppColors.textTertiary, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      onChanged: (val) => campaignProvider.setSearchQuery(val),
                      decoration: const InputDecoration(
                        hintText: 'Search 3D experiences...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Categories Horizontal
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              itemCount: AppConstants.categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final cat = AppConstants.categories[i];
                return PastelChip(
                  label: cat,
                  isSelected: campaignProvider.selectedCategory == cat,
                  onTap: () => campaignProvider.selectCategory(cat),
                );
              },
            ),
          ),

          const SizedBox(height: 14),

          // Grid of Campaigns
          Expanded(
            child: campaigns.isEmpty
                ? const Center(child: Text('No campaigns found matching your criteria.'))
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 100),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.74,
                    ),
                    itemCount: campaigns.length,
                    itemBuilder: (context, index) {
                      final c = campaigns[index];
                      final p = c.product;
                      return CustomCard(
                        borderRadius: 20,
                        showShadow: true,
                        onTap: () {
                          context.read<CampaignProvider>().selectCampaign(c);
                          context.push('/product/${c.id}');
                        },
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    p?.category ?? 'Ad',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.primary,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.view_in_ar_rounded, size: 16, color: AppColors.primary),
                              ],
                            ),
                            const Spacer(),
                            Center(
                              child: Icon(
                                Icons.auto_awesome_motion_rounded,
                                size: 44,
                                color: AppColors.primary.withValues(alpha: 0.7),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              p?.brand ?? 'Brand',
                              style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              c.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.labelLarge,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  Formatters.formatCurrency(p?.price ?? 0.0),
                                  style: AppTypography.headlineSmall.copyWith(color: AppColors.textPrimary, fontSize: 15),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    context.read<CampaignProvider>().selectCampaign(c);
                                    context.push('/ar-view/${c.id}');
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 16),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
