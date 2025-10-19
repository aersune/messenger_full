import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ms_web/screens/chat_room_screen/chat_room_appbar.dart';
import 'package:ms_web/screens/chat_room_screen/widgets/messege_list.dart';
import 'package:provider/provider.dart';
import '../../bloc/session_cubit.dart';
import '../../bloc/theme_cubit/theme.dart';
import '../../model/user.dart';
import '../../utils/colors.dart';
import '../../widgets/message_widget.dart';
import 'bloc/chat_cubit.dart';

class ChatRoomScreen extends StatefulWidget {
  final UserData userData;

  const ChatRoomScreen({super.key, required this.userData});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  bool isScrolled = false;

  @override
  Widget build(BuildContext context) {
    return ChatRoomView();
  }

  Widget ChatRoomView() {
    // final userData = context.read<SessionState>();
    final theme = context.watch<ThemeCubit>().state;
    final size = MediaQuery.of(context).size;
    final chatWatch = context.watch<ChatCubit>();
    final chatCubit = context.read<ChatCubit>();


    return WillPopScope(
      onWillPop: () async {
        chatCubit.messageController.clear();
        chatCubit.isEditing = false;
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: ChatRoomAppbar(userData: widget.userData),
        backgroundColor: theme.isDark ? AppColors.dark : AppColors.primary,
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  // height: size.height * 0.78,
                  child: MessegeListWidget(userData: widget.userData),
                ),
                chatWatch.isReplying
                    ? Container(
                      padding: EdgeInsets.symmetric(horizontal: size.width * 0.05, vertical: size.height * 0.01),
                      color: theme.isDark ? AppColors.textFieldDark : AppColors.teal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(CupertinoIcons.reply, color: AppColors.light),
                          const SizedBox(width: 10),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                chatWatch.whoSender
                                    ? "Reply to ${widget.userData.name}"
                                    : "Reply to  ${widget.userData.name}",
                                style: const TextStyle(
                                  color: AppColors.light,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1,
                                ),
                              ),
                              SizedBox(
                                width: size.width * .5,
                                child: Text(
                                  overflow: TextOverflow.ellipsis,
                                  chatWatch.editingMessage,
                                  style: TextStyle(color: AppColors.light.withOpacity(.5)),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              chatCubit.cancelEditing();
                            },
                            icon: const Icon(Icons.close, color: AppColors.light),
                          ),
                        ],
                      ),
                    )
                    : const SizedBox.shrink(),
                chatWatch.isEditing
                    ? Container(
                      padding: EdgeInsets.symmetric(horizontal: size.width * 0.05, vertical: size.height * 0.01),
                      color: theme.isDark ? AppColors.textFieldDark : AppColors.teal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(Icons.edit, color: AppColors.light),
                          const SizedBox(width: 10),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Editing",
                                style: TextStyle(color: AppColors.light, fontWeight: FontWeight.w500, letterSpacing: 1),
                              ),
                              SizedBox(
                                width: size.width * .5,
                                child: Text(
                                  overflow: TextOverflow.ellipsis,
                                  chatWatch.editingMessage,
                                  style: TextStyle(color: AppColors.light.withOpacity(.5)),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              chatWatch.isReplying ? chatCubit.cancelReply() : chatCubit.cancelEditing();
                            },
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    )
                    : const SizedBox.shrink(),
                Container(
                  color:
                      theme.isDark ? AppColors.textFieldDark : AppColors.teal
                        ..withOpacity(.5),
                  width: size.width,
                  child: SendMessageWidget(receiverUserId: widget.userData.uid),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
