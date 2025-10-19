


import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:uuid/uuid.dart';

import '../../../model/message.dart';
import '../../../model/user.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final Map<String, int> messageKeys = {};
  final ItemScrollController itemScrollController = ItemScrollController();
  final FocusNode messageFocusNode = FocusNode();
  TextEditingController messageController = TextEditingController();
  UserData userData = UserData(email: '', name: '', uid: '', isOnline: false, imageUrl: '');

  var isEditing = false;
  bool isReplying = false;
  bool whoSender = false;
  bool isScrolling = false;

  String editingMessageId = "";
  String editingMessage = "";
  String repliedMessageSenderId = "";


  ChatCubit(this._auth, this._firestore) : super(ChatInitial());



  Future<void> sendMessage({
    required String receiverId,
    required String message,
    required bool isReply,
    required String replyUser,
    required String replyMessId,
    required String repliedMessage,
    bool isFile = false,
    String filePath = '',
  }) async {
    final String currentUserId = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
      message: message,
      senderId: currentUserId,
      receiverId: receiverId,
      senderEmail: currentUserEmail,
      timestamp: timestamp,
      isReplied: isReply,
      repliedMessage: isReply ? repliedMessage : '',
      repliedMessageId: isReply ? replyMessId : '',
      repliedMessageSenderId: isReply ? replyUser : '',
      isFile: isFile,
      filePath: filePath,
    );

    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join('_');

    await _firestore.collection('chat_rooms').doc(chatRoomId).collection('messages').add(newMessage.toMap());
    cancelReply();
  }

  cancelReply() {
    isReplying = false;
    editingMessageId = "";
    editingMessage = "";

  }

  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');
    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<void> deleteMessage({required String messageId, required String otherUserId}) async {
    List<String> ids = [_auth.currentUser!.uid, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  replayMessage({required String message, required String senderId, required String messageId}) {
    isReplying = true;
    senderId == _auth.currentUser!.uid ? whoSender = true : whoSender = false;
    editingMessageId = messageId;
    repliedMessageSenderId = senderId;
    editingMessage = message;
    messageFocusNode.requestFocus();

  }

  setMessage(String messageId, String message) {
    editingMessageId = messageId;
    messageController.text = message;
    editingMessage = message;
    messageFocusNode.requestFocus();
    isEditing = true;

  }

  cancelEditing() {
    editingMessageId = "";
    editingMessage = "";
    messageController.clear();
    messageFocusNode.unfocus();
    isEditing = false;
    isReplying = false;

  }



  Future<void> clearHistory(String otherUserId) async {
    List<String> ids = [_auth.currentUser!.uid, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        doc.reference.delete();
      }
    });
  }


  Future<void> getUserData() async {
    final user = _auth.currentUser;
    final userDataDb = await _firestore.collection('users').doc(user!.uid).get();
    final data = userDataDb.data()!;


    userData = UserData.fromJson(data);

  }


  Future scrollToItem(int index) async {
    await itemScrollController.scrollTo(
      index: index,
      duration: const Duration(seconds: 1),
      alignment: .5,
      curve: Curves.easeInOut,
    );
  }
  void navToFirst() {
    itemScrollController.scrollTo(
      index: 0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }


  Future<void> sendImageMessage({
    required String receiverId,
    required bool isReply,
    required String replyUser,
    required String replyMessId,
    required String repliedMessage,
  }) async {
    String? downloadURL;
    final fileName = const Uuid().v4();
    final ref = FirebaseStorage.instance.ref().child('images/$fileName');

    if (kIsWeb) {
      // ✅ Web: FilePicker ishlatamiz
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null && result.files.single.bytes != null) {
        final bytes = result.files.single.bytes!;
        await ref.putData(bytes);
        downloadURL = await ref.getDownloadURL();
      }
    } else {
      // 📱 Mobil: ImagePicker ishlatamiz
      final XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        await ref.putFile(file);
        downloadURL = await ref.getDownloadURL();
      }
    }

    if (downloadURL != null) {
      await sendMessage(
        receiverId: receiverId,
        message: '',
        isReply: isReply,
        replyUser: replyUser,
        replyMessId: replyMessId,
        repliedMessage: repliedMessage,
        isFile: true,
        filePath: downloadURL,
      );
    }
  }


  Future<void> updateMessageReadStatus(String messageId) async {
    await _firestore.collection('chat_rooms').doc(messageId).update({
      'isRead': true,
    });

  }

  Future<void> updateMessage({required String messageId, required String newMessage, required otherUserId}) async {
    List<String> ids = [_auth.currentUser!.uid, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');
    await _firestore.collection('chat_rooms').doc(chatRoomId).collection('messages').doc(messageId).update({
      'message': newMessage,
      'isChanged': true,
    });

  }



  // 🔹 changeImage() — web va mobil uchun moslashtirildi
  Future<void> changeImage(BuildContext context) async {
    final user = _auth.currentUser;
    if (user == null) return;

    XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    // Progress ko‘rsatish
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final imageName = const Uuid().v1();
      final ref = FirebaseStorage.instance.ref().child('user_image/$imageName');

      UploadTask uploadTask;

      if (kIsWeb) {
        // 🔹 Web uchun: file bytes orqali
        final Uint8List bytes = await pickedFile.readAsBytes();
        final metadata = SettableMetadata(contentType: 'image/jpeg');
        uploadTask = ref.putData(bytes, metadata);
      } else {
        // 🔹 Mobil uchun: file orqali
        final file = File(pickedFile.path);
        final metadata = SettableMetadata(contentType: 'image/jpeg');
        uploadTask = ref.putFile(file, metadata);
      }

      final snapshot = await uploadTask.whenComplete(() {});
      final imageUrl = await snapshot.ref.getDownloadURL();

      // 🔹 Eski rasmni o‘chirish
      final userDoc =
      await _firestore.collection('users').doc(user.uid).get();
      final oldUrl = userDoc.data()?['photoUrl'];

      if (oldUrl != null && oldUrl.toString().isNotEmpty) {
        try {
          await FirebaseStorage.instance.refFromURL(oldUrl).delete();
        } catch (e) {
          debugPrint('Old image not found or already deleted: $e');
        }
      }

      // 🔹 Firestore ni yangilash
      await _firestore.collection('users').doc(user.uid).update({
        'photoUrl': imageUrl,
      });

      await getUserData();


    } catch (e) {
      debugPrint('Error changing image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rasm yuklashda xatolik: $e')),
      );
    } finally {
      Navigator.of(context).pop();
    }
  }


  Future<void> changeName(String newName) async {
    final user = _auth.currentUser;
    await _firestore.collection('users').doc(user!.uid).update({"name": newName});

  }


  void showImagePopup(BuildContext context, String imageUrl) {
    final size = MediaQuery.of(context).size;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            contentPadding: EdgeInsets.zero,
            content: Container(
              width: size.width * 0.8,
              height: size.width * 0.6,
              decoration: BoxDecoration(
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(imageUrl),
                    fit: BoxFit.cover,
                  )),
            ));
      },
    );
  }


  String _chatId(String a, String b) => a.hashCode <= b.hashCode ? '${a}_$b' : '${b}_$a';
}
