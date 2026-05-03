import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Get current user's uid safely
  String? get _uid => _auth.currentUser?.uid;

  // ── One-time fetch (use in initState) ──────────────────────────────────────
  Future<UserModel?> getCurrentUser() async {
    if (_uid == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(_uid).get();
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromMap(doc.data()!, _uid!);
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  // ── Real-time stream (use in profile page) ─────────────────────────────────
  Stream<UserModel?> userStream() {
    if (_uid == null) return Stream.value(null);

    return _firestore
        .collection('users')
        .doc(_uid)
        .snapshots()
        .map((doc) {
          if (!doc.exists || doc.data() == null) return null;
          return UserModel.fromMap(doc.data()!, _uid!);
        });
  }

  // ── Update profile fields ──────────────────────────────────────────────────
Future<void> updateUser({
  required String firstName,
  required String lastName,
}) async {
  if (_uid == null) return;
  await _firestore.collection('users').doc(_uid).update({
    'firstName': firstName,
    'lastName': lastName,
  });
}
}