import 'package:flutter/material.dart';
import '../core/utils/qr_utils.dart';
import '../data/models/campaign_model.dart';
import '../data/repositories/campaign_repository.dart';
import '../data/repositories/product_repository.dart';

class CampaignProvider extends ChangeNotifier {
  final CampaignRepository _campaignRepository = CampaignRepository();
  final ProductRepository _productRepository = ProductRepository();

  List<CampaignModel> _campaigns = [];
  bool _isLoading = false;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  CampaignModel? _selectedCampaign;

  List<CampaignModel> get campaigns => _campaigns;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  CampaignModel? get selectedCampaign => _selectedCampaign;

  List<CampaignModel> get filteredCampaigns {
    return _campaigns.where((c) {
      final matchesCategory = _selectedCategory == 'All' ||
          (c.product?.category.toLowerCase() == _selectedCategory.toLowerCase());
      final matchesSearch = _searchQuery.isEmpty ||
          c.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (c.product?.name.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          (c.product?.brand.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  List<CampaignModel> get trendingCampaigns {
    final list = List<CampaignModel>.from(_campaigns);
    list.sort((a, b) => b.scanCount.compareTo(a.scanCount));
    return list;
  }

  CampaignProvider() {
    loadCampaigns();
  }

  Future<void> loadCampaigns({bool forceRefresh = false}) async {
    _isLoading = true;
    notifyListeners();

    _campaigns = await _campaignRepository.getActiveCampaigns(forceRefresh: forceRefresh);
    _isLoading = false;
    notifyListeners();
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void selectCampaign(CampaignModel campaign) {
    _selectedCampaign = campaign;
    notifyListeners();
  }

  /// Resolve campaign from raw scanned QR data
  Future<CampaignModel?> resolveQrCode(String rawQrData) async {
    final campaignId = QrUtils.extractCampaignId(rawQrData);
    if (campaignId == null) return null;

    final campaign = await _campaignRepository.getCampaignById(campaignId);
    if (campaign != null) {
      _selectedCampaign = campaign;
      await _campaignRepository.recordCampaignScan(campaign.id);
      notifyListeners();
      return campaign;
    }
    return null;
  }
}
