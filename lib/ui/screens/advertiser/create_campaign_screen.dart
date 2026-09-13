import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/qr_utils.dart';
import '../../../data/models/campaign_model.dart';
import '../../../data/models/offer_model.dart';
import '../../../data/models/product_model.dart';
import '../../../providers/advertiser_provider.dart';
import '../../common/custom_button.dart';
import '../../common/custom_card.dart';

class CreateCampaignScreen extends StatefulWidget {
  const CreateCampaignScreen({super.key});

  @override
  State<CreateCampaignScreen> createState() => _CreateCampaignScreenState();
}

class _CreateCampaignScreenState extends State<CreateCampaignScreen> {
  final _titleController = TextEditingController(text: 'Summer 3D AR Showcase');
  final _descController = TextEditingController(text: 'Scan this print ad to view the product in 3D in your room.');
  final _promoCodeController = TextEditingController(text: 'SUMMER25');
  final _discountController = TextEditingController(text: '25');
  final _ctaUrlController = TextEditingController(text: 'https://example.com/shop/summer');

  ProductModel? _selectedProduct;
  final String _generatedCampaignId = 'camp_${DateTime.now().millisecondsSinceEpoch}';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final products = context.read<AdvertiserProvider>().myProducts;
      if (products.isNotEmpty) {
        setState(() => _selectedProduct = products.first);
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _promoCodeController.dispose();
    _discountController.dispose();
    _ctaUrlController.dispose();
    super.dispose();
  }

  void _generateAiCopy() async {
    if (_selectedProduct == null) return;
    final advertiser = context.read<AdvertiserProvider>();

    final copy = await advertiser.generateAiCopy(
      productName: _selectedProduct!.name,
      brand: _selectedProduct!.brand,
      goal: 'Drive in-store & online AR engagement with discount code',
    );

    setState(() {
      _titleController.text = copy['headline'] ?? _titleController.text;
      _descController.text = copy['subheading'] ?? _descController.text;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✨ AI Marketing Copy generated via Groq Llama 3!'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  void _handlePublish() async {
    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a 3D product model')),
      );
      return;
    }

    final advertiser = context.read<AdvertiserProvider>();
    final qrPayload = QrUtils.generateCampaignPayload(
      _generatedCampaignId,
      productId: _selectedProduct!.id,
    );

    final campaign = CampaignModel(
      id: _generatedCampaignId,
      advertiserId: 'adv_brand_01',
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 30)),
      productId: _selectedProduct!.id,
      product: _selectedProduct,
      offer: OfferModel(
        id: 'off_${DateTime.now().millisecondsSinceEpoch}',
        title: '${_discountController.text}% Summer Special',
        description: 'Exclusive discount unlocked via AR scan.',
        code: _promoCodeController.text.trim(),
        discountPercentage: double.tryParse(_discountController.text.trim()) ?? 20.0,
        expiryDate: DateTime.now().add(const Duration(days: 30)),
        ctaUrl: _ctaUrlController.text.trim(),
      ),
      qrPayload: qrPayload,
      createdAt: DateTime.now(),
    );

    await advertiser.createCampaign(campaign);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Campaign published & QR code generated successfully!'),
          backgroundColor: AppColors.secondary,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final advertiser = context.watch<AdvertiserProvider>();
    final products = advertiser.myProducts;
    final isGeneratingAi = advertiser.isGeneratingAiCopy;

    final currentQrPayload = QrUtils.generateCampaignPayload(
      _generatedCampaignId,
      productId: _selectedProduct?.id,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create AR Campaign'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI Assistance Header Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: AppColors.primary, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('AI Campaign Assistant', style: AppTypography.labelLarge.copyWith(color: AppColors.primaryDark)),
                        Text('Let Groq Llama 3 generate high-converting ad headlines & offer copy.', style: AppTypography.bodySmall),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: Size.zero,
                    ),
                    onPressed: isGeneratingAi ? null : _generateAiCopy,
                    child: isGeneratingAi
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Generate', style: TextStyle(fontSize: 12, color: Colors.white)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Step 1: Select 3D Product
            Text('1. Select 3D Model Asset', style: AppTypography.headlineMedium),
            const SizedBox(height: 10),
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  final p = products[i];
                  final isSelected = _selectedProduct?.id == p.id;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedProduct = p),
                    child: Container(
                      width: 150,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryLight : AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(Icons.view_in_ar_rounded, size: 20, color: isSelected ? AppColors.primary : AppColors.textSecondary),
                              if (isSelected) const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.primary),
                            ],
                          ),
                          const Spacer(),
                          Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.labelMedium),
                          Text(p.category, style: AppTypography.labelSmall.copyWith(fontSize: 10, color: AppColors.textTertiary)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Step 2: Campaign Details
            Text('2. Campaign Details', style: AppTypography.headlineMedium),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Campaign Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Ad Description / Instructions'),
            ),

            const SizedBox(height: 24),

            // Step 3: Promotional Offer
            Text('3. Promotional Offer & CTA', style: AppTypography.headlineMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _promoCodeController,
                    decoration: const InputDecoration(labelText: 'Promo Code (e.g. SUMMER25)'),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 110,
                  child: TextField(
                    controller: _discountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Discount %'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ctaUrlController,
              decoration: const InputDecoration(labelText: 'Call to Action URL'),
            ),

            const SizedBox(height: 28),

            // Step 4: Live Dynamic QR Code Preview
            Text('4. Live AR Trigger QR Code', style: AppTypography.headlineMedium),
            const SizedBox(height: 12),
            Center(
              child: CustomCard(
                padding: const EdgeInsets.all(20),
                borderRadius: 24,
                showShadow: true,
                child: Column(
                  children: [
                    QrImageView(
                      data: currentQrPayload,
                      version: QrVersions.auto,
                      size: 200.0,
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
                    const SizedBox(height: 12),
                    Text(
                      'Ready to print on billboards, flyers & magazines',
                      style: AppTypography.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Target: ${_selectedProduct?.name ?? "3D Model"}',
                      style: AppTypography.labelMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Submit Button
            CustomButton(
              text: 'Publish Campaign & Generate Live AR Ad',
              isLoading: advertiser.isLoading,
              onPressed: _handlePublish,
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
