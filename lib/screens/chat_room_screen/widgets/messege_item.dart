import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:intl/intl.dart';
import 'package:ms_web/screens/chat_room_screen/bloc/chat_cubit.dart';

import '../../../bloc/session_cubit.dart';
import '../../../bloc/theme_cubit/theme.dart';
import '../../../model/message.dart';
import '../../../utils/colors.dart';

class MessegeItemWidget extends StatelessWidget {
  final DocumentSnapshot snapshot;
  const MessegeItemWidget({super.key,required this.snapshot});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

    final theme = context.watch<ThemeCubit>().state;
    Color senderColor = theme.isDark ? AppColors.dark3 : AppColors.primary.withGreen(150);
    Color receiverColor = theme.isDark ? AppColors.dark4 : AppColors.primary2.withOpacity(.4);
    final userData = context.watch<SessionCubit>().state.user;
    Message message = Message.fromJson(data);
    bool whoSender = data['senderId'] == userData!.uid;
    final chatCubit = context.read<ChatCubit>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        // crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: whoSender ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          ConstrainedBox(
            // key: key,
            // key: isResponse ? _responseKey : null,
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            child: GestureDetector(
              onTapDown:
                  (details) => _showContextMenu(
                    position: details.globalPosition,
                    message: message.message,
                    messageId: snapshot.id,
                    context: context,
                    whoSender: whoSender,
                    senderId: message.senderId,
                  ),
              child: Container(
                // key: key,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: whoSender ? senderColor : receiverColor,
                  // color: AppColors.primary.withGreen(150),
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                ),
                child: Column(
                  crossAxisAlignment: whoSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    message.isReplied == true
                        ? InkWell(
                          onTap: () {
                            chatCubit.scrollToItem(chatCubit.messageKeys[message.repliedMessageId]!);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: whoSender ? AppColors.dark2.withOpacity(.5) : AppColors.dark2,
                              borderRadius: BorderRadius.circular(10),
                              border: const Border(left: BorderSide(color: AppColors.dark2, width: 5)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message.repliedMessageSenderId != userData!.uid
                                      ? userData.name
                                      : userData.name,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: AppColors.light,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.45),
                                  child: Text(
                                    overflow: TextOverflow.ellipsis,
                                    "${message.repliedMessage}",
                                    style: const TextStyle(fontSize: 12, color: AppColors.light),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        : const SizedBox.shrink(),
                    const SizedBox(height: 5),
                    !message.isFile
                        ? Text(
                          textAlign: TextAlign.left,
                          message.message,
                          style: const TextStyle(color: AppColors.light, fontSize: 18),
                        )
                        : InstaImageViewer(
                          child: CachedNetworkImage(
                            width: MediaQuery.of(context).size.width * 0.45,
                            placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                            imageUrl: message.filePath!,
                          ),
                        ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        message.isChanged == true
                            ? const Padding(
                              padding: EdgeInsets.only(right: 5.0),
                              child: Text('changed', style: TextStyle(fontSize: 12, color: AppColors.light)),
                            )
                            : const SizedBox.shrink(),
                        Text(
                          DateFormat('hh:mm').format(message.timestamp.toDate()),
                          style: const TextStyle(fontSize: 12, color: AppColors.light),
                        ),
                        const SizedBox(width: 5),
                        const Icon(Icons.check, size: 15, color: AppColors.light),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

  }






  void _showContextMenu(
      {required Offset position,
        required String message,
        required String messageId,
        required BuildContext context,
        required String senderId,
        required bool whoSender}) async {
    // final chatProvider = context.read<ChatService>();

    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final chatService = context.read<ChatCubit>();
    final userData = context.watch<SessionCubit>().state.user;
    // final chatService = Provider.of<ChatService>(context);
    await showMenu(
      menuPadding: EdgeInsets.zero,
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        overlay.size.width - position.dx,
        overlay.size.height - position.dy,
      ),
      items: [
        const PopupMenuItem(
          value: 'reply',
          child: Text('Reply'),
        ),
        const PopupMenuItem(
          value: 'copy',
          child: Text('Copy'),
        ),
        if (whoSender)
          const PopupMenuItem(
            value: 'edit',
            child: Text('Edit'),
          ),
        if (whoSender)
          const PopupMenuItem(
            value: 'delete',
            child: Text('Delete'),
          ),
      ],
    ).then((value) {
      if (value == 'copy') {
        Clipboard.setData(ClipboardData(text: message));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Copied to clipboard'),
          duration: Duration(milliseconds: 200),
        ));
      } else if (value == 'edit') {
        chatService.setMessage(messageId, message);
        // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Edit feature not implemented')));
      } else if (value == 'delete') {
        chatService.deleteMessage(messageId: messageId, otherUserId: userData!.uid);
        // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Delete feature not implemented')));
      } else if (value == 'reply') {
        chatService.replayMessage(message: message, senderId: senderId, messageId: messageId);
      }
    });
  }
}
