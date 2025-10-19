import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../model/message.dart';
import '../model/user.dart';
import 'package:file_picker/file_picker.dart'; // 🔹 web uchun qo‘shildi

class ChatService  {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FocusNode messageFocusNode = FocusNode();
  TextEditingController messageController = TextEditingController();

  String editingMessageId = "";
  String editingMessage = "";
  String repliedMessageSenderId = "";
  UserData userData = UserData(email: '', name: '', uid: '', isOnline: false, imageUrl: '');
  var isEditing = false;
  bool isReplying = false;
  bool whoSender = false;
  bool isScrolling = false;












}

// get messages
