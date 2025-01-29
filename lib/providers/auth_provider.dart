import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  String? _authToken;

  String? get authToken => _authToken;

  bool get isAuthenticated => _authToken != null;

  // Signup Method
  Future<http.Response?> signup({
    required String name,
    required int age,
    required String mobile,
    required String? gender,
  }) async {
    final url = Uri.parse('https://api.rabattindia.com/register-user/');
    try {
      final response = await http.post(
        url,
        body: json.encode({
          "name": name,
          "age": age,
          "mobile_number": mobile,
          "gender": gender,
        }),
        headers: {"Content-Type": "application/json"},
      );

      print("Signup Response: ${response.body}");
      return response;
    } catch (error) {
      print(error);
      return null;
    }
  }

  // verify-otp Method
  Future<http.Response?> verifyOtp(
      {required String mobileNumber,
      required String verificationId,
      required String otp}) async {
    final url = Uri.parse('https://api.rabattindia.com/verify-otp/');
    try {
      final response = await http.post(
        url,
        body: json.encode({
          "mobile_number": mobileNumber,
          "verification_id": verificationId,
          "otp": otp,
        }),
        headers: {"Content-Type": "application/json"},
      );

      print("verify-otp Response: ${response.body}");
      return response;
    } catch (error) {
      print(error);
      return null;
    }
  }

  Future<http.Response?> sendOtp({
    required String mobile,
  }) async {
    final url = Uri.parse('https://api.rabattindia.com/send-otp/');
    try {
      final response = await http.post(
        url,
        body: json.encode({
          "mobile_number": mobile,
        }),
        headers: {"Content-Type": "application/json"},
      );

      print("sendOtp Response: ${response.body}");
      return response;
    } catch (error) {
      print(error);
      return null;
    }
  }

  // Auto-login on app restart
  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('authToken')) return;

    _authToken = prefs.getString('authToken');
    notifyListeners();
  }

  // Logout method
  Future<void> logout() async {
    _authToken = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    prefs.remove('authToken');
  }
}
