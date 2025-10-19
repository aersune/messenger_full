import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ms_web/screens/chat_room_screen/bloc/chat_cubit.dart';
import 'package:ms_web/services/chat_services.dart';
import 'package:provider/provider.dart';
import '../bloc/session_cubit.dart';
import '../bloc/theme_cubit/theme.dart';
import '../utils/colors.dart';


class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final TextEditingController nameController = TextEditingController();
  final FocusNode nameFocusNode = FocusNode();




  @override
  void dispose() {
    nameController.dispose();
    nameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeCubit>().state;
    final session = context.read<SessionCubit>().state;
    final currentUser = session.user;
    final chatCubit = context.read<ChatCubit>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Edit profile"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                  GestureDetector(
                    onTap: (){
                      chatCubit.showImagePopup(context, currentUser.imageUrl);
                    },
                    child: CachedNetworkImage(
                      imageUrl: currentUser!.imageUrl ,
                      placeholder: (context, url) => const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                      imageBuilder: (context, imageProvider) => CircleAvatar(
                        backgroundImage: imageProvider,
                        radius: 95,
                      )
                    ),
                  ),

                Positioned(
                    bottom: 0,
                    right: 0,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(100),
                        onTap: () {
                          chatCubit.changeImage(context);

                        },
                        child: Ink(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: theme.isDark ? AppColors.dark2 : AppColors.light,
                            ),
                            child: const Icon(
                              Icons.camera_alt_outlined,
                              size: 30,
                            )),
                      ),
                    )),

              ],
            ),
            const SizedBox(
              height: 25,
            ),
            // textarea for edit user name with design icons and text
            TextField(
                focusNode: nameFocusNode,
                controller: nameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: Colors.white.withOpacity(.2),
                  prefixIcon: const Icon(Icons.person),
                  hintText: currentUser.name,
                )),
            const SizedBox(
              height: 25,
            ),
            TextField(
                enabled: false,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: Colors.white.withOpacity(.2),
                  prefixIcon: const Icon(Icons.email_outlined),
                  hintText: currentUser.email,
                )),
            const SizedBox(
              height: 25,
            ),
            Row(

              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.shade100,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  onPressed: () {
                   Navigator.of(context).pop();
                    nameFocusNode.unfocus();
                  },
                  child: const Text("Cancel", style: TextStyle(color: Colors.white),),
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  onPressed: () {
                    chatCubit.changeName(nameController.text.trim());
                    chatCubit.getUserData();
                    nameFocusNode.unfocus();
                  },
                  child: const Text("Save"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
