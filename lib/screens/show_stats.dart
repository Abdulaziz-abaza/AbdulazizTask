import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:mydo/screens/todos_by_month.dart';

class ShowStatistics extends StatefulWidget {
  @override
  _ShowStatisticsState createState() => _ShowStatisticsState();
}

class _ShowStatisticsState extends State<ShowStatistics> {
  String uid = '';
  Map<String, int> monthlyStatistics = {};

  @override
  void initState() {
    getuid();
    super.initState();
  }

  getuid() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = await auth.currentUser;
    if (user != null) {
      setState(() {
        uid = user.uid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statistics'),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('tasks')
              .doc(uid)
              .collection('mytasks')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (!snapshot.hasData ||
                snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text("No statistics available", style: TextStyle(color: Colors.white)),
              );
            } else {
              final docs = snapshot.data?.docs;
              for (var doc in docs!) {
                final data = doc.data() as Map<String, dynamic>;
                final date = data['timestamp'];
                String month = DateFormat('MMMM yyyy').format(date.toDate());

                if (monthlyStatistics.containsKey(month)) {
                  monthlyStatistics[month] = monthlyStatistics[month]! + 1;
                } else {
                  monthlyStatistics[month] = 1;
                }
              }

              final months = monthlyStatistics.keys.toList();

              return ListView.builder(
                itemCount: monthlyStatistics.length,

                itemBuilder: (context, index) {
                  final month = months[index];
                  final numberOfTasks = monthlyStatistics[month];

                  return ListTile(
                    title: Text(month),
                    subtitle: Text('Number of tasks: $numberOfTasks'),
                    onTap: () {
                      // Navigate to a new page to display todos for the selected month
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TodosByMonth(month: month, uid: uid),
                        ),
                      );
                    },
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
