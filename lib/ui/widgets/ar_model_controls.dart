import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/offer_model.dart';
import '../../data/models/product_model.dart';
import '../common/custom_button.dart';

class ArModelControls extends StatelessWidget {
  final ProductModel product;
  final OfferModel? offer;
  final String selectedColorHex;
  final Function(String) onColorSelected;
  final HotspotInfo? activeHotspot;
  final VoidCallback onDismissHotspot;
  final VoidCallback onBuyNow;
  final VoidCallback onViewSpecs;

  const ArModelControls({
    super.key,
    required this.product,
    this.offer,
    required this.selectedColorHex,
    required this.onColorSelected,
    this.activeHotspot,
    required this.onDismissHotspot,
    required this.onBuyNow,
    required this.onViewSpecs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 24,
            offset: const Offset(0, -4),
          )
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Hotspot Banner (if active)
          if (activeHotspot != null) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activeHotspot!.title,
                          style: AppTypography.labelLarge.copyWith(color: AppColors.primaryDark),
                        ),
                        Text(
                          activeHotspot!.description,
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: onDismissHotspot,
                  )
                ],
              ),
            ),
          ],

          // Product Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.brand.toUpperCase(),
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primary,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.name,
                      style: AppTypography.headlineMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Formatters.formatCurrency(product.price),
                    style: AppTypography.headlineLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (offer != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accentLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${offer!.discountPercentage.toInt()}% OFF',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.accentDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Color Switcher & Gesture Hints
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Color Variants
              Row(
                children: [
                  Text(
                    'Color:',
                    style: AppTypography.labelMedium,
                  ),
                  const SizedBox(width: 8),
                  ...product.availableColors.map((hex) {
                    final isSelected = hex.toLowerCase() == selectedColorHex.toLowerCase();
                    final color = _parseColor(hex);
                    return GestureDetector(
                      onTap: () => onColorSelected(hex),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.border,
                            width: isSelected ? 2.5 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.3),
                                    blurRadius: 6,
                                  )
                                ]
                              : null,
                        ),
                      ),
                    );
                  }),
                ],
              ),

              // Interaction Guides
              Row(
                children: [
                  _buildGestureHint(Icons.sync_rounded, 'Rotate'),
                  const SizedBox(width: 8),
                  _buildGestureHint(Icons.pinch_rounded, 'Scale'),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                flex: 1,
                child: CustomButton(
                  text: 'Details & AI',
                  isOutlined: true,
                  height: 48,
                  onPressed: onViewSpecs,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: CustomButton(
                  text: 'Buy Now',
                  height: 48,
                  backgroundColor: AppColors.primary,
                  onPressed: onBuyNow,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGestureHint(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(label, style: AppTypography.labelSmall.copyWith(fontSize: 10)),
        ],
      ),
    );
  }

  Color _parseColor(String hex) {
    final clean = hex.replaceAll('#', '');
    if (clean.length == 6) {
      return Color(int.parse('FF$clean', radix: 16));
    }
    return AppColors.primary;
  }
}
