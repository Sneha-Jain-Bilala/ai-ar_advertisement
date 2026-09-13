import 'package:flutter/material.dart';
import '../data/models/campaign_model.dart';
import '../data/models/product_model.dart';
import '../data/repositories/analytics_repository.dart';
import '../data/repositories/campaign_repository.dart';
import '../data/repositories/product_repository.dart';
import '../services/groq_service.dart';

class AdvertiserProvider extends ChangeNotifier {
  final CampaignRepository _campaignRepository = CampaignRepository();
  final ProductRepository _productRepository = ProductRepository();
  final AnalyticsRepository _analyticsRepository = AnalyticsRepository();
  final GroqService _groqService = GroqService();

  List<CampaignModel> _myCampaigns = [];
  List<ProductModel> _myProducts = [];
  bool _isLoading = false;
  bool _isGeneratingAiCopy = false;

  List<CampaignModel> get myCampaigns => _myCampaigns;
  List<ProductModel> get myProducts => _myProducts;
  bool get isLoading => _isLoading;
  bool get isGeneratingAiCopy => _isGeneratingAiCopy;

  Map<String, dynamic> get kpiMetrics =>
      _analyticsRepository.computeOverviewMetrics(_myCampaigns);

  List<DailyMetric> get weeklyTrend => _analyticsRepository.getWeeklyTrend();

  AdvertiserProvider() {
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    _myProducts = await _productRepository.getProducts();
    _myCampaigns = await _campaignRepository.getActiveCampaigns();

    _isLoading = false;
    notifyListeners();
  }

  /// Use Groq Llama 3 to generate campaign headline and copy
  Future<Map<String, String>> generateAiCopy({
    required String productName,
    required String brand,
    required String goal,
  }) async {
    _isGeneratingAiCopy = true;
    notifyListeners();

    final copy = await _groqService.generateCampaignCopy(
      productName: productName,
      brand: brand,
      campaignGoal: goal,
    );

    _isGeneratingAiCopy = false;
    notifyListeners();
    return copy;
  }

  /// Create a new AR campaign
  Future<CampaignModel> createCampaign(CampaignModel campaign) async {
    _isLoading = true;
    notifyListeners();

    final created = await _campaignRepository.createCampaign(campaign);
    _myCampaigns.insert(0, created);

    _isLoading = false;
    notifyListeners();
    return created;
  }

  /// Toggle pause / resume campaign
  Future<void> toggleCampaignStatus(String campaignId) async {
    final index = _myCampaigns.indexWhere((c) => c.id == campaignId);
    if (index != -1) {
      final current = _myCampaigns[index];
      final newStatus = current.status == 'active' ? 'paused' : 'active';
      _myCampaigns[index] = current.copyWith(status: newStatus);
      notifyListeners();
      await _campaignRepository.updateCampaignStatus(campaignId, newStatus);
    }
  }
}
