import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'description.dart';
class TodosByMonth extends StatelessWidget {
  final String month; // The selected month
  final String uid;

  TodosByMonth({required this.month, required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todos for $month') ,
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('tasks')
              .doc(uid)
              .collection('mytasks')
              .where('timestamp',
              isGreaterThanOrEqualTo: DateTime(2023, DateFormat('MMMM yyyy').parse(month).month), // Define your month start date
              isLessThan: DateTime(2023, DateFormat('MMMM yyyy').parse(month).month + 1)) // Define your month end date
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text("No todos available for $month",
                    style: TextStyle(color: Colors.white)),
              );
            } else {
              final docs  = snapshot.data?.docs;

              return ListView.builder(
                itemCount: docs?.length,
                itemBuilder: (context, index) {
                  var time =
                  (docs?[index]['timestamp'] as Timestamp).toDate();

                  return InkWell(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Color(0xff121211),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      height: 90,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(left: 20),
                                child: Text(
                                  docs?[index]['title'],
                                  style: GoogleFonts.roboto(fontSize: 20),
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 20),
                                child: Text(
                                  DateFormat.yMd().add_jm().format(time),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
