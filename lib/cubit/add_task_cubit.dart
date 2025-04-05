import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mydo/core/notificationService.dart';
import 'package:mydo/cubit/add_task_state.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;

class AddTaskCubit extends Cubit<AddTaskState> {
  AddTaskCubit() : super(AddTaskInitial());

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedStartTime;
  TimeOfDay? selectedEndTime;
  String taskStatus = 'Pending';
  bool isGroupTask = false;

  void updateDate(DateTime date) {
    selectedDate = date;
    emit(AddTaskUpdated());
  }

  void updateTime(TimeOfDay time, bool isStartTime) {
    if (isStartTime) {
      selectedStartTime = time;
    } else {
      selectedEndTime = time;
    }
    emit(AddTaskUpdated());
  }

  void updateStatus(String status) {
    taskStatus = status;
    emit(AddTaskUpdated());
  }

  void toggleGroupTask(bool value) {
    isGroupTask = value;
    emit(AddTaskUpdated());
  }

  Future<String> getAccessToken() async {
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

  Future<void> scheduleNotification({
    required String taskId,
    required String title,
    required String body,
    required DateTime sendAt,
  }) async {
    try {
      final data = {
        "taskId": taskId,
        "title": title,
        "body": body,
        "sendAt": sendAt.toIso8601String(),
      };

      await FirebaseFirestore.instance
          .collection('scheduledNotifications')
          .add(data);

      print("✅ تم إضافة الإشعار المجدول إلى Firestore بنجاح");
    } catch (e) {
      print("  فشل في إضافة الإشعار المجدول: $e");
    }
  }

  Future<void> addTaskToFirebase(BuildContext context) async {
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        selectedDate == null ||
        selectedStartTime == null ||
        selectedEndTime == null) {
      Fluttertoast.showToast(msg: 'يرجى ملء جميع الحقول');
      return;
    }

    DateTime startDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedStartTime!.hour,
      selectedStartTime!.minute,
    );

    DateTime endDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedEndTime!.hour,
      selectedEndTime!.minute,
    );

    if (endDateTime.isBefore(startDateTime)) {
      Fluttertoast.showToast(msg: 'وقت النهاية يجب أن يكون بعد وقت البداية');
      return;
    }

    emit(AddTaskLoading());

    try {
      final auth = FirebaseAuth.instance;
      final uid = auth.currentUser!.uid;

      CollectionReference taskCollection;

      if (isGroupTask) {
        taskCollection = FirebaseFirestore.instance
            .collection('tasks')
            .doc('publicTasks')
            .collection('allTasks');

        final docRef = taskCollection.doc(startDateTime.toUtc().toString());
        final snapshot = await docRef.get();

        if (!snapshot.exists) {
          await docRef.set({
            'title': titleController.text,
            'description': descriptionController.text,
            'start_time': startDateTime.toIso8601String(),
            'end_time': endDateTime.toIso8601String(),
            'timestamp': startDateTime,
            'status': taskStatus,
            'isGroupTask': isGroupTask,
            'created_by': uid,
          });

          DateTime notificationTime =
              endDateTime.subtract(Duration(minutes: 1));
          Duration timeUntilNotification =
              notificationTime.difference(DateTime.now());
          await scheduleNotification(
            taskId: docRef.id,
            title: titleController.text,
            body: "مهمة جماعية ستنتهي قريبًا: ${titleController.text}",
            sendAt: notificationTime,
          );
          if (!timeUntilNotification.isNegative) {
            final data = {
              "taskId": docRef.id,
              "title": titleController.text,
              "body": "مهمة جماعية ستنتهي قريبًا: ${titleController.text}",
              "sendAt": notificationTime.toIso8601String(),
            };

            FirebaseFirestore.instance
                .collection('scheduledNotifications')
                .add(data);
          }
        } else {
          await docRef.update({
            'title': titleController.text,
            'description': descriptionController.text,
            'start_time': startDateTime.toIso8601String(),
            'end_time': endDateTime.toIso8601String(),
            'timestamp': startDateTime,
            'status': taskStatus,
          });
        }
      } else {
        taskCollection = FirebaseFirestore.instance
            .collection('tasks')
            .doc(uid)
            .collection('mytasks');

        await taskCollection.doc(startDateTime.toUtc().toString()).set({
          'title': titleController.text,
          'description': descriptionController.text,
          'start_time': startDateTime.toIso8601String(),
          'end_time': endDateTime.toIso8601String(),
          'timestamp': startDateTime,
          'status': taskStatus,
          'isGroupTask': isGroupTask,
          'created_by': uid,
        });
      }

      NotificationService.sendNotificationToAll(
        "تم إضافة مهمة جديدة",
        "تم إضافة مهمة جديدة: ${titleController.text}",
      );

      Fluttertoast.showToast(msg: 'تمت إضافة المهمة بنجاح');
      Navigator.pop(context);
    } catch (e) {
      Fluttertoast.showToast(msg: 'حدث خطأ، حاول مرة أخرى');
    }

    emit(AddTaskLoaded());
  }
}
