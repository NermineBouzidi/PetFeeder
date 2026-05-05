import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


// ── Model ─────────────────────────────────────────────────────────────────────

class ScheduleModel {
  final int? id;           // null before first save
  final String label;
  final TimeOfDay time;    // stored as "HH:mm" on server
  final int grams;
  final List<int> days;    // 0=Sun,1=Mon…6=Sat  ← server uses JS weekday
  bool isActive;

  ScheduleModel({
    this.id,
    required this.label,
    required this.time,
    required this.grams,
    required this.days,
    this.isActive = true,
  });

  // ── Serialise to JSON for POST / PUT ──────────────────────────────────────
  Map<String, dynamic> toJson() {
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    return {
      'label'  : label,
      'time'   : '$hh:$mm',
      'days'   : days,
      'grams'  : grams,
      'enabled': isActive,
    };
  }

  // ── Deserialise from server JSON ──────────────────────────────────────────
  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    final parts = (json['time'] as String).split(':');
    return ScheduleModel(
      id      : json['id'] as int?,
      label   : json['label'] as String? ?? 'Meal',
      time    : TimeOfDay(
        hour  : int.parse(parts[0]),
        minute: int.parse(parts[1]),
      ),
      grams   : (json['grams'] as num?)?.toInt() ?? 50,
      days    : List<int>.from(json['days'] as List),
      isActive: json['enabled'] as bool? ?? true,
    );
  }

  // ── Display helpers ───────────────────────────────────────────────────────
  String get formattedTime {
    final h      = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final m      = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  // days stored as JS weekday: 0=Sun,1=Mon…6=Sat
  String get daysLabel {
    const names = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    if (days.length == 7) return 'Everyday';
    final sorted = List<int>.from(days)..sort();
    return sorted.map((d) => names[d]).join(', ');
  }

  String get nextOccurrence {
    if (!isActive) return 'Paused';
    final now        = DateTime.now();
    final todayJS    = now.weekday % 7; // Dart: Mon=1…Sun=7 → JS: Sun=0
    for (int offset = 0; offset < 8; offset++) {
      final checkDay = (todayJS + offset) % 7;
      if (days.contains(checkDay)) {
        if (offset == 0) {
          final nowMin   = now.hour * 60 + now.minute;
          final schedMin = time.hour * 60 + time.minute;
          if (schedMin > nowMin) return 'Today';
        } else if (offset == 1) {
          return 'Tomorrow';
        } else {
          const names = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
          return names[checkDay];
        }
      }
    }
    return 'N/A';
  }

  ScheduleModel copyWith({
    int? id, String? label, TimeOfDay? time, int? grams,
    List<int>? days, bool? isActive,
  }) {
    return ScheduleModel(
      id      : id       ?? this.id,
      label   : label    ?? this.label,
      time    : time     ?? this.time,
      grams   : grams    ?? this.grams,
      days    : days     ?? this.days,
      isActive: isActive ?? this.isActive,
    );
  }
}

// ── Service ───────────────────────────────────────────────────────────────────

class ScheduleService {
  final _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;

String? get _uid => _auth.currentUser?.uid;
  final String _base = 'http://172.20.10.2:3001';

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
  };

  // GET /api/schedule
  Future<List<ScheduleModel>> fetchAll() async {
    final res = await http.get(Uri.parse('$_base/api/schedule'));
    if (res.statusCode != 200) throw Exception('fetchAll failed: ${res.statusCode}');
    final list = jsonDecode(res.body) as List;
    return list.map((j) => ScheduleModel.fromJson(j as Map<String, dynamic>)).toList();
  }

  // POST /api/schedule
 Future<ScheduleModel> create(ScheduleModel s) async {
  final res = await http.post(
    Uri.parse('$_base/api/schedule'),
    headers: _headers,
    body: jsonEncode(s.toJson()),
  );

  if (res.statusCode != 200) {
    throw Exception('create failed: ${res.statusCode}');
  }

  final saved = ScheduleModel.fromJson(
      jsonDecode(res.body) as Map<String, dynamic>);

  // ✅ SAVE TO FIREBASE
  if (_uid != null) {
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('schedules')
        .doc(saved.id.toString())
        .set(saved.toJson());
  }

  return saved;
}

  // PUT /api/schedule/:id
  Future<ScheduleModel> update(ScheduleModel s) async {
    if (s.id == null) throw Exception('Cannot update: id is null');
    final res = await http.put(
      Uri.parse('$_base/api/schedule/${s.id}'),
      headers: _headers,
      body: jsonEncode(s.toJson()),
    );
    if (res.statusCode != 200) throw Exception('update failed: ${res.statusCode}');
    return ScheduleModel.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  // DELETE /api/schedule/:id
  Future<void> delete(int id) async {
    final res = await http.delete(Uri.parse('$_base/api/schedule/$id'));
    if (res.statusCode != 200) throw Exception('delete failed: ${res.statusCode}');
  }

  // POST /api/feed  (Feed Now button)
  Future<void> feedNow() async {
    final res = await http.post(Uri.parse('$_base/api/feed'), headers: _headers);
    if (res.statusCode != 200) throw Exception('feedNow failed: ${res.statusCode}');
  }
}