import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ms_web/screens/chat_app/chat_app.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform.copyWith(
      databaseURL: "https://messenger-8de19-default-rtdb.firebaseio.com",
      projectId: "messenger-8de19",
    ),
  );
  await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  runApp(ChatApp());
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
}
