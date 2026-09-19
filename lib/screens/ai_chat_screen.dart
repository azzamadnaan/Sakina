import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sakinah/services/gemini_service.dart';
import 'package:sakinah/utils/theme.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;
  final GeminiService _gemini = GeminiService();
  static const String _chatHistoryKey = 'chat_history';

  @override
  void initState() {
    super.initState();
    _loadHistory();
    if (_messages.isEmpty) {
      _addSystemMessage(_welcomeMessage);
    }
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_chatHistoryKey);
    if (stored != null) {
      final List<dynamic> decoded = jsonDecode(stored);
      setState(() {
        _messages.addAll(decoded.map((e) => _ChatMessage.fromMap(e)));
      });
    }
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(_messages.map((e) => e.toMap()).toList());
    await prefs.setString(_chatHistoryKey, jsonString);
  }

  void _addSystemMessage(String text) {
    setState(() {
      _messages.add(_ChatMessage(
        role: Role.assistant,
        content: text,
        timestamp: DateTime.now(),
      ));
    });
    _saveHistory();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(
        role: Role.user,
        content: text,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });
    _controller.clear();
    await _saveHistory();

    // Keep only last 10 messages for context.
    final recent = _messages
        .where((m) => m.role != Role.system)
        .skip((_messages.length - 10).clamp(0, _messages.length))
        .toList();

    final payload = recent
        .map((m) => {'role': m.role.name, 'content': m.content})
        .toList();

    final response = await _gemini.sendMessage(payload);

    setState(() {
      _messages.add(_ChatMessage(
        role: Role.assistant,
        content: response,
        timestamp: DateTime.now(),
      ));
      _isLoading = false;
    });
    await _saveHistory();
  }

  Future<void> _clearChat() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chatHistoryKey);
    setState(() {
      _messages.clear();
      _addSystemMessage(_welcomeMessage);
    });
  }

  static const String _welcomeMessage = '''
السلام عليكم ورحمة الله وبركاته 🌸

أنا "سكينة"، رفيقتك الروحية.
أنا هنا لمساعدتك في أمور دينك: تفسير آية، حديث، ذكر، دعاء، 
أو نصيحة إيمانية.

كيف أستطيع خدمتك اليوم؟
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سكينة ❤️'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'مسح الدردشة',
            onPressed: _clearChat,
          ),
        ],
      ),
      body: Column(
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
      padding: const EdgeInsets.all(12),
      reverse: true,
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages.reversed.toList()[index];
        final isUser = msg.role == Role.user;
        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(12),
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75),
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
          CircularProgressIndicator(),
          SizedBox(width: 8),
          Text('سكينة تفكر...',
              style: TextStyle(fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return SafeArea(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  hintText: 'اكتب رسالتك...',
                  fillColor: Colors.white,
                  filled: true,
                ),
                enabled: !_isLoading,
                onSubmitted: (_) => _sendMessage(),
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
      role: Role.values.firstWhere((e) => e.name == map['role']),
      content: map['content'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
        'role': role.name,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
      };
}

