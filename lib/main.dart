import 'package:flutter/material.dart';
import 'package:sakinah/config.dart';
import 'package:sakinah/screens/splash_screen.dart';
import 'package:sakinah/utils/theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Force RTL for Arabic UI; English will be LTR.
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
      // Arabic is the default locale; English fallback.
      locale: const Locale('ar'),
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
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

