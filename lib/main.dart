import 'package:flutter/material.dart';
import 'package:sakinah/screens/splash_screen.dart';
import 'package:sakinah/utils/theme.dart';

void main() {
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
      theme: AppTheme.lightTheme,
      locale: const Locale('ar'),
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
      home: const SplashScreen(),
    );
  }
}
