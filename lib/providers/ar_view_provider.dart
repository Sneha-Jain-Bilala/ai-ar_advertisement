import 'dart:async';
import 'package:flutter/material.dart';
import '../data/models/campaign_model.dart';
import '../data/models/interaction_model.dart';
import '../data/models/product_model.dart';
import '../data/repositories/analytics_repository.dart';

class ArViewProvider extends ChangeNotifier {
  final AnalyticsRepository _analyticsRepository = AnalyticsRepository();

  CampaignModel? _activeCampaign;
  ProductModel? _activeProduct;

  bool _isPlaneDetected = true; // Set to true initially or after brief scanning
  bool _isModelPlaced = true;
  double _scale = 1.0;
  double _rotationDegrees = 0.0;
  String _selectedColor = '#7C9FE5';
  HotspotInfo? _activeHotspot;
  bool _showAiInsight = true;

  // Telemetry session state
  int _dwellTimeSeconds = 0;
  Timer? _dwellTimer;
  bool _hasRotated = false;
  bool _hasScaled = false;
  final List<String> _tappedHotspots = [];
  bool _hasClaimedOffer = false;
  bool _hasClickedCta = false;

  // Getters
  CampaignModel? get activeCampaign => _activeCampaign;
  ProductModel? get activeProduct => _activeProduct;
  bool get isPlaneDetected => _isPlaneDetected;
  bool get isModelPlaced => _isModelPlaced;
  double get scale => _scale;
  double get rotationDegrees => _rotationDegrees;
  String get selectedColor => _selectedColor;
  HotspotInfo? get activeHotspot => _activeHotspot;
  bool get showAiInsight => _showAiInsight;
  int get dwellTimeSeconds => _dwellTimeSeconds;

  void startSession(CampaignModel campaign) {
    _activeCampaign = campaign;
    _activeProduct = campaign.product;
    _scale = 1.0;
    _rotationDegrees = 0.0;
    _isPlaneDetected = true;
    _isModelPlaced = true;
    _activeHotspot = null;
    _showAiInsight = true;
    _dwellTimeSeconds = 0;
    _hasRotated = false;
    _hasScaled = false;
    _tappedHotspots.clear();
    _hasClaimedOffer = false;
    _hasClickedCta = false;

    if (_activeProduct?.availableColors.isNotEmpty ?? false) {
      _selectedColor = _activeProduct!.availableColors.first;
    }

    _startDwellTimer();
    notifyListeners();
  }

  void _startDwellTimer() {
    _dwellTimer?.cancel();
    _dwellTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _dwellTimeSeconds++;
      notifyListeners();
    });
  }

  void endSession() {
    _dwellTimer?.cancel();
    if (_activeCampaign != null && _activeProduct != null) {
      final interaction = InteractionModel(
        id: 'int_${DateTime.now().millisecondsSinceEpoch}',
        campaignId: _activeCampaign!.id,
        productId: _activeProduct!.id,
        userId: 'user_active',
        timestamp: DateTime.now(),
        dwellTimeSeconds: _dwellTimeSeconds,
        rotated3D: _hasRotated,
        scaled3D: _hasScaled,
        tappedHotspots: List.from(_tappedHotspots),
        claimedOffer: _hasClaimedOffer,
        clickedCta: _hasClickedCta,
      );
      _analyticsRepository.logInteraction(interaction);
    }
  }

  void onPlaneDetected(bool detected) {
    _isPlaneDetected = detected;
    notifyListeners();
  }

  void placeModel() {
    _isModelPlaced = true;
    notifyListeners();
  }

  void rotateModel(double deltaDegrees) {
    _rotationDegrees = (_rotationDegrees + deltaDegrees) % 360;
    _hasRotated = true;
    notifyListeners();
  }

  void scaleModel(double newScale) {
    _scale = newScale.clamp(0.4, 2.5);
    _hasScaled = true;
    notifyListeners();
  }

  void selectColor(String colorHex) {
    _selectedColor = colorHex;
    notifyListeners();
  }

  void selectHotspot(HotspotInfo? hotspot) {
    _activeHotspot = hotspot;
    if (hotspot != null && !_tappedHotspots.contains(hotspot.id)) {
      _tappedHotspots.add(hotspot.id);
    }
    notifyListeners();
  }

  void toggleAiInsight() {
    _showAiInsight = !_showAiInsight;
    notifyListeners();
  }

  void claimOffer() {
    _hasClaimedOffer = true;
    notifyListeners();
  }

  void clickCta() {
    _hasClickedCta = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _dwellTimer?.cancel();
    super.dispose();
  }
}
