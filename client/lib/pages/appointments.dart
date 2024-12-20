import 'package:client/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AppointmentsPage extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Appointments')),
        body: Center(child: Text('No user logged in.')),
      );
    }

    final String userId = user.uid;

    return Scaffold(
      appBar: AppBar(title: Text('Appointments')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _firestoreService.getAppointments(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No appointments found.'));
          }
          final appointments = snapshot.data!
            ..sort((a, b) {
              final dateA = (a['appointmentDate'] as Timestamp).toDate();
              final dateB = (b['appointmentDate'] as Timestamp).toDate();
              return dateB.compareTo(dateA);
            });
          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];

              String appointmentDate = 'No Date';
              if (appointment['appointmentDate'] is Timestamp) {
                final date =
                    (appointment['appointmentDate'] as Timestamp).toDate();
                appointmentDate = DateFormat('yyyy-MM-dd HH:mm').format(date);
              }

              Color cardColor;
              switch (appointment['status']) {
                case 'Completed':
                  cardColor = Colors.green;
                  break;
                case 'Cancelled':
                  cardColor = Colors.red;
                  break;
                case 'Scheduled':
                  cardColor = Colors.blue;
                  break;
                default:
                  cardColor = Colors.grey;
              }

              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AppointmentDetailsPage(appointment: appointment),
                  ),
                ),
                child: Card(
                  color: cardColor,
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appointment['doctorName'] != null &&
                                        appointment['specialization'] != null
                                    ? '${appointment['doctorName']} (${appointment['specialization']})'
                                    : 'No Doctor Information',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                appointmentDate,
                                style: TextStyle(fontSize: 14.0),
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                appointment['location'] ?? 'No Location',
                                style: TextStyle(fontSize: 14.0),
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                'Status: ${appointment['status'] ?? 'Unknown'}',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AppointmentDetailsPage extends StatelessWidget {
  final Map<String, dynamic> appointment;

  AppointmentDetailsPage({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Appointment Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notes:',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              appointment['notes'] ?? 'No notes available.',
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}
