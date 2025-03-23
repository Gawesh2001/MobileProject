import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingPage extends StatelessWidget {
  final String userId; // Worker's user ID
  final String name;
  final String age;
  final String rating;
  final String imageUrl;

  BookingPage({
    required this.userId,
    required this.name,
    required this.age,
    required this.rating,
    required this.imageUrl,
  });

  // Function to generate job number
  Future<String> _generateJobNumber() async {
    final firestore = FirebaseFirestore.instance;
    final querySnapshot = await firestore
        .collection('jobs')
        .orderBy('jobNumber', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final lastJobNumber = querySnapshot.docs.first['jobNumber'] as String;
      final lastNumber =
          int.parse(lastJobNumber.substring(1)); // Extract number after 'J'
      return 'J${lastNumber + 1}'; // Increment by 1
    } else {
      return 'J1000'; // Start from J1000 if no jobs exist
    }
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController textController = TextEditingController();

    // Get the current user from Firebase Authentication
    User? user = FirebaseAuth.instance.currentUser;
    String currentUserId = user?.uid ?? 'Not logged in';

    return Scaffold(
      appBar: AppBar(
        title:
            Text('Booking Page', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: imageUrl.isNotEmpty
                  ? NetworkImage(imageUrl)
                  : AssetImage('assets/default_avatar.png') as ImageProvider,
            ),
            SizedBox(height: 15),
            Text(name,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text("Age: $age years",
                style: TextStyle(fontSize: 16, color: Colors.black54)),
            SizedBox(height: 5),
            Text("User ID: $userId",
                style: TextStyle(fontSize: 16, color: Colors.black54)),
            SizedBox(height: 5),
            Text("Current User UID: $currentUserId",
                style: TextStyle(fontSize: 16, color: Colors.black54)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: Colors.amber, size: 24),
                SizedBox(width: 5),
                Text(rating,
                    style: TextStyle(fontSize: 18, color: Colors.black54)),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              controller: textController,
              maxLength: 100,
              decoration: InputDecoration(
                hintText:
                    "Enter a short detail about the requirement (max 100 words)",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              maxLines: 4,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String additionalInfo = textController.text;

                // Generate job number
                String jobNumber = await _generateJobNumber();

                // Store job details in Firestore
                final firestore = FirebaseFirestore.instance;
                await firestore.collection('jobs').add({
                  'jobNumber': jobNumber,
                  'customer': currentUserId,
                  'worker': userId,
                  'text': additionalInfo,
                  'timestamp':
                      FieldValue.serverTimestamp(), // Optional: Add timestamp
                });

                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          "Worker booked successfully! Job Number: $jobNumber")),
                );
              },
              child: Text("Book Now", style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
