import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo completo de usuario con toda la información necesaria
class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoURL;
  final String? phoneNumber;
  final bool emailVerified;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final Map<String, dynamic> businessInfo;
  final List<String> roles;
  final bool isActive;
  final Map<String, dynamic> profileInfo;
  final Map<String, dynamic> preferences;
  final String? deviceInfo;
  final String? appVersion;
  final String? referralCode;
  final int referralCount;

  const UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
    this.phoneNumber,
    this.emailVerified = false,
    required this.createdAt,
    required this.lastLoginAt,
    this.businessInfo = const {},
    this.roles = const ['user'],
    this.isActive = true,
    this.profileInfo = const {},
    this.preferences = const {},
    this.deviceInfo,
    this.appVersion,
    this.referralCode,
    this.referralCount = 0,
  });

  /// Crear usuario desde Firebase Auth User
  factory UserModel.fromFirebaseUser(dynamic firebaseUser) {
    return UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      photoURL: firebaseUser.photoURL,
      phoneNumber: firebaseUser.phoneNumber,
      emailVerified: firebaseUser.emailVerified,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
  }

  /// Crear usuario desde Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoURL: data['photoURL'],
      phoneNumber: data['phoneNumber'],
      emailVerified: data['emailVerified'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp).toDate(),
      businessInfo: data['businessInfo'] ?? {},
      roles: List<String>.from(data['roles'] ?? ['user']),
      isActive: data['isActive'] ?? true,
      profileInfo: data['profileInfo'] ?? {},
      preferences: data['preferences'] ?? {},
      deviceInfo: data['deviceInfo'],
      appVersion: data['appVersion'],
      referralCode: data['referralCode'] as String?,
      referralCount: (data['referralCount'] as num?)?.toInt() ?? 0,
    );
  }

  /// Convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'phoneNumber': phoneNumber,
      'emailVerified': emailVerified,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': Timestamp.fromDate(lastLoginAt),
      'businessInfo': businessInfo,
      'roles': roles,
      'isActive': isActive,
      'profileInfo': profileInfo,
      'preferences': preferences,
      'deviceInfo': deviceInfo,
      'appVersion': appVersion,
      'referralCode': referralCode,
      'referralCount': referralCount,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
  }

  /// Crear copia con cambios
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    String? phoneNumber,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    Map<String, dynamic>? businessInfo,
    List<String>? roles,
    bool? isActive,
    Map<String, dynamic>? profileInfo,
    Map<String, dynamic>? preferences,
    String? deviceInfo,
    String? appVersion,
    String? referralCode,
    int? referralCount,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      businessInfo: businessInfo ?? this.businessInfo,
      roles: roles ?? this.roles,
      isActive: isActive ?? this.isActive,
      profileInfo: profileInfo ?? this.profileInfo,
      preferences: preferences ?? this.preferences,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      appVersion: appVersion ?? this.appVersion,
      referralCode: referralCode ?? this.referralCode,
      referralCount: referralCount ?? this.referralCount,
    );
  }

  /// Verificar si el usuario tiene un rol específico
  bool hasRole(String role) => roles.contains(role);

  /// Verificar si el usuario es administrador
  bool get isAdmin => hasRole('admin');

  /// Obtener información del negocio
  String get businessName => businessInfo['businessName'] ?? '';
  String get businessRuc => businessInfo['businessRuc'] ?? '';
  String get businessAddress => businessInfo['businessAddress'] ?? '';
  String get ownerName => businessInfo['ownerName'] ?? '';

  /// Obtener información del perfil
  String get fullName => profileInfo['fullName'] ?? displayName ?? '';
  String get firstName => profileInfo['firstName'] ?? '';
  String get lastName => profileInfo['lastName'] ?? '';
  String get country => profileInfo['country'] ?? '';
  String get city => profileInfo['city'] ?? '';
  String get timezone => profileInfo['timezone'] ?? '';

  /// Obtener preferencias
  String get language => preferences['language'] ?? 'es';
  String get theme => preferences['theme'] ?? 'light';
  bool get notificationsEnabled => preferences['notificationsEnabled'] ?? true;

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, displayName: $displayName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
} 