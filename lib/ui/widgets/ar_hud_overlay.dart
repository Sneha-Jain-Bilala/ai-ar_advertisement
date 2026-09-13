import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class ArHudOverlay extends StatelessWidget {
  final bool isTrackingLocked;
  final VoidCallback onBack;
  final VoidCallback onShare;
  final VoidCallback onToggleFlash;
  final bool isFlashOn;

  const ArHudOverlay({
    super.key,
    required this.isTrackingLocked,
    required this.onBack,
    required this.onShare,
    required this.onToggleFlash,
    this.isFlashOn = false,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back Button
            _buildGlassCircleButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: onBack,
            ),

            // Tracking Status Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.hudGlassBackground,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.hudGlassBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                  )
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isTrackingLocked ? AppColors.secondary : AppColors.warning,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isTrackingLocked ? 'Surface Locked • 60 FPS' : 'Detecting Plane...',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Right Action Buttons
            Row(
              children: [
                _buildGlassCircleButton(
                  icon: isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                  color: isFlashOn ? AppColors.warning : null,
                  onTap: onToggleFlash,
                ),
                const SizedBox(width: 8),
                _buildGlassCircleButton(
                  icon: Icons.share_rounded,
                  onTap: onShare,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.hudGlassBackground,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.hudGlassBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
          )
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 18, color: color ?? AppColors.textPrimary),
        onPressed: onTap,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
