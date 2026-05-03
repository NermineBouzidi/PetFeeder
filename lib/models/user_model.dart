import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final bool onboardingDone;   // ← add
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.onboardingDone = false,  // ← add
    this.createdAt,
  });

  String get fullName => '$firstName $lastName';

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      onboardingDone: map['onboardingDone'] ?? false,  // ← add
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'onboardingDone': onboardingDone,  // ← add
      'createdAt': Timestamp.now(),
    };
  }
}