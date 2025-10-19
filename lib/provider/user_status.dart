import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' as html;
class UserStatus {
  final String status;
  final dynamic timestamp;

  UserStatus({
    required this.status,
    required this.timestamp,
  });

  factory UserStatus.fromMap(String userId, Map<dynamic, dynamic> data) {
    return UserStatus(
      status: data['status'] ?? '',
      timestamp: data['timestamp'] ?? '',
    );
  }

  factory UserStatus.fromJson(Map<dynamic, dynamic> json) {
    return UserStatus(
      status: json['status'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }
}

class UserStatusService with ChangeNotifier {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isOnline = false;

  void setData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final ref = _databaseRef.child("status/${user.uid}");
    await ref.set({
      'status': 'online',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  void _updateStatus() {
    final user = _auth.currentUser;
    if (user == null) return;

    _databaseRef.child('status').child(user.uid).set({
      'status': 'online',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    }).then((_) {
      if (kDebugMode) print('Status updated successfully');
    }).catchError((error) {
      if (kDebugMode) print('Failed to update status: $error');
    });
  }

  void _onAuthStateChange() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _updateStatus();
      }
    });
  }

  void _onDisconnect() {
    final user = _auth.currentUser;
    if (user == null) return;

    // ⚠️ Webda onDisconnect to‘liq ishlamasligi mumkin
    if (!kIsWeb) {
      _databaseRef.child('status').child(user.uid).onDisconnect().set({
        'status': 'offline',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } else {
      // Web uchun muqobil yechim
      html.window.onBeforeUnload.listen((_) {
        _databaseRef.child('status').child(user.uid).set({
          'status': 'offline',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
      });
    }
  }

  void init() {
    setData();
    _onAuthStateChange();
    _onDisconnect();
  }

  @override
  void dispose() {
    _databaseRef.onDisconnect().cancel();
    super.dispose();
  }
}

