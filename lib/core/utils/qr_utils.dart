import 'dart:convert';

class QrUtils {
  static const String qrPrefix = 'arvision://campaign/';

  /// Encodes campaign ID into standard AR-AdVision QR payload
  static String generateCampaignPayload(String campaignId, {String? productId}) {
    final payload = <String, dynamic>{
      'app': 'arvision',
      'campaignId': campaignId,
      't': DateTime.now().millisecondsSinceEpoch,
    };
    if (productId != null) {
      payload['productId'] = productId;
    }
    return '$qrPrefix${base64Url.encode(utf8.encode(jsonEncode(payload)))}';
  }

  /// Parses scanned string to extract campaignId
  static String? extractCampaignId(String rawData) {
    final trimmed = rawData.trim();
    if (trimmed.startsWith(qrPrefix)) {
      try {
        final encoded = trimmed.substring(qrPrefix.length);
        final decoded = utf8.decode(base64Url.decode(encoded));
        final map = jsonDecode(decoded) as Map<String, dynamic>;
        return map['campaignId'] as String?;
      } catch (_) {
        // Fallback: raw ID passed after prefix
        return trimmed.substring(qrPrefix.length);
      }
    }

    // Try direct JSON
    if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
      try {
        final map = jsonDecode(trimmed) as Map<String, dynamic>;
        return map['campaignId'] ?? map['id'];
      } catch (_) {}
    }

    // Otherwise assume the raw string might be the campaign ID itself
    if (trimmed.isNotEmpty && !trimmed.contains(' ') && trimmed.length > 3) {
      return trimmed;
    }

    return null;
  }
}
