import 'dart:async'; // 1. استيراد هذه المكتبة للتعامل مع الاشتراكات
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:health_compass/feature/chatbot/data/logic/cubit/chat_state.dart';
import 'package:health_compass/feature/chatbot/data/models/message_model.dart';
import 'package:uuid/uuid.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(const ChatState()) {
    _initModel();
    startNewChat();
  }

  late final GenerativeModel _model;
  late ChatSession _chatSession;

  // 🔑 ضع مفتاحك هنا
  final String _apiKey = 'AIzaSyAf3C00S4oZ17IdGH-yzQ0VcnCBiTYXnag';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? currentSessionId;
  StreamSubscription? _messagesSubscription; // 2. متغير لحفظ الاشتراك الحالي

  void _initModel() {
    _model = GenerativeModel(
      model: 'gemini-3-flash-preview',
      apiKey: _apiKey,
      systemInstruction: Content.system("""
أنت "دليل"، مساعد طبي أردني ذكي.
مهمتك: تقديم نصائح طبية وإرشادات بخصوص (السكري، الضغط، الكوليسترول، وأمراض القلب).

القواعد:
1. تحدث باللهجة الأردنية الودودة (مثال: "يا هلا"، "سلامتك"، "ما تشوف شر").
2. اجعل إجاباتك مفيدة، علمية دقيقة، ومختصرة.
3. إذا سألك المستخدم عن شيء خارج اختصاصك، اعتذر بلطف وأخبره أنك مختص فقط بالأمراض المزمنة المذكورة.

مهم جداً: يجب أن تنهي *كل* رد من ردودك بهذه الجملة الثابتة في سطر جديد ومستقل:
"تذكير: معلوماتي للإرشاد والتوعية بس، وما بتغني أبداً عن زيارة الطبيب للتشخيص والعلاج."
"""),
    );
  }

  void startNewChat() {
    _messagesSubscription?.cancel(); // إلغاء أي استماع سابق
    currentSessionId = const Uuid().v4();
    _chatSession = _model.startChat();

    emit(
      state.copyWith(
        messages: [
          bot_MessageModel(
            text: "هلا بك! أنا دليل، كيف بقدر أساعدك اليوم؟",
            isBot: true,
            timestamp: DateTime.now(),
          ),
        ],
        status: ChatStatus.success,
      ),
    );
  }

  Stream<QuerySnapshot> getHistoryStream() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('sessions')
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }

  void loadSession(String sessionId) {
    // ✅ 3. إلغاء الاشتراك السابق قبل بدء واحد جديد لمنع تداخل الرسائل
    _messagesSubscription?.cancel();

    currentSessionId = sessionId;
    emit(state.copyWith(messages: [], status: ChatStatus.loading));

    final user = _auth.currentUser;
    if (user == null) return;

    // ✅ حفظ الاشتراك في المتغير
    _messagesSubscription = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('sessions')
        .doc(sessionId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .listen((snapshot) {
          final messages = snapshot.docs
              .map((doc) => bot_MessageModel.fromMap(doc.data()))
              .toList();

          // ملاحظة: هنا نبدأ جلسة جديدة مع الذكاء الاصطناعي (ذاكرة نظيفة)
          // لكن نعرض الرسائل القديمة للمستخدم
          _chatSession = _model.startChat();

          emit(state.copyWith(messages: messages, status: ChatStatus.success));
        });
  }

  Future<void> sendMessage(String text) async {
    final user = _auth.currentUser;
    if (currentSessionId == null) startNewChat();

    if (text.isEmpty || user == null) return;

    final userMessage = bot_MessageModel(
      text: text,
      isBot: false,
      timestamp: DateTime.now(),
    );

    // تحديث الواجهة (Optimistic UI)
    emit(
      state.copyWith(
        messages: [...state.messages, userMessage],
        status: ChatStatus.loading,
      ),
    );

    try {
      // 1. الحفظ في Firebase
      await _saveMessageToFirebase(userMessage);
      await _updateSessionInfo(text);

      // 2. الإرسال لـ Gemini
      final response = await _chatSession.sendMessage(Content.text(text));
      final botText = response.text ?? "عذراً، لم أفهم.";

      final botMessage = bot_MessageModel(
        text: botText,
        isBot: true,
        timestamp: DateTime.now(),
      );

      // 3. حفظ الرد
      await _saveMessageToFirebase(botMessage);
      await _updateSessionInfo(botText);

      // التحديث في الواجهة
      emit(
        state.copyWith(
          messages: [...state.messages, botMessage],
          status: ChatStatus.success,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: ChatStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _saveMessageToFirebase(bot_MessageModel msg) async {
    final user = _auth.currentUser;
    await _firestore
        .collection('users')
        .doc(user!.uid)
        .collection('sessions')
        .doc(currentSessionId)
        .collection('messages')
        .add(msg.toMap());
  }

  Future<void> _updateSessionInfo(String lastMsg) async {
    final user = _auth.currentUser;
    await _firestore
        .collection('users')
        .doc(user!.uid)
        .collection('sessions')
        .doc(currentSessionId)
        .set({
          'sessionId': currentSessionId,
          'preview': lastMsg,
          'lastMessageTime': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  // ✅ دالة لإغلاق الاشتراك عند تدمير الكيوبت
  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
