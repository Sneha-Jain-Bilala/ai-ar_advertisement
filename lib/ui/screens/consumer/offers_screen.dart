import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/offer_model.dart';
import '../../../providers/campaign_provider.dart';
import '../../common/custom_card.dart';

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final campaignProvider = context.watch<CampaignProvider>();
    final campaigns = campaignProvider.campaigns;

    // Collect all non-null offers from campaigns
    final offers = campaigns
        .where((c) => c.offer != null)
        .map((c) => _OfferWithCampaign(offer: c.offer!, campaignTitle: c.title, productName: c.product?.name ?? 'Product'))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Offers & Promos'),
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accentLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_fire_department_rounded, size: 16, color: AppColors.accentDark),
                const SizedBox(width: 4),
                Text(
                  '${offers.length} Active',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.accentDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: offers.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.card_giftcard_rounded, size: 64, color: AppColors.border),
                  const SizedBox(height: 16),
                  Text('No active offers right now', style: AppTypography.bodyMedium),
                  const SizedBox(height: 8),
                  Text('Scan AR ads to unlock exclusive deals!', style: AppTypography.bodySmall),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              itemCount: offers.length,
              separatorBuilder: (_, i) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final item = offers[index];
                return _OfferCard(item: item);
              },
            ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final _OfferWithCampaign item;

  const _OfferCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final offer = item.offer;
    final daysLeft = offer.expiryDate.difference(DateTime.now()).inDays;
    final hoursLeft = offer.expiryDate.difference(DateTime.now()).inHours % 24;
    final isExpiringSoon = daysLeft <= 3;

    return CustomCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Top Banner with Discount
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isExpiringSoon
                    ? [AppColors.accent, AppColors.accentDark]
                    : [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${offer.discountPercentage.toInt()}% OFF',
                    style: AppTypography.headlineSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer.title,
                        style: AppTypography.headlineSmall.copyWith(color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.productName,
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Details Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer.description,
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 14),

                // Countdown Row
                Row(
                  children: [
                    Icon(
                      isExpiringSoon ? Icons.timer_rounded : Icons.schedule_rounded,
                      size: 16,
                      color: isExpiringSoon ? AppColors.error : AppColors.textTertiary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      offer.isExpired
                          ? 'Expired'
                          : isExpiringSoon
                              ? '${daysLeft}d ${hoursLeft}h left — Hurry!'
                              : '$daysLeft days remaining',
                      style: AppTypography.labelSmall.copyWith(
                        color: isExpiringSoon ? AppColors.error : AppColors.textTertiary,
                        fontWeight: isExpiringSoon ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    // Campaign Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSecondary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.campaignTitle,
                        style: AppTypography.labelSmall.copyWith(fontSize: 9),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Coupon Code + CTA
                Row(
                  children: [
                    // Coupon Code Chip
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: offer.code));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Copied "${offer.code}" to clipboard'),
                              backgroundColor: AppColors.secondary,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSecondary,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.content_copy_rounded, size: 14, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  offer.code,
                                  style: AppTypography.labelLarge.copyWith(
                                    color: AppColors.primary,
                                    letterSpacing: 1.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Redeem Button
                    if (offer.ctaUrl != null && !offer.isExpired)
                      ElevatedButton(
                        onPressed: () async {
                          final uri = Uri.tryParse(offer.ctaUrl!);
                          if (uri != null) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textOnPrimary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Redeem', style: AppTypography.buttonText.copyWith(fontSize: 13)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OfferWithCampaign {
  final OfferModel offer;
  final String campaignTitle;
  final String productName;

  const _OfferWithCampaign({
    required this.offer,
    required this.campaignTitle,
    required this.productName,
  });
}
