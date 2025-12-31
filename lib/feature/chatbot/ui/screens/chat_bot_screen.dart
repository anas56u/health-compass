import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_compass/core/widgets/chat_bubble.dart';
import 'package:health_compass/core/widgets/chat_drawer.dart';
import 'package:health_compass/feature/chatbot/data/logic/cubit/chat_cubit.dart';
import 'package:health_compass/feature/chatbot/data/logic/cubit/chat_state.dart';
import 'package:health_compass/feature/chatbot/ui/screens/chat_history_screen.dart';
import 'package:health_compass/feature/chatbot/ui/screens/voice_assistant_screen.dart';

class ChatBotScreen extends StatelessWidget {
  final VoidCallback? onBack;

  const ChatBotScreen({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatCubit(),
      child: _ChatView(onBack: onBack),
    );
  }
}

class _ChatView extends StatefulWidget {
  final VoidCallback? onBack;
  const _ChatView({this.onBack});

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final Color _primaryColor = const Color(0xFF0D9488);
  bool _isTyping = false; // ✅ متغير لمراقبة حالة الكتابة

  final List<String> _suggestions = [
    "ما هي أعراض السكري؟",
    "نصائح لخفض الكوليسترول",
    "كيف أحافظ على صحة قلبي؟",
    "جدول غذائي لمرضى الضغط",
  ];

  @override
  void initState() {
    super.initState();
    // ✅ مراقبة النص لتغيير لون زر الإرسال
    _controller.addListener(() {
      setState(() {
        _isTyping = _controller.text.trim().isNotEmpty;
      });
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutQuad,
        );
      }
    });
  }

  void _handleSend([String? text]) {
    final messageText = text ?? _controller.text.trim();
    if (messageText.isEmpty) return;

    context.read<ChatCubit>().sendMessage(messageText);
    _controller.clear();
    // ستعود حالة الكتابة تلقائياً لـ false بسبب الليسنر
  }

  void _openHistory(BuildContext context) {
    final chatCubit = context.read<ChatCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: chatCubit,
          child: const ChatHistoryScreen(),
        ),
      ),
    );
  }

  void _openVoiceAssistant(BuildContext context) {
    final chatCubit = context.read<ChatCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: chatCubit,
          child: const VoiceAssistantScreen(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        drawer: const ChatDrawer(),

        // --- 1. الشريط العلوي ---
        appBar: AppBar(
          backgroundColor: _primaryColor,
          elevation: 0,
          toolbarHeight: 70,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
          ),
          leading: widget.onBack != null
              ? IconButton(
                  onPressed: widget.onBack,
                  icon: const Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Colors.white,
                  ),
                )
              : Builder(
                  builder: (context) => IconButton(
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    icon: const Icon(
                      Icons.menu_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 18,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundImage: AssetImage('assets/images/chatlogo.png'),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'دليل',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'مساعدك الطبي',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () => _openHistory(context),
              tooltip: "سجل المحادثات",
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.history_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),

        body: Column(
          children: [
            Expanded(
              child: BlocConsumer<ChatCubit, ChatState>(
                listener: (context, state) {
                  if (state.status == ChatStatus.success ||
                      state.status == ChatStatus.loading) {
                    _scrollToBottom();
                  }
                },
                builder: (context, state) {
                  // --- 2. حالة الشاشة الفارغة ---
                  if (state.messages.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    // إضافة فيزياء للحركة الطبيعية
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final msg = state.messages[index];
                      return ChatBubble(
                        text: msg.text,
                        isBot: msg.isBot,
                        primaryColor: _primaryColor,
                      );
                    },
                  );
                },
              ),
            ),

            // مؤشر الكتابة
            BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                if (state.status == ChatStatus.loading) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "دليل يكتب الآن...",
                          style: TextStyle(
                            color: _primaryColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // --- 3. منطقة الإدخال ---
            SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // زر المحادثة الصوتية
                    Container(
                      decoration: BoxDecoration(
                        color: _primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () => _openVoiceAssistant(context),
                        icon: Icon(
                          Icons.mic_rounded,
                          color: _primaryColor,
                          size: 26,
                        ),
                        tooltip: "تحدث صوتياً",
                      ),
                    ),
                    const SizedBox(width: 10),

                    // حقل الكتابة
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F7FA),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: TextField(
                          controller: _controller,
                          onSubmitted: (_) => _handleSend(),
                          textInputAction: TextInputAction.send,
                          style: const TextStyle(fontSize: 15),
                          decoration: InputDecoration(
                            hintText: 'اكتب سؤالك هنا...',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // ✅ زر الإرسال التفاعلي
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        // تغيير اللون بناءً على حالة الكتابة
                        color: _isTyping ? _primaryColor : Colors.grey.shade300,
                        shape: BoxShape.circle,
                        boxShadow: _isTyping
                            ? [
                                BoxShadow(
                                  color: _primaryColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                        // تعطيل الزر إذا كان النص فارغاً
                        onPressed: _isTyping ? () => _handleSend() : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ودجت الشاشة الفارغة
  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.health_and_safety_rounded,
              size: 60,
              color: _primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "مرحباً بك في دليل!",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
              fontFamily: 'Tajawal',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "أنا هنا لمساعدتك في الإجابة على استفساراتك الطبية.\nيمكنك البدء بسؤال أو اختيار مما يلي:",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 30),

          // الاقتراحات
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: _suggestions.map((suggestion) {
              return ActionChip(
                elevation: 0,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: _primaryColor.withOpacity(0.3)),
                ),
                avatar: Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 18,
                  color: _primaryColor,
                ),
                label: Text(
                  suggestion,
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
                onPressed: () => _handleSend(suggestion),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
