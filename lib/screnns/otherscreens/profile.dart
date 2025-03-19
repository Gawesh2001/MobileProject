// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously, avoid_print, use_key_in_widget_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gofinder/screnns/authentication/sign_in.dart'; // Assuming this import is correct
import 'package:gofinder/screnns/otherscreens/provider_profile.dart';
import 'package:gofinder/screnns/otherscreens/workreg.dart';

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

  // Function to fetch user's name from Firestore
  Future<String> _fetchUserName(String userId) async {
    try {
      // Access Firestore collection "workerregister" to get the name
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('workerregister')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        // If user document exists, return the name
        return userDoc['name'] ?? 'No Name Available';
      } else {
        return 'No Name Available';
      }
    } catch (e) {
      print("Error fetching user name: $e");
      return 'Error fetching name';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return FutureBuilder<String>(
      future: _fetchUserName(user?.uid ?? ''),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Profile',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: const Color(0xff0079C2),
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Profile',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: const Color(0xff0079C2),
            ),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        final userName = snapshot.data ?? 'No Name Available';

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Profile',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xff0079C2),
            actions: [
              // IconButton(
              //   icon: const Icon(Icons.logout, color: Colors.white),
              //   onPressed: () =>
              //       _confirmLogout(context), // Call confirmation dialog
              // ),
            ],
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Displaying the user name instead of user ID
                Text("Name: $userName",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text("Email: ${user?.email ?? 'Not Available'}",
                    style: TextStyle(fontSize: 16)),
                SizedBox(height: 20),
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
                SizedBox(height: 30),
                // Options Section
                ListTile(
                  leading: Icon(Icons.app_registration, color: Colors.blue),
                  title: Text("Register"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WorkReg()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.work, color: Colors.green),
                  title: Text("Jobs"),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(Icons.supervised_user_circle,
                      color: const Color.fromARGB(255, 195, 197, 45)),
                  title: Text("User Profile"),
                  onTap: () {},
                ),
                ListTile(
                  leading:
                      Icon(Icons.settings_accessibility, color: Colors.green),
                  title: Text("Provider Profile"),
                  onTap: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) =>WorkerProfile())
                  );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.flag, color: Colors.green),
                  title: Text("On Going Jobs"),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(Icons.settings,
                      color: const Color.fromARGB(255, 209, 114, 5)),
                  title: Text("Settings"),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(Icons.attach_money, color: Colors.orange),
                  title: Text("Income"),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text("Log Out"),
                  onTap: () => _confirmLogout(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
