import '../../../core/constants/app_colors.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/app_localizations.dart';
import '../../widgets/app_loading.dart';

class AskAiScreen extends StatefulWidget {
  const AskAiScreen({super.key});

  @override
  State<AskAiScreen> createState() => _AskAiScreenState();
}

class _AskAiScreenState extends State<AskAiScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  Timer? _typewriterTimer;

  bool get _isAiResponding =>
      _isLoading || (_typewriterTimer != null && _typewriterTimer!.isActive);

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final String? messagesJson = prefs.getString('ai_messages');
    if (messagesJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(messagesJson);
        setState(() {
          _messages = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
        });
        _scrollToBottom();
      } catch (e) {
        debugPrint("Error loading messages: $e");
      }
    }
  }

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final String messagesJson = jsonEncode(_messages);
    await prefs.setString('ai_messages', messagesJson);
  }

  Future<void> _clearMessages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('ai_messages');
    setState(() {
      _messages.clear();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _typewriterTimer?.cancel();
    super.dispose();
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) {
      return;
    }
    if (_isLoading ||
        (_typewriterTimer != null && _typewriterTimer!.isActive)) {
      return;
    }

    final prompt = _controller.text.trim();
    _controller.clear();

    setState(() {
      _messages.add({"isUser": true, "text": prompt});
      _messages.add({"isUser": false, "text": ""});
      _isLoading = true;
    });
    _saveMessages();

    _scrollToBottom();

    final response = await AiService.ask(prompt);

    setState(() {
      _isLoading = false;
    });

    if (response['success'] == true) {
      _typeWriterEffect(response['answer'] ?? "");
    } else {
      _typeWriterEffect(response['message'] ?? "Error");
    }
  }

  void _typeWriterEffect(String fullText) {
    int charIndex = 0;
    _typewriterTimer = Timer.periodic(const Duration(milliseconds: 20), (
      timer,
    ) {
      if (charIndex < fullText.length) {
        setState(() {
          _messages.last["text"] = fullText.substring(0, charIndex + 1);
        });
        charIndex++;
        if (charIndex % 5 == 0) {
          _scrollToBottom();
        }
      } else {
        setState(() {
          timer.cancel();
        });
        _saveMessages();
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.get('clear_chat_title')),
          content: Text(AppLocalizations.get('clear_chat_message')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.get('cancel')),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _clearMessages();
              },
              child: Text(
                AppLocalizations.get('delete'),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isAiResponding,
      child: Scaffold(
        backgroundColor: AppColors.bgPage,
        appBar: AppBar(
          backgroundColor: AppColors.navy,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _isAiResponding ? null : () => Navigator.pop(context),
            color: _isAiResponding ? Colors.white38 : Colors.white,
          ),
          title: Text(
            AppLocalizations.get('ask_ai_title'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _isAiResponding
                  ? null
                  : () {
                      if (_messages.isNotEmpty) {
                        _showClearDialog();
                      }
                    },
              color: _isAiResponding ? Colors.white38 : Colors.white,
              tooltip: AppLocalizations.get('delete_chat'),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length) {
                      return const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 12.0, left: 8.0),
                          child: SizedBox(
                            width: 24, 
                            height: 24, 
                            child: AppLoading()
                          ),
                        ),
                      );
                    }

                    final isUser = _messages[index]["isUser"];
                    final text = _messages[index]["text"];

                    return Align(
                      alignment: isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color: isUser ? AppColors.accent : AppColors.bgCard,
                          borderRadius: BorderRadius.circular(12).copyWith(
                            bottomRight: isUser
                                ? const Radius.circular(0)
                                : const Radius.circular(12),
                            bottomLeft: isUser
                                ? const Radius.circular(12)
                                : const Radius.circular(0),
                          ),
                          border: isUser
                              ? null
                              : Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          text,
                          style: TextStyle(
                            color: isUser ? Colors.white : AppColors.txtHigh,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.bgCard,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        enabled: !_isAiResponding,
                        decoration: InputDecoration(
                          hintText: _isAiResponding
                              ? AppLocalizations.get('ai_typing')
                              : AppLocalizations.get('type_message'),
                          hintStyle: const TextStyle(fontSize: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: AppColors.bgPage,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          isDense: true,
                        ),
                        onSubmitted: _isAiResponding
                            ? null
                            : (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: _isAiResponding ? null : _sendMessage,
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: _isAiResponding
                              ? Colors.grey
                              : AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
