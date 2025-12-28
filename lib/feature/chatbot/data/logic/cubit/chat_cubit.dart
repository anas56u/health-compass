import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:health_compass/feature/chatbot/data/logic/cubit/chat_state.dart';
import 'package:health_compass/feature/chatbot/data/models/message_model.dart';

class ChatCubit extends Cubit<ChatState> {
  late final GenerativeModel _model;

  final String _apiKey = 'AIzaSyAf3C00S4oZ17IdGH-yzQ0VcnCBiTYXnag';

  ChatCubit() : super(const ChatState()) {
    _initModel();
  }

  void _initModel() {
    // إعداد الموديل مع التعليمات الطبية
    _model = GenerativeModel(
      model: 'gemini-3-flash-preview',
      apiKey: _apiKey,
      systemInstruction: Content.system("""
أنت "دليل"، مساعد طبي ذكي داخل تطبيق Health Compass.
دورك هو توجيه المستخدمين وتقديم نصائح صحية دقيقة وموثوقة.
تحدث بلهجة عربية ودودة، مهنية، ومطمئنة.
دائماً نبه المستخدم أن نصائحك لا تغني عن زيارة الطبيب.
"""),
    );

    // إضافة رسالة الترحيب الافتراضية عند فتح الشاشة
    emit(
      state.copyWith(
        messages: [
          MessageModel(
            text:
                "مرحباً بك! أنا **دليل** 🧭\nمساعدك الطبي الذكي في Health Compass.\n\nبمَ يمكنني أن أرشدك اليوم؟",
            isBot: true,
          ),
        ],
      ),
    );
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // 1. إضافة رسالة المستخدم إلى القائمة الحالية
    // ✅ هنا تم الإصلاح: استخدام List<MessageModel>.from لمنع خطأ dynamic
    final userMessage = MessageModel(text: text, isBot: false);
    List<MessageModel> currentMessages = List<MessageModel>.from(state.messages)
      ..add(userMessage);

    emit(
      state.copyWith(
        messages: currentMessages,
        status: ChatStatus.loading, // تفعيل مؤشر التحميل
      ),
    );

    try {
      // 2. إرسال النص إلى Gemini واستقبال الرد
      final content = [Content.text(text)];
      final response = await _model.generateContent(content);
      final botText =
          response.text ?? "عذراً، لم أستطع فهم ذلك، هل يمكنك التوضيح؟";

      // 3. إضافة رد البوت إلى القائمة
      final botMessage = MessageModel(text: botText, isBot: true);
      // ✅ وهنا أيضاً نستخدم نفس الإصلاح
      final updatedMessages = List<MessageModel>.from(state.messages)
        ..add(botMessage);

      emit(
        state.copyWith(messages: updatedMessages, status: ChatStatus.success),
      );
    } catch (e) {
      // في حالة الخطأ (مثل انقطاع النت)
      emit(
        state.copyWith(
          status: ChatStatus.failure,
          errorMessage: "حدث خطأ في الاتصال: $e",
        ),
      );
    }
  }
}
