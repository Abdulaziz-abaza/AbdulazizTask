// const functions = require("firebase-functions");
// const admin = require("firebase-admin");

// admin.initializeApp();

// exports.sendNotificationToAll = functions.https.onRequest(async (req, res) => {
//   try {
//     const tokensSnapshot = await admin.firestore().collection("fcm_tokens").get();

//     if (tokensSnapshot.empty) {
//       return res.status(200).send("  لا يوجد توكنات لإرسال الإشعار.");
//     }

//     const tokens = [];
//     tokensSnapshot.forEach(doc => {
//       const token = doc.data().token;
//       if (token) tokens.push(token);
//     });

//     const message = {
//       notification: {
//         title: "📢 إشعار جديد!",
//         body: "تم إرسال إشعار إلى جميع المستخدمين 🎉",
//       },
//       data: {
//         click_action: "FLUTTER_NOTIFICATION_CLICK",
//         id: "1",
//         status: "done",
//       },
//       tokens: tokens
//     };

//     const response = await admin.messaging().sendMulticast(message);

//     res.status(200).send(`✅ تم إرسال ${response.successCount} إشعار! ✅`);
//   } catch (error) {
//     console.error("  خطأ أثناء إرسال الإشعار:", error);
//     res.status(500).send("  فشل في إرسال الإشعار");
//   }
// });
const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

// وظيفة Firebase Cloud Function لإرسال إشعار عند الوصول إلى الوقت المحدد
exports.sendScheduledNotification = functions.firestore
  .document("scheduledNotifications/{notificationId}")
  .onCreate(async (snap, context) => {
    const data = snap.data();
    const taskId = data.taskId;
    const title = data.title;
    const body = data.body;
    const sendAt = new Date(data.sendAt);

    // التأكد من أن الوقت المحدد قد وصل
    const now = new Date();
    if (sendAt <= now) {
      // إرسال إشعار باستخدام Firebase Cloud Messaging (FCM)
      const payload = {
        notification: {
          title: title,
          body: body,
        },
        topic: "all", // إذا كنت تريد إرسال إشعار لجميع المستخدمين
      };

      try {
        await admin.messaging().send(payload);
        console.log("✅ تم إرسال الإشعار بنجاح!");
        // حذف الوثيقة بعد إرسال الإشعار
        await snap.ref.delete();
      } catch (error) {
        console.error("  فشل في إرسال الإشعار: ", error);
      }
    } else {
      console.log("  الوقت المحدد للإشعار لم يحن بعد");
    }
  });
  exports.sendScheduledNotification = functions.firestore
  .document("scheduledNotifications/{notificationId}")
  .onCreate(async (snap, context) => {
    const data = snap.data();
    const taskId = data.taskId;
    const title = data.title;
    const body = data.body;
    const sendAt = new Date(data.sendAt);

    console.log(`✅ وقت الإرسال: ${sendAt}`);
    console.log(`✅ الوقت الحالي: ${new Date()}`);

    const now = new Date();
    if (sendAt <= now) {
      console.log(`✅ الوقت المحدد للإشعار قد وصل!`);

      const payload = {
        notification: {
          title: title,
          body: body,
        },
        topic: "all", // إذا كنت تريد إرسال إشعار لجميع المستخدمين
      };

      try {
        await admin.messaging().send(payload);
        console.log("✅ تم إرسال الإشعار بنجاح!");
        await snap.ref.delete();
      } catch (error) {
        console.error("  فشل في إرسال الإشعار: ", error);
      }
    } else {
      console.log("  الوقت المحدد للإشعار لم يحن بعد");
    }
  });
