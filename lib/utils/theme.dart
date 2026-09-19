import 'package:flutter/material.dart';

// ⚠️ مهم: اسم المتغير appTheme (بحرف صغير) ليطابق main.dart
final ThemeData appTheme = ThemeData(
  // ✅ تعطيل Material 3 لمنع مشاكل العرض على الأندرويد
  useMaterial3: false,
  brightness: Brightness.light,

  // 🎨 الألوان الأساسية
  scaffoldBackgroundColor: const Color(0xFFFFFFFF),
  primaryColor: const Color(0xFFD81B60),
  canvasColor: const Color(0xFFFFFFFF),

  // 🎨 لوحة الألوان الكاملة
  colorScheme: const ColorScheme.light(
    primary: Color(0xFFD81B60),      // وردي غامق
    secondary: Color(0xFFB71C1C),    // أحمر غامق
    background: Color(0xFFFCE4EC),   // وردي ناعم
    surface: Color(0xFFFFF5F8),      // بيج وردي
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Color(0xFF4A1E2C),    // بني محمر داكن
  ),

  // 🎯 شريط العنوان العلوي
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFD81B60),
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    iconTheme: IconThemeData(color: Colors.white),
  ),

  // 📝 حقل الإدخال (TextField)
  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(24)),
      borderSide: BorderSide.none,
    ),
    filled: true,
    fillColor: Color(0xFFFCE4EC),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    hintStyle: TextStyle(
      color: Color(0xFF8B5A6B),
      fontSize: 14,
    ),
  ),

  // 🎨 الأزرار العائمة
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFFD81B60),
    foregroundColor: Colors.white,
  ),

  // 🎨 أزرار ElevatedButton
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFD81B60),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    ),
  ),

  // 🎨 شريط التقدم
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: Color(0xFFD81B60),
  ),

  // 🎨 الحوارات
  dialogTheme: const DialogTheme(
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
    ),
  ),

  // 🎨 الـ SnackBar
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: Color(0xFFD81B60),
    contentTextStyle: TextStyle(color: Colors.white),
  ),
);
