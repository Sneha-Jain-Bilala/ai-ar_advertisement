import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/campaign_model.dart';
import '../../../providers/advertiser_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../common/custom_card.dart';

class AdvertiserDashboardScreen extends StatelessWidget {
  const AdvertiserDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final advertiser = context.watch<AdvertiserProvider>();
    final auth = context.watch<AuthProvider>();
    final kpis = advertiser.kpiMetrics;
    final trend = advertiser.weeklyTrend;
    final campaigns = advertiser.myCampaigns;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.storefront_rounded, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Text('Brand Hub • ${auth.currentUser?.displayName ?? "Aura Tech"}'),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () {
            auth.switchRole('consumer');
            context.go('/home');
          },
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.secondaryLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.secondary),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text('Advertiser', style: AppTypography.labelSmall.copyWith(color: AppColors.secondaryDark)),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Action Buttons Row (Stitch Screen 5)
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.add_rounded,
                    label: '+ New Ad',
                    color: AppColors.primary,
                    bgColor: AppColors.primaryLight,
                    onTap: () => context.push('/advertiser/create-campaign'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.view_in_ar_rounded,
                    label: '3D Products',
                    color: AppColors.secondaryDark,
                    bgColor: AppColors.secondaryLight,
                    onTap: () => context.push('/advertiser/products'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.qr_code_2_rounded,
                    label: 'QR Studio',
                    color: AppColors.accentDark,
                    bgColor: AppColors.accentLight,
                    onTap: () => context.push('/advertiser/qr-export'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // KPI Grid (2x2)
            Text('Campaign Performance', style: AppTypography.headlineMedium),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildKpiCard(
                    title: 'Total AR Scans',
                    value: Formatters.formatCompactNumber(kpis['totalScans']),
                    trend: '+18.4% this week',
                    icon: Icons.qr_code_scanner_rounded,
                    color: AppColors.primary,
                    bgColor: AppColors.primaryLight,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildKpiCard(
                    title: 'Avg. Dwell Time',
                    value: Formatters.formatDuration(kpis['avgDwellTime']),
                    trend: '+12s vs avg',
                    icon: Icons.timer_outlined,
                    color: AppColors.secondaryDark,
                    bgColor: AppColors.secondaryLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildKpiCard(
                    title: '3D Interaction Rate',
                    value: '${kpis['interactionRate'].toStringAsFixed(1)}%',
                    trend: '+5.1% engagement',
                    icon: Icons.touch_app_outlined,
                    color: AppColors.accentDark,
                    bgColor: AppColors.accentLight,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildKpiCard(
                    title: 'Conversion CTR',
                    value: '${kpis['conversionRate']}%',
                    trend: 'Above benchmark',
                    icon: Icons.ads_click_rounded,
                    color: const Color(0xFFC48B00),
                    bgColor: AppColors.warningLight,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Engagement Trend Line Chart
            CustomCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('7-Day Engagement Trend', style: AppTypography.headlineSmall),
                          Text('Daily QR Scans vs 3D Rotations', style: AppTypography.bodySmall),
                        ],
                      ),
                      Row(
                        children: [
                          _buildLegendDot(AppColors.primary, 'Scans'),
                          const SizedBox(width: 12),
                          _buildLegendDot(AppColors.secondary, '3D Moves'),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 180,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: FlTitlesData(
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (val, meta) {
                                final idx = val.toInt();
                                if (idx >= 0 && idx < trend.length) {
                                  final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                                  return Text(days[idx % 7], style: AppTypography.labelSmall.copyWith(fontSize: 10));
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          // Scans Line
                          LineChartBarData(
                            spots: trend.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.scans.toDouble())).toList(),
                            isCurved: true,
                            color: AppColors.primary,
                            barWidth: 3,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppColors.primary.withValues(alpha: 0.1),
                            ),
                          ),
                          // Interactions Line
                          LineChartBarData(
                            spots: trend.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.interactions.toDouble())).toList(),
                            isCurved: true,
                            color: AppColors.secondary,
                            barWidth: 3,
                            dotData: const FlDotData(show: false),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Active Campaigns Management List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Active Campaigns (${campaigns.length})', style: AppTypography.headlineMedium),
                TextButton(
                  onPressed: () => context.push('/advertiser/create-campaign'),
                  child: const Text('+ Create New'),
                ),
              ],
            ),
            const SizedBox(height: 10),

            ...campaigns.map((c) => _buildCampaignManageCard(context, c)),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 6),
            Text(label, style: AppTypography.labelMedium.copyWith(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String trend,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary)),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
                child: Icon(icon, size: 16, color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: AppTypography.statNumber.copyWith(fontSize: 22)),
          const SizedBox(height: 4),
          Text(trend, style: AppTypography.labelSmall.copyWith(color: color, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildCampaignManageCard(BuildContext context, CampaignModel c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CustomCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.qr_code_2_rounded, size: 26, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.title, style: AppTypography.headlineSmall),
                      Text('${c.product?.name ?? "Product"} • ${c.daysLeft} days left', style: AppTypography.bodySmall),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    c.status == 'active' ? Icons.pause_circle_outline_rounded : Icons.play_circle_outline_rounded,
                    color: c.status == 'active' ? AppColors.warning : AppColors.secondary,
                  ),
                  onPressed: () {
                    context.read<AdvertiserProvider>().toggleCampaignStatus(c.id);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: AppColors.border),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMiniStat('Scans', '${c.scanCount}'),
                _buildMiniStat('Dwell', '${c.avgDwellTimeSeconds}s'),
                _buildMiniStat('Engage', '${c.interactionRate.toStringAsFixed(0)}%'),
                TextButton(
                  onPressed: () {
                    context.push('/advertiser/campaign-detail/${c.id}');
                  },
                  child: const Text('Analytics →'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelSmall.copyWith(fontSize: 10, color: AppColors.textTertiary)),
        Text(val, style: AppTypography.labelLarge),
      ],
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: AppTypography.labelSmall.copyWith(fontSize: 10)),
      ],
    );
  }
}
