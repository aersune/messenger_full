import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AuthService {
  // 🔹 Controllerlar saqlanadi (email / parol kirish uchun)
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔑 Faqat web uchun Google bilan kirish
  Future<String?> signInWithGoogle() async {
    try {
      if (!kIsWeb) {
        throw Exception('Bu funksiya faqat web uchun mo‘ljallangan');
      }

      final GoogleAuthProvider googleProvider = GoogleAuthProvider();

      // Pop-up orqali tizimga kirish
      final userCredential = await firebaseAuth.signInWithPopup(googleProvider);
      final user = userCredential.user;

      if (user != null) {
        final userDoc = _firestore.collection('users').doc(user.uid);
        final userSnapshot = await userDoc.get();

        if (!userSnapshot.exists) {
          // yangi foydalanuvchi bo‘lsa — Firestore’ga yozamiz
          await userDoc.set({
            'uid': user.uid,
            'name': user.displayName,
            'email': user.email,
            'photoUrl': user.photoURL,
            'isOnline': true,
            'createdAt': FieldValue.serverTimestamp(),
          });
        } else {
          // mavjud foydalanuvchi holatini yangilaymiz
          await userDoc.update({'isOnline': true});
        }
      }

      return user?.email;
    } catch (e) {
      if (kDebugMode) {
        print('🔴 Google Sign-In xatolik: $e');
      }
      return null;
    }
  }

  /// 📧 Email orqali ro‘yxatdan o‘tish
  Future<UserCredential?> signUpWithEmail() async {
    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      final confirm = confirmPassword.text.trim();

      if (password != confirm) {
        throw Exception('Parollar mos emas');
      }

      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);

      final user = userCredential.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'isOnline': true,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return userCredential;
    } catch (e) {
      if (kDebugMode) {
        print('🔴 Email Sign-Up xatolik: $e');
      }
      return null;
    }
  }

  /// 🔐 Email orqali tizimga kirish
  Future<UserCredential?> signInWithEmail() async {
    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      final userCredential = await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);

      final user = userCredential.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({'isOnline': true});
      }

      return userCredential;
    } catch (e) {
      if (kDebugMode) {
        print('🔴 Email Sign-In xatolik: $e');
      }
      return null;
    }
  }

  ///Chiqish
  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print('SignOut xatolik: $e');
      } else {}
    }
  }

  /// 👤 Hozirgi foydalanuvchi
  User? get currentUser => firebaseAuth.currentUser;
}
