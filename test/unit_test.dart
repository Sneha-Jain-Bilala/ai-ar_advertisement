import 'package:flutter_test/flutter_test.dart';
import 'package:ai_ar_advertisement/core/utils/qr_utils.dart';
import 'package:ai_ar_advertisement/core/utils/formatters.dart';
import 'package:ai_ar_advertisement/data/seed_data.dart';
import 'package:ai_ar_advertisement/data/models/campaign_model.dart';
import 'package:ai_ar_advertisement/data/models/product_model.dart';
import 'package:ai_ar_advertisement/providers/auth_provider.dart';

void main() {
  group('QrUtils Tests', () {
    test('Encodes and extracts campaign ID correctly', () {
      const campaignId = 'camp_summer_runner_123';
      final payload = QrUtils.generateCampaignPayload(campaignId, productId: 'prod_shoe_01');
      expect(payload.startsWith(QrUtils.qrPrefix), isTrue);

      final extractedId = QrUtils.extractCampaignId(payload);
      expect(extractedId, equals(campaignId));
    });

    test('Extracts direct raw campaign ID correctly', () {
      const rawId = 'camp_aeroglide_summer';
      final extractedId = QrUtils.extractCampaignId(rawId);
      expect(extractedId, equals(rawId));
    });
  });

  group('Formatters Tests', () {
    test('Currency formatting', () {
      expect(Formatters.formatCurrency(189.99), equals('\$189.99'));
      expect(Formatters.formatCurrency(3.5), equals('\$3.50'));
    });

    test('Duration formatting', () {
      expect(Formatters.formatDuration(45), equals('45s'));
      expect(Formatters.formatDuration(84), equals('1m 24s'));
      expect(Formatters.formatDuration(120), equals('2m 0s'));
    });
  });

  group('SeedData & Data Models Tests', () {
    test('Default products list contains 5 rich 3D items', () {
      expect(SeedData.defaultProducts.length, equals(5));
      for (final p in SeedData.defaultProducts) {
        expect(p.modelAssetPath, isNotEmpty);
        expect(p.price, isPositive);
        expect(p.hotspots, isNotEmpty);
      }
    });

    test('Default campaigns list contains active campaigns with valid products', () {
      final campaigns = SeedData.defaultCampaigns;
      expect(campaigns.length, equals(5));
      for (final c in campaigns) {
        expect(c.qrPayload, isNotEmpty);
        expect(c.product, isNotNull);
        expect(c.isActive, isTrue);
      }
    });

    test('ProductModel serialization round-trip', () {
      final original = SeedData.defaultProducts.first;
      final map = original.toMap();
      final reconstructed = ProductModel.fromMap(map, original.id);
      expect(reconstructed.id, equals(original.id));
      expect(reconstructed.name, equals(original.name));
      expect(reconstructed.price, equals(original.price));
      expect(reconstructed.modelAssetPath, equals(original.modelAssetPath));
    });

    test('CampaignModel serialization round-trip', () {
      final original = SeedData.defaultCampaigns.first;
      final map = original.toMap();
      final reconstructed = CampaignModel.fromMap(map, original.id, product: original.product);
      expect(reconstructed.id, equals(original.id));
      expect(reconstructed.title, equals(original.title));
      expect(reconstructed.scanCount, equals(original.scanCount));
    });
  });

  group('AuthProvider Tests', () {
    test('Initial state has default explorer user', () {
      final auth = AuthProvider();
      expect(auth.isAuthenticated, isTrue);
      expect(auth.isConsumer, isTrue);
      expect(auth.isAdvertiser, isFalse);
    });

    test('Switch role updates state', () {
      final auth = AuthProvider();
      auth.switchRole('advertiser');
      expect(auth.isAdvertiser, isTrue);
      expect(auth.isConsumer, isFalse);

      auth.switchRole('admin');
      expect(auth.isAdmin, isTrue);
    });

    test('Bookmark ad toggling', () {
      final auth = AuthProvider();
      const testAd = 'camp_test_ad_99';
      expect(auth.isAdSaved(testAd), isFalse);

      auth.toggleSaveAd(testAd);
      expect(auth.isAdSaved(testAd), isTrue);

      auth.toggleSaveAd(testAd);
      expect(auth.isAdSaved(testAd), isFalse);
    });
  });
}
