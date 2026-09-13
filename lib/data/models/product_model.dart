class HotspotInfo {
  final String id;
  final String title;
  final String description;
  final double x;
  final double y;
  final double z;

  HotspotInfo({
    required this.id,
    required this.title,
    required this.description,
    this.x = 0.0,
    this.y = 0.0,
    this.z = 0.0,
  });

  factory HotspotInfo.fromMap(Map<String, dynamic> map) {
    return HotspotInfo(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      x: (map['x'] as num?)?.toDouble() ?? 0.0,
      y: (map['y'] as num?)?.toDouble() ?? 0.0,
      z: (map['z'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'x': x,
      'y': y,
      'z': z,
    };
  }
}

class ProductModel {
  final String id;
  final String name;
  final String brand;
  final String category;
  final String description;
  final double price;
  final String modelAssetPath; // Local asset e.g. assets/models/shoe.glb
  final String? modelUrl; // Remote storage url
  final String? thumbnailUrl;
  final Map<String, String> specifications;
  final List<HotspotInfo> hotspots;
  final List<String> availableColors;
  final String? aiSummary;
  final double rating;
  final int reviewCount;
  final String? ctaLink;

  ProductModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.description,
    required this.price,
    required this.modelAssetPath,
    this.modelUrl,
    this.thumbnailUrl,
    this.specifications = const {},
    this.hotspots = const [],
    this.availableColors = const ['#7C9FE5', '#A8D8B9', '#1E2432'],
    this.aiSummary,
    this.rating = 4.8,
    this.reviewCount = 124,
    this.ctaLink,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map, String id) {
    return ProductModel(
      id: id,
      name: map['name'] as String? ?? 'Product',
      brand: map['brand'] as String? ?? 'Brand',
      category: map['category'] as String? ?? 'General',
      description: map['description'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      modelAssetPath: map['modelAssetPath'] as String? ?? 'assets/models/shoe.glb',
      modelUrl: map['modelUrl'] as String?,
      thumbnailUrl: map['thumbnailUrl'] as String?,
      specifications: Map<String, String>.from(map['specifications'] as Map? ?? {}),
      hotspots: (map['hotspots'] as List? ?? [])
          .map((h) => HotspotInfo.fromMap(Map<String, dynamic>.from(h as Map)))
          .toList(),
      availableColors: List<String>.from(map['availableColors'] as List? ?? []),
      aiSummary: map['aiSummary'] as String?,
      rating: (map['rating'] as num?)?.toDouble() ?? 4.8,
      reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 120,
      ctaLink: map['ctaLink'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'brand': brand,
      'category': category,
      'description': description,
      'price': price,
      'modelAssetPath': modelAssetPath,
      'modelUrl': modelUrl,
      'thumbnailUrl': thumbnailUrl,
      'specifications': specifications,
      'hotspots': hotspots.map((h) => h.toMap()).toList(),
      'availableColors': availableColors,
      'aiSummary': aiSummary,
      'rating': rating,
      'reviewCount': reviewCount,
      'ctaLink': ctaLink,
    };
  }

  ProductModel copyWith({
    String? name,
    String? brand,
    String? category,
    String? description,
    double? price,
    String? modelAssetPath,
    String? modelUrl,
    String? thumbnailUrl,
    Map<String, String>? specifications,
    List<HotspotInfo>? hotspots,
    List<String>? availableColors,
    String? aiSummary,
    double? rating,
    int? reviewCount,
    String? ctaLink,
  }) {
    return ProductModel(
      id: id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      description: description ?? this.description,
      price: price ?? this.price,
      modelAssetPath: modelAssetPath ?? this.modelAssetPath,
      modelUrl: modelUrl ?? this.modelUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      specifications: specifications ?? this.specifications,
      hotspots: hotspots ?? this.hotspots,
      availableColors: availableColors ?? this.availableColors,
      aiSummary: aiSummary ?? this.aiSummary,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      ctaLink: ctaLink ?? this.ctaLink,
    );
  }
}
