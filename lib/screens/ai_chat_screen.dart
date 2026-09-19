import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sakinah/services/gemini_service.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<_ChatMessage> _messages = [];
  final GeminiService _gemini = GeminiService();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  bool _isReady = false;
  static const String _chatHistoryKey = 'chat_history';

  static const String _welcomeMessage =
      'السلام عليكم ورحمة الله وبركاته 🌸\n\n'
      'أنا "سكينة"، رفيقتك الروحية.\n'
      'أنا هنا لمساعدتك في أمور دينك: تفسير آية، حديث، ذكر، دعاء، '
      'أو نصيحة إيمانية.\n\n'
      'كيف أستطيع خدمتك اليوم؟';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadHistory();
    if (!mounted) return;
    if (_messages.isEmpty) {
      setState(() {
        _messages.add(_ChatMessage(
          role: Role.assistant,
          content: _welcomeMessage,
          timestamp: DateTime.now(),
        ));
        _isReady = true;
      });
      await _saveHistory();
    } else {
      setState(() => _isReady = true);
    }
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_chatHistoryKey);
      if (stored != null && stored.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(stored);
        setState(() {
          _messages.addAll(
            decoded.map((e) => _ChatMessage.fromMap(e as Map<String, dynamic>)),
          );
        });
      }
    } catch (e) {
      debugPrint('Load history error: $e');
    }
  }

  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString =
          jsonEncode(_messages.map((e) => e.toMap()).toList());
      await prefs.setString(_chatHistoryKey, jsonString);
    } catch (e) {
      debugPrint('Save history error: $e');
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(_ChatMessage(
        role: Role.user,
        content: text,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();
    await _saveHistory();

    try {
      // آخر 10 رسائل فقط
      final recent = _messages.length > 10
          ? _messages.sublist(_messages.length - 10)
          : _messages.toList();

      final payload = recent
          .map((m) => {
                'role': m.role == Role.user ? 'user' : 'model',
                'content': m.content,
              })
          .toList();

      final response = await _gemini.sendMessage(payload);

      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(
          role: Role.assistant,
          content: response,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
      await _saveHistory();
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(
          role: Role.assistant,
          content: 'عذرًا، حدث خطأ في الاتصال 🌸\n'
              'تأكد من الإنترنت وحاول مرة أخرى.',
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
      await _saveHistory();
      _scrollToBottom();
    }
  }

  Future<void> _clearChat() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('مسح المحادثة'),
        content: const Text('هل تريد مسح كل الرسائل؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('مسح', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok != true) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chatHistoryKey);
    setState(() {
      _messages.clear();
      _messages.add(_ChatMessage(
        role: Role.assistant,
        content: _welcomeMessage,
        timestamp: DateTime.now(),
      ));
    });
    await _saveHistory();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFD81B60),
        title: const Text(
          'سكينة ❤️',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.white),
            tooltip: 'مسح المحادثة',
            onPressed: _clearChat,
          ),
        ],
      ),
      body: !_isReady
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFD81B60)),
            )
          : Column(
              children: [
                Expanded(child: _buildChatList()),
                if (_isLoading) _buildLoadingIndicator(),
                _buildInputBar(),
              ],
            ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      reverse: true,
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[_messages.length - 1 - index];
        final isUser = msg.role == Role.user;
        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(12),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: isUser
                  ? const Color(0xFFD81B60)
                  : const Color(0xFFFCE4EC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              msg.content,
              style: TextStyle(
                color: isUser ? Colors.white : const Color(0xFF4A1E2C),
                fontSize: 16,
                height: 1.5,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFFD81B60),
            ),
          ),
          SizedBox(width: 8),
          Text(
            'سكينة تفكر...',
            style: TextStyle(
              color: Color(0xFFD81B60),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                textDirection: TextDirection.rtl,
                enabled: !_isLoading,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: 'اكتب رسالتك...',
                  fillColor: const Color(0xFFFCE4EC),
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send),
              color: const Color(0xFFD81B60),
              onPressed: _isLoading ? null : _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}

enum Role { user, assistant, system }

class _ChatMessage {
  final Role role;
  final String content;
  final DateTime timestamp;

  _ChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
  });

  factory _ChatMessage.fromMap(Map<String, dynamic> map) {
    return _ChatMessage(
      role: Role.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => Role.assistant,
      ),
      content: map['content'] as String? ?? '',
      timestamp:
          DateTime.tryParse(map['timestamp'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'role': role.name,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
      };
}
