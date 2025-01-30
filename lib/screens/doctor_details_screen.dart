import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/doctor.dart';
import '../models/slots.dart';

class DoctorDetailsScreen extends StatefulWidget {
  final Doctor doctor;

  const DoctorDetailsScreen({Key? key, required this.doctor}) : super(key: key);

  static const routeName = '/doctor-details-screen';

  @override
  State<DoctorDetailsScreen> createState() => _DoctorDetailsScreenState();
}

class _DoctorDetailsScreenState extends State<DoctorDetailsScreen> {
  List<Slot> slots = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSlots();
  }

  /// Fetch available slots for the doctor
  Future<void> fetchSlots() async {
    final url =
        'https://api.rabattindia.com/clinic-management/doctors/${widget.doctor.id}/slots/';
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('authToken');

      if (token == null) {
        throw Exception("No token found.");
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          slots = data.map((json) => Slot.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load slots');
      }
    } catch (e) {
      print('Error fetching slots: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Function to book an appointment
  Future<void> bookAppointment(String slotId) async {
    final url =
        'https://api.rabattindia.com/clinic-management/appointments/book/$slotId/';
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('authToken');

      if (token == null) {
        throw Exception("No token found in preferences.");
      }

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        print("Booking successful: $responseData");

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Slot booked successfully!"),
            backgroundColor: Colors.green,
          ),
        );

        fetchSlots(); // Refresh slots
      } else {
        final errorData = json.decode(response.body);
        print("Booking failed: ${errorData['error']}");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to book: ${errorData['error']}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error booking appointment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong, try again!"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String formatTime(String time) {
    final DateTime parsedTime = DateTime.parse(time).toLocal();
    final DateFormat dateFormat = DateFormat('dd MMM, hh:mm a');
    return dateFormat.format(parsedTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Details'),
      ),
      body: Column(
        children: [
          // Doctor Card
          Card(
            margin: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: widget.doctor.photoUrl.isNotEmpty
                        ? NetworkImage(widget.doctor.photoUrl)
                        : null,
                    child: widget.doctor.photoUrl.isEmpty
                        ? const Icon(Icons.person, size: 40)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.doctor.name,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(widget.doctor.specialization),
                        const SizedBox(height: 8),
                        Text("Age: ${widget.doctor.age}"),
                        const SizedBox(height: 8),
                        Text("Gender: ${widget.doctor.gender}"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Slots Section
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : slots.isEmpty
                    ? Center(
                        child: Column(
                          children: [
                            const Icon(Icons.event_busy,
                                size: 100, color: Colors.grey),
                            const SizedBox(height: 16),
                            const Text(
                              'No slots available',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: slots.length,
                        itemBuilder: (context, index) {
                          final slot = slots[index];
                          final startTime = formatTime(slot.startTime);
                          final endTime = formatTime(slot.endTime);

                          // Check if the slot is in the future
                          bool isSlotInPast = DateTime.parse(slot.startTime)
                              .toLocal()
                              .isBefore(DateTime.now());

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$startTime -',
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '$endTime',
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        slot.isAvailable
                                            ? 'Available'
                                            : 'Not Available',
                                        style: TextStyle(
                                            color: slot.isAvailable
                                                ? Colors.green
                                                : Colors.red),
                                      ),
                                    ],
                                  ),
                                  ElevatedButton(
                                    onPressed: isSlotInPast || !slot.isAvailable
                                        ? () {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Cannot book a past or unavailable slot.'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        : () => bookAppointment(slot.id),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          isSlotInPast || !slot.isAvailable
                                              ? Colors.grey
                                              : Colors.blue,
                                    ),
                                    child: const Text('Book Appointment'),
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
    );
  }
}
