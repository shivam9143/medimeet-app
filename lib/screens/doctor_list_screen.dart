import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/doctor_provider.dart';
import '../widgets/doctor_card.dart';
import 'doctor_details_screen.dart';

class DoctorListScreen extends StatefulWidget {
  @override
  _DoctorListScreenState createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  @override
  void initState() {
    super.initState();
    final doctorProvider = Provider.of<DoctorProvider>(context, listen: false);
    if (doctorProvider.doctors.isEmpty) {
      doctorProvider.fetchDoctors();
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctorProvider = Provider.of<DoctorProvider>(context);

    return Scaffold(
      body: doctorProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : doctorProvider.doctors.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 100, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              'No doctors found.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: doctorProvider.doctors.length,
        itemBuilder: (contextc, index) {
          final doctor = doctorProvider.doctors[index];
          return GestureDetector(
            onTap: () {
              print('Clicked on: ${doctor.name}');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DoctorDetailsScreen(doctor: doctor),
                ),
              );
            },
            child: DoctorCard(doctor: doctor),
          );
        },
      ),
    );
  }
}