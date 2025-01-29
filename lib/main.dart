import 'package:flutter/material.dart';
import 'package:medimeet/providers/doctor_provider.dart';
import 'package:medimeet/screens/otp_screen.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider(create: (_) => DoctorProvider()),  // Add the DoctorProvider here
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediMeet',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SplashScreen(),
      routes: {
        OTPScreen.routeName: (ctx) =>
            OTPScreen(mobileNumber: '', verificationId: ''),
        // Register the OTP screen route
        // '/signup': (context) => SignupScreen(),
        // '/mobile': (context) => MobileScreen(),
        // '/otp': (context) => OTPScreen(),
        // '/home': (context) => HomeScreen(),
      },
    );
  }
}
