import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../models/doctor.dart';

class DoctorProvider with ChangeNotifier {
  List<Doctor> _doctors = [];
  bool _isLoading = false;

  List<Doctor> get doctors => _doctors;
  bool get isLoading => _isLoading;

  Future<void> fetchDoctors() async {
    if (_isLoading || _doctors.isNotEmpty) return; // Avoid duplicate calls
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('https://api.rabattindia.com/doctors/'),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        final List data = json.decode(response.body)['data'];
        if (data != null) {
          _doctors = data.map((json) => Doctor.fromJson(json)).toList();
        }
      } else {
        throw Exception('Failed to load doctors');
      }
    } catch (e) {
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}