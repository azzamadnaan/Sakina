import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:sakinah/screens/ai_chat_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final VideoPlayerController _controller;
  bool _fallbackShown = false; // إذا فشل الفيديو نُظهر fallback.

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  /// يحمِّل الفيديو من الـ assets.
  /// إذا غيرت اسم الملف أو مساره، عدِّل السطر داخل `VideoPlayerController.asset(...)`.
  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.asset(
          'assets/images/splash_video.mp4') // <‑‑ عدِّل المسار هنا إذا لزم
        ..initialize().then((_) {
          setState(() {});
          _controller.play();
          _controller.setLooping(false);
          _controller.addListener(_videoListener);
        });
    } catch (_) {
      _showFallback();
    }
  }

  void _videoListener() {
    if (_controller.value.isInitialized &&
        _controller.value.position >= _controller.value.duration) {
      _navigateToChat();
    }
  }

  /// تُظهر شاشة بديلة في حال فشل تشغيل الفيديو.
  void _showFallback() {
    if (_fallbackShown) return;
    _fallbackShown = true;
    // بديل بسيط لمدة 3 ثوانٍ ثم الانتقال.
    Timer(const Duration(seconds: 3), _navigateToChat);
  }

  void _navigateToChat() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AiChatScreen()),
    );
  }

  @override
  void dispose() {
    if (!_fallbackShown) {
      _controller.removeListener(_videoListener);
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // حالة fallback (فشل الفيديو أو لم يُضيف بعد)
    if (_fallbackShown) {
      return Scaffold(
        backgroundColor: const Color(0xFFB71C1C),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.spa, size: 80, color: Colors.white),
              SizedBox(height: 20),
              CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      );
    }

    // عندما يـُجهّز الفيديو
    if (_controller.value.isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
        ),
      );
    }

    // حالة الانتظار أثناء تحميل الأصول
    return Scaffold(
      backgroundColor: Colors.black,
      body: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
