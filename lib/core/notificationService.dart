import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;

class NotificationService {
  static Future<void> sendNotificationToAll(String title, String body) async {
    final String accessToken = await _getAccessToken();
    if (accessToken.isEmpty) {
      print("  فشل في الحصول على Access Token");
      return;
    }

    final url = Uri.parse(
        "https://fcm.googleapis.com/v1/projects/chatmodule-ac96c/messages:send");

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

    final bodyJson = jsonEncode({
      "message": {
        "topic": "all",
        "notification": {
          "title": title,
          "body": body,
        },
        "data": {
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "id": "2",
          "status": "done",
        },
      }
    });

    final response = await http.post(url, headers: headers, body: bodyJson);

    if (response.statusCode == 200) {
      print("✅ تم إرسال الإشعار بنجاح!");
    } else {
      print("  فشل في الإرسال: ${response.body}");
    }
  }

  static Future<String> _getAccessToken() async {
    final jsonString = await rootBundle.loadString(
        'assets/chatmodule-ac96c-firebase-adminsdk-92f4m-34eb1d1107.json');
    final jsonData = jsonDecode(jsonString);

    final credentials = auth.ServiceAccountCredentials.fromJson(jsonData);
    final client = await auth.clientViaServiceAccount(
      credentials,
      ['https://www.googleapis.com/auth/firebase.messaging'],
    );

    return client.credentials.accessToken.data;
  }
}
