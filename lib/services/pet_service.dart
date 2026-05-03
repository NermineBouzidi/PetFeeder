// lib/services/pet_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/pet_model.dart';

class PetService {
  final _firestore = FirebaseFirestore.instance;
  final _auth      = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  // Save pet + mark onboarding done
  Future<void> savePetAndFinishOnboarding(PetModel pet) async {
    if (_uid == null) return;

    final batch = _firestore.batch();

    // Save pet document
    final petRef = _firestore
        .collection('users')
        .doc(_uid)
        .collection('pets')
        .doc();
    batch.set(petRef, pet.toMap());

    // Mark onboarding done
    final userRef = _firestore.collection('users').doc(_uid);
    batch.update(userRef, {'onboardingDone': true});

    await batch.commit();
  }

  // Get first pet (real-time)
  Stream<PetModel?> petStream() {
    if (_uid == null) return Stream.value(null);

    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('pets')
        .limit(1)
        .snapshots()
        .map((snap) {
          if (snap.docs.isEmpty) return null;
          return PetModel.fromMap(snap.docs.first.data(), snap.docs.first.id);
        });
  }
  Future<void> updatePet({
  required String petId,
  required String name,
  required String species,
  required double weight,
  required int dailyFood,
}) async {
  if (_uid == null) return;

  await _firestore
      .collection('users')
      .doc(_uid)
      .collection('pets')
      .doc(petId)
      .update({
    'name':      name,
    'species':   species,
    'weight':    weight,
    'dailyFood': dailyFood,
  });
}
}