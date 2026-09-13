class OfferModel {
  final String id;
  final String title;
  final String description;
  final String code;
  final double discountPercentage;
  final double? discountAmount;
  final DateTime expiryDate;
  final String? ctaUrl;
  final bool isClaimed;

  OfferModel({
    required this.id,
    required this.title,
    required this.description,
    required this.code,
    this.discountPercentage = 20.0,
    this.discountAmount,
    required this.expiryDate,
    this.ctaUrl,
    this.isClaimed = false,
  });

  bool get isExpired => DateTime.now().isAfter(expiryDate);

  factory OfferModel.fromMap(Map<String, dynamic> map, [String? id]) {
    return OfferModel(
      id: id ?? map['id'] as String? ?? '',
      title: map['title'] as String? ?? 'Special Offer',
      description: map['description'] as String? ?? '',
      code: map['code'] as String? ?? 'ARVISION20',
      discountPercentage: (map['discountPercentage'] as num?)?.toDouble() ?? 20.0,
      discountAmount: (map['discountAmount'] as num?)?.toDouble(),
      expiryDate: map['expiryDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['expiryDate'] as int)
          : DateTime.now().add(const Duration(days: 7)),
      ctaUrl: map['ctaUrl'] as String?,
      isClaimed: map['isClaimed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'code': code,
      'discountPercentage': discountPercentage,
      'discountAmount': discountAmount,
      'expiryDate': expiryDate.millisecondsSinceEpoch,
      'ctaUrl': ctaUrl,
      'isClaimed': isClaimed,
    };
  }

  OfferModel copyWith({
    String? title,
    String? description,
    String? code,
    double? discountPercentage,
    double? discountAmount,
    DateTime? expiryDate,
    String? ctaUrl,
    bool? isClaimed,
  }) {
    return OfferModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      code: code ?? this.code,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      discountAmount: discountAmount ?? this.discountAmount,
      expiryDate: expiryDate ?? this.expiryDate,
      ctaUrl: ctaUrl ?? this.ctaUrl,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }
}
