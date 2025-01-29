import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:medimeet/widgets/signup_form.dart';

import 'otp_screen.dart';

class SignupScreen extends StatelessWidget {
  static const routeName = '/signup';

  void _navigateToOTP(BuildContext context, Map<String, dynamic> response) {
    Navigator.of(context).pushNamed(
      OTPScreen.routeName,
      arguments: {
        'verification_id': response['data']['verification_id'],
        'mobile_number': response['data']['mobile_number'],
        'timeout': response['data']['timeout'],
      },
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign Up")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SignupForm(
          onSignupSuccess: (response) => _navigateToOTP(context, response),
          onSignupFailure: (message) => _showError(context, message),
        ),
      ),
    );
  }
}

// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/auth_provider.dart';
// import 'otp_screen.dart';
//
// class SignupScreen extends StatefulWidget {
//   static const routeName = '/signup';
//
//   @override
//   _SignupScreenState createState() => _SignupScreenState();
// }
//
// class _SignupScreenState extends State<SignupScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _ageController = TextEditingController();
//   final _mobileController = TextEditingController();
//   String? _selectedGender;
//
//   void _submitSignup(BuildContext context) async {
//     if (_formKey.currentState!.validate()) {
//       final name = _nameController.text;
//       final age = int.parse(_ageController.text);
//       final mobile = _mobileController.text;
//
//       // Call signup method from provider
//       final response = await Provider.of<AuthProvider>(context, listen: false)
//           .signup(
//               name: name, age: age, mobile: mobile, gender: _selectedGender);
//
//       if (response != null) {
//         // Navigate to the OTP screen and pass the data
//         switch (response.statusCode) {
//           case 201:
//             final data = json.decode(response.body);
//             Navigator.of(context).pushNamed(
//               OTPScreen.routeName,
//               arguments: {
//                 'verification_id': data['data']['verification_id'],
//                 'mobile_number': data['data']['mobile_number'],
//                 'timeout': data['data']['timeout'],
//               },
//             );
//             break;
//           default:
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text('Signup failed. Please try again.')),
//             );
//         }
//       } else {
//         // Show an error message
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Signup failed. Please try again.')),
//         );
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         toolbarHeight: 0, // Remove the default toolbar
//         backgroundColor: Colors.transparent, // Transparent app bar
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.blue.shade200, Colors.blue.shade50],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 SizedBox(height: 40),
//                 // Logo and App Name
//                 Icon(
//                   Icons.local_hospital,
//                   size: 100,
//                   color: Colors.blueAccent,
//                 ),
//                 SizedBox(height: 10),
//                 Text(
//                   "MediMeet",
//                   style: TextStyle(
//                     fontSize: 30,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.blueAccent,
//                   ),
//                 ),
//                 SizedBox(height: 40),
//                 // Form for Signup
//                 Expanded(
//                   child: Form(
//                     key: _formKey,
//                     child: ListView(
//                       children: [
//                         // Name Input
//                         TextFormField(
//                           controller: _nameController,
//                           decoration: InputDecoration(
//                             labelText: "Name",
//                             prefixIcon: Icon(Icons.person),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return "Please enter your name";
//                             }
//                             return null;
//                           },
//                         ),
//                         SizedBox(height: 16),
//                         // Age Input
//                         TextFormField(
//                           controller: _ageController,
//                           keyboardType: TextInputType.number,
//                           decoration: InputDecoration(
//                             labelText: "Age",
//                             prefixIcon: Icon(Icons.cake),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           validator: (value) {
//                             if (value == null || int.tryParse(value) == null) {
//                               return "Please enter a valid age";
//                             }
//                             return null;
//                           },
//                         ),
//                         SizedBox(height: 16),
//                         // Mobile Number Input
//                         TextFormField(
//                           controller: _mobileController,
//                           keyboardType: TextInputType.phone,
//                           decoration: InputDecoration(
//                             labelText: "Mobile Number",
//                             prefixIcon: Icon(Icons.phone),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           validator: (value) {
//                             if (value == null || value.length != 10) {
//                               return "Please enter a valid 10-digit mobile number";
//                             }
//                             return null;
//                           },
//                         ),
//                         SizedBox(height: 16),
//                         // Gender Dropdown
//                         DropdownButtonFormField<String>(
//                           value: _selectedGender,
//                           decoration: InputDecoration(
//                             labelText: "Gender",
//                             prefixIcon: Icon(Icons.transgender),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           items: [
//                             DropdownMenuItem(
//                                 value: "Male", child: Text("Male")),
//                             DropdownMenuItem(
//                                 value: "Female", child: Text("Female")),
//                             DropdownMenuItem(
//                                 value: "Other", child: Text("Other")),
//                           ],
//                           onChanged: (value) {
//                             setState(() {
//                               _selectedGender = value;
//                             });
//                           },
//                           validator: (value) {
//                             if (value == null) {
//                               return "Please select your gender";
//                             }
//                             return null;
//                           },
//                         ),
//                         SizedBox(height: 30),
//                         // Signup Button
//                         ElevatedButton(
//                           onPressed: () => _submitSignup(context),
//                           style: ElevatedButton.styleFrom(
//                             padding: EdgeInsets.symmetric(vertical: 15),
//                             primary: Colors.blueAccent,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           child: Text(
//                             "Register",
//                             style: TextStyle(fontSize: 18),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
