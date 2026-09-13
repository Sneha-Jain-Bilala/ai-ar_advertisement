import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Reusable metric display card for dashboards
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final String? trend; // e.g. "+12%"
  final bool trendPositive;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color = AppColors.primary,
    this.backgroundColor = AppColors.primaryLight,
    this.trend,
    this.trendPositive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              if (trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: trendPositive ? AppColors.secondaryLight : AppColors.errorLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        trendPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                        size: 12,
                        color: trendPositive ? AppColors.secondaryDark : AppColors.error,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        trend!,
                        style: AppTypography.labelSmall.copyWith(
                          color: trendPositive ? AppColors.secondaryDark : AppColors.error,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: AppTypography.statNumber),
          const SizedBox(height: 2),
          Text(label, style: AppTypography.bodySmall),
        ],
      ),
    );
  }
}
