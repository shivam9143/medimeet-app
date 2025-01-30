import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart'; // Import your LoginScreen here

class UserProfileScreen extends StatelessWidget {
  // Function to fetch user data from SharedPreferences
  Future<Map<String, dynamic>> _fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();

    // Retrieve data from SharedPreferences
    final String? name = prefs.getString('name');
    final String? mobile = prefs.getString('mobile');
    final int? age = prefs.getInt('age');
    final String? gender = prefs.getString('gender');
    final String? token = prefs.getString('authToken');

    // If the user is logged in, return the user data
    return {
      'name': name ?? 'N/A',
      'mobile': mobile ?? 'N/A',
      'age': age ?? 0,
      'gender': gender ?? 'N/A',
      'token': token ?? 'N/A'
    };
  }

  // Function to handle logout
  void _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    // Clear all shared preferences
    await prefs.clear();

    // Navigate to the login screen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      // Replace LoginScreen with your actual login screen
      (route) => false, // Remove all previous routes
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          // Extracting user data
          final userData = snapshot.data;

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade200, Colors.blue.shade50],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo and App Name
                    Icon(
                      Icons.local_hospital,
                      size: 100,
                      color: Colors.blueAccent,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "MediMeet",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    SizedBox(height: 30),

                    // User Profile Info (List of Tiles)
                    Container(
                      width: double.infinity, // Ensure it takes the full width
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 3,
                            blurRadius: 5,
                            offset: Offset(0, 3), // Shadow direction
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildProfileTile(Icons.account_circle,
                              "Name: ${userData?['name']}"),
                          _buildProfileTile(
                              Icons.phone, "Mobile: ${userData?['mobile']}"),
                          _buildProfileTile(
                              Icons.cake, "Age: ${userData?['age']}"),
                          _buildProfileTile(Icons.transgender,
                              "Gender: ${userData?['gender']}"),
                        ],
                      ),
                    ),

                    SizedBox(height: 30),

                    // Logout Button
                    ElevatedButton.icon(
                      onPressed: () => _logout(context),
                      icon: Icon(Icons.exit_to_app, color: Colors.white),
                      label:
                          Text("Logout", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red, // Red color for logout
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        textStyle: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper function to create profile list items
  Widget _buildProfileTile(IconData icon, String text) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(
        text,
        style: TextStyle(fontSize: 16, color: Colors.black87),
      ),
    );
  }
}
