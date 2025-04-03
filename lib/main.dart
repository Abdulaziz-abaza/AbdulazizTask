// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import '/auth/authscreen.dart';
// import 'dart:ui';
// import 'package:firebase_core/firebase_core.dart';
// import '/screens/home.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(new MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: StreamBuilder(
//         stream: FirebaseAuth.instance.authStateChanges(),
//         builder: (context, usersnapshot) {
//           if (usersnapshot.hasData) {
//             return Home();
//           } else {
//             return AuthScreen();
//           }
//         },
//       ),
//       debugShowCheckedModeBanner: false,
//       theme:
//           ThemeData(brightness: Brightness.dark, primaryColor: Colors.purple),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '/auth/authscreen.dart';
import '/screens/home.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("📢 إشعار في الخلفية: ${message.notification?.title}");
}

// إعداد إشعارات محلية
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // إعداد الإشعارات المحلية
  var initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  var initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    setupFirebaseMessaging();
  }

//TEST
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  List<String> notifications = []; // قائمة تخزين الإشعارات

  void setupFirebaseMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      String title = message.notification?.title ?? "No Title";
      String body = message.notification?.body ?? "No Body";
      Timestamp timestamp = Timestamp.now();

      // حفظ الإشعار في Firestore
      await FirebaseFirestore.instance.collection("notifications").add({
        "title": title,
        "body": body,
        "timestamp": timestamp,
      });

      // عرض الإشعار في التطبيق
      showNotification(title, body);
    });

    String? token = await messaging.getToken();
    print("📱 FCM Token: $token");
  }

  Future<void> showNotification(String title, String body) async {
    var androidDetails = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.high,
      priority: Priority.high,
    );

    var generalNotificationDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      generalNotificationDetails,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, usersnapshot) {
          if (usersnapshot.hasData) {
            return Home();
          } else {
            return AuthScreen();
          }
        },
      ),
      debugShowCheckedModeBanner: false,
      theme:
          ThemeData(brightness: Brightness.dark, primaryColor: Colors.purple),
    );
  }
}
