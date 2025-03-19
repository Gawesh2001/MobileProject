import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gofinder/navigators/bottomnavigatorbar.dart';
import 'package:gofinder/screnns/home/home.dart';

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
      home: GardnerListScreen(),
    );
  }
}

class GardnerListScreen extends StatefulWidget {
  @override
  _GardnerListScreenState createState() => _GardnerListScreenState();
}

class _GardnerListScreenState extends State<GardnerListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          CustomAppBar(title: "Gardner"),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('workerregister')
                  .where('jobTitle', isEqualTo: 'Gardner')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No gardeners found"));
                }

                var workers = snapshot.data!.docs;

                return ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: workers.length,
                  itemBuilder: (context, index) {
                    var data = workers[index].data() as Map<String, dynamic>;
                    return WorkerCard(
                      name: data['name'] ?? 'No Name',
                      age: data['age'] ?? 'N/A',
                      rating: data['rating']?.toString() ?? '0.00',
                      imageUrl: data['imageUrl'] ?? '',
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigatorBar(),
    );
  }
}

class CustomAppBar extends StatelessWidget {
  final String title;
  CustomAppBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color.fromARGB(255, 91, 96, 254),
            const Color.fromARGB(255, 77, 120, 250)
          ],
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
          Positioned(
            left: 10,
            top: 55,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Home()),
                );
              },
            ),
          ),
          Positioned(
            top: 58,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 26,
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

class WorkerCard extends StatefulWidget {
  final String name;
  final String age;
  final String rating;
  final String imageUrl;

  WorkerCard({
    required this.name,
    required this.age,
    required this.rating,
    required this.imageUrl,
  });

  @override
  _WorkerCardState createState() => _WorkerCardState();
}

class _WorkerCardState extends State<WorkerCard> {
  bool isSaved = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: widget.imageUrl.isNotEmpty
                  ? NetworkImage(widget.imageUrl)
                  : AssetImage('assets/default_avatar.png') as ImageProvider,
            ),
            SizedBox(width: 15),
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
            IconButton(
              icon: Icon(
                isSaved ? Icons.bookmark : Icons.bookmark_border,
                color: isSaved ? Colors.yellow : Colors.grey,
                size: 26,
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
    );
  }
}