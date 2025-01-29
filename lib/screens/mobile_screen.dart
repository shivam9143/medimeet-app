import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for input formatters
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'otp_screen.dart';

class MobileScreen extends StatefulWidget {
  MobileScreen({super.key});

  @override
  _MobileScreenState createState() => _MobileScreenState();
}

class _MobileScreenState extends State<MobileScreen> {
  final _mobileController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _mobileError;

  Future<void> sendOtp(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final mobileNumber = _mobileController.text;
      // Call signup method from provider
      final response = await Provider.of<AuthProvider>(context, listen: false)
          .sendOtp(mobile: mobileNumber);

      if (response != null) {
        final data = json.decode(response.body);
        switch (response.statusCode) {
          case 201:
            Navigator.of(context).pushNamed(
              OTPScreen.routeName,
              arguments: {
                'verification_id': data['data']['verification_id'],
                'mobile_number': data['data']['mobile_number'],
                'timeout': data['data']['timeout'],
              },
            );
            break;
          default:
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("${data['message']} ${data['error']}")));
        }
      } else {
        // Show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup failed. Please try again.')),
        );
      }
    }
  }

  String? validateMobileNumber(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your mobile number";
    } else if (value.length != 10) {
      return "Please enter a valid 10-digit mobile number";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
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
            child: Form(
              key: _formKey,
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
                  // Mobile Number Input
                  TextFormField(
                    controller: _mobileController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Mobile Number",
                      prefixIcon: Icon(Icons.phone, color: Colors.blueAccent),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    inputFormatters: [
                      // Restrict user to only digits and limit to 10 digits
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    validator: validateMobileNumber,
                  ),
                  SizedBox(height: 10),
                  // Error Message
                  if (_mobileError != null)
                    Text(
                      _mobileError!,
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  SizedBox(height: 20),
                  // Send OTP Button
                  ElevatedButton.icon(
                    onPressed: () => sendOtp(context),
                    icon: Icon(Icons.message, color: Colors.white),
                    label: Text("Send OTP"),
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
                  // Footer Text
                  Text(
                    "Enter your 10-digit mobile number to proceed.",
                    style: TextStyle(
                      color: Colors.blueGrey.shade600,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}