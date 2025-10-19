import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ms_web/bloc/auth_check_bloc/auth_check_bloc.dart';
import 'package:provider/provider.dart';
import '../../auth_check.dart';
import '../../bloc/theme_cubit/theme.dart';

import '../../services/auth_services.dart';
import '../../utils/colors.dart';

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  // ChangeNotifierProvider(create: (context) => ChatService()),
  // ChangeNotifierProvider(create: (context) => ThemeProvider()..init()),
  // ChangeNotifierProvider(create: (context) => UserStatusService()),

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (context) => AuthCheckBloc(AuthService())..add(AuthCheckRequested()),),

      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, theme ) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Chat App',
          themeMode: theme.isDark ? ThemeMode.dark : ThemeMode.light,
          darkTheme: theme.darkTheme,
          theme: ThemeData(
            scaffoldBackgroundColor: AppColors.primary,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
            appBarTheme: AppBarTheme(
              iconTheme: const IconThemeData(color: Colors.white),
              backgroundColor: theme.isDark ? AppColors.dark : AppColors.primary,
              titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              centerTitle: true,
            ),
          ),
          home: const AuthCheck(),
        );
      },
    );
  }
}
