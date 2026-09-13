import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/campaign_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/campaign_provider.dart';
import '../../common/custom_button.dart';
import '../../common/custom_card.dart';
import '../../common/pastel_chip.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final campaignProvider = context.watch<CampaignProvider>();
    final auth = context.watch<AuthProvider>();

    final user = auth.currentUser;
    final campaigns = campaignProvider.filteredCampaigns;
    final trending = campaignProvider.trendingCampaigns;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => campaignProvider.loadCampaigns(forceRefresh: true),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row (Greeting + Notification + Role Badge)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, ${user?.displayName ?? "Alex"} ✨',
                          style: AppTypography.headlineLarge,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Discover immersive AR campaigns near you',
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // Quick Advertiser Switcher Pill
                        GestureDetector(
                          onTap: () {
                            auth.switchRole('advertiser');
                            context.go('/advertiser');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.accentLight,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.accent),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.storefront_rounded, size: 14, color: AppColors.accentDark),
                                const SizedBox(width: 4),
                                Text(
                                  'Brand View',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.accentDark,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.notifications_none_rounded, size: 20),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('No new notifications')),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Search Bar
                Container(
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
                            hintText: 'Search products, brands, or 3D ads...',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const Icon(Icons.mic_none_rounded, color: AppColors.primary, size: 20),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Hero Banner (Stitch Screen 1)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEBF2FD), Color(0xFFF7F9FE)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'INTERACTIVE AR',
                                style: AppTypography.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontSize: 9,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Experience Ads in Real 3D Space',
                              style: AppTypography.headlineMedium.copyWith(height: 1.2),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Point your camera at QR tags on posters & packaging.',
                              style: AppTypography.bodySmall,
                            ),
                            const SizedBox(height: 14),
                            CustomButton(
                              text: 'Scan AR Ad Now',
                              icon: Icons.qr_code_scanner_rounded,
                              isFullWidth: false,
                              height: 42,
                              onPressed: () => context.push('/scanner'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            )
                          ],
                        ),
                        child: const Icon(
                          Icons.view_in_ar_rounded,
                          size: 44,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // Category Filter Chips
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
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

                const SizedBox(height: 22),

                // Section: Featured AR Experiences
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Featured AR Ads', style: AppTypography.headlineMedium),
                    Text(
                      '${campaigns.length} campaigns',
                      style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Horizontal Carousel of Featured Cards
                SizedBox(
                  height: 250,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: campaigns.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 14),
                    itemBuilder: (context, i) {
                      final c = campaigns[i];
                      return _buildFeaturedAdCard(context, c);
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Section: Trending Offers
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Exclusive AR Offers', style: AppTypography.headlineMedium),
                    Text(
                      'Limited time',
                      style: AppTypography.labelSmall.copyWith(color: AppColors.accentDark),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Offers Column
                ...trending.take(3).map((c) => _buildOfferCard(context, c)),

                const SizedBox(height: 80), // Padding for docked FAB
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedAdCard(BuildContext context, CampaignModel campaign) {
    final product = campaign.product;

    return CustomCard(
      borderRadius: 20,
      showShadow: true,
      onTap: () {
        context.read<CampaignProvider>().selectCampaign(campaign);
        context.push('/product/${campaign.id}');
      },
      padding: const EdgeInsets.all(14),
      child: SizedBox(
        width: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Badge & Favorite
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.threed_rotation_rounded, size: 12, color: AppColors.secondaryDark),
                      const SizedBox(width: 4),
                      Text(
                        'AR Ready',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.secondaryDark,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    final isSaved = auth.isAdSaved(campaign.id);
                    return GestureDetector(
                      onTap: () => auth.toggleSaveAd(campaign.id),
                      child: Icon(
                        isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        size: 20,
                        color: isSaved ? AppColors.primary : AppColors.textTertiary,
                      ),
                    );
                  },
                ),
              ],
            ),

            const Spacer(),

            // 3D Model Representation Placeholder Graphic
            Center(
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppColors.surfaceSecondary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    _getCategoryIcon(product?.category),
                    size: 36,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),

            const Spacer(),

            // Info
            Text(
              product?.brand ?? 'Brand',
              style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary),
            ),
            const SizedBox(height: 2),
            Text(
              campaign.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelLarge,
            ),
            const SizedBox(height: 6),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Formatters.formatCurrency(product?.price ?? 0.0),
                  style: AppTypography.headlineSmall.copyWith(color: AppColors.primary),
                ),
                GestureDetector(
                  onTap: () {
                    context.read<CampaignProvider>().selectCampaign(campaign);
                    context.push('/ar-view/${campaign.id}');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'View in AR',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferCard(BuildContext context, CampaignModel campaign) {
    final offer = campaign.offer;
    if (offer == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CustomCard(
        backgroundColor: AppColors.accentLight,
        borderColor: AppColors.accent,
        borderRadius: 18,
        onTap: () {
          context.read<CampaignProvider>().selectCampaign(campaign);
          context.push('/product/${campaign.id}');
        },
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.local_offer_rounded, color: AppColors.accentDark, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${offer.discountPercentage.toInt()}% DISCOUNT',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.accentDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Code: ${offer.code}',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    offer.title,
                    style: AppTypography.headlineSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    offer.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'fashion':
        return Icons.hiking_rounded;
      case 'accessories':
        return Icons.watch_rounded;
      case 'beverages':
        return Icons.local_drink_rounded;
      case 'electronics':
        return Icons.speaker_rounded;
      default:
        return Icons.view_in_ar_rounded;
    }
  }
}
