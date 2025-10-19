import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ms_web/services/auth_services.dart';
import 'package:remixicon/remixicon.dart';

import '../bloc/auth_check_bloc/auth_check_bloc.dart';



class SocialButtonsWidget extends StatelessWidget {

   SocialButtonsWidget({super.key, });


  final AuthService authService = AuthService();


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * .7,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            socialButton(icon: Remix.google_fill,callBack:  (){
              context.read<AuthCheckBloc>().add(AuthSignInRequested());
            }),
            socialButton(icon: Icons.apple,callBack:  (){}),
            socialButton(icon: Icons.facebook,callBack:  (){}),
          ],
        ),
      ),
    );
  }

  Widget socialButton({required IconData icon, required VoidCallback callBack}) {
    return IconButton(
        onPressed: callBack,
        style: IconButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(.2)
        ),
        icon:  Icon(icon, color: Colors.white, size: 30,));
  }
}
