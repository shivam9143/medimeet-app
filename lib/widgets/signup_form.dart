import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/custom_button.dart';
import '../screens/gender_selector.dart';

class SignupForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSignupSuccess;
  final Function(String) onSignupFailure;

  SignupForm({required this.onSignupSuccess, required this.onSignupFailure});

  @override
  _SignupFormState createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _mobileController = TextEditingController();
  String? _selectedGender;

  void _submitSignup(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();

      final response = await authProvider.signup(
        name: _nameController.text,
        age: int.parse(_ageController.text),
        mobile: _mobileController.text,
        gender: _selectedGender,
      );

      if (response != null && response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        widget.onSignupSuccess(responseData);
      } else {
        String errorMessage =
            "Signup failed. Please try again."; // Default error message
        final Map<String, dynamic> responseData = jsonDecode(response!.body);

        if (responseData.containsKey('error')) {
          // Get the 'error' field as a string
          String errorStr = responseData['error'];

          // Replace single quotes with double quotes to make it valid JSON
          errorStr = errorStr.replaceAll("'", "\"");

          try {
            // Decode the error string to JSON
            final Map<String, dynamic> errorData = jsonDecode(errorStr);

            // Find the first key with a non-empty list of errors
            String firstKeyWithError = '';
            dynamic firstErrorMessage = '';

            errorData.forEach((key, value) {
              if (value is List && value.isNotEmpty) {
                firstKeyWithError = key;
                firstErrorMessage =
                    value[0]; // Get the first error message from the list
                return; // Exit as we found the first non-empty list
              }
            });

            if (firstErrorMessage.isNotEmpty) {
              errorMessage = firstErrorMessage;
            }
          } catch (e) {
            // Handle any error in JSON parsing
            errorMessage = "Failed to parse error details.";
          }
        }

        widget.onSignupFailure(errorMessage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Name'),
            validator: (value) =>
                value!.isEmpty ? 'Please enter your name' : null,
          ),
          TextFormField(
            controller: _ageController,
            decoration: InputDecoration(labelText: 'Age'),
            keyboardType: TextInputType.number,
            validator: (value) =>
                value!.isEmpty ? 'Please enter your age' : null,
          ),
          TextFormField(
            controller: _mobileController,
            decoration: InputDecoration(labelText: 'Mobile Number'),
            keyboardType: TextInputType.phone,
            validator: (value) =>
                value!.isEmpty ? 'Please enter your mobile number' : null,
          ),
          GenderSelector(
            selectedGender: _selectedGender,
            onGenderSelected: (gender) => setState(() {
              _selectedGender = gender;
            }),
          ),
          SizedBox(height: 20),
          CustomButton(
            label: "Sign Up",
            onPressed: () => _submitSignup(context),
          ),
        ],
      ),
    );
  }
}
