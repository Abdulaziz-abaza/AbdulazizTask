import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mydo/core/constants/constants.dart';
import 'package:mydo/core/notificationService.dart';
import 'package:mydo/cubit/edit_todo_cubit.dart';
import 'package:mydo/cubit/edit_todo_state.dart';

class EditTodoScreen extends StatelessWidget {
  final String docId;
  final String uid;
  final bool isGroupTask;

  const EditTodoScreen({
    Key? key,
    required this.docId,
    required this.uid,
    required this.isGroupTask,
  }) : super(key: key);
  Future<String> getUserName(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        return userDoc['username'];
      } else {
        return 'Unknown User';
      }
    } catch (e) {
      print('❌ Error fetching user name: $e');
      return 'Unknown User';
    }
  }

  void updateTaskAndNotify(String createdByUserId) async {
    String userName = await getUserName(createdByUserId);

    NotificationService.sendNotificationToAll(
        "تم تحديث المهمة", "قام $userName بتحديث المهمة");
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EditTodoCubit()
        ..fetchTodoData(docId: docId, uid: uid, isGroupTask: isGroupTask),
      child: BlocConsumer<EditTodoCubit, EditTodoState>(
        listener: (context, state) {
          if (state is EditTodoError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is EditTodoSuccess) {
            Fluttertoast.showToast(msg: "Task updated successfully");

            updateTaskAndNotify(uid);
            // Navigate back to the previous screen after updating

            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          final cubit = context.read<EditTodoCubit>();

          if (state is EditTodoLoading) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          return Scaffold(
            appBar: AppBar(
              title: Text('Edit Task'),
              backgroundColor: AppColors.primary,
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: cubit.titleController,
                    decoration: InputDecoration(
                      labelText: 'Edit Title',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  TextFormField(
                    controller: cubit.descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Edit Description',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Theme.of(context).primaryColor),
                      ),
                    ),
                    maxLines: 4,
                  ),
                  SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: cubit.selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: cubit.statuses.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (value) => cubit.changeStatus(value!),
                  ),
                  SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          cubit.startTime != null
                              ? 'Start: ${cubit.startTime!.hour}:${cubit.startTime!.minute}'
                              : 'Select Start Time',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (picked != null) {
                            cubit.pickTime(isStartTime: true, picked: picked);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: Text("Pick Start"),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          cubit.endTime != null
                              ? 'End: ${cubit.endTime!.hour}:${cubit.endTime!.minute}'
                              : 'Select End Time',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (picked != null) {
                            cubit.pickTime(isStartTime: false, picked: picked);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: Text("Pick End"),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Update Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => cubit.updateTodo(
                          docId: docId, uid: uid, isGroupTask: isGroupTask),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child:
                          Text('Update Todo', style: TextStyle(fontSize: 16)),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
