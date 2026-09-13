import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/campaign_provider.dart';
import '../../common/custom_card.dart';
import '../../common/empty_state.dart';

class SavedAdsScreen extends StatelessWidget {
  const SavedAdsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final campaignProvider = context.watch<CampaignProvider>();

    final savedIds = auth.currentUser?.savedAdIds ?? [];
    final savedCampaigns = campaignProvider.campaigns.where((c) => savedIds.contains(c.id)).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Saved AR Ads'),
        centerTitle: false,
      ),
      body: savedCampaigns.isEmpty
          ? EmptyState(
              icon: Icons.bookmark_border_rounded,
              title: 'No Saved Ads Yet',
              message: 'When you spot an AR advertisement you love, tap the bookmark icon to save it here for later.',
              actionLabel: 'Explore AR Ads',
              onAction: () => context.go('/home'),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 100),
              itemCount: savedCampaigns.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final c = savedCampaigns[index];
                final p = c.product;
                return CustomCard(
                  onTap: () {
                    context.read<CampaignProvider>().selectCampaign(c);
                    context.push('/product/${c.id}');
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.view_in_ar_rounded, color: AppColors.primary, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p?.brand ?? 'Brand', style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary)),
                            const SizedBox(height: 2),
                            Text(c.title, style: AppTypography.headlineSmall),
                            const SizedBox(height: 2),
                            Text('${c.offer?.discountPercentage.toInt() ?? 20}% OFF code available',
                                style: AppTypography.bodySmall.copyWith(color: AppColors.accentDark)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                        onPressed: () => auth.toggleSaveAd(c.id),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
