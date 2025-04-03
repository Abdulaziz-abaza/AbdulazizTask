// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:mydo/main.dart';

// class AddTask extends StatefulWidget {
//   @override
//   _AddTaskState createState() => _AddTaskState();
// }

// class _AddTaskState extends State<AddTask> {
//   TextEditingController titleController = TextEditingController();
//   TextEditingController descriptionController = TextEditingController();
//   DateTime? selectedDate;

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime currentDate = DateTime.now();

//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: selectedDate ?? currentDate,
//       firstDate: currentDate,
//       lastDate: DateTime(2101),
//     );

//     if (picked != null) {
//       setState(() {
//         selectedDate = picked;
//       });
//     }
//   }

//   TimeOfDay? selectedStartTime;
//   TimeOfDay? selectedEndTime;
//   bool isLoading = false;
//   String taskStatus = 'Pending';
//   bool isGroupTask = false; // متغير للتحكم في المهمة الجماعية

//   Future<void> _selectTime(BuildContext context,
//       {required bool isStartTime}) async {
//     final TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: isStartTime
//           ? (selectedStartTime ?? TimeOfDay.now())
//           : (selectedEndTime ?? TimeOfDay.now()),
//     );

//     if (picked != null) {
//       setState(() {
//         if (isStartTime) {
//           selectedStartTime = picked;
//         } else {
//           selectedEndTime = picked;
//         }
//       });
//     }
//   }

//   void _sendNotification(String title, String description) async {
//     const AndroidNotificationDetails androidDetails =
//         AndroidNotificationDetails(
//       'task_channel',
//       'إشعارات المهام',
//       importance: Importance.max,
//       priority: Priority.high,
//     );

//     const NotificationDetails notificationDetails =
//         NotificationDetails(android: androidDetails);

//     await flutterLocalNotificationsPlugin.show(
//       0,
//       title,
//       description,
//       notificationDetails,
//     );

//     // 🔹 حفظ الإشعار في Firestore
//     FirebaseFirestore.instance.collection('notifications').add({
//       'title': title,
//       'body': description,
//       'timestamp': FieldValue.serverTimestamp(),
//     });
//   }

//   Future<void> addTaskToFirebase(BuildContext context) async {
//     if (titleController.text.isEmpty ||
//         descriptionController.text.isEmpty ||
//         selectedDate == null ||
//         selectedStartTime == null ||
//         selectedEndTime == null) {
//       Fluttertoast.showToast(msg: 'يرجى ملء جميع الحقول');
//       return;
//     }

//     DateTime startDateTime = DateTime(
//       selectedDate!.year,
//       selectedDate!.month,
//       selectedDate!.day,
//       selectedStartTime!.hour,
//       selectedStartTime!.minute,
//     );

//     DateTime endDateTime = DateTime(
//       selectedDate!.year,
//       selectedDate!.month,
//       selectedDate!.day,
//       selectedEndTime!.hour,
//       selectedEndTime!.minute,
//     );

//     if (endDateTime.isBefore(startDateTime)) {
//       Fluttertoast.showToast(msg: 'وقت النهاية يجب أن يكون بعد وقت البداية');
//       return;
//     }

//     setState(() {
//       isLoading = true;
//     });

//     try {
//       FirebaseAuth auth = FirebaseAuth.instance;
//       User user = auth.currentUser!;
//       String uid = user.uid;

//       // تحديد مسار حفظ المهمة
//       CollectionReference taskCollection = isGroupTask
//           ? FirebaseFirestore.instance
//               .collection('tasks')
//               .doc('publicTasks')
//               .collection('allTasks') // المسار للمهام الجماعية
//           : FirebaseFirestore.instance
//               .collection('tasks')
//               .doc(uid)
//               .collection('mytasks'); // المسار للمهام الفردية

//       await taskCollection.doc(startDateTime.toUtc().toString()).set({
//         'title': titleController.text,
//         'description': descriptionController.text,
//         'start_time': startDateTime.toIso8601String(),
//         'end_time': endDateTime.toIso8601String(),
//         'timestamp': startDateTime,
//         'status': taskStatus,
//         'isGroupTask': isGroupTask, // إضافة هذا الحقل لمعرفة نوع المهمة
//         //  'created_by': uid, // حفظ معرف المستخدم الذي أنشأ المهمة
//         'created_by': user.uid,
//       });
// // 🔔 إرسال الإشعار بعد إضافة المهمة بنجاح
//       _sendNotification(titleController.text, descriptionController.text);

