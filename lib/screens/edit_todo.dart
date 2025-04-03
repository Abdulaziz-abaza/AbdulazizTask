import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EditTodo extends StatefulWidget {
  final String docId;
  final String uid;
  final bool isGroupTask;

  EditTodo({required this.docId, required this.uid, required this.isGroupTask});

  @override
  _EditTodoState createState() => _EditTodoState();
}

class _EditTodoState extends State<EditTodo> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  DateTime? selectedStartTime;
  DateTime? selectedEndTime;
  String? selectedStatus;
  List<String> statuses = ['Pending', 'In Progress', 'Completed'];

  @override
  void initState() {
    super.initState();
    fetchTodoData();
  }

  void fetchTodoData() async {
    final snapshot;
    if (widget.isGroupTask) {
      snapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .doc("publicTasks")
          .collection('allTasks')
          .doc(widget.docId)
          .get();
    } else {
      snapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .doc(widget.uid)
          .collection('mytasks')
          .doc(widget.docId)
          .get();
    }

    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      titleController.text = data['title'];
      descriptionController.text = data['description'];
      selectedStatus = data['status'] ?? 'Pending';

      selectedStartTime = DateTime.tryParse(data['start_time'] ?? '');
      selectedEndTime = DateTime.tryParse(data['end_time'] ?? '');

      setState(() {});
    }
  }

  Future<void> _selectTime({required bool isStartTime}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        DateTime now = DateTime.now();
        DateTime selectedTime =
            DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
        if (isStartTime) {
          selectedStartTime = selectedTime;
        } else {
          selectedEndTime = selectedTime;
        }
      });
    }
  }

  void updateTodo() async {
    print("widget.uidwidget.uid ${widget.docId}");
    print("widget.uidwidget.uid ${widget.uid}");

    if (titleController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter a title');
      return;
    }
    if (descriptionController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter a description');
      return;
    }
    if (selectedStartTime == null) {
      Fluttertoast.showToast(msg: 'Please select a start time');
      return;
    }
    if (selectedEndTime == null) {
      Fluttertoast.showToast(msg: 'Please select an end time');
      return;
    }
    if (selectedEndTime!.isBefore(selectedStartTime!)) {
      Fluttertoast.showToast(msg: 'End time must be after start time');
      return;
    }

    if (widget.isGroupTask) {
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc("publicTasks")
          .collection('allTasks')
          .doc(widget.docId)
          .update({
        'title': titleController.text,
        'description': descriptionController.text,
        'status': selectedStatus,
        'start_time': selectedStartTime!.toIso8601String(),
        'end_time': selectedEndTime!.toIso8601String(),
      });
    } else {
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(widget.uid)
          .collection('mytasks')
          .doc(widget.docId)
          .update({
        'title': titleController.text,
        'description': descriptionController.text,
        'status': selectedStatus,
        'start_time': selectedStartTime!.toIso8601String(),
        'end_time': selectedEndTime!.toIso8601String(),
      });
    }

    Fluttertoast.showToast(msg: 'Todo updated successfully');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Task')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Edit Title',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Edit Description',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedStatus,
              decoration: InputDecoration(
                labelText: 'Status',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              items: statuses.map((status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedStatus = newValue;
                });
              },
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Text(selectedStartTime != null
                    ? 'Start Time: ${selectedStartTime!.hour}:${selectedStartTime!.minute}'
                    : 'Select Start Time'),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => _selectTime(isStartTime: true),
                  child: Text('Pick Start Time'),
                ),
              ],
            ),
            Row(
              children: [
                Text(selectedEndTime != null
                    ? 'End Time: ${selectedEndTime!.hour}:${selectedEndTime!.minute}'
                    : 'Select End Time'),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => _selectTime(isStartTime: false),
                  child: Text('Pick End Time'),
                ),
              ],
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                child: Text(
                  'Update Todo',
                  style: TextStyle(fontSize: 18),
                ),
                onPressed: updateTodo,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
