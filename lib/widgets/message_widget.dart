import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../bloc/theme_cubit/theme.dart';
import '../provider/chat_service.dart';
import '../screens/chat_room_screen/bloc/chat_cubit.dart';
import '../services/chat_services.dart';
import '../utils/colors.dart';

class SendMessageWidget extends StatefulWidget {
  final String receiverUserId;

  const SendMessageWidget({
    super.key,
    required this.receiverUserId,
  });

  @override
  State<SendMessageWidget> createState() => _SendMessageWidgetState();
}

class _SendMessageWidgetState extends State<SendMessageWidget> {

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery
        .of(context)
        .size;
    final theme = context.watch<ThemeCubit>().state;
    final chatCubit = context.read<ChatCubit>();
    final chatWatcher = context.read<ChatCubit>();

    // final chatPro = Provider.of<ChatService>(context);
    void sendMessage() async {
      if (chatCubit.messageController.text.isNotEmpty) {
        await chatCubit.sendMessage(
          receiverId: widget.receiverUserId,
          message: chatCubit.messageController.text.trim(),
          isReply: chatWatcher.isReplying,
          repliedMessage: chatWatcher.editingMessage,
          replyMessId: chatWatcher.editingMessageId,
          replyUser: chatWatcher.repliedMessageSenderId,
        );
        chatCubit.messageController.clear();
        chatCubit.cancelReply();
      }
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: size.width * .9,
        maxHeight: size.height * .2,
        minHeight: size.height * .05,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: TextField(
          enabled: true,
          autofocus: false,
          focusNode: chatWatcher.messageFocusNode,
          controller: chatCubit.messageController,
          minLines: 1,
          maxLines: 5,
          style: const TextStyle(color: AppColors.light),
          textAlign: TextAlign.left,
          decoration: InputDecoration(

            hintText: "Message",
            hintStyle: TextStyle(color: AppColors.light.withOpacity(.45)),
            suffixIcon: IconButton(
                onPressed: () {
                  if (chatWatcher.isEditing) {
                    chatCubit.updateMessage(
                        otherUserId: widget.receiverUserId,
                        messageId: chatWatcher.editingMessageId,
                        newMessage: chatCubit.messageController.text.trim());
                    chatCubit.messageController.clear();
                    chatCubit.editingMessageId = "";
                    chatCubit.messageFocusNode.unfocus();
                    chatCubit.isEditing = false;
                    chatCubit.isReplying = false;
                  } else {
                    sendMessage();
                    // chatProvider.messageFocusNode.unfocus();
                  }
                },
                icon: Icon(
                  chatWatcher.isEditing ? Icons.check_circle : Icons.send_outlined,
                  color: theme.isDark ? AppColors.darkButton : AppColors.light,
                )),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: theme.isDark ? AppColors.textFieldDark : AppColors.teal,
            prefixIcon: Container(
              margin: const EdgeInsets.all(8),
              width: 40,
              height: 40,
              child: IconButton(
                  onPressed: () {
                    chatCubit.sendImageMessage(receiverId: widget.receiverUserId,
                        isReply: chatWatcher.isReplying,
                        replyUser: chatWatcher.repliedMessageSenderId,
                        replyMessId: chatWatcher.editingMessageId,
                        repliedMessage: chatWatcher.repliedMessageSenderId,

                    );
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: theme.isDark ? AppColors.darkButton : AppColors.primary2,
                  ),
                  icon: Transform.rotate(
                    angle: .45,
                    child: Icon(
                      Icons.attach_file,
                      color: theme.isDark ? AppColors.dark : AppColors.primary,
                      size: 25,
                    ),
                  )),
            ),
          ),
        ),
      ),
    );
  }
}
