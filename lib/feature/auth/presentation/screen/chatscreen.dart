import 'package:flutter/material.dart';
// 1. استيراد الحارس
import 'package:health_compass/core/widgets/doctor_link_guard.dart';

// -------------------- المودل والبيانات --------------------

class ChatMessage {
  final String text;
  final bool isMe;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isMe,
    required this.timestamp,
  });
}

// -------------------- الشاشة الرئيسية --------------------

class ChatScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const ChatScreen({super.key, this.onBack});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Color _primaryColor = const Color(0xFF0D9488);

  // بيانات وهمية للتجربة
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: "ان شاء الله، شكراً دكتور",
      isMe: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
    ),
    ChatMessage(
      text: "الرجاء حجز موعد غدا صباحا او بعد الظهر للمراجعة",
      isMe: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
    ChatMessage(
      text: "نعم لكن لا ادري ما السبب، أشعر بدوار خفيف أيضاً",
      isMe: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    ChatMessage(
      text: "وعليكم السلام، هل كنت تلتزم باخذ الادويه في وقتها؟",
      isMe: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 6)),
    ),
    ChatMessage(
      text: "السلام عليكم دكتور، اعاني من ارتفاع في السكر",
      isMe: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 7)),
    ),
    ChatMessage(
      text: "مرحباً دكتور، كيف حالك؟",
      isMe: true,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _messages.insert(
        0,
        ChatMessage(
          text: _controller.text,
          isMe: true,
          timestamp: DateTime.now(),
        ),
      );
    });
    _controller.clear();
    _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  String _formatTime(DateTime date) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hour = date.hour > 12
        ? date.hour - 12
        : (date.hour == 0 ? 12 : date.hour);
    final period = date.hour >= 12 ? "م" : "ص";
    return "$hour:${twoDigits(date.minute)} $period";
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    // 2. تطبيق الحارس هنا
    return DoctorLinkGuard(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFFF0F2F5),
          appBar: AppBar(
            backgroundColor: _primaryColor,
            elevation: 0,
            titleSpacing: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.grey),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "د. محمد أبو موسى",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.greenAccent[400],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          "متصل الآن",
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.videocam_rounded, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.call_rounded, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    final bool isFirstInSequence =
                        index == 0 || _messages[index - 1].isMe != message.isMe;
                    final bool isNewDay =
                        index == _messages.length - 1 ||
                        !_isSameDay(
                          message.timestamp,
                          _messages[index + 1].timestamp,
                        );

                    return Column(
                      children: [
                        if (isNewDay) _buildDateDivider(message.timestamp),
                        _buildEnhancedBubble(message, isFirstInSequence),
                      ],
                    );
                  },
                ),
              ),
              _buildModernInputArea(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateDivider(DateTime date) {
    final now = DateTime.now();
    String text;
    if (_isSameDay(date, now)) {
      text = "اليوم";
    } else if (_isSameDay(date, now.subtract(const Duration(days: 1)))) {
      text = "أمس";
    } else {
      text = "${date.year}/${date.month}/${date.day}";
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey[700],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEnhancedBubble(ChatMessage msg, bool isFirstInSequence) {
    return Align(
      alignment: msg.isMe ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 4,
          top: isFirstInSequence ? 4 : 0,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: msg.isMe ? const Color(0xFF0D9488) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(msg.isMe && isFirstInSequence ? 4 : 16),
            bottomRight: Radius.circular(!msg.isMe && isFirstInSequence ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                msg.text,
                style: TextStyle(
                  color: msg.isMe ? Colors.white : Colors.black87,
                  fontSize: 15,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    _formatTime(msg.timestamp),
                    style: TextStyle(
                      color: msg.isMe ? Colors.white70 : Colors.grey[500],
                      fontSize: 10,
                    ),
                  ),
                  if (msg.isMe) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.done_all, size: 14, color: Colors.white70),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: Colors.white,
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(
                Icons.add_rounded,
                size: 28,
                color: Color(0xFF0D9488),
              ),
              onPressed: () {},
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F2F5),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _controller,
                  maxLines: 5,
                  minLines: 1,
                  decoration: const InputDecoration(
                    hintText: 'اكتب رسالة...',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sendMessage,
              child: CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFF0D9488),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}