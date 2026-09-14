class AppConstants {
  static const String appName = 'AR-AdVision';
  static const String appTagline = 'Bring Everyday Ads to Life in AR';
  static const String appVersion = '1.0.0';

  // 3D Model Matched Categories
  static const List<String> categories = [
    'All',
    'Fashion',
    'Accessories',
    'Beverages',
    'Electronics',
  ];

  // User Roles
  static const String roleConsumer = 'consumer';
  static const String roleAdvertiser = 'advertiser';
  static const String roleAdmin = 'admin';

  // Asset Models Mapping
  static const Map<String, String> default3DModels = {
    'shoe': 'assets/models/shoe.glb',
    'sunglasses': 'assets/models/sunglasses.glb',
    'beverage': 'assets/models/beverage.glb',
    'watch': 'assets/models/watch.glb',
    'boombox': 'assets/models/boombox.glb',
  };
}
