import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mydo/screens/notification/notification.dart';
import 'package:mydo/screens/notification/test.dart';
import 'add_task.dart';
import 'description.dart';
import 'edit_todo.dart';
import 'package:rxdart/rxdart.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String uid = '';
  String selectedStatus = 'All';

  @override
  void initState() {
    getuid();
    super.initState();
  }

  getuid() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    final User user = auth.currentUser!;
    setState(() {
      uid = user.uid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Taskify',
              style: GoogleFonts.poppins(
                  fontSize: 22, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.blueAccent,
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
            },
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Pending'),
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
                        // builder: (context) => NotificationsScreen()));
                        builder: (context) => NotificationsScreen()));
              },
            ),
            IconButton(
              icon: Icon(Icons.logout, size: 28, color: Colors.redAccent),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Fluttertoast.showToast(msg: "Signed out successfully");
              },
            ),
          ],
        ),
        body: StreamBuilder(
          stream:
              FirebaseFirestore.instance.collectionGroup('mytasks').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data?.docs.isEmpty == true) {
              return Center(
                child: Text("لا توجد مهام متاحة",
                    style:
                        GoogleFonts.poppins(fontSize: 18, color: Colors.grey)),
              );
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

            return StreamBuilder(
              stream: Rx.combineLatest2(individualTasks, groupTasks,
                  (individualSnap, groupSnap) {
                return [
                  ...(individualSnap as QuerySnapshot).docs,
                  ...(groupSnap as QuerySnapshot).docs,
                ];
              }),
              builder: (context, combinedSnapshot) {
                if (!combinedSnapshot.hasData ||
                    (combinedSnapshot.data as List).isEmpty) {
                  return Center(
                      child: Text("لا توجد مهام",
                          style: GoogleFonts.poppins(
                              fontSize: 18, color: Colors.grey)));
                }

                final docs = (combinedSnapshot.data! as List).where((doc) {
                  if (selectedStatus == 'All') return true;
                  return doc['status'] == selectedStatus;
                }).toList();

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
                                          builder: (context) => EditTodo(
                                              isGroupTask: docs[index]
                                                      ['isGroupTask'] ??
                                                  false,
                                              docId: docs[index].id,
                                              uid: uid),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete,
                                        color: Colors.redAccent),
                                    onPressed: () async {
                                      if (docs[index]["isGroupTask"] == true) {
                                        await FirebaseFirestore.instance
                                            .collection('tasks')
                                            .doc("publicTasks")
                                            .collection('allTasks')
                                            .doc(docs[index].id)
                                            .delete();
                                      } else {
                                        await FirebaseFirestore.instance
                                            .collection('tasks')
                                            .doc(uid)
                                            .collection('mytasks')
                                            .doc(docs[index].id)
                                            .delete();
                                      }

                                      Fluttertoast.showToast(
                                          msg: "تم حذف المهمة بنجاح");
                                    },
                                  ),
                                ],
                              )
                            : null,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  //  Description(
                                  //   title: docs[index]['title'],
                                  //   description: docs[index]['description'],
                                  //   time: time,
                                  //   key: UniqueKey(),
                                  // ),
                                  Description(
                                createdBy: docs[index]['created_by'],
                                // createdBy: docs[index]['created_by'],
                                endTime:
                                    DateTime.parse(docs[index]['end_time']),
                                isGroupTask: docs[index]['isGroupTask'] ??
                                    false, // التأكد من أنها قيمة منطقية
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
              },
            );
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
              MaterialPageRoute(builder: (context) => AddTask()),
            );
          },
        ),
      ),
    );
  }
}
