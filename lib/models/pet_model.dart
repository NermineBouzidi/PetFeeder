// lib/models/pet_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class PetModel {
  final String id;
  final String name;
  final String species; // 'cat' or 'dog'
  final double weight;
  final int dailyFood;
  final DateTime? createdAt;

  PetModel({
    required this.id,
    required this.name,
    required this.species,
    required this.weight,
    required this.dailyFood,
    this.createdAt,
  });

  String get emoji => species == 'cat' ? '🐱' : '🐶';

  factory PetModel.fromMap(Map<String, dynamic> map, String id) {
    return PetModel(
      id:        id,
      name:      map['name']      ?? '',
      species:   map['species']   ?? 'cat',
      weight:    (map['weight']   ?? 0).toDouble(),
      dailyFood: map['dailyFood'] ?? 0,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name':      name,
      'species':   species,
      'weight':    weight,
      'dailyFood': dailyFood,
      'createdAt': Timestamp.now(),
    };
  }
}