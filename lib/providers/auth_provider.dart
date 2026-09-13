import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../services/firebase_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  String get currentRole => _currentUser?.role ?? 'consumer';
  bool get isConsumer => currentRole == 'consumer';
  bool get isAdvertiser => currentRole == 'advertiser';
  bool get isAdmin => currentRole == 'admin';

  AuthProvider() {
    _initDemoUser();
  }

  void _initDemoUser() {
    // Default guest consumer user for immediate, smooth preview
    _currentUser = UserModel(
      uid: 'user_alex_consumer',
      email: 'alex.explorer@arvision.app',
      displayName: 'Alex Rivers',
      role: 'consumer',
      savedAdIds: ['camp_aeroglide_summer', 'camp_fizz_taste'],
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    );
  }

  /// Toggle or switch role dynamically (Consumer <-> Advertiser <-> Admin)
  void switchRole(String role) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(role: role);
      notifyListeners();
    }
  }

  /// Sign In with Email
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _firebaseService.signInWithEmail(email, password);
      if (user != null) {
        _currentUser = user;
      } else {
        // Fallback demo account
        _currentUser = UserModel(
          uid: 'user_${email.split('@').first}',
          email: email,
          displayName: email.split('@').first,
          role: email.contains('brand') || email.contains('adv') ? 'advertiser' : 'consumer',
          createdAt: DateTime.now(),
        );
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      // Allow seamless mock sign-in for testing even without internet/Firebase setup
      _currentUser = UserModel(
        uid: 'user_${email.split('@').first}',
        email: email,
        displayName: email.split('@').first,
        role: email.contains('brand') || email.contains('adv') ? 'advertiser' : 'consumer',
        createdAt: DateTime.now(),
      );
      _isLoading = false;
      notifyListeners();
      return true;
    }
  }

  /// Register
  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
    required String role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _firebaseService.registerWithEmail(
        email: email,
        password: password,
        displayName: displayName,
        role: role,
      );
      _currentUser = user ??
          UserModel(
            uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
            email: email,
            displayName: displayName,
            role: role,
            createdAt: DateTime.now(),
          );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      // Fallback
      _currentUser = UserModel(
        uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        displayName: displayName,
        role: role,
        createdAt: DateTime.now(),
      );
      _isLoading = false;
      notifyListeners();
      return true;
    }
  }

  /// Toggle Saved / Bookmark Ad
  void toggleSaveAd(String campaignId) {
    if (_currentUser == null) return;
    final list = List<String>.from(_currentUser!.savedAdIds);
    if (list.contains(campaignId)) {
      list.remove(campaignId);
    } else {
      list.add(campaignId);
    }
    _currentUser = _currentUser!.copyWith(savedAdIds: list);
    notifyListeners();
  }

  bool isAdSaved(String campaignId) {
    return _currentUser?.savedAdIds.contains(campaignId) ?? false;
  }

  /// Sign Out
  Future<void> signOut() async {
    await _firebaseService.signOut();
    _currentUser = null;
    notifyListeners();
  }
}
