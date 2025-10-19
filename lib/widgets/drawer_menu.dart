import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../bloc/theme_cubit/theme.dart';
import '../model/user.dart';
import '../provider/chat_service.dart';
import 'dart:io';
import '../screens/auth/login_screen.dart';
import '../screens/profile.dart';
import '../services/auth_services.dart';
import '../utils/colors.dart';

class DrawerMenu extends StatefulWidget {
  const DrawerMenu({super.key});

  @override
  State<DrawerMenu> createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  bool isDark = false;

  File? downloadedFile;

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final chatService = context.watch<ChatService>();
    final theme = context.watch<ThemeCubit>().state;
    UserData user = chatService.userData;
    final size = MediaQuery.of(context).size;
    final chatRead = context.read<ChatService>();

    final imageUrl =  user.imageUrl;


    return Drawer(
      width: MediaQuery.of(context).size.width * 0.7,
      backgroundColor: theme.isDark ? AppColors.dark : AppColors.primary2,
      child: Consumer<ThemeCubit>(builder: (context, ThemeCubit theme, child) {
        return SizedBox(
          height: size.height,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: theme.state.isDark ? AppColors.dark2 : AppColors.primary,
                ),
                currentAccountPicture: Stack(
                  children: [
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: () {
                          chatRead.showImagePopup(context, user.imageUrl);
                        },
                        child:


                        CachedNetworkImage(
                          placeholder: (context, url) => const CircularProgressIndicator(),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                          imageUrl: user.imageUrl,
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),)

                        ),
                      ),
                    ),
                    Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: () {
                            chatService.changeImage(context);
                          },
                          child: Container(
                              width: 25,
                              height: 25,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: theme.state.isDark ? AppColors.dark : AppColors.light,
                              ),
                              child: const Icon(
                                Icons.edit,
                                size: 15,
                              )),
                        ))
                  ],
                ),
                accountName: Text(
                  user.name,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
                accountEmail: Text(user.email),
              ),

              ListTile(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const UserProfile()));
                },
                leading: const Icon(Icons.person),
                title: const Text("Profile"),
              ),
              ListTile(
                leading: const Icon(Icons.dark_mode),
                onTap: () {
                  theme.toggleTheme();
                },
                title: const Text("Dark"),
                trailing: Switch(
                    thumbIcon: WidgetStateProperty.resolveWith<Icon?>(
                      (Set<WidgetState> states) {
                        if (states.contains(WidgetState.selected)) {
                          return const Icon(
                            Icons.dark_mode,
                            color: AppColors.light,
                          );
                        }
                        return const Icon(
                          Icons.light_mode,
                          color: AppColors.primary,
                        );
                      },
                    ),
                    value: theme.state.isDark,
                    activeColor: AppColors.dark,
                    inactiveThumbColor: AppColors.light,
                    trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                    inactiveTrackColor: AppColors.primary,
                    activeTrackColor: AppColors.dark2,
                    onChanged: (bool value) {
                      theme.toggleTheme();
                    }),
              ),

              const ListTile(
                leading: Icon(Icons.settings),
                title: Text("Settings"),
              ),
              SizedBox(
                width: size.width  * .2,
                child: Divider(
                  color: Colors.black.withOpacity(.2),
                  height: 10,
                  thickness: 1,
                ),
              ),

              ListTile(
                onTap: () {
                  _firebaseAuth.signOut();
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>  LoginScreen()));
                },
                leading: const Icon(Icons.logout),
                title: const Text("Logout"),
              ),
            ],
          ),
        );
      }),
    );
  }
}
