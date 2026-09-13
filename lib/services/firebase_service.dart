import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../data/models/user_model.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;

  User? get currentFirebaseUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Collections
  CollectionReference get usersRef => _firestore.collection('users');
  CollectionReference get campaignsRef => _firestore.collection('campaigns');
  CollectionReference get productsRef => _firestore.collection('products');
  CollectionReference get interactionsRef => _firestore.collection('interactions');

  /// Sign In with Email and Password
  Future<UserModel?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (credential.user != null) {
        return await getUserProfile(credential.user!.uid);
      }
    } catch (e) {
      debugPrint('Firebase signIn error: $e');
      rethrow;
    }
    return null;
  }

  /// Register with Email, Password and Role
  Future<UserModel?> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
    required String role,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (credential.user != null) {
        final userModel = UserModel(
          uid: credential.user!.uid,
          email: email.trim(),
          displayName: displayName.trim(),
          role: role,
          createdAt: DateTime.now(),
        );

        await usersRef.doc(userModel.uid).set(userModel.toMap());
        return userModel;
      }
    } catch (e) {
      debugPrint('Firebase register error: $e');
      rethrow;
    }
    return null;
  }

  /// Fetch user profile from Firestore
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await usersRef.doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, uid);
      }
    } catch (e) {
      debugPrint('Firebase getUserProfile error: $e');
    }
    return null;
  }

  /// Update User Profile
  Future<void> updateUserProfile(UserModel user) async {
    await usersRef.doc(user.uid).update(user.toMap());
  }

  /// Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
