import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/campaign_model.dart';
import '../seed_data.dart';
import 'product_repository.dart';
import '../../services/firebase_service.dart';

class CampaignRepository {
  final FirebaseService _firebaseService = FirebaseService();
  final ProductRepository _productRepository = ProductRepository();
  List<CampaignModel> _cachedCampaigns = [];

  List<CampaignModel> get cachedCampaigns =>
      _cachedCampaigns.isEmpty ? SeedData.defaultCampaigns : _cachedCampaigns;

  /// Fetch all active campaigns
  Future<List<CampaignModel>> getActiveCampaigns({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedCampaigns.isNotEmpty) {
      return _cachedCampaigns;
    }

    try {
      final snapshot = await _firebaseService.campaignsRef.get();
      if (snapshot.docs.isNotEmpty) {
        final List<CampaignModel> list = [];
        for (final doc in snapshot.docs) {
          final data = Map<String, dynamic>.from(doc.data() as Map);
          final productId = data['productId'] as String? ?? '';
          final product = await _productRepository.getProductById(productId);
          list.add(CampaignModel.fromMap(data, doc.id, product: product));
        }
        _cachedCampaigns = list;
        return _cachedCampaigns;
      }
    } catch (e) {
      debugPrint('CampaignRepository fetch error: $e');
    }

    _cachedCampaigns = List.from(SeedData.defaultCampaigns);
    return _cachedCampaigns;
  }

  /// Fetch campaign by Campaign ID
  Future<CampaignModel?> getCampaignById(String id) async {
    final list = await getActiveCampaigns();
    try {
      return list.firstWhere((c) => c.id == id);
    } catch (_) {
      try {
        final doc = await _firebaseService.campaignsRef.doc(id).get();
        if (doc.exists && doc.data() != null) {
          final data = Map<String, dynamic>.from(doc.data() as Map);
          final productId = data['productId'] as String? ?? '';
          final product = await _productRepository.getProductById(productId);
          return CampaignModel.fromMap(data, doc.id, product: product);
        }
      } catch (e) {
        debugPrint('CampaignRepository getById error: $e');
      }
    }
    return null;
  }

  /// Fetch campaigns created by a specific advertiser
  Future<List<CampaignModel>> getAdvertiserCampaigns(String advertiserId) async {
    final list = await getActiveCampaigns();
    final filtered = list.where((c) => c.advertiserId == advertiserId).toList();
    if (filtered.isNotEmpty) return filtered;
    // Fallback: return default list for demo advertiser
    return list;
  }

  /// Create a new campaign
  Future<CampaignModel> createCampaign(CampaignModel campaign) async {
    try {
      final docRef = await _firebaseService.campaignsRef.add(campaign.toMap());
      final savedCampaign = CampaignModel.fromMap(
        campaign.toMap(),
        docRef.id,
        product: campaign.product,
      );
      _cachedCampaigns.insert(0, savedCampaign);
      return savedCampaign;
    } catch (e) {
      debugPrint('CampaignRepository create error: $e');
      _cachedCampaigns.insert(0, campaign);
      return campaign;
    }
  }

  /// Increment scan count & update interaction stats
  Future<void> recordCampaignScan(String campaignId) async {
    // Update local cache
    final index = _cachedCampaigns.indexWhere((c) => c.id == campaignId);
    if (index != -1) {
      final c = _cachedCampaigns[index];
      _cachedCampaigns[index] = c.copyWith(
        scanCount: c.scanCount + 1,
        uniqueViewCount: c.uniqueViewCount + 1,
      );
    }

    try {
      await _firebaseService.campaignsRef.doc(campaignId).update({
        'scanCount': FieldValue.increment(1),
        'uniqueViewCount': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('recordCampaignScan remote error: $e');
    }
  }

  /// Update campaign status (e.g. active, paused)
  Future<void> updateCampaignStatus(String campaignId, String status) async {
    final index = _cachedCampaigns.indexWhere((c) => c.id == campaignId);
    if (index != -1) {
      _cachedCampaigns[index] = _cachedCampaigns[index].copyWith(status: status);
    }
    try {
      await _firebaseService.campaignsRef.doc(campaignId).update({'status': status});
    } catch (e) {
      debugPrint('updateCampaignStatus error: $e');
    }
  }
}
