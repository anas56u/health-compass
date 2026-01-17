/**
 * ملف السيرفر (Backend) - الحل النهائي
 */

// ✅ التغيير هنا: نستدعي النسخة الأولى (v1) مباشرة لتجنب المشاكل
const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendChatNotification = functions.firestore
  .document("chat_rooms/{roomId}/messages/{messageId}")
  .onCreate(async (snapshot, context) => {
    
    // 1. الحصول على البيانات
    const messageData = snapshot.data();
    if (!messageData) return;

    const receiverId = messageData.receiverId;
    const senderId = messageData.senderId;
    const text = messageData.text;

    if (!receiverId || !senderId) {
      console.log("بيانات الرسالة غير مكتملة");
      return null;
    }

    try {
      // 2. جلب اسم المرسل
      const senderDoc = await admin.firestore().collection("users").doc(senderId).get();
      const senderName = senderDoc.exists ? (senderDoc.data().fullName || "مستخدم") : "مستخدم";

      // 3. جلب توكن المستلم
      const receiverDoc = await admin.firestore().collection("users").doc(receiverId).get();
      
      if (!receiverDoc.exists) {
         console.log("المستلم غير موجود");
         return null;
      }

      const fcmToken = receiverDoc.data().fcmToken;

      if (!fcmToken) {
        console.log("المستلم ليس لديه توكن");
        return null;
      }

      // 4. تجهيز الإشعار
      const payload = {
        notification: {
          title: senderName,
          body: text,
          sound: "default",
          clickAction: "FLUTTER_NOTIFICATION_CLICK"
        },
        data: {
          type: "chat",
          senderId: senderId,
          roomId: context.params.roomId
        }
      };

      // 5. إرسال الإشعار
      await admin.messaging().sendToDevice(fcmToken, payload);
      console.log("تم إرسال الإشعار للمستخدم:", receiverId);

    } catch (error) {
      console.error("حدث خطأ:", error);
    }
  });