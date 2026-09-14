import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sceneview/flutter_sceneview.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/campaign_model.dart';
import '../../../providers/ar_view_provider.dart';
import '../../../providers/campaign_provider.dart';
import '../../widgets/ai_insight_pill.dart';
import '../../widgets/ar_hud_overlay.dart';
import '../../widgets/ar_model_controls.dart';

class ArViewerScreen extends StatefulWidget {
  final String campaignId;

  const ArViewerScreen({super.key, required this.campaignId});

  @override
  State<ArViewerScreen> createState() => _ArViewerScreenState();
}

class _ArViewerScreenState extends State<ArViewerScreen> {
  SceneViewController? _sceneController;
  final bool _isArSupported = true;
  bool _useStudioFallback = true;
  bool _isFlashOn = false;
  ArViewProvider? _arProvider;
  Timer? _scaleDebounce;
  double _lastLoadedScale = 1.0;

  String _resolveModelPath(String rawPath) {
    var path = rawPath;
    if (Platform.isIOS && path.endsWith('.glb')) {
      path = path.replaceAll('.glb', '.usdz');
    }
    if (path.startsWith('http://') ||
        path.startsWith('https://') ||
        path.startsWith('flutter_assets/')) {
      return path;
    }
    // Android AssetManager opens Flutter assets under flutter_assets/
    return 'flutter_assets/$path';
  }

  @override
  void initState() {
    super.initState();
    _sceneController = SceneViewController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final campaignProvider = context.read<CampaignProvider>();
      final arProvider = context.read<ArViewProvider>();

      CampaignModel? campaign = campaignProvider.selectedCampaign;
      if (campaign == null || campaign.id != widget.campaignId) {
        try {
          campaign = campaignProvider.campaigns.firstWhere((c) => c.id == widget.campaignId);
        } catch (_) {
          campaign = campaignProvider.campaigns.first;
        }
      }

      arProvider.startSession(campaign);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _arProvider = context.read<ArViewProvider>();
  }

  @override
  void dispose() {
    _scaleDebounce?.cancel();
    _arProvider?.endSession();
    _sceneController?.dispose();
    super.dispose();
  }

