import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/campaign_model.dart';
import '../../../providers/campaign_provider.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> with SingleTickerProviderStateMixin {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  late AnimationController _laserController;
  late Animation<double> _laserAnimation;

  bool _isProcessing = false;
  bool _isTorchOn = false;

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _laserAnimation = Tween<double>(begin: 0.1, end: 0.9).animate(
      CurvedAnimation(parent: _laserController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _laserController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    setState(() => _isProcessing = true);

    final campaignProvider = context.read<CampaignProvider>();
    final campaign = await campaignProvider.resolveQrCode(rawValue);

    if (!mounted) return;

    if (campaign != null) {
      context.pushReplacement('/ar-view/${campaign.id}');
    } else {
      // If code was not recognized, show snackbar and resume
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unrecognized QR: $rawValue. Try one of the demo ads below.'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 2),
        ),
      );
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _launchDemoCampaign(CampaignModel campaign) {
    context.read<CampaignProvider>().selectCampaign(campaign);
    context.pushReplacement('/ar-view/${campaign.id}');
  }

  @override
  Widget build(BuildContext context) {
    final campaignProvider = context.watch<CampaignProvider>();
    final campaigns = campaignProvider.campaigns;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Camera Viewfinder
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
            errorBuilder: (context, error) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.camera_alt_outlined, size: 54, color: AppColors.textTertiary),
                      const SizedBox(height: 16),
                      Text(
                        'Camera access unavailable or on simulator',
                        style: AppTypography.headlineSmall.copyWith(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You can tap any demo ad below to test the AR experience directly!',
                        style: AppTypography.bodySmall.copyWith(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // 2. Darkened Mask & Reticle
          _buildScannerOverlay(context),

          // 3. Top Controls Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCircleButton(
                    icon: Icons.close_rounded,
                    onTap: () => context.pop(),
                  ),
                  Text(
                    'Scan AR Ad',
                    style: AppTypography.headlineSmall.copyWith(color: Colors.white),
                  ),
                  _buildCircleButton(
                    icon: _isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                    color: _isTorchOn ? AppColors.warning : Colors.white,
                    onTap: () {
                      _scannerController.toggleTorch();
                      setState(() => _isTorchOn = !_isTorchOn);
                    },
                  ),
                ],
              ),
            ),
          ),

          // 4. Instruction Pill
          Positioned(
            top: 100,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                children: [
                  const Icon(Icons.qr_code_2_rounded, size: 20, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Point camera at any AR poster or packaging QR code.',
                      style: AppTypography.bodySmall.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 5. Bottom Quick Actions & Demo Scans Row
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, size: 14, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        'MATCHED 3D AR ADS (TAP TO PREVIEW):',
                        style: AppTypography.labelSmall.copyWith(
                          color: Colors.white70,
                          letterSpacing: 0.6,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Horizontal list of demo ads for instant 1-tap testing
                SizedBox(
                  height: 48,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: campaigns.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final c = campaigns[index];
                      return GestureDetector(
                        onTap: () => _launchDemoCampaign(c),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.6)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.play_circle_fill_rounded, size: 16, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Text(
                                c.product?.name ?? c.title,
                                style: AppTypography.labelMedium.copyWith(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerOverlay(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scanBoxSize = size.width * 0.72;

    return Center(
      child: Container(
        width: scanBoxSize,
        height: scanBoxSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 1.5),
        ),
        child: Stack(
          children: [
            // Corner Brackets
            _buildCornerBracket(top: 0, left: 0, isTop: true, isLeft: true),
            _buildCornerBracket(top: 0, right: 0, isTop: true, isLeft: false),
            _buildCornerBracket(bottom: 0, left: 0, isTop: false, isLeft: true),
            _buildCornerBracket(bottom: 0, right: 0, isTop: false, isLeft: false),

            // Animated Laser Line
            AnimatedBuilder(
              animation: _laserAnimation,
              builder: (context, child) {
                return Positioned(
                  top: scanBoxSize * _laserAnimation.value,
                  left: 12,
                  right: 12,
                  child: Container(
                    height: 2.5,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.8),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCornerBracket({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required bool isTop,
    required bool isLeft,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          border: Border(
            top: isTop ? const BorderSide(color: AppColors.primary, width: 4) : BorderSide.none,
            bottom: !isTop ? const BorderSide(color: AppColors.primary, width: 4) : BorderSide.none,
            left: isLeft ? const BorderSide(color: AppColors.primary, width: 4) : BorderSide.none,
            right: !isLeft ? const BorderSide(color: AppColors.primary, width: 4) : BorderSide.none,
          ),
          borderRadius: BorderRadius.only(
            topLeft: isTop && isLeft ? const Radius.circular(16) : Radius.zero,
            topRight: isTop && !isLeft ? const Radius.circular(16) : Radius.zero,
            bottomLeft: !isTop && isLeft ? const Radius.circular(16) : Radius.zero,
            bottomRight: !isTop && !isLeft ? const Radius.circular(16) : Radius.zero,
          ),
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24),
      ),
      child: IconButton(
        icon: Icon(icon, size: 20, color: color ?? Colors.white),
        onPressed: onTap,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
