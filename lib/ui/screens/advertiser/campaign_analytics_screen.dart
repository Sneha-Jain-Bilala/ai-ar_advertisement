import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';

import '../../../providers/advertiser_provider.dart';
import '../../common/custom_card.dart';

class CampaignAnalyticsScreen extends StatelessWidget {
  final String campaignId;

  const CampaignAnalyticsScreen({super.key, required this.campaignId});

  @override
  Widget build(BuildContext context) {
    final advertiser = context.watch<AdvertiserProvider>();
    final campaign = advertiser.myCampaigns.firstWhere(
      (c) => c.id == campaignId,
      orElse: () => advertiser.myCampaigns.first,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Campaign Analytics'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined, size: 22),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export coming soon')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campaign Name Header
            Text(campaign.title, style: AppTypography.headlineLarge),
            const SizedBox(height: 4),
            Text(
              '${campaign.product?.brand ?? "Brand"} • ${campaign.status.toUpperCase()}',
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: 20),

            // Metric Cards Grid (2x2)
            Row(
              children: [
                Expanded(child: _buildMetricCard('Total Scans', Formatters.formatCompactNumber(campaign.scanCount), Icons.qr_code_scanner_rounded, AppColors.primary, AppColors.primaryLight)),
                const SizedBox(width: 12),
                Expanded(child: _buildMetricCard('Unique Views', Formatters.formatCompactNumber(campaign.uniqueViewCount), Icons.visibility_rounded, AppColors.secondary, AppColors.secondaryLight)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildMetricCard('Avg. Dwell', '${campaign.avgDwellTimeSeconds}s', Icons.timer_rounded, AppColors.accent, AppColors.accentLight)),
                const SizedBox(width: 12),
                Expanded(child: _buildMetricCard('Interaction', '${campaign.interactionRate.toStringAsFixed(1)}%', Icons.touch_app_rounded, AppColors.warning, AppColors.warningLight)),
              ],
            ),
            const SizedBox(height: 24),

            // Scans Over Time Chart
            Text('Scans Over Time', style: AppTypography.headlineSmall),
            const SizedBox(height: 4),
            Text('Last 7 days', style: AppTypography.bodySmall),
            const SizedBox(height: 14),
            CustomCard(
              padding: const EdgeInsets.fromLTRB(12, 20, 20, 12),
              child: SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 500,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: AppColors.border,
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              Formatters.formatCompactNumber(value.toInt()),
                              style: AppTypography.bodySmall.copyWith(fontSize: 10),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                            final idx = value.toInt();
                            if (idx >= 0 && idx < days.length) {
                              return Text(days[idx], style: AppTypography.bodySmall.copyWith(fontSize: 10));
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _generateScanTrend(campaign.scanCount),
                        isCurved: true,
                        color: AppColors.primary,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, bar, index) =>
                              FlDotCirclePainter(
                                radius: 4,
                                color: AppColors.surface,
                                strokeWidth: 2.5,
                                strokeColor: AppColors.primary,
                              ),
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.primary.withValues(alpha: 0.15),
                              AppColors.primary.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Interaction Breakdown Pie Chart
            Text('Interaction Breakdown', style: AppTypography.headlineSmall),
            const SizedBox(height: 4),
            Text('Distribution of user interactions', style: AppTypography.bodySmall),
            const SizedBox(height: 14),
            CustomCard(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  // Pie Chart
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 30,
                        sections: [
                          PieChartSectionData(
                            color: AppColors.primary,
                            value: 40,
                            title: '40%',
                            titleStyle: AppTypography.labelSmall.copyWith(color: Colors.white, fontSize: 10),
                            radius: 28,
                          ),
                          PieChartSectionData(
                            color: AppColors.secondary,
                            value: 25,
                            title: '25%',
                            titleStyle: AppTypography.labelSmall.copyWith(color: Colors.white, fontSize: 10),
                            radius: 28,
                          ),
                          PieChartSectionData(
                            color: AppColors.accent,
                            value: 20,
                            title: '20%',
                            titleStyle: AppTypography.labelSmall.copyWith(color: Colors.white, fontSize: 10),
                            radius: 28,
                          ),
                          PieChartSectionData(
                            color: AppColors.warning,
                            value: 10,
                            title: '10%',
                            titleStyle: AppTypography.labelSmall.copyWith(color: Colors.white, fontSize: 10),
                            radius: 28,
                          ),
                          PieChartSectionData(
                            color: AppColors.textTertiary,
                            value: 5,
                            title: '5%',
                            titleStyle: AppTypography.labelSmall.copyWith(color: Colors.white, fontSize: 10),
                            radius: 28,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Legend
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLegendItem('AR Session', AppColors.primary, '40%'),
                        const SizedBox(height: 8),
                        _buildLegendItem('Model Interact', AppColors.secondary, '25%'),
                        const SizedBox(height: 8),
                        _buildLegendItem('CTA Click', AppColors.accent, '20%'),
                        const SizedBox(height: 8),
                        _buildLegendItem('Coupon Claim', AppColors.warning, '10%'),
                        const SizedBox(height: 8),
                        _buildLegendItem('Share', AppColors.textTertiary, '5%'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Budget Utilization
            Text('Budget Utilization', style: AppTypography.headlineSmall),
            const SizedBox(height: 14),
            CustomCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Spent', style: AppTypography.bodyMedium),
                      Text(
                        '${Formatters.formatCurrency(campaign.spend)} / ${Formatters.formatCurrency(campaign.budget)}',
                        style: AppTypography.labelLarge.copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: campaign.budget > 0 ? (campaign.spend / campaign.budget).clamp(0.0, 1.0) : 0,
                      minHeight: 10,
                      backgroundColor: AppColors.surfaceSecondary,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        campaign.spend / campaign.budget > 0.8 ? AppColors.error : AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${((campaign.spend / campaign.budget) * 100).toStringAsFixed(1)}% used',
                        style: AppTypography.bodySmall,
                      ),
                      Text(
                        '${campaign.daysLeft} days remaining',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color, Color bgColor) {
    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 12),
          Text(value, style: AppTypography.statNumber),
          const SizedBox(height: 2),
          Text(label, style: AppTypography.bodySmall),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, String percentage) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
        ),
        Text(percentage, style: AppTypography.labelSmall.copyWith(color: AppColors.textPrimary)),
      ],
    );
  }

  /// Generate simulated daily scan data based on total scans
  List<FlSpot> _generateScanTrend(int totalScans) {
    final dailyAvg = totalScans / 14.0; // Average over ~2 weeks
    final multipliers = [0.7, 0.85, 1.1, 1.3, 1.0, 0.9, 1.15];
    return List.generate(7, (i) {
      return FlSpot(i.toDouble(), (dailyAvg * multipliers[i]).roundToDouble());
    });
  }
}
