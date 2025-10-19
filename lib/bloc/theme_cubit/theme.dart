import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/colors.dart';



class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeState.initial()) {
    init();
  }

  /// Dark/Light rejimni almashtirish
  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final newValue = !state.isDark;
    await prefs.setBool('isDark', newValue);
    emit(state.copyWith(isDark: newValue));
  }

  /// Avvalgi rejimni yuklash (saqlangan qiymat bo‘lsa)
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool('isDark') ?? false;
    emit(state.copyWith(isDark: saved));
  }

  /// Hozirgi ThemeData ni qaytaradi
  ThemeData get currentTheme =>
      state.isDark ? state.darkTheme : state.lightTheme;
}

class ThemeState {
  final bool isDark;
  final ThemeData darkTheme;
  final ThemeData lightTheme;

  const ThemeState({
    required this.isDark,
    required this.darkTheme,
    required this.lightTheme,
  });

  factory ThemeState.initial() => ThemeState(
    isDark: false,
    darkTheme: ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.dark,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.dark,
      ),
      scaffoldBackgroundColor: AppColors.dark,
    ),
    lightTheme: ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
      ),
      scaffoldBackgroundColor: AppColors.primary,
    ),
  );

  ThemeState copyWith({bool? isDark}) {
    return ThemeState(
      isDark: isDark ?? this.isDark,
      darkTheme: darkTheme,
      lightTheme: lightTheme,
    );
  }
}