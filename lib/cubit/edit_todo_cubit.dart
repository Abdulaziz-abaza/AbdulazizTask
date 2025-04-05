import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mydo/cubit/edit_todo_state.dart';

class EditTodoCubit extends Cubit<EditTodoState> {
  EditTodoCubit() : super(EditTodoInitial());

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final statuses = ['Pending', 'In Progress', 'Completed'];

  DateTime? startTime;
  DateTime? endTime;
  String? selectedStatus;

  Future<void> fetchTodoData({
    required String docId,
    required String uid,
    required bool isGroupTask,
  }) async {
    emit(EditTodoLoading());

    try {
      final docRef = isGroupTask
          ? FirebaseFirestore.instance
              .collection('tasks')
              .doc("publicTasks")
              .collection('allTasks')
              .doc(docId)
          : FirebaseFirestore.instance
              .collection('tasks')
              .doc(uid)
              .collection('mytasks')
              .doc(docId);

      final snapshot = await docRef.get();

      if (snapshot.exists) {
        final data = snapshot.data()!;
        titleController.text = data['title'];
        descriptionController.text = data['description'];
        selectedStatus = data['status'] ?? 'Pending';
        startTime = DateTime.tryParse(data['start_time'] ?? '');
        endTime = DateTime.tryParse(data['end_time'] ?? '');

        emit(EditTodoLoaded());
      } else {
        emit(EditTodoError("Task not found"));
      }
    } catch (e) {
      emit(EditTodoError("Error fetching data: $e"));
    }
  }

  void pickTime({required bool isStartTime, required TimeOfDay picked}) {
    DateTime now = DateTime.now();
    final selected =
        DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
    if (isStartTime) {
      startTime = selected;
    } else {
      endTime = selected;
    }
    emit(EditTodoLoaded());
  }

  Future<void> updateTodo({
    required String docId,
    required String uid,
    required bool isGroupTask,
  }) async {
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        startTime == null ||
        endTime == null) {
      emit(EditTodoError("Please fill in all fields"));
      return;
    }

    if (endTime!.isBefore(startTime!)) {
      emit(EditTodoError("End time must be after start time"));
      return;
    }

    try {
      final docRef = isGroupTask
          ? FirebaseFirestore.instance
              .collection('tasks')
              .doc("publicTasks")
              .collection('allTasks')
              .doc(docId)
          : FirebaseFirestore.instance
              .collection('tasks')
              .doc(uid)
              .collection('mytasks')
              .doc(docId);

      await docRef.update({
        'title': titleController.text,
        'description': descriptionController.text,
        'status': selectedStatus,
        'start_time': startTime!.toIso8601String(),
        'end_time': endTime!.toIso8601String(),
      });

      emit(EditTodoSuccess());
    } catch (e) {
      emit(EditTodoError("Update failed: $e"));
    }
  }

  void changeStatus(String status) {
    selectedStatus = status;
    emit(EditTodoLoaded());
  }
}
