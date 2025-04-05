import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mydo/cubit/task_state.dart';
import 'package:rxdart/rxdart.dart';

class TaskCubit extends Cubit<TaskState> {
  TaskCubit() : super(TaskInitial());

  void fetchTasks(String selectedStatus) async {
    emit(TaskLoading());

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        emit(TaskError("User not logged in"));
        return;
      }

      final individualTasks = FirebaseFirestore.instance
          .collection('tasks')
          .doc(uid)
          .collection('mytasks')
          .snapshots();

      final groupTasks = FirebaseFirestore.instance
          .collection('tasks')
          .doc('publicTasks')
          .collection('allTasks')
          .snapshots();

      Rx.combineLatest2(
          individualTasks,
          groupTasks,
          (a, b) => [
                ...(a as QuerySnapshot).docs,
                ...(b as QuerySnapshot).docs
              ]).listen((combinedDocs) {
        final filtered = selectedStatus == 'All'
            ? combinedDocs
            : combinedDocs
                .where((doc) => doc['status'] == selectedStatus)
                .toList();

        emit(TaskLoaded(filtered));
      });
    } catch (e) {
      emit(TaskError("فشل تحميل المهام"));
    }
  }

  void deleteTask({
    required String docId,
    required String uid,
    required bool isGroupTask,
    required String selectedStatus,
  }) async {
    try {
      if (isGroupTask) {
        await FirebaseFirestore.instance
            .collection('tasks')
            .doc('publicTasks')
            .collection('allTasks')
            .doc(docId)
            .delete();
      } else {
        await FirebaseFirestore.instance
            .collection('tasks')
            .doc(uid)
            .collection('mytasks')
            .doc(docId)
            .delete();
      }

      fetchTasks(selectedStatus);
      Fluttertoast.showToast(msg: "Task Deleted successfully");
    } catch (e) {
      emit(TaskError("فشل حذف المهمة"));
    }
  }
}
