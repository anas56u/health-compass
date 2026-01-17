import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:health_compass/core/widgets/doctor_link_guard.dart';
import 'package:health_compass/feature/auth/data/model/masseag_model.dart';
import 'package:health_compass/feature/auth/data/model/user_model.dart';
// استدعاء الريبو والمودل
import 'package:health_compass/feature/chat/repo/chat_repo.dart'; 

class ChatScreen extends StatefulWidget {
  final UserModel otherUser; 
  final VoidCallback? onBack;

  const ChatScreen({super.key, required this.otherUser, this.onBack});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ChatRepo _chatRepo = ChatRepo(); // نستخدم الريبو هنا
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;
    
    // حفظ النص ومسح الحقل فوراً لتجربة مستخدم أفضل
    String textToSend = _controller.text;
    _controller.clear();

    try {
      await _chatRepo.sendMessage(
        receiverId: widget.otherUser.uid,
        text: textToSend,
      );
    } catch (e) {
      // يمكنك إظهار سناك بار في حال الفشل
      print("Error sending message: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return DoctorLinkGuard(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFFF0F2F5),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0D9488),
            // ... (نفس تصميم الـ AppBar السابق)
            title: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white,
                  backgroundImage: (widget.otherUser.profileImage != null && widget.otherUser.profileImage!.isNotEmpty)
                      ? NetworkImage(widget.otherUser.profileImage!)
                      : null,
                  child: (widget.otherUser.profileImage == null || widget.otherUser.profileImage!.isEmpty)
                      ? const Icon(Icons.person, color: Colors.grey)
                      : null,
                ),
                const SizedBox(width: 15),
                Text(
                  widget.otherUser.fullName,
                  style: const TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.white
                  ),
                ),
              ],
            ),
             leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Column(
            children: [
              // قائمة الرسائل المتصلة بـ Firebase
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _chatRepo.getMessages(widget.otherUser.uid),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text("حدث خطأ: ${snapshot.error}"));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // تحويل البيانات القادمة من فايربيس إلى قائمة مودل
                    var docs = snapshot.data!.docs;
                    
                    return ListView.builder(
                      reverse: true, // نبدأ من الأسفل
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> data = docs[index].data() as Map<String, dynamic>;
                        MessageModel message = MessageModel.fromMap(data);

                        // تحديد هل أنا المرسل أم لا
                        bool isMe = message.senderId == _auth.currentUser!.uid;

                        return _buildMessageBubble(message, isMe);
                      },
                    );
                  },
                ),
              ),
              _buildInputArea(),
            ],
          ),
        ),
      ),
    );
  }

  // ودجت بناء الفقاعة (مبسطة عن السابقة لتركيز الكود)
  Widget _buildMessageBubble(MessageModel message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF0D9488) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 4 : 16),
            bottomRight: Radius.circular(!isMe ? 4 : 16),
          ),
          boxShadow: [
             BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
               // هنا يمكنك استخدام دالة التنسيق _formatTime التي كتبتها سابقاً
              "${message.timestamp.hour}:${message.timestamp.minute}",
              style: TextStyle(
                color: isMe ? Colors.white70 : Colors.grey[500],
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'اكتب رسالة...',
                filled: true,
                fillColor: const Color(0xFFF0F2F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: const Color(0xFF0D9488),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}