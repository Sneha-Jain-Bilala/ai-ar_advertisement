import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/campaign_model.dart';
import '../../../providers/advertiser_provider.dart';
import '../../common/custom_button.dart';
import '../../common/custom_card.dart';

class QrExportScreen extends StatefulWidget {
  const QrExportScreen({super.key});

  @override
  State<QrExportScreen> createState() => _QrExportScreenState();
}

class _QrExportScreenState extends State<QrExportScreen> {
  CampaignModel? _selectedCampaign;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final campaigns = context.read<AdvertiserProvider>().myCampaigns;
      if (campaigns.isNotEmpty) {
        setState(() => _selectedCampaign = campaigns.first);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final campaigns = context.watch<AdvertiserProvider>().myCampaigns;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('QR Code Studio'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Campaign to Export QR', style: AppTypography.headlineMedium),
            const SizedBox(height: 10),

            // Dropdown Campaign Picker
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<CampaignModel>(
                  isExpanded: true,
                  value: _selectedCampaign ?? (campaigns.isNotEmpty ? campaigns.first : null),
                  items: campaigns.map((c) {
                    return DropdownMenuItem(
                      value: c,
                      child: Text(c.title, style: AppTypography.labelLarge),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCampaign = val);
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Center QR Code Canvas Card
            Center(
              child: CustomCard(
                padding: const EdgeInsets.all(28),
                borderRadius: 24,
                showShadow: true,
                child: Column(
                  children: [
                    if (_selectedCampaign != null) ...[
                      QrImageView(
                        data: _selectedCampaign!.qrPayload,
                        version: QrVersions.auto,
                        size: 240.0,
                        backgroundColor: Colors.white,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: AppColors.textPrimary,
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.circle,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _selectedCampaign!.title,
                        style: AppTypography.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Target 3D: ${_selectedCampaign!.product?.name ?? "Model"}',
                        style: AppTypography.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'ID: ${_selectedCampaign!.id}',
                          style: AppTypography.labelSmall.copyWith(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Print & Export Specs
            CustomCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Print Recommendations', style: AppTypography.labelLarge),
                  const SizedBox(height: 6),
                  Text('• Billboard / Poster: Minimum 15cm x 15cm print dimensions', style: AppTypography.bodySmall),
                  Text('• Magazine / Packaging: Minimum 3cm x 3cm print dimensions', style: AppTypography.bodySmall),
                  Text('• Camera scan distance: 0.3m to 5.0m depending on print scale', style: AppTypography.bodySmall),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Download Buttons
            CustomButton(
              text: 'Save PNG to Gallery',
              icon: Icons.download_rounded,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('QR Code image exported to gallery!'),
                    backgroundColor: AppColors.secondary,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: 'Share Print Template PDF / Vector',
              isOutlined: true,
              icon: Icons.share_rounded,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Preparing print vector package...')),
                );
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
