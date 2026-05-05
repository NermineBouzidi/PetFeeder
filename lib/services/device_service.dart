import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DeviceService {
  final String baseUrl = 'http://172.20.10.2:3001/api/state';

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  Map<String, dynamic>? _lastSaved; // prevent spam writes

  Future<Map<String, dynamic>> fetchData() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // ✅ SAVE TO FIREBASE
      await _saveToFirebaseIfChanged(data);

      return data;
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> _saveToFirebaseIfChanged(Map<String, dynamic> data) async {
    if (_uid == null) return;

    // prevent writing same data every 2 sec
    if (_lastSaved != null &&
        jsonEncode(_lastSaved) == jsonEncode(data)) {
      return;
    }

    _lastSaved = data;

    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('device')
        .doc('current')
        .set({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}