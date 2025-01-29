import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({Key? key}) : super(key: key);

  @override
  _AppointmentsScreenState createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  List<Map<String, dynamic>> appointments = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchAppointments();
  }

  Future<void> cancelAppointment(String slotId) async {
    const url =
        'https://api.rabattindia.com/clinic-management/appointments/cancel/';

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('authToken');

      if (token == null) {
        throw Exception("No token found.");
      }

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'slot_id': slotId}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Refresh the list of appointments
        fetchAppointments();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Appointment canceled successfully.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
              Text(data['message'] ?? 'Failed to cancel appointment.')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  Future<void> fetchAppointments() async {
    const url = 'https://api.rabattindia.com/clinic-management/appointments/';
    try {
      // Get the shared preferences instance
      final prefs = await SharedPreferences.getInstance();

      // Read the stored token from prefs
      final String? token = prefs
          .getString('authToken'); // Replace 'authToken' with your actual key

      if (token == null) {
        throw Exception("No token found in preferences.");
      }

      // Make the POST request
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          // Pass the token in the Bearer format
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 200) {
          setState(() {
            appointments = List<Map<String, dynamic>>.from(data['data']);
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = data['message'] ?? 'Failed to fetch appointments';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to fetch appointments. Please try again.';
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = 'An error occurred: $error';
        isLoading = false;
      });
    }
  }

  // Function to parse the time and format it
  String formatTime(String time) {
    final DateTime parsedTime = DateTime.parse(time);
    final DateFormat dateFormat = DateFormat('dd MMM, hh:mm a');
    return dateFormat.format(parsedTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null, // Removed AppBar (No back button)
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Upcoming Appointments',
              style: Theme.of(context).textTheme.headline6?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            SizedBox(height: 16),
            if (isLoading)
              Center(child: CircularProgressIndicator())
            else if (appointments.isEmpty)
              Center(child: Text('No appointments found.'))
            else if (errorMessage.isNotEmpty)
                Center(
                    child:
                    Text(errorMessage, style: TextStyle(color: Colors.red)))
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: appointments.length,
                    itemBuilder: (context, index) {
                      final appointment = appointments[index];
                      final doctor = appointment['doctor'];
                      final patient = appointment['patient'];
                      final slot = appointment['slot'];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              // Calendar dots instead of the calendar icon
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: Theme.of(context).primaryColor,
                                child: Text(
                                  '•', // Dot character
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Doctor: ${doctor['name']}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1
                                          ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Patient: ${patient['name']}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          ?.copyWith(
                                        color: Colors.black54,
                                      ),
                                    ),
                                    Text(
                                      'Time: ${formatTime(slot['start_time'])} - ${formatTime(slot['end_time'])}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          ?.copyWith(
                                        color: Colors.black54,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: appointment['status'] == 'Booked'
                                            ? Colors.green
                                            : Colors.orange,
                                        // Adjust based on status
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        appointment['status'],
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Conditionally show the Cancel button based on the status
                              if (appointment['status'] != 'Cancelled')
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        cancelAppointment(appointment['slot']['id']);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                              content:
                                              Text('Canceling appointment...')),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.red, // Red for cancel
                                        padding: EdgeInsets.symmetric(
                                            vertical: 12.0, horizontal: 16.0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text('Cancel'),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
          ],
        ),
      ),
    );
  }
}