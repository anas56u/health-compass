import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_compass/core/widgets/chat_bubble.dart';
import 'package:health_compass/feature/chatbot/data/logic/cubit/chat_cubit.dart';
import 'package:health_compass/feature/chatbot/data/logic/cubit/chat_state.dart';
import 'package:health_compass/feature/chatbot/ui/screens/voice_assistant_screen.dart';

class ChatBotScreen extends StatelessWidget {
  const ChatBotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // نقوم بإنشاء الكيوبت هنا
    return BlocProvider(
      create: (context) => ChatCubit(),
      child: const _ChatView(),
    );
  }
}

class _ChatView extends StatefulWidget {
  const _ChatView();

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final Color _primaryColor = const Color(0xFF0D9488);

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

  // ✅ دالة عرض نافذة التنبيه عند تجاوز الحد (مثل الشات الصوتي تماماً)
  void _showQuotaDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.hourglass_empty_rounded, color: Colors.orange, size: 30),
            SizedBox(width: 10),
            Text(
              "استراحة قصيرة ",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          "لقد تجاوزنا الحد المسموح من الأسئلة في الدقيقة.\n\nيرجى الانتظار دقيقة واحدة ثم المحاولة مجدداً.",
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "حسناً",
              style: TextStyle(
                color: _primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
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
        appBar: AppBar(
          backgroundColor: _primaryColor,
          elevation: 0,
          toolbarHeight: 70,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
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
                  radius: 20,
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/images/chatlogo.png'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'دليل',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'مساعدك الطبي الشخصي',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {
                // 💡 نقل المحادثة الحالية للشات الصوتي (ميزة احترافية)
                // نمرر نفس الكيوبت للشاشة التالية
                final chatCubit = context.read<ChatCubit>();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: chatCubit, // تمرير الحالة الحالية
                      child: const VoiceAssistantScreen(),
                    ),
                  ),
                );
              },
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mic, color: Colors.white, size: 25),
              ),
            ),
            const SizedBox(width: 8),
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

                  // 👇👇 معالجة الأخطاء الذكية 👇👇
                  if (state.status == ChatStatus.failure) {
                    bool isQuotaError =
                        state.errorMessage.toLowerCase().contains("quota") ||
                        state.errorMessage.contains("429") ||
                        state.errorMessage.toLowerCase().contains("limit");

                    if (isQuotaError) {
                      _showQuotaDialog(context); // عرض النافذة
                    } else {
                      // خطأ عادي (انترنت مثلاً)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.errorMessage),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  }
                },
                builder: (context, state) {
                  return ListView.builder(
                    controller: _scrollController,
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

            // منطقة الإدخال
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        onSubmitted: (value) {
                          context.read<ChatCubit>().sendMessage(value);
                          _controller.clear();
                        },
                        style: const TextStyle(fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'اسأل دليل عن صحتك...',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_primaryColor, const Color(0xFF14B8A6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () {
                          context.read<ChatCubit>().sendMessage(
                            _controller.text,
                          );
                          _controller.clear();
                        },
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
}
