import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/user.dart';

class SessionState {
  final UserData? user;
  final bool isLoading;
  final String? error;

  SessionState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  SessionState copyWith({
    UserData? user,
    bool? isLoading,
    String? error,
  }) {
    return SessionState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class SessionCubit extends Cubit<SessionState> {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  SessionCubit(this._auth, this._firestore)
      : super(SessionState(isLoading: true));

  /// 🔹 Dastur ishga tushganda chaqiriladi
  Future<void> init() async {
    final user = _auth.currentUser;
    if (user == null) {
      emit(SessionState(isLoading: false));
      return;
    }

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final userData = UserData.fromJson(doc.data()!);
      emit(SessionState(user: userData, isLoading: false));
    } catch (e) {
      emit(SessionState(isLoading: false, error: e.toString()));
    }
  }

  /// 🔹 Auth paytida foydalanuvchi ma’lumotini yangilash
  void updateUser(UserData user) {
    emit(state.copyWith(user: user));
  }

  /// 🔹 Logout paytida
  Future<void> clearSession() async {
    await _auth.signOut();
    emit(SessionState(user: null, isLoading: false));
  }






}
