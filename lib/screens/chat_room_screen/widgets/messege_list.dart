import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ms_web/model/user.dart';
import 'package:ms_web/screens/chat_room_screen/bloc/chat_cubit.dart';
import 'package:ms_web/screens/chat_room_screen/widgets/messege_item.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class MessegeListWidget extends StatelessWidget {
  final UserData userData;
  MessegeListWidget({super.key, required this.userData});

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final chatCubit = context.read<ChatCubit>();
    return StreamBuilder(
      stream: chatCubit.getMessages(userData.uid, _auth.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        // SchedulerBinding.instance.addPostFrameCallback((_) async {
        //   _itemScrollController.jumpTo(
        //     index: snapshot.data!.docs.length - 1,
        //   );
        // });
        return ScrollablePositionedList.builder(
          itemScrollController: chatCubit.itemScrollController,
          physics: const ClampingScrollPhysics(),
          // physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var document = snapshot.data!.docs[index];
            var messageId = document.id;

            chatCubit.messageKeys[messageId] = index;

            // _messageKeys[messageId] = GlobalKey();
            // _messageKeys2.add(GlobalKey());  `

            return MessegeItemWidget(snapshot: document);
          },
          // children: snapshot.data!.docs.map((document) => _buildMessageItem(document)).toList(),
        );
      },
    );

  }
}
