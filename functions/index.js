/**
 * ملف السيرفر (Backend) - متوافق مع firebase-admin v12+
 */
const functions = require("firebase-functions/v1"); // نستخدم v1 لضمان استقرار التريغر
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendChatNotification = functions.firestore
  .document("chat_rooms/{roomId}/messages/{messageId}")
  .onCreate(async (snapshot, context) => {
    
    const messageData = snapshot.data();
    if (!messageData) return;

    const receiverId = messageData.receiverId;
    const senderId = messageData.senderId;
    const text = messageData.text;

    if (!receiverId || !senderId) {
      console.log("بيانات ناقصة");
      return null;
    }

    try {
      // جلب اسم المرسل
      const senderDoc = await admin.firestore().collection("users").doc(senderId).get();
      const senderName = senderDoc.exists ? (senderDoc.data().full_name || "مستخدم") : "مستخدم";

      // جلب توكن المستلم
      const receiverDoc = await admin.firestore().collection("users").doc(receiverId).get();
      
      if (!receiverDoc.exists) return null;

      const fcmToken = receiverDoc.data().fcmToken;

      if (!fcmToken) {
        console.log("المستلم ليس لديه توكن:", receiverId);
        return null;
      }

      // 🔥🔥🔥 التغيير الجذري هنا: بناء الرسالة بالشكل الجديد 🔥🔥🔥
      const message = {
        token: fcmToken, // التوكن يوضع هنا مباشرة
        notification: {
          title: senderName,
          body: text,
        },
        data: {
          // ملاحظة: يجب أن تكون كل القيم هنا نصوص (String)
          type: "chat",
          senderId: senderId,
          roomId: context.params.roomId,
          click_action: "FLUTTER_NOTIFICATION_CLICK"
        },
        // إعدادات خاصة للأندرويد
        android: {
          priority: "high",
          notification: {
            channelId: "chat_channel_id", // القناة التي أنشأناها في Flutter
            clickAction: "FLUTTER_NOTIFICATION_CLICK",
            sound: "default"
          }
        },
        // إعدادات خاصة للآيفون
        apns: {
          payload: {
            aps: {
              sound: "default",
              contentAvailable: true
            }
          }
        }
      };

      // استخدام الدالة الجديدة send بدلاً من sendToDevice
      await admin.messaging().send(message);
      console.log("تم الإرسال بنجاح (V1 API) إلى:", receiverId);

    } catch (error) {
      console.error("خطأ أثناء الإرسال:", error);
    }
  });