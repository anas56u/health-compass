import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:health_compass/feature/chatbot/data/logic/cubit/chat_cubit.dart';
import 'package:health_compass/feature/chatbot/data/logic/cubit/chat_state.dart';

class VoiceAssistantScreen extends StatelessWidget {
  const VoiceAssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatCubit(),
      child: const _VoiceView(),
    );
  }
}

class _VoiceView extends StatefulWidget {
  const _VoiceView();

  @override
  State<_VoiceView> createState() => _VoiceViewState();
}

class _VoiceViewState extends State<_VoiceView> {
  // ألوان الثيم
  final Color _primaryColor = const Color(0xFF0D9488);
  final Color _accentColor = const Color(0xFFE0F2F1);

  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;

  bool _isListening = false;
  bool _isSpeaking = false;
  String _liveText = "";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _initTts();
  }

  void _initTts() async {
    await _flutterTts.setLanguage("ar-SA");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setIosAudioCategory(
      IosTextToSpeechAudioCategory.playback,
      [IosTextToSpeechAudioCategoryOptions.defaultToSpeaker],
    );

    _flutterTts.setStartHandler(() {
      setState(() {
        _isSpeaking = true;
        _isListening = false;
        _speech.stop();
      });
    });

    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
        _liveText = "";
      });
    });

    _flutterTts.setErrorHandler((msg) {
      setState(() => _isSpeaking = false);
    });
  }

  void _listen(BuildContext context) async {
    // 1. إذا كان البوت يتحدث -> نوقفه
    if (_isSpeaking) {
      await _flutterTts.stop();
      setState(() => _isSpeaking = false);
    }

    // 2. إذا لم يكن يسجل -> ابدأ التسجيل
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          // هذا الجزء يعمل في حال توقف المستخدم عن الكلام وسكت (Auto Stop)
          if (status == 'done' || status == 'notListening') {
            setState(() => _isListening = false);
            // نرسل فقط إذا كان النص موجوداً (لم يرسل يدوياً بعد)
            if (_liveText.isNotEmpty) {
              context.read<ChatCubit>().sendMessage(_liveText);
              _liveText = ""; // نفرغ النص لضمان عدم إرساله مرتين
            }
          }
        },
        onError: (val) => print('onError: $val'),
      );

      if (available) {
        setState(() {
          _isListening = true;
          _liveText = "";
        });
        _speech.listen(
          localeId: 'ar_JO',
          onResult: (val) {
            setState(() {
              _liveText = val.recognizedWords;
            });
          },
        );
      }
    }
    // 3. ✅ الزر السحري (Manual Stop): المستخدم ضغط لإنهاء الكلام وإرسال الرد فوراً
    else {
      setState(() => _isListening = false);
      _speech.stop();

      // إرسال فوري دون انتظار الـ Status
      if (_liveText.isNotEmpty) {
        context.read<ChatCubit>().sendMessage(_liveText);
        _liveText = ""; // نفرغ النص هنا حتى لا يرسله الـ onStatus مرة أخرى
      }
    }
  }

  void _speak(String text) async {
    if (text.isNotEmpty) {
      await _flutterTts.speak(text);
    }
  }

  @override
  void dispose() {
    _speech.stop();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, _accentColor],
          ),
        ),
        child: BlocConsumer<ChatCubit, ChatState>(
          listener: (context, state) {
            if (state.status == ChatStatus.success &&
                state.messages.isNotEmpty) {
              final lastMsg = state.messages.last;
              if (lastMsg.isBot) {
                _speak(lastMsg.text);
              }
            }
            if (state.status == ChatStatus.failure) {
              String errorMsg = state.errorMessage.contains("Quota")
                  ? "عذراً، تجاوزت الحد المسموح. يرجى الانتظار دقيقة"
                  : "عذراً، حدث خطأ في الاتصال";

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(errorMsg),
                  backgroundColor: _primaryColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              _speak("عذراً، حاول مرة أخرى");
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: IconButton(
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: _primaryColor.withOpacity(0.8),
                          size: 38,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),

                  const Spacer(flex: 1),

                  // الأفاتار
                  AvatarGlow(
                    animate: _isSpeaking,
                    glowColor: _primaryColor,
                    duration: const Duration(milliseconds: 2000),
                    repeat: true,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _primaryColor.withOpacity(0.15),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const CircleAvatar(
                        radius: 80,
                        backgroundColor: Colors.white,
                        backgroundImage: AssetImage(
                          'assets/images/chatlogo.png',
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 80,
                    child: Center(
                      child: state.status == ChatStatus.loading
                          ? SizedBox(
                              width: 30,
                              height: 30,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _primaryColor.withOpacity(0.7),
                                ),
                              ),
                            )
                          : const SizedBox(),
                    ),
                  ),

                  const Spacer(flex: 1),

                  // زر المايكروفون (الزر الذكي)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 50),
                    child: AvatarGlow(
                      animate: _isListening,
                      glowColor: _primaryColor,
                      duration: const Duration(milliseconds: 1500),
                      repeat: true,
                      child: GestureDetector(
                        onTap: () => _listen(context),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            // إذا يسجل (يعني زر توقف) -> ممتلئ بلون الثيم
                            // إذا واقف (يعني زر تسجيل) -> فارغ أبيض
                            color: _isListening ? _primaryColor : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: _primaryColor, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: _primaryColor.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            // ⏹️ مربع = اضغط للإرسال وإنهاء الكلام
                            // 🎙️ مايك = اضغط للتحدث
                            _isListening
                                ? Icons.stop_rounded
                                : Icons.mic_none_rounded,
                            color: _isListening ? Colors.white : _primaryColor,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
