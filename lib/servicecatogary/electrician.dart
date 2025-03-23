import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:gofinder/navigators/bottomnavigatorbar.dart'; // Import BottomNavigatorBar
import 'package:gofinder/screnns/home/home.dart'; // Import Home.dart
import 'package:gofinder/Booking/bookingpage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      home: ElectricianListScreen(),
    );
  }
}

class ElectricianListScreen extends StatefulWidget {
  @override
  _ElectricianListScreenState createState() => _ElectricianListScreenState();
}

class _ElectricianListScreenState extends State<ElectricianListScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance; // FirebaseAuth instance
  String uid = 'Loading...'; // Placeholder for UID

  @override
  void initState() {
    super.initState();
    _getUserUid(); // Fetch UID when the widget initializes
  }

  // Function to fetch the current user's UID
  void _getUserUid() {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        uid = user.uid; // Update UID
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          CustomAppBar(title: "Home"), // ✅ Updated App Bar
          // Padding(
          // padding: EdgeInsets.all(16.0),
          // child: Text(
          //'Your UID: $uid', // Display UID
          // style: TextStyle(
          //  fontSize: 16,
          //  fontWeight: FontWeight.bold,
          //  color: Colors.blue.shade900,
          // ),
          // ),
          //),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('workerregister')
                  .where('jobTitle', isEqualTo: 'Electrician')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No workers found"));
                }

                var workers = snapshot.data!.docs;

                return ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: workers.length,
                  itemBuilder: (context, index) {
                    var data = workers[index].data() as Map<String, dynamic>;
                    return WorkerCard(
                      userId: data['userId'] ?? 'N/A',
                      name: data['name'] ?? 'No Name',
                      age: data['age'] ?? 'N/A',
                      rating: data['rating']?.toString() ?? '0.00',
                      imageUrl: data['imageUrl'] ?? '',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookingPage(
                              userId: data['userId'] ?? 'N/A',
                              name: data['name'] ?? 'No Name',
                              age: data['age'] ?? 'N/A',
                              rating: data['rating']?.toString() ?? '0.00',
                              imageUrl: data['imageUrl'] ?? '',
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigatorBar(), // ✅ Custom BottomNavigationBar
    );
  }
}

// ✅ Custom AppBar with Home Navigation
class CustomAppBar extends StatelessWidget {
  final String title;
  CustomAppBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130, // Increased height
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade900, Colors.blueAccent], // Blue Gradient
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 🔹 Back Arrow that navigates to Home.dart
          Positioned(
            left: 10,
            top: 55,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Home()), // ✅ Navigates to Home.dart
                );
              },
            ),
          ),
          Positioned(
            top: 58,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 26, // Increased text size
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ Worker Card UI (Updated)
class WorkerCard extends StatefulWidget {
  final String userId;
  final String name;
  final String age;
  final String rating;
  final String imageUrl;
  final VoidCallback onTap;

  WorkerCard({
    required this.userId,
    required this.name,
    required this.age,
    required this.rating,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  _WorkerCardState createState() => _WorkerCardState();
}

class _WorkerCardState extends State<WorkerCard> {
  bool isSaved = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 3,
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              // Worker Profile Image
              CircleAvatar(
                radius: 28, // Slightly smaller avatar
                backgroundImage: widget.imageUrl.isNotEmpty
                    ? NetworkImage(widget.imageUrl)
                    : AssetImage('assets/default_avatar.png') as ImageProvider,
              ),
              SizedBox(width: 15),

              // Worker Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.name,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black)),
                    SizedBox(height: 3),
                    Text("${widget.age} years",
                        style: TextStyle(color: Colors.black54, fontSize: 14)),
                    SizedBox(height: 3),
                    Text("User ID: ${widget.userId}",
                        style: TextStyle(color: Colors.black54, fontSize: 14)),
                    SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        SizedBox(width: 5),
                        Text(widget.rating,
                            style:
                                TextStyle(color: Colors.black54, fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ),

              // Save (Bookmark) Button
              IconButton(
                icon: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: isSaved ? Colors.yellow : Colors.grey,
                  size: 26, // Smaller size
                ),
                onPressed: () {
                  setState(() {
                    isSaved = !isSaved;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
