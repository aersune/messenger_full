import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ms_web/screens/chat_room_screen/bloc/chat_cubit.dart';

import '../../bloc/theme_cubit/theme.dart';
import '../../model/user.dart';
import '../../utils/colors.dart';
import '../../widgets/user_profile_info.dart';

class ChatRoomAppbar extends StatelessWidget implements PreferredSizeWidget {
  final UserData userData;

  const ChatRoomAppbar({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeCubit>().state;
    final size = MediaQuery.of(context).size;
    final  chatCubit = context.read<ChatCubit>();
    return AppBar(
      elevation: 0,
      backgroundColor: theme.isDark ? AppColors.dark : AppColors.primary,
      title: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfileInfo(userData: userData)));
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(radius: 20, backgroundImage: CachedNetworkImageProvider(userData.imageUrl)),
            const SizedBox(width: 16),
            SizedBox(
              width: size.width * .35,
              child: Text(userData.name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(CupertinoIcons.search, opticalSize: 50)),
        PopupMenuButton(
          onSelected: (val) {
            // print(val);
            if (val == 'first') {
              chatCubit.navToFirst();
            } else if (val == 'clear') {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      backgroundColor: theme.isDark ? AppColors.dark : AppColors.primary,
                      title: const Text('Clear History'),
                      content: const Text('Are you sure you want to clear chat history?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            chatCubit.clearHistory(userData.uid);
                            Navigator.pop(context);
                          },
                          child: const Text('Yes', style: TextStyle(color: Colors.white)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
              );
            }
          },
          color: theme.isDark ? AppColors.dark : AppColors.deepGreen,
          itemBuilder:
              (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'first',
                  child: Text('Go to first message', style: TextStyle(color: Colors.white)),
                ),
                const PopupMenuItem<String>(
                  value: 'clear',
                  child: Text('Clear history', style: TextStyle(color: Colors.white)),
                ),
                const PopupMenuItem<String>(
                  value: 'changeBg',
                  child: Text('Change background', style: TextStyle(color: Colors.white)),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Text('Delete chat', style: TextStyle(color: Colors.white)),
                ),
              ],
        ),
      ],
      centerTitle: false,
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
