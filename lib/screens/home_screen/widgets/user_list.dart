import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../model/user.dart';
import '../../../widgets/favs_widget.dart';
import '../../../widgets/user_card.dart';
import '../../chat_room_screen/chat_room_screen.dart';

class UserList extends StatelessWidget {
  final List<QueryDocumentSnapshot> users;
  final Map<dynamic, dynamic> userStatus;
  final UserData currentUser;

  const UserList({
    super.key,
    required this.users,
    required this.userStatus,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final data = users[index].data() as Map<String, dynamic>;
        final userData = UserData.fromJson(data);

        if (userData.email == currentUser.email) {
          return ListTile();
          //   FavoritesWidget(
          //   callback: () => Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //       builder: (_) => ChatRoomScreen(userData: userData),
          //     ),
          //   ),
          // );
        } else {
          return UserCard(
            userData: userData,
            isOnline: userStatus[userData.uid]?['status'] == 'online',
            callback: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatRoomScreen(userData: userData),
              ),
            ),
          );
        }
      },
    );
  }
}