//       Fluttertoast.showToast(msg: 'تمت إضافة المهمة بنجاح');
//       Navigator.pop(context);
//     } catch (e) {
//       Fluttertoast.showToast(msg: 'حدث خطأ، حاول مرة أخرى');
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('إضافة مهمة جديدة')),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             TextField(
//               controller: titleController,
//               decoration: InputDecoration(
//                 labelText: 'عنوان المهمة',
//                 border:
//                     OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//               ),
//             ),
//             SizedBox(height: 10),
//             TextField(
//               controller: descriptionController,
//               decoration: InputDecoration(
//                 labelText: 'وصف المهمة',
//                 border:
//                     OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//               ),
//             ),
//             SizedBox(height: 10),
//             Row(
//               children: [
//                 Text(selectedDate != null
//                     ? 'التاريخ: ${selectedDate!.toLocal().toString().split(' ')[0]}'
//                     : 'حدد التاريخ'),
//                 SizedBox(width: 20),
//                 ElevatedButton(
//                   onPressed: () => _selectDate(context),
//                   child: Text('اختيار التاريخ'),
//                 ),
//               ],
//             ),
//             Row(
//               children: [
//                 Text(selectedStartTime != null
//                     ? 'وقت البداية: ${selectedStartTime!.format(context)}'
//                     : 'حدد وقت البداية'),
//                 SizedBox(width: 20),
//                 ElevatedButton(
//                   onPressed: () => _selectTime(context, isStartTime: true),
//                   child: Text('اختيار وقت البداية'),
//                 ),
//               ],
//             ),
//             Row(
//               children: [
//                 Text(selectedEndTime != null
//                     ? 'وقت النهاية: ${selectedEndTime!.format(context)}'
//                     : 'حدد وقت النهاية'),
//                 SizedBox(width: 20),
//                 ElevatedButton(
//                   onPressed: () => _selectTime(context, isStartTime: false),
//                   child: Text('اختيار وقت النهاية'),
//                 ),
//               ],
//             ),
//             DropdownButtonFormField<String>(
//               value: taskStatus,
//               decoration: InputDecoration(
//                 labelText: 'حالة المهمة',
//                 border:
//                     OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//               ),
//               items: ['Pending', 'In Progress', 'Completed']
//                   .map((status) => DropdownMenuItem(
//                         value: status,
//                         child: Text(status),
//                       ))
//                   .toList(),
//               onChanged: (newValue) {
//                 setState(() => taskStatus = newValue!);
//               },
//             ),
//             SizedBox(height: 10),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text('هل هذه المهمة جماعية؟'),
//                 Switch(
//                   value: isGroupTask,
//                   onChanged: (value) {
//                     setState(() {
//                       isGroupTask = value;
//                     });
//                   },
//                 ),
//               ],
//             ),
//             SizedBox(height: 10),
//             SizedBox(
//               width: double.infinity,
//               height: 50,
//               child: ElevatedButton(
//                 style: ButtonStyle(
//                   shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                     RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(15)),
//                   ),
//                 ),
//                 child: isLoading
//                     ? CircularProgressIndicator(color: Colors.white)
//                     : Text(
//                         'إضافة المهمة',
//                         style: GoogleFonts.roboto(fontSize: 18),
//                       ),
//                 onPressed: isLoading ? null : () => addTaskToFirebase(context),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mydo/main.dart';

class AddTask extends StatefulWidget {
  @override
  _AddTaskState createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedStartTime;
  TimeOfDay? selectedEndTime;
  bool isLoading = false;
  String taskStatus = 'Pending';
  bool isGroupTask = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime currentDate = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? currentDate,
      firstDate: currentDate,
      lastDate: DateTime(2101),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _selectTime(BuildContext context,
      {required bool isStartTime}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime
          ? (selectedStartTime ?? TimeOfDay.now())
          : (selectedEndTime ?? TimeOfDay.now()),
    );
    if (picked != null)
      setState(() =>
          isStartTime ? selectedStartTime = picked : selectedEndTime = picked);
  }

  void _sendNotification(String title, String description) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'task_channel',
      'إشعارات المهام',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
        0, title, description, notificationDetails);
    FirebaseFirestore.instance.collection('notifications').add({
      'title': title,
      'body': description,
      'timestamp': FieldValue.serverTimestamp()
    });
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

    DateTime startDateTime = DateTime(selectedDate!.year, selectedDate!.month,
        selectedDate!.day, selectedStartTime!.hour, selectedStartTime!.minute);
    DateTime endDateTime = DateTime(selectedDate!.year, selectedDate!.month,
        selectedDate!.day, selectedEndTime!.hour, selectedEndTime!.minute);

    if (endDateTime.isBefore(startDateTime)) {
      Fluttertoast.showToast(msg: 'وقت النهاية يجب أن يكون بعد وقت البداية');
      return;
    }

    setState(() => isLoading = true);

    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      User user = auth.currentUser!;
      String uid = user.uid;

      CollectionReference taskCollection;

      if (isGroupTask) {
        taskCollection = FirebaseFirestore.instance
            .collection('tasks')
            .doc('publicTasks')
            .collection('allTasks');
        DocumentSnapshot docSnapshot =
            await taskCollection.doc(startDateTime.toUtc().toString()).get();

        if (!docSnapshot.exists) {
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
        } else {
          await taskCollection.doc(startDateTime.toUtc().toString()).update({
            'title': titleController.text,
            'description': descriptionController.text,
            'start_time': startDateTime.toIso8601String(),
            'end_time': endDateTime.toIso8601String(),
            'timestamp': startDateTime,
            'status': taskStatus,
          });
        }

        _sendNotification(titleController.text, descriptionController.text);
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

      Fluttertoast.showToast(msg: 'تمت إضافة المهمة بنجاح');
      Navigator.pop(context);
    } catch (e) {
      Fluttertoast.showToast(msg: 'حدث خطأ، حاول مرة أخرى');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Future<void> addTaskToFirebase(BuildContext context) async {
  //   if (titleController.text.isEmpty ||
  //       descriptionController.text.isEmpty ||
  //       selectedDate == null ||
  //       selectedStartTime == null ||
  //       selectedEndTime == null) {
  //     Fluttertoast.showToast(msg: 'يرجى ملء جميع الحقول');
  //     return;
  //   }

  //   DateTime startDateTime = DateTime(selectedDate!.year, selectedDate!.month,
  //       selectedDate!.day, selectedStartTime!.hour, selectedStartTime!.minute);
  //   DateTime endDateTime = DateTime(selectedDate!.year, selectedDate!.month,
  //       selectedDate!.day, selectedEndTime!.hour, selectedEndTime!.minute);

  //   if (endDateTime.isBefore(startDateTime)) {
  //     Fluttertoast.showToast(msg: 'وقت النهاية يجب أن يكون بعد وقت البداية');
  //     return;
  //   }

  //   setState(() => isLoading = true);

  //   try {
  //     FirebaseAuth auth = FirebaseAuth.instance;
  //     User user = auth.currentUser!;
  //     String uid = user.uid;

  //     CollectionReference taskCollection = isGroupTask
  //         ? FirebaseFirestore.instance
  //             .collection('tasks')
  //             .doc('publicTasks')
  //             .collection('allTasks')
  //         : FirebaseFirestore.instance
  //             .collection('tasks')
  //             .doc(uid)
  //             .collection('mytasks');

  //     await taskCollection.doc(startDateTime.toUtc().toString()).set({
  //       'title': titleController.text,
  //       'description': descriptionController.text,
  //       'start_time': startDateTime.toIso8601String(),
  //       'end_time': endDateTime.toIso8601String(),
  //       'timestamp': startDateTime,
  //       'status': taskStatus,
  //       'isGroupTask': isGroupTask,
  //       'created_by': uid,
  //     });

  //     if (isGroupTask)
  //       _sendNotification(titleController.text, descriptionController.text);

  //     Fluttertoast.showToast(msg: 'تمت إضافة المهمة بنجاح');
  //     Navigator.pop(context);
  //   } catch (e) {
  //     Fluttertoast.showToast(msg: 'حدث خطأ، حاول مرة أخرى');
  //   } finally {
  //     setState(() => isLoading = false);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('إضافة مهمة جديدة')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(titleController, 'عنوان المهمة'),
            SizedBox(height: 10),
            _buildTextField(descriptionController, 'وصف المهمة'),
            SizedBox(height: 15),
            _buildDateSelector(context),
            SizedBox(height: 10),
            _buildTimeSelector(context, true),
            SizedBox(height: 10),
            _buildTimeSelector(context, false),
            SizedBox(height: 15),
            _buildDropdown(),
            SizedBox(height: 10),
            _buildGroupTaskSwitch(),
            SizedBox(height: 20),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    return ListTile(
      title: Text(selectedDate != null
          ? 'التاريخ: ${selectedDate!.toLocal().toString().split(' ')[0]}'
          : 'حدد التاريخ'),
      trailing: IconButton(
          icon: Icon(Icons.calendar_today),
          onPressed: () => _selectDate(context)),
    );
  }

  Widget _buildTimeSelector(BuildContext context, bool isStartTime) {
    return ListTile(
      title: Text(isStartTime
          ? (selectedStartTime != null
              ? 'وقت البداية: ${selectedStartTime!.format(context)}'
              : 'حدد وقت البداية')
          : (selectedEndTime != null
              ? 'وقت النهاية: ${selectedEndTime!.format(context)}'
              : 'حدد وقت النهاية')),
      trailing: IconButton(
          icon: Icon(Icons.access_time),
          onPressed: () => _selectTime(context, isStartTime: isStartTime)),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: taskStatus,
      decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
      items: ['Pending', 'In Progress', 'Completed']
          .map((status) => DropdownMenuItem(value: status, child: Text(status)))
          .toList(),
      onChanged: (newValue) => setState(() => taskStatus = newValue!),
    );
  }

  Widget _buildGroupTaskSwitch() {
    return SwitchListTile(
      title: Text('هل هذه المهمة جماعية؟'),
      value: isGroupTask,
      onChanged: (value) => setState(() => isGroupTask = value),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        child: isLoading
            ? CircularProgressIndicator(color: Colors.white)
            : Text('إضافة المهمة', style: GoogleFonts.roboto(fontSize: 18)),
        onPressed: isLoading ? null : () => addTaskToFirebase(context),
      ),
    );
  }
}
