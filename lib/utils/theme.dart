import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  // لا نستخدم Material 3 وفقًا للمتطلبات.
  useMaterial3: false,
  scaffoldBackgroundColor: const Color(0xFFFFFFFF),
  primaryColor: const Color(0xFFD81B60),
  colorScheme: const ColorScheme.light(
    primary: Color(0xFFD81B60),
    secondary: Color(0xFFB71C1C),
    background: Color(0xFFFCE4EC),
    surface: Color(0xFFF5F8FF),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFD81B60),
    foregroundColor: Colors.white,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(24)),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),
);
