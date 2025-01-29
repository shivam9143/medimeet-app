import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';

class OTPScreen extends StatefulWidget {
  final String mobileNumber;
  final String verificationId;
  final String timeout;

  OTPScreen({
    required this.mobileNumber,
    required this.verificationId,
    this.timeout = '',
  });

  static const routeName = '/otp-screen';

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final _otpControllers = List.generate(6, (index) => TextEditingController());
  final _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isOtpValid = true; // To track OTP validity

  void verifyOtp(BuildContext context, String mobileNumber, String verificationId) async {
    final otp = _otpControllers.map((controller) => controller.text).join();

    if (otp.length == 6) {
      setState(() {
        _isOtpValid = true; // OTP is valid, so set to true
      });

      // Call your backend API to verify OTP
      // Call verifyOtp method from provider
      final response = await Provider.of<AuthProvider>(context, listen: false)
          .verifyOtp(mobileNumber: mobileNumber, verificationId: verificationId, otp: otp);

      print("verify-otp Response: ${response?.body}");
      if (response != null && response.statusCode == 200) {
        saveUserDataToPrefs(response);
        // final prefs = await SharedPreferences.getInstance();
        // prefs.setBool('isLoggedIn', true);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
              (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Invalid OTP. Please try again.")),
        );
      }
    } else {
      setState(() {
        _isOtpValid = false; // OTP is invalid, show error message
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a valid 6-digit OTP.")),
      );
    }
  }


  Future<void> saveUserDataToPrefs(Response? response) async {
    if (response != null && response.statusCode == 200) {
      final responseData = json.decode(response.body);

      // Extracting user details and token from the response
      final String token = responseData["data"]["token"];
      final String userId = responseData["data"]["user"]["id"];
      final String name = responseData["data"]["user"]["name"];
      final int age = responseData["data"]["user"]["age"];
      final String mobile = responseData["data"]["user"]["mobile_number"];
      final String gender = responseData["data"]["user"]["gender"] ?? 'Not Provided'; // Handle nullable field

      // Saving data to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('authToken', token);
      await prefs.setString('userId', userId);
      await prefs.setString('name', name);
      await prefs.setInt('age', age);
      await prefs.setString('mobile', mobile);
      await prefs.setString('gender', gender);

      print("User data saved successfully:");
      print("Token: $token");
      print("User ID: $userId");
      print("Name: $name");
      print("Age: $age");
      print("Mobile: $mobile");
      print("Gender: $gender");
    } else {
      print("Failed to verify OTP. Response: ${response?.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Read arguments passed through Navigator
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    // You can also access these values directly from the args map
    final String verificationId = args['verification_id'];
    final String mobileNumber = args['mobile_number'];
    final String timeout = args['timeout'];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade200, Colors.blue.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo
                Icon(
                  Icons.local_hospital,
                  size: 100,
                  color: Colors.blueAccent,
                ),
                SizedBox(height: 10),
                // App Name
                Text(
                  "MediMeet",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                SizedBox(height: 30),
                // OTP Input - 6 digit boxes
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: SizedBox(
                        width: 50,
                        child: TextField(
                          controller: _otpControllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 24),
                          decoration: InputDecoration(
                            counterText: "",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty && index < 5) {
                              FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
                            } else if (value.isEmpty && index > 0) {
                              FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
                            }
                          },
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: 10),
                // Error message if OTP is invalid
                if (!_isOtpValid)
                  Text(
                    "Please enter a valid 6-digit OTP.",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                SizedBox(height: 20),
                // Submit Button
                ElevatedButton.icon(
                  onPressed: () => verifyOtp(context, mobileNumber, verificationId),
                  icon: Icon(Icons.check_circle, color: Colors.white),
                  label: Text("Submit"),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                SizedBox(height: 20),
                // Timeout Text
                if (timeout.isNotEmpty) ...[
                  Text(
                    "OTP valid for $timeout seconds.",
                    style: TextStyle(
                      color: Colors.blueGrey.shade600,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}