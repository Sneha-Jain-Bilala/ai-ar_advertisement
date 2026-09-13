class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String role; // 'consumer', 'advertiser', 'admin'
  final String? photoUrl;
  final List<String> savedAdIds;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.role = 'consumer',
    this.photoUrl,
    this.savedAdIds = const [],
    required this.createdAt,
  });

  bool get isAdvertiser => role == 'advertiser';
  bool get isAdmin => role == 'admin';
  bool get isConsumer => role == 'consumer';

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String? ?? 'User',
      role: map['role'] as String? ?? 'consumer',
      photoUrl: map['photoUrl'] as String?,
      savedAdIds: List<String>.from(map['savedAdIds'] as List? ?? []),
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'role': role,
      'photoUrl': photoUrl,
      'savedAdIds': savedAdIds,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  UserModel copyWith({
    String? email,
    String? displayName,
    String? role,
    String? photoUrl,
    List<String>? savedAdIds,
  }) {
    return UserModel(
      uid: uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      savedAdIds: savedAdIds ?? this.savedAdIds,
      createdAt: createdAt,
    );
  }
}
