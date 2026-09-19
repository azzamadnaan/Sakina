import 'package:flutter/material.dart';
import 'package:sakinah/screens/splash_screen.dart';
import 'package:sakinah/utils/theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SakinahApp());
}

class SakinahApp extends StatelessWidget {
  const SakinahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'سكينة',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      locale: const Locale('ar'),               // العربية هي اللغة الأساسية
      supportedLocales: const [
        Locale('ar'),                           // العربية
        Locale('en'),                           // الإنجليزية (fallback)
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashScreen(),
    );
  }
}

