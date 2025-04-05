import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mydo/core/constants/constants.dart';

class Description extends StatelessWidget {
  final String title, description, createdBy, status;
  final DateTime startTime, endTime;
  final bool isGroupTask;

  const Description({
    Key? key,
    required this.title,
    required this.description,
    required this.createdBy,
    required this.status,
    required this.startTime,
    required this.endTime,
    required this.isGroupTask,
  }) : super(key: key);

  Future<String> getUserName(String userId) async {
    print('User ID Created Byyyyyyy: $createdBy');
    print('User ID: $userId');
    print('User ID Fetching user name for ID: $userId');
    print('User ID Fetching user name for ID: $createdBy');
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          // .collection(
          //     'users')
          // .doc(userId)
          // .get();
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        return userDoc['username'];
      } else {
        return 'Unknown User';
      }
    } catch (e) {
      print('Error fetching user name: $e');
      return 'Unknown User';
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedStartTime =
        DateFormat('MMM d, y | hh:mm a').format(startTime);
    final formattedEndTime = DateFormat('MMM d, y | hh:mm a').format(endTime);

    return Scaffold(
      appBar: AppBar(
        title: Text('Task Details', style: GoogleFonts.roboto()),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailItem(Icons.title, 'Title', title),
                _buildDetailItem(Icons.description, 'Description', description),

                FutureBuilder<String>(
                  future: getUserName(createdBy),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildDetailItem(
                          Icons.person, 'Created By', 'Loading...');
                    } else if (snapshot.hasError) {
                      return _buildDetailItem(
                          Icons.person, 'Created By', 'Unknown User');
                    } else {
                      return _buildDetailItem(Icons.person, 'Created By',
                          snapshot.data ?? 'Unknown User');
                    }
                  },
                ),

                // _buildDetailItem(Icons.person, 'Created By', createdBy),
                _buildDetailItem(Icons.group, 'Task Type',
                    isGroupTask ? 'Group Task' : 'Individual Task'),
                _buildDetailItem(
                    Icons.access_time, 'Start Time', formattedStartTime),
                _buildDetailItem(
                    Icons.access_time_filled, 'End Time', formattedEndTime),
                _buildStatusChip(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple, size: 24),
          SizedBox(width: 10),
          Text('$label:',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              )),
          SizedBox(width: 10),
          Expanded(
            child: Text(value,
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  color: Colors.white,
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    Color statusColor;
    switch (status) {
      case 'Completed':
        statusColor = Colors.green;
        break;
      case 'In Progress':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Chip(
        backgroundColor: statusColor,
        label: Text(status,
            style: GoogleFonts.roboto(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )),
      ),
    );
  }
}