  Future<bool> _ensureCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      return true;
    }

    final result = await Permission.camera.request();
    if (result.isGranted) {
      return true;
    }

    if (!mounted) return false;

    if (result.isPermanentlyDenied) {
      _showSettingsDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera permission is required for AR mode. Switched to 3D Studio.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
    return false;
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Camera Permission Required', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'AR mode needs access to your camera to project 3D models in your space. Please enable camera permission in Settings.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Stay in 3D', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              Navigator.of(ctx).pop();
              openAppSettings();
            },
            child: const Text('Open Settings', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleViewMode() async {
    if (_useStudioFallback) {
      // Switching to AR mode: check permission first!
      final granted = await _ensureCameraPermission();
      if (!granted) {
        return;
      }
    }

    setState(() {
      _useStudioFallback = !_useStudioFallback;
      _sceneController?.dispose();
      _sceneController = SceneViewController();
    });
  }

  void _onSceneCreated() {
    if (!mounted) return;
    final arProvider = _arProvider ?? context.read<ArViewProvider>();
    final product = arProvider.activeProduct;
    if (product != null && _sceneController != null) {
      final effectivePath = _resolveModelPath(product.modelAssetPath);
      _lastLoadedScale = arProvider.scale;
      try {
        _sceneController!.loadModel(
          ModelNode(
            modelPath: effectivePath,
            scale: arProvider.scale,
            x: 0.0,
            y: _useStudioFallback ? 0.0 : -0.15,
            z: _useStudioFallback ? 0.0 : -0.85,
          ),
        );
      } catch (e) {
        debugPrint('SceneView loadModel error: $e');
      }
    }
  }

  void _applyScaleToScene(double newScale) {
    if ((newScale - _lastLoadedScale).abs() < 0.05) return;
    _scaleDebounce?.cancel();
    _scaleDebounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted || _sceneController == null) return;
      final arProvider = _arProvider ?? context.read<ArViewProvider>();
      final product = arProvider.activeProduct;
      if (product == null) return;

      final effectivePath = _resolveModelPath(product.modelAssetPath);
      _lastLoadedScale = newScale;
      try {
        _sceneController!.clearScene();
        _sceneController!.loadModel(
          ModelNode(
            modelPath: effectivePath,
            scale: newScale,
            x: 0.0,
            y: _useStudioFallback ? 0.0 : -0.15,
            z: _useStudioFallback ? 0.0 : -0.85,
          ),
        );
      } catch (e) {
        debugPrint('SceneView reloadModel error: $e');
      }
    });
  }

  void _handleShare(CampaignModel campaign) {
    SharePlus.instance.share(
      ShareParams(
        text: 'Check out ${campaign.product?.name ?? campaign.title} in AR on AR-AdVision!\n${campaign.offer?.ctaUrl ?? ""}',
        subject: campaign.title,
      ),
    );
  }

  void _handleBuyNow(CampaignModel campaign) async {
    context.read<ArViewProvider>().clickCta();
    final url = campaign.offer?.ctaUrl ?? campaign.product?.ctaLink ?? 'https://google.com';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Offer code ${campaign.offer?.code ?? "APPLIED"} copied to clipboard!'),
            backgroundColor: AppColors.secondary,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final arProvider = context.watch<ArViewProvider>();
    final campaign = arProvider.activeCampaign;
    final product = arProvider.activeProduct;

    if (campaign == null || product == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    // Apply scale changes via debounced reload pipeline
    if ((arProvider.scale - _lastLoadedScale).abs() >= 0.05) {
      _applyScaleToScene(arProvider.scale);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. AR SceneView (or fallback 3D Orbit Studio)
          // Passive Listener does not compete in the gesture arena, allowing
          // native touches to reach the SceneView platform view for orbit/zoom.
          Positioned.fill(
            child: Listener(
              onPointerMove: (_) => arProvider.markRotated(),
              onPointerDown: (_) => arProvider.markScaled(),
              child: _build3dOrArView(product.modelAssetPath),
            ),
          ),

          // 2. Detected Dotted Plane Grid Indicator
          if (arProvider.isPlaneDetected && !_useStudioFallback)
            Positioned(
              bottom: 240,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.secondary.withValues(alpha: 0.5)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.blur_on_rounded, color: AppColors.secondary, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Surface Tracking Active',
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 3. Floating Hotspots (Overlay on top of 3D Model)
          ...product.hotspots.map((hotspot) {
            return Positioned(
              top: MediaQuery.of(context).size.height * 0.38 + (hotspot.y * 500),
              left: MediaQuery.of(context).size.width * 0.5 + (hotspot.x * 500) - 20,
              child: GestureDetector(
                onTap: () => arProvider.selectHotspot(hotspot),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Center(
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),

          // 4. Top Glass HUD Overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ArHudOverlay(
              isTrackingLocked: arProvider.isPlaneDetected,
              isFlashOn: _isFlashOn,
              onBack: () => context.pop(),
              onToggleFlash: () => setState(() => _isFlashOn = !_isFlashOn),
              onShare: () => _handleShare(campaign),
            ),
          ),

          // 5. Floating AI Insight Pill (Groq AI Summary)
          if (arProvider.showAiInsight && product.aiSummary != null)
            Positioned(
              top: 110,
              left: 0,
              right: 0,
              child: AiInsightPill(
                text: product.aiSummary!,
                onTap: () {
                  context.push('/product/${campaign.id}');
                },
              ),
            ),

          // 6. View Mode Switcher Pill (AR Mode vs 3D Studio Mode)
          Positioned(
            top: 180,
            right: 16,
            child: GestureDetector(
              onTap: _toggleViewMode,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.hudGlassBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.hudGlassBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _useStudioFallback ? Icons.view_in_ar_rounded : Icons.threed_rotation_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _useStudioFallback ? 'Switch to AR' : '3D Studio',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 7. Bottom Control Sheet
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ArModelControls(
              product: product,
              offer: campaign.offer,
              selectedColorHex: arProvider.selectedColor,
              onColorSelected: (color) => arProvider.selectColor(color),
              activeHotspot: arProvider.activeHotspot,
              onDismissHotspot: () => arProvider.selectHotspot(null),
              onBuyNow: () => _handleBuyNow(campaign),
              onViewSpecs: () {
                context.push('/product/${campaign.id}');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _build3dOrArView(String modelPath) {
    if (_useStudioFallback || !_isArSupported) {
      return SceneView(
        key: const ValueKey('studio_3d_view'),
        controller: _sceneController,
        cameraControlMode: CameraControlMode.orbit,
        autoCenterContent: true,
        onViewCreated: _onSceneCreated,
      );
    }

    return ARSceneView(
      key: const ValueKey('ar_camera_view'),
      controller: _sceneController,
      planeDetection: true,
      onViewCreated: _onSceneCreated,
      onPlaneDetected: (planeType) {
        if (!mounted) return;
        (_arProvider ?? context.read<ArViewProvider>()).onPlaneDetected(true);
      },
      onTap: (nodeName) {
        debugPrint('Tapped model: $nodeName');
      },
    );
  }
}
