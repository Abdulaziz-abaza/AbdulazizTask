// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:flutter/material.dart';
// // import 'package:firebase_core/firebase_core.dart';
// // import 'package:firebase_messaging/firebase_messaging.dart';
// // import 'package:flutter_bloc/flutter_bloc.dart';
// // import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// // import 'package:mydo/cubit/task_cubit.dart';
// // import '/auth/authscreen.dart';
// // import '/screens/home.dart';

// // Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
// //   await Firebase.initializeApp();
// //   print(" إشعار vvvvvvvvvvvvvv : ${message.notification?.title}");
// // }

// // final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
// //     FlutterLocalNotificationsPlugin();

// // void main() async {
// //   WidgetsFlutterBinding.ensureInitialized();
// //   await Firebase.initializeApp();

// //   var initializationSettingsAndroid =
// //       AndroidInitializationSettings('@mipmap/ic_launcher');

// //   var initializationSettings =
// //       InitializationSettings(android: initializationSettingsAndroid);

// //   await flutterLocalNotificationsPlugin.initialize(initializationSettings);

// //   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

// //   runApp(MyApp());
// // }

// // class MyApp extends StatefulWidget {
// //   @override
// //   _MyAppState createState() => _MyAppState();
// // }

// // class _MyAppState extends State<MyApp> {
// //   @override
// //   void initState() {
// //     super.initState();
// //     setupFirebaseMessaging();
// //   }

// // //TEST
// //   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
// //       FlutterLocalNotificationsPlugin();
// //   List<String> notifications = [];

// //   void setupFirebaseMessaging() async {
// //     FirebaseMessaging messaging = FirebaseMessaging.instance;

// //     NotificationSettings settings = await messaging.requestPermission(
// //       alert: true,
// //       badge: true,
// //       sound: true,
// //     );

// //     FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
// //       String title = message.notification?.title ?? "No Title";
// //       String body = message.notification?.body ?? "No Body";
// //       Timestamp timestamp = Timestamp.now();

// //       await FirebaseFirestore.instance.collection("notifications").add({
// //         "title": title,
// //         "body": body,
// //         "timestamp": timestamp,
// //       });

// //       showNotification(title, body);
// //     });

// //     String? token = await messaging.getToken();
// //     print("📱 FCM Token: $token");
// //   }

// //   Future<void> showNotification(String title, String body) async {
// //     var androidDetails = AndroidNotificationDetails(
// //       'channel_id',
// //       'channel_name',
// //       importance: Importance.high,
// //       priority: Priority.high,
// //     );

// //     var generalNotificationDetails =
// //         NotificationDetails(android: androidDetails);

// //     await flutterLocalNotificationsPlugin.show(
// //       0,
// //       title,
// //       body,
// //       generalNotificationDetails,
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       home: StreamBuilder(
// //         stream: FirebaseAuth.instance.authStateChanges(),
// //         builder: (context, userSnapshot) {
// //           if (userSnapshot.hasData) {
// //             final uid = userSnapshot.data!.uid;
// //             return BlocProvider(
// //               create: (_) => TaskCubit(),
// //               child: Home(),
// //             );
// //           } else {
// //             return AuthScreen();
// //           }
// //         },
// //       ),
// //       debugShowCheckedModeBanner: false,
// //       theme:
// //           ThemeData(brightness: Brightness.dark, primaryColor: Colors.purple),
// //     );
// //   }
// // }
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:mydo/cubit/task_cubit.dart';
// import '/auth/authscreen.dart';
// import '/screens/home.dart';

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print(" إشعار vvvvvvvvvvvvvv : ${message.notification?.title}");
// }

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();

//   var initializationSettingsAndroid =
//       AndroidInitializationSettings('@mipmap/ic_launcher');

//   var initializationSettings =
//       InitializationSettings(android: initializationSettingsAndroid);

//   // إعداد الإشعارات
//   await flutterLocalNotificationsPlugin.initialize(initializationSettings,
//       onDidReceiveNotificationResponse: (NotificationResponse response) {
//     print("🛎️ Notification clicked!");
//     // هنا يمكنك التعامل مع الحدث عندما يقوم المستخدم بالنقر على الإشعار
//   });

//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//   runApp(MyApp());
// }

// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   @override
//   void initState() {
//     super.initState();
//     setupFirebaseMessaging();
//   }

//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();
//   List<String> notifications = [];

//   void setupFirebaseMessaging() async {
//     FirebaseMessaging messaging = FirebaseMessaging.instance;

//     // طلب الصلاحيات
//     NotificationSettings settings = await messaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );

//     // طلب صلاحية الإشعارات لـ Android 13+
//     // if (await Permission.notification.isDenied) {
//     //   await Permission.notification.request();
//     // }

//     FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
//       String title = message.notification?.title ?? "No Title";
//       String body = message.notification?.body ?? "No Body";
//       Timestamp timestamp = Timestamp.now();

//       await FirebaseFirestore.instance.collection("notifications").add({
//         "title": title,
//         "body": body,
//         "timestamp": timestamp,
//       });

//       // عرض الإشعار عند الوصول
//       showNotification(title, body);
//     });

//     String? token = await messaging.getToken();
//     print("📱 FCM Token: $token");
//   }

//   Future<void> showNotification(String title, String body) async {
//     var androidDetails = AndroidNotificationDetails(
//       'high_importance_channel', // اسم القناة
//       'High Importance Notifications',
//       channelDescription: 'This channel is used for important notifications.',
//       importance: Importance.max, // إعطاء الأولوية العالية
//       priority: Priority.high,
//       playSound: true,
//     );

//     var generalNotificationDetails =
//         NotificationDetails(android: androidDetails);

//     await flutterLocalNotificationsPlugin.show(
//       0,
//       title,
//       body,
//       generalNotificationDetails,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: StreamBuilder(
//         stream: FirebaseAuth.instance.authStateChanges(),
//         builder: (context, userSnapshot) {
//           if (userSnapshot.hasData) {
//             final uid = userSnapshot.data!.uid;
//             return BlocProvider(
//               create: (_) => TaskCubit(),
//               child: Home(),
//             );
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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mydo/cubit/task_cubit.dart';
import '/auth/authscreen.dart';
import '/screens/home.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print(" إشعار vvvvvvvvvvvvvv : ${message.notification?.title}");
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

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
  List<String> notifications = [];

  void setupFirebaseMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    await FirebaseMessaging.instance.subscribeToTopic("all");

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      String title = message.notification?.title ?? "No Title";
      String body = message.notification?.body ?? "No Body";
      Timestamp timestamp = Timestamp.now();

      await FirebaseFirestore.instance.collection("notifications").add({
        "title": title,
        "body": body,
        "timestamp": timestamp,
      });

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
        builder: (context, userSnapshot) {
          if (userSnapshot.hasData) {
            final uid = userSnapshot.data!.uid;
            return BlocProvider(
              create: (_) => TaskCubit(),
              child: Home(),
            );
          } else {
            //   return BlocProvider(
            //   create: (_) => AuthCubit(),
            //   child: AuthScreen(),
            // );
            return AuthScreen();
          }
        },
      ),

      // home: StreamBuilder(
      //   stream: FirebaseAuth.instance.authStateChanges(),
      //   builder: (context, usersnapshot) {
      //     if (usersnapshot.hasData) {
      //       return HomeScreen();
      //     } else {
      //       return AuthScreen();
      //     }
      //   },
      // ),
      debugShowCheckedModeBanner: false,
      theme:
          ThemeData(brightness: Brightness.dark, primaryColor: Colors.purple),
    );
  }
}
