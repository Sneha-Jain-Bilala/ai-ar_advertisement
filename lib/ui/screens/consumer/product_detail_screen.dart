import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sceneview/flutter_sceneview.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/campaign_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/campaign_provider.dart';
import '../../../services/groq_service.dart';
import '../../common/custom_button.dart';
import '../../common/custom_card.dart';

class ProductDetailScreen extends StatefulWidget {
  final String campaignId;

  const ProductDetailScreen({super.key, required this.campaignId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final GroqService _groqService = GroqService();
  final TextEditingController _questionController = TextEditingController();

  String? _customAiAnswer;
  bool _isAiThinking = false;

  final List<String> _suggestedQuestions = [
    'Is it durable for daily use?',
    'What makes it better than competitors?',
    'What is the warranty coverage?',
  ];

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  void _askAi(String question, CampaignModel campaign) async {
    final product = campaign.product;
    if (product == null) return;

    setState(() {
      _isAiThinking = true;
      _customAiAnswer = null;
    });

    final answer = await _groqService.askProductQuestion(
      productName: product.name,
      brand: product.brand,
      description: product.description,
      specs: product.specifications,
      question: question,
    );

    if (mounted) {
      setState(() {
        _isAiThinking = false;
        _customAiAnswer = answer;
      });
    }
  }

  void _copyPromoCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Promo code "$code" copied!'),
        backgroundColor: AppColors.secondary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final campaignProvider = context.watch<CampaignProvider>();
    final auth = context.watch<AuthProvider>();

    CampaignModel? campaign = campaignProvider.selectedCampaign;
    if (campaign == null || campaign.id != widget.campaignId) {
      try {
        campaign = campaignProvider.campaigns.firstWhere((c) => c.id == widget.campaignId);
      } catch (_) {
        campaign = campaignProvider.campaigns.first;
      }
    }

    final product = campaign.product;
    if (product == null) {
      return const Scaffold(body: Center(child: Text('Product not found')));
    }

    final isSaved = auth.isAdSaved(campaign.id);
    final offer = campaign.offer;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(product.brand),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: isSaved ? AppColors.primary : AppColors.textPrimary,
            ),
            onPressed: () => auth.toggleSaveAd(campaign!.id),
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () => SharePlus.instance.share(
              ShareParams(text: 'Check out ${product.name} on AR-AdVision!'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 3D Model Interactive Container
            Container(
              height: 280,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Stack(
                children: [
                  // 3D SceneView Orbit Preview
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: SceneView(
                      cameraControlMode: CameraControlMode.orbit,
                      autoCenterContent: true,
                      initialModels: [
                        ModelNode(
                          modelPath: product.modelAssetPath,
                          scale: 1.0,
                        ),
                      ],
                    ),
                  ),

                  // 360 Badge
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.hudGlassBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.hudGlassBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.threed_rotation_rounded, size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text('360° Orbit', style: AppTypography.labelSmall.copyWith(color: AppColors.primary)),
                        ],
                      ),
                    ),
                  ),

                  // Launch AR Mode Button
                  Positioned(
                    bottom: 14,
                    right: 14,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onPressed: () {
                        context.push('/ar-view/${campaign!.id}');
                      },
                      icon: const Icon(Icons.view_in_ar_rounded, size: 18),
                      label: Text('Launch in AR', style: AppTypography.labelLarge.copyWith(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 2. Title, Rating & Price
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.category.toUpperCase(),
                          style: AppTypography.labelSmall.copyWith(color: AppColors.primary)),
                      const SizedBox(height: 2),
                      Text(product.name, style: AppTypography.displayLarge.copyWith(fontSize: 22)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 18, color: AppColors.warning),
                          const SizedBox(width: 4),
                          Text('${product.rating}', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold)),
                          Text(' (${product.reviewCount} reviews)', style: AppTypography.bodySmall),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  Formatters.formatCurrency(product.price),
                  style: AppTypography.displayMedium.copyWith(color: AppColors.primary),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 3. Product Description
            Text('Overview', style: AppTypography.headlineMedium),
            const SizedBox(height: 6),
            Text(product.description, style: AppTypography.bodyMedium),

            const SizedBox(height: 24),

            // 4. AI Insight Card (Stitch Screen 3)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        child: const Icon(Icons.auto_awesome, size: 16, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('AI Summary & Highlights', style: AppTypography.labelLarge.copyWith(color: AppColors.primaryDark)),
                            Text('Powered by Groq Llama 3', style: AppTypography.labelSmall.copyWith(fontSize: 10, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    product.aiSummary ?? 'Analyzing product specs and verified customer reviews...',
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                  ),

                  const SizedBox(height: 16),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 8),

                  Text('Ask AI About This Product:', style: AppTypography.labelMedium.copyWith(color: AppColors.primaryDark)),
                  const SizedBox(height: 8),

                  // Suggested Question Chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: _suggestedQuestions.map((q) {
                      return ActionChip(
                        label: Text(q, style: AppTypography.labelSmall.copyWith(fontSize: 11)),
                        backgroundColor: AppColors.surface,
                        side: const BorderSide(color: AppColors.border),
                        onPressed: () => _askAi(q, campaign!),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 10),

                  // Custom Question Field
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _questionController,
                          decoration: InputDecoration(
                            hintText: 'Type your question...',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                        icon: const Icon(Icons.send_rounded, size: 18, color: Colors.white),
                        onPressed: () {
                          if (_questionController.text.trim().isNotEmpty) {
                            _askAi(_questionController.text.trim(), campaign!);
                            _questionController.clear();
                          }
                        },
                      ),
                    ],
                  ),

                  // AI Answer Display
                  if (_isAiThinking) ...[
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
                        SizedBox(width: 10),
                        Text('AI Assistant is analyzing...', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ] else if (_customAiAnswer != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      child: Text(_customAiAnswer!, style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary)),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 5. Specifications Grid
            Text('Technical Specifications', style: AppTypography.headlineMedium),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.2,
              children: product.specifications.entries.map((entry) {
                return CustomCard(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(entry.key, style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary)),
                      const SizedBox(height: 2),
                      Text(
                        entry.value,
                        style: AppTypography.labelLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // 6. Exclusive AR Offer Card
            if (offer != null) ...[
              CustomCard(
                backgroundColor: AppColors.accentLight,
                borderColor: AppColors.accent,
                borderRadius: 20,
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.local_offer_rounded, color: AppColors.accentDark, size: 20),
                        const SizedBox(width: 8),
                        Text('EXCLUSIVE AR OFFER', style: AppTypography.labelSmall.copyWith(color: AppColors.accentDark, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(offer.title, style: AppTypography.headlineMedium),
                    const SizedBox(height: 4),
                    Text(offer.description, style: AppTypography.bodySmall),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.accentDark.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(offer.code, style: AppTypography.headlineSmall.copyWith(letterSpacing: 1.5, color: AppColors.accentDark)),
                          TextButton(
                            onPressed: () => _copyPromoCode(offer.code),
                            child: const Text('COPY CODE'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: const Border(top: BorderSide(color: AppColors.border)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: CustomButton(
                text: isSaved ? 'Saved' : 'Save Ad',
                icon: isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                isOutlined: true,
                onPressed: () => auth.toggleSaveAd(campaign!.id),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: CustomButton(
                text: 'Buy Now • ${Formatters.formatCurrency(product.price)}',
                onPressed: () async {
                  final url = offer?.ctaUrl ?? product.ctaLink ?? 'https://google.com';
                  final uri = Uri.parse(url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
