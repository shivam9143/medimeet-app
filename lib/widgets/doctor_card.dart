import 'package:flutter/material.dart';

import '../models/doctor.dart';

class DoctorCard extends StatelessWidget {
  final Doctor doctor;

  DoctorCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            // Doctor Image (Default icon as placeholder)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 80,
                height: 80,
                color: Colors.blue, // Light grey background for the icon
                child: Icon(
                  Icons.person, // Default person icon
                  size: 40,
                  color: Colors.white, // Icon color
                ),
              ),
            ),
            SizedBox(width: 15),
            // Doctor Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    doctor.specialization,
                    style: TextStyle(color: Colors.blueGrey),
                  ),
                  SizedBox(height: 5),
                  Text('Age: ${doctor.age}, Gender: ${doctor.gender}'),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.phone, size: 20, color: Colors.blue),
                      SizedBox(width: 5),
                      Text(doctor.mobileNumber),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
