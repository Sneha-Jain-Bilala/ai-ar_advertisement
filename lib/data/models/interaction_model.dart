class InteractionModel {
  final String id;
  final String campaignId;
  final String productId;
  final String userId;
  final DateTime timestamp;
  final int dwellTimeSeconds;
  final bool rotated3D;
  final bool scaled3D;
  final List<String> tappedHotspots;
  final bool claimedOffer;
  final bool clickedCta;
  final String? deviceModel;

  InteractionModel({
    required this.id,
    required this.campaignId,
    required this.productId,
    required this.userId,
    required this.timestamp,
    this.dwellTimeSeconds = 0,
    this.rotated3D = false,
    this.scaled3D = false,
    this.tappedHotspots = const [],
    this.claimedOffer = false,
    this.clickedCta = false,
    this.deviceModel,
  });

  factory InteractionModel.fromMap(Map<String, dynamic> map, String id) {
    return InteractionModel(
      id: id,
      campaignId: map['campaignId'] as String? ?? '',
      productId: map['productId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int)
          : DateTime.now(),
      dwellTimeSeconds: (map['dwellTimeSeconds'] as num?)?.toInt() ?? 0,
      rotated3D: map['rotated3D'] as bool? ?? false,
      scaled3D: map['scaled3D'] as bool? ?? false,
      tappedHotspots: List<String>.from(map['tappedHotspots'] as List? ?? []),
      claimedOffer: map['claimedOffer'] as bool? ?? false,
      clickedCta: map['clickedCta'] as bool? ?? false,
      deviceModel: map['deviceModel'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'campaignId': campaignId,
      'productId': productId,
      'userId': userId,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'dwellTimeSeconds': dwellTimeSeconds,
      'rotated3D': rotated3D,
      'scaled3D': scaled3D,
      'tappedHotspots': tappedHotspots,
      'claimedOffer': claimedOffer,
      'clickedCta': clickedCta,
      'deviceModel': deviceModel,
    };
  }
}
