// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously, avoid_print, use_key_in_widget_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gofinder/screnns/authentication/sign_in.dart'; // Assuming this import is correct

class ProfilePage extends StatelessWidget {
  // Function to show logout confirmation dialog
  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Log Out",
              style: TextStyle(color: Color.fromARGB(255, 199, 16, 3))),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close dialog
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _logOut(context); // Call the logout function
              },
              child: const Text("OK",
                  style: TextStyle(color: Color.fromARGB(255, 10, 134, 124))),
            ),
          ],
        );
      },
    );
  }

  // Function to handle Firebase logout
  void _logOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut(); // Firebase Sign Out
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => const Sign_In()), // Navigate to Sign-In page
      );
    } catch (e) {
      print("Error logging out: $e"); // Handle logout error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xff0079C2),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () =>
                _confirmLogout(context), // Call confirmation dialog
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(
                'https://i.pinimg.com/736x/03/eb/d6/03ebd625cc0b9d636256ecc44c0ea324.jpg',
              ),
              radius: 50,
            ),
            SizedBox(height: 20),
            Text(
              'Profile Page',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
