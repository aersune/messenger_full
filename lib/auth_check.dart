import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ms_web/screens/auth/login_screen.dart';
import 'package:ms_web/screens/home_screen/home_screen.dart';
import 'bloc/auth_check_bloc/auth_check_bloc.dart';



class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: BlocListener<AuthCheckBloc, AuthCheckState>(
        listener: (context, state) {
          if (state is Unauthenticated) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          } else if (state is Authenticated) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          }
        },
        child: BlocBuilder<AuthCheckBloc, AuthCheckState>(
          builder: (context, state) {
            if (state is AuthLoading) {
              return const Center(child: CircularProgressIndicator());
            } else {
              // bu UI shunchaki oraliq ko‘rinish — nav bo‘lgunga qadar
              return const SizedBox();
            }
          },
        ),
      ),
    );
  }
}


