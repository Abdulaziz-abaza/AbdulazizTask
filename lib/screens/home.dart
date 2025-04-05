import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:mydo/auth/authscreen.dart';
import 'package:mydo/core/constants/constants.dart';
import 'package:mydo/core/notificationService.dart';
import 'package:mydo/cubit/task_cubit.dart';
import 'package:mydo/cubit/task_state.dart';
import 'package:mydo/screens/add_task.dart';
import 'package:mydo/screens/description.dart';
import 'package:mydo/screens/edit_todo.dart';
import 'package:mydo/screens/notification/notification.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String uid = '';
  String selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    getUid();
  }

  void getUid() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    final User user = auth.currentUser!;
    setState(() {
      uid = user.uid;
    });
    context.read<TaskCubit>().fetchTasks(selectedStatus);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Abduaziz Task',
              style: GoogleFonts.poppins(
                  fontSize: 22, fontWeight: FontWeight.bold)),
          backgroundColor: AppColors.primary,
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          bottom: TabBar(
            onTap: (index) {
              setState(() {
                selectedStatus =
                    ['All', 'Pending', 'In Progress', 'Completed'][index];
              });
              context.read<TaskCubit>().fetchTasks(selectedStatus);
            },
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'To Do'),
              Tab(text: 'In Progress'),
              Tab(text: 'Completed'),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.notifications_active, size: 28),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NotificationsScreen()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.logout, size: 28, color: Colors.redAccent),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Fluttertoast.showToast(msg: "Signed out successfully");
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => AuthScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<TaskCubit, TaskState>(
          builder: (context, state) {
            if (state is TaskLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is TaskLoaded) {
              final docs = state.tasks;

              if (docs.isEmpty) {
                return Column(
                  children: [
                    SizedBox(height: 100),
                    Lottie.asset(
                      'assets/nofound.json',
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 20),
                    Text(
                      "لا توجد مهام",
                      style: GoogleFonts.poppins(
                        textStyle: AppTextStyles.heading,
                      ),
                    ),
                  ],
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(10),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  var time = (docs[index]['timestamp'] as Timestamp).toDate();

                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      title: Text(
                        docs[index]['title'],
                        style: GoogleFonts.poppins(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        DateFormat.yMd().add_jm().format(time),
                        style: GoogleFonts.poppins(
                            fontSize: 14, color: Colors.grey[700]),
                      ),
                      trailing: docs[index]['created_by'] == uid
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit,
                                      color: Colors.blueAccent),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditTodoScreen(
                                          isGroupTask: docs[index]
                                                  ['isGroupTask'] ??
                                              false,
                                          docId: docs[index].id,
                                          uid: uid,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete,
                                      color: Colors.redAccent),
                                  onPressed: () {
                                    context.read<TaskCubit>().deleteTask(
                                          docId: docs[index].id,
                                          uid: uid,
                                          isGroupTask: docs[index]
                                                  ['isGroupTask'] ??
                                              false,
                                          selectedStatus: selectedStatus,
                                        );
                                  },
                                ),
                              ],
                            )
                          : null,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Description(
                              createdBy: docs[index]['created_by'],
                              endTime: DateTime.parse(docs[index]['end_time']),
                              isGroupTask: docs[index]['isGroupTask'] ?? false,
                              status: docs[index]['status'],
                              startTime:
                                  DateTime.parse(docs[index]['start_time']),
                              title: docs[index]['title'],
                              description: docs[index]['description'],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            } else {
              return Center(
                child: Text(
                  "حدث خطأ",
                  style: GoogleFonts.poppins(
                    textStyle: AppTextStyles.heading,
                    color: Colors.redAccent,
                  ),
                ),
              );
            }
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          label: Text("Add Task",
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 16)),
          icon: Icon(Icons.add, color: Colors.white),
          backgroundColor: Colors.blueAccent,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddTaskScreen()),
            );
          },
        ),
      ),
    );
  }
}
