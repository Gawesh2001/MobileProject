import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WorkerProfile extends StatefulWidget {
  @override
  _WorkerProfileState createState() => _WorkerProfileState();
}

class _WorkerProfileState extends State<WorkerProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<DocumentSnapshot> _userStream;
  late Stream<QuerySnapshot> _scheduleStream;
  String? documentId;

  @override
  void initState() {
    super.initState();
    _fetchUserDocument();
  }

  void _fetchUserDocument() async {
    User? user = _auth.currentUser;
    if (user != null) {
      QuerySnapshot querySnapshot = await _firestore
          .collection("workerregister")
          .where("userId", isEqualTo: user.uid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          documentId = querySnapshot.docs.first.id;
          _userStream = _firestore.collection("workerregister").doc(documentId).snapshots();

          // Fetch schedules for the worker
          _scheduleStream = _firestore
              .collection("schedules")
              .where("workerId", isEqualTo: user.uid)
              .orderBy("date")
              .snapshots();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (documentId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xff0060D0),
        title: const Text("Worker Profile", style: TextStyle(color: Colors.white, fontSize: 22)),
        centerTitle: true,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _userStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("No profile data found.", style: TextStyle(fontSize: 16, color: Colors.black54)));
          }

          var userData = snapshot.data!;
          String name = userData["name"] ?? "Unknown";
          String email = userData["email"] ?? "No Email";

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(),
                const SizedBox(height: 20),
                _buildProfileCard(name, email),
                const SizedBox(height: 20),
                _buildScheduleSection(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: CircleAvatar(
        radius: 60,
        backgroundColor: const Color(0xff0060D0),
        child: Icon(
          Icons.person,
          size: 80,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildProfileCard(String name, String email) {
    return Card(
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileDetail("Name: $name", Icons.person),
            const SizedBox(height: 10),
            _buildProfileDetail("Email: $email", Icons.email),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetail(String detail, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xff0060D0)),
        const SizedBox(width: 10),
        Expanded(child: Text(detail, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
      ],
    );
  }

  Widget _buildScheduleSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: _scheduleStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Center(child: Text("No upcoming schedules.", style: TextStyle(fontSize: 16, color: Colors.black54))),
          );
        }

        var schedules = snapshot.data!.docs;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Upcoming Schedules:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xff0060D0)),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: schedules.length,
              itemBuilder: (context, index) {
                var schedule = schedules[index];
                String task = schedule["task"] ?? "No task";
                DateTime date = (schedule["date"] as Timestamp).toDate();
                String formattedDate = "${date.day}/${date.month}/${date.year}";
                String formattedTime = "${date.hour}:${date.minute.toString().padLeft(2, '0')}";

                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(15),
                    title: Text(task, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    subtitle: Text("Date: $formattedDate\nTime: $formattedTime"),
                    leading: const Icon(Icons.schedule, color: Color(0xff0060D0)),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildEditButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          // Implement edit functionality here
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff0060D0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        ),
        child: const Text(
          "Edit Profile",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
    );
  }
}
