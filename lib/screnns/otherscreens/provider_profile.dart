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
          _userStream = _firestore
              .collection("workerregister")
              .doc(documentId)
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
        title: const Text("Worker Profile",
            style: TextStyle(color: Colors.white, fontSize: 22)),
        centerTitle: true,
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _userStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
                child: Text("No profile data found.",
                    style: TextStyle(fontSize: 16, color: Colors.black54)));
          }

          var userData = snapshot.data!;
          String name = userData["name"] ?? "Unknown";
          String email = userData["email"] ?? "No Email";
          String userId = userData["userId"] ?? "No User ID";
          String jobTitle = userData["jobTitle"] ?? "";

          if (jobTitle == "User") {
            return Center(
              child: Text(
                "You are not a service provider.",
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(),
                const SizedBox(height: 20),
                _buildProfileCard(name, email, userId),
                const SizedBox(height: 20),
                _buildJobList(userId),
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

  Widget _buildProfileCard(String name, String email, String userId) {
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
            const SizedBox(height: 10),
            _buildProfileDetail("User ID: $userId", Icons.account_circle),
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
        Expanded(
            child: Text(detail,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w500))),
      ],
    );
  }

  // This function fetches the job data from the "jobs" collection
  Widget _buildJobList(String userId) {
    return FutureBuilder<QuerySnapshot>(
      future: _firestore
          .collection("jobs")
          .where("worker", isEqualTo: userId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
              child: Text("No jobs found.",
                  style: TextStyle(fontSize: 16, color: Colors.black54)));
        }

        var jobDocs = snapshot.data!.docs;
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: jobDocs.length,
          itemBuilder: (context, index) {
            var jobData = jobDocs[index];
            String customerUserId = jobData["customer"] ?? "No User ID";
            String jobId = jobData.id;
            String text = jobData["text"] ?? "No Text Provided";

            // Fetch the customer's name based on the customerUserId
            return _buildJobContainer(customerUserId, text, jobId);
          },
        );
      },
    );
  }

  // Function to get the customer name based on userId
  Future<String> _getCustomerName(String userId) async {
    QuerySnapshot customerSnapshot = await _firestore
        .collection("workerregister")
        .where("userId", isEqualTo: userId)
        .limit(1)
        .get();

    if (customerSnapshot.docs.isNotEmpty) {
      DocumentSnapshot customerDoc = customerSnapshot.docs.first;
      return customerDoc["name"] ?? "Unknown";
    } else {
      return "Customer Not Found";
    }
  }

  // Display customer name and job text
  Widget _buildJobContainer(String customerUserId, String text, String jobId) {
    return FutureBuilder<String>(
      future: _getCustomerName(customerUserId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasData) {
          String customerName = snapshot.data ?? "Customer Not Found";
          return _buildJobCard(customerName, text, jobId);
        }

        return const Center(child: Text("Error fetching customer name"));
      },
    );
  }

  Widget _buildJobCard(String customer, String text, String jobId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Customer: $customer",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          Text(
            "Job Description: $text",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  _updateJobStatus(jobId, "accepted");
                },
                child: const Text("Accept Job"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff0060D0),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  _updateJobStatus(jobId, "rejected");
                },
                child: const Text("Reject Job"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Function to update the job status
  void _updateJobStatus(String jobId, String status) async {
    try {
      await _firestore.collection("jobs").doc(jobId).update({
        "status": status,
      });
      print("Job $jobId status updated to $status.");
    } catch (e) {
      print("Error updating job status: $e");
    }
  }
}
