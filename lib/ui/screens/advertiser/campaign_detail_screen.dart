import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/campaign_model.dart';
import '../../../providers/campaign_provider.dart';
import '../../common/custom_card.dart';

class CampaignDetailScreen extends StatelessWidget {
  final String campaignId;

  const CampaignDetailScreen({super.key, required this.campaignId});

  @override
  Widget build(BuildContext context) {
    final campaignProvider = context.watch<CampaignProvider>();
    CampaignModel? foundCampaign;
    try {
      foundCampaign = campaignProvider.campaigns.firstWhere((c) => c.id == campaignId);
    } catch (_) {
      foundCampaign = campaignProvider.campaigns.isNotEmpty ? campaignProvider.campaigns.first : null;
    }

    if (foundCampaign == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Campaign Details')),
        body: const Center(child: Text('Campaign not found')),
      );
    }
    final campaign = foundCampaign;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(campaign.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded, size: 22, color: AppColors.primary),
            tooltip: 'View Analytics',
            onPressed: () => context.push('/advertiser/analytics/${campaign.id}'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status & Dates Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Campaign Status', style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: campaign.isActive ? AppColors.secondary : AppColors.warning,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            campaign.status.toUpperCase(),
                            style: AppTypography.labelLarge.copyWith(
                              color: campaign.isActive ? AppColors.secondaryDark : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Duration', style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary)),
                      const SizedBox(height: 4),
                      Text(
                        '${Formatters.formatDate(campaign.startDate)} - ${Formatters.formatDate(campaign.endDate)}',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Performance Metrics Cards Grid
            Row(
              children: [
                Expanded(
                  child: CustomCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total AR Scans', style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary)),
                        const SizedBox(height: 6),
                        Text('${campaign.scanCount}', style: AppTypography.statNumber),
                        const SizedBox(height: 4),
                        Text('${campaign.uniqueViewCount} unique users', style: AppTypography.bodySmall),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Avg Dwell Time', style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary)),
                        const SizedBox(height: 6),
                        Text(Formatters.formatDuration(campaign.avgDwellTimeSeconds), style: AppTypography.statNumber),
                        const SizedBox(height: 4),
                        Text('${campaign.interactionRate}% rotated 3D', style: AppTypography.bodySmall),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Dwell Time Distribution Bar Chart
            CustomCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dwell Time Distribution', style: AppTypography.headlineSmall),
                  Text('How long shoppers explored the 3D model in AR', style: AppTypography.bodySmall),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 160,
                    child: BarChart(
                      BarChartData(
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (val, _) {
                                final buckets = ['<30s', '30-60s', '1-2m', '2-3m', '3m+'];
                                final i = val.toInt();
                                if (i >= 0 && i < buckets.length) {
                                  return Text(buckets[i], style: AppTypography.labelSmall.copyWith(fontSize: 10));
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                        ),
                        barGroups: [
                          BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 18, color: AppColors.primaryLight, width: 22)]),
                          BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 34, color: AppColors.primary, width: 22)]),
                          BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 48, color: AppColors.primary, width: 22)]),
                          BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 26, color: AppColors.primary, width: 22)]),
                          BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 12, color: AppColors.primaryLight, width: 22)]),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Conversion & Offer Claims
            if (campaign.offer != null) ...[
              CustomCard(
                backgroundColor: AppColors.accentLight,
                borderColor: AppColors.accent,
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Promotional Offer Metrics', style: AppTypography.headlineSmall),
                    const SizedBox(height: 4),
                    Text('Code: ${campaign.offer!.code} • ${campaign.offer!.discountPercentage.toInt()}% Discount', style: AppTypography.bodySmall),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMetricCol('Coupon Copies', '1,420'),
                        _buildMetricCol('Direct Checkouts', '684'),
                        _buildMetricCol('Conversion Rate', '8.9%'),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCol(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary)),
        const SizedBox(height: 2),
        Text(value, style: AppTypography.headlineMedium.copyWith(color: AppColors.accentDark)),
      ],
    );
  }
}
