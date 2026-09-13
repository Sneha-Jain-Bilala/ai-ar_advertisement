import 'offer_model.dart';
import 'product_model.dart';

class CampaignModel {
  final String id;
  final String advertiserId;
  final String title;
  final String description;
  final String status; // 'active', 'paused', 'scheduled', 'draft'
  final DateTime startDate;
  final DateTime endDate;
  final String productId;
  final ProductModel? product;
  final OfferModel? offer;
  final String qrPayload;
  final String? qrImageUrl;
  final int scanCount;
  final int uniqueViewCount;
  final int avgDwellTimeSeconds;
  final double interactionRate; // e.g. 64.2%
  final double budget;
  final double spend;
  final DateTime createdAt;

  CampaignModel({
    required this.id,
    required this.advertiserId,
    required this.title,
    required this.description,
    this.status = 'active',
    required this.startDate,
    required this.endDate,
    required this.productId,
    this.product,
    this.offer,
    required this.qrPayload,
    this.qrImageUrl,
    this.scanCount = 0,
    this.uniqueViewCount = 0,
    this.avgDwellTimeSeconds = 0,
    this.interactionRate = 0.0,
    this.budget = 1000.0,
    this.spend = 0.0,
    required this.createdAt,
  });

  bool get isActive => status == 'active' && DateTime.now().isBefore(endDate);
  int get daysLeft => endDate.difference(DateTime.now()).inDays.clamp(0, 365);

  factory CampaignModel.fromMap(Map<String, dynamic> map, String id, {ProductModel? product}) {
    return CampaignModel(
      id: id,
      advertiserId: map['advertiserId'] as String? ?? '',
      title: map['title'] as String? ?? 'Campaign',
      description: map['description'] as String? ?? '',
      status: map['status'] as String? ?? 'active',
      startDate: map['startDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['startDate'] as int)
          : DateTime.now(),
      endDate: map['endDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['endDate'] as int)
          : DateTime.now().add(const Duration(days: 30)),
      productId: map['productId'] as String? ?? '',
      product: product ?? (map['product'] != null ? ProductModel.fromMap(Map<String, dynamic>.from(map['product'] as Map), map['productId'] ?? '') : null),
      offer: map['offer'] != null ? OfferModel.fromMap(Map<String, dynamic>.from(map['offer'] as Map)) : null,
      qrPayload: map['qrPayload'] as String? ?? '',
      qrImageUrl: map['qrImageUrl'] as String?,
      scanCount: (map['scanCount'] as num?)?.toInt() ?? 0,
      uniqueViewCount: (map['uniqueViewCount'] as num?)?.toInt() ?? 0,
      avgDwellTimeSeconds: (map['avgDwellTimeSeconds'] as num?)?.toInt() ?? 0,
      interactionRate: (map['interactionRate'] as num?)?.toDouble() ?? 0.0,
      budget: (map['budget'] as num?)?.toDouble() ?? 1000.0,
      spend: (map['spend'] as num?)?.toDouble() ?? 0.0,
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'advertiserId': advertiserId,
      'title': title,
      'description': description,
      'status': status,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch,
      'productId': productId,
      'product': product?.toMap(),
      'offer': offer?.toMap(),
      'qrPayload': qrPayload,
      'qrImageUrl': qrImageUrl,
      'scanCount': scanCount,
      'uniqueViewCount': uniqueViewCount,
      'avgDwellTimeSeconds': avgDwellTimeSeconds,
      'interactionRate': interactionRate,
      'budget': budget,
      'spend': spend,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  CampaignModel copyWith({
    String? title,
    String? description,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    String? productId,
    ProductModel? product,
    OfferModel? offer,
    String? qrPayload,
    String? qrImageUrl,
    int? scanCount,
    int? uniqueViewCount,
    int? avgDwellTimeSeconds,
    double? interactionRate,
    double? budget,
    double? spend,
  }) {
    return CampaignModel(
      id: id,
      advertiserId: advertiserId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      productId: productId ?? this.productId,
      product: product ?? this.product,
      offer: offer ?? this.offer,
      qrPayload: qrPayload ?? this.qrPayload,
      qrImageUrl: qrImageUrl ?? this.qrImageUrl,
      scanCount: scanCount ?? this.scanCount,
      uniqueViewCount: uniqueViewCount ?? this.uniqueViewCount,
      avgDwellTimeSeconds: avgDwellTimeSeconds ?? this.avgDwellTimeSeconds,
      interactionRate: interactionRate ?? this.interactionRate,
      budget: budget ?? this.budget,
      spend: spend ?? this.spend,
      createdAt: createdAt,
    );
  }
}
