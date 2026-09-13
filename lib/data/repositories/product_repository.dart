import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../seed_data.dart';
import '../../services/firebase_service.dart';

class ProductRepository {
  final FirebaseService _firebaseService = FirebaseService();
  List<ProductModel> _cachedProducts = [];

  List<ProductModel> get cachedProducts => _cachedProducts.isEmpty ? SeedData.defaultProducts : _cachedProducts;

  /// Get all available products
  Future<List<ProductModel>> getProducts({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedProducts.isNotEmpty) {
      return _cachedProducts;
    }

    try {
      final snapshot = await _firebaseService.productsRef.get();
      if (snapshot.docs.isNotEmpty) {
        _cachedProducts = snapshot.docs.map((doc) {
          return ProductModel.fromMap(
            Map<String, dynamic>.from(doc.data() as Map),
            doc.id,
          );
        }).toList();
        return _cachedProducts;
      }
    } catch (e) {
      debugPrint('ProductRepository fetch error: $e');
    }

    // Default to seed products if remote is empty
    _cachedProducts = List.from(SeedData.defaultProducts);
    return _cachedProducts;
  }

  /// Get product by ID
  Future<ProductModel?> getProductById(String id) async {
    final list = await getProducts();
    try {
      return list.firstWhere((p) => p.id == id);
    } catch (_) {
      try {
        final doc = await _firebaseService.productsRef.doc(id).get();
        if (doc.exists && doc.data() != null) {
          return ProductModel.fromMap(
            Map<String, dynamic>.from(doc.data() as Map),
            doc.id,
          );
        }
      } catch (e) {
        debugPrint('ProductRepository getById error: $e');
      }
    }
    return null;
  }

  /// Add a new product to Firestore
  Future<ProductModel> addProduct(ProductModel product) async {
    try {
      final docRef = await _firebaseService.productsRef.add(product.toMap());
      final newProduct = product.copyWith();
      _cachedProducts.add(ProductModel.fromMap(newProduct.toMap(), docRef.id));
      return ProductModel.fromMap(newProduct.toMap(), docRef.id);
    } catch (e) {
      debugPrint('ProductRepository add error: $e');
      _cachedProducts.add(product);
      return product;
    }
  }
}
