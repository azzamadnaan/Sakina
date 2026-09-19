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
  bool _fallbackShown = false;
  bool _navigated = false;
  Timer? _fallbackTimer;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.asset(
        'assets/images/splash_video.mp4',
      );
      await _controller.initialize();
      await _controller.setVolume(1.0);
      await _controller.setLooping(false);
      await _controller.play();

      _controller.addListener(_videoListener);

      if (mounted) setState(() {});

      // ⏱️ احتياط: انتقل بعد 15 ثانية
      _fallbackTimer = Timer(const Duration(seconds: 15), _navigateToChat);
    } catch (e) {
      debugPrint('Video failed: $e');
      _showFallback();
    }
  }

  void _videoListener() {
    if (_controller.value.isInitialized &&
        _controller.value.position >= _controller.value.duration &&
        _controller.value.duration > Duration.zero) {
      _navigateToChat();
    }
  }

  void _showFallback() {
    if (_fallbackShown || !mounted) return;
    setState(() => _fallbackShown = true);
    Timer(const Duration(seconds: 3), _navigateToChat);
  }

  void _navigateToChat() {
    if (_navigated || !mounted) return;
    _navigated = true;
    _fallbackTimer?.cancel();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AiChatScreen()),
    );
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    try {
      _controller.removeListener(_videoListener);
      _controller.dispose();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🎨 حالة الفشل
    if (_fallbackShown) {
      return const Scaffold(
        backgroundColor: Color(0xFFD81B60),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.spa, size: 80, color: Colors.white),
              SizedBox(height: 20),
              CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      );
    }

    // 🎬 حالة الفيديو
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

    // ⏳ حالة التحميل
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
