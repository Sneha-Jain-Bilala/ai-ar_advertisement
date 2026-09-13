/// AR Target Model — Maps QR codes to campaigns/products
/// Used in the `ar_targets` Firestore collection for quick QR → Campaign resolution
class ArTargetModel {
  final String id;
  final String campaignId;
  final String productId;
  final String qrData; // Encoded campaign/product payload
  final String modelPath; // Local asset path or Firebase Storage URL
  final DateTime createdAt;
  final bool isActive;

  ArTargetModel({
    required this.id,
    required this.campaignId,
    required this.productId,
    required this.qrData,
    required this.modelPath,
    DateTime? createdAt,
    this.isActive = true,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ArTargetModel.fromMap(Map<String, dynamic> map, String id) {
    return ArTargetModel(
      id: id,
      campaignId: map['campaignId'] as String? ?? '',
      productId: map['productId'] as String? ?? '',
      qrData: map['qrData'] as String? ?? '',
      modelPath: map['modelPath'] as String? ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
          : DateTime.now(),
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'campaignId': campaignId,
      'productId': productId,
      'qrData': qrData,
      'modelPath': modelPath,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isActive': isActive,
    };
  }

  ArTargetModel copyWith({
    String? campaignId,
    String? productId,
    String? qrData,
    String? modelPath,
    bool? isActive,
  }) {
    return ArTargetModel(
      id: id,
      campaignId: campaignId ?? this.campaignId,
      productId: productId ?? this.productId,
      qrData: qrData ?? this.qrData,
      modelPath: modelPath ?? this.modelPath,
      createdAt: createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
