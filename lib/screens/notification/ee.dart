import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationsScreen11 extends StatefulWidget {
  @override
  _NotificationsScreen11State createState() => _NotificationsScreen11State();
}

class _NotificationsScreen11State extends State<NotificationsScreen11> {
  @override
  void initState() {
    super.initState();
    _printFcmToken();
  }

  void _printFcmToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    print("📱 FCM Token: $token");
  }

  // دالة لحذف الإشعار من Firestore
  void _deleteNotification(String docId) {
    FirebaseFirestore.instance.collection("notifications").doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("الإشعارات"),
        backgroundColor: Colors.purple,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("notifications")
            .orderBy("timestamp", descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "لا توجد إشعارات حتى الآن",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          var notifications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              var notification = notifications[index];
              var title = notification["title"];
              var body = notification["body"];
              var time = (notification["timestamp"] as Timestamp).toDate();
              var formattedTime = DateFormat.yMd().add_jm().format(time);
              var docId = notification.id;

              return Dismissible(
                key: Key(docId),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.centerRight,
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  _deleteNotification(docId);
                },
                child: Card(
                  color: Colors.purple.shade200,
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(title,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(body),
                    trailing:
                        Text(formattedTime, style: TextStyle(fontSize: 12)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
