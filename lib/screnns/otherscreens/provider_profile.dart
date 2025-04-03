// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/services.dart';

class WorkerProfile extends StatefulWidget {
  @override
  _WorkerProfileState createState() => _WorkerProfileState();
}

class _WorkerProfileState extends State<WorkerProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<DocumentSnapshot> _userStream;
  String? documentId;
  bool _isLoading = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserDocument();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  _fetchUserDocument() async {
    setState(() => _isLoading = true);
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
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildProfileHeader(String name, String jobTitle) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: const Color(0xFFF8FAFD),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SERVICE PROVIDER',
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: Colors.grey[600],
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2E3E5C),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildDetailChip(Icons.work_outline, jobTitle),
                const SizedBox(width: 12),
                _buildDetailChip(Icons.verified_user, 'Verified'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: const Color(0xFF9FA5C0),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: const Color(0xFF3E5481),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(Map<String, dynamic> jobData) {
    final jobNumber = jobData['jobNumber'] ?? 'N/A';
    final text = jobData['text'] ?? 'No details provided';
    final jobId = jobData['id'];
    final requiredDate = jobData['required_date'] != null
        ? (jobData['required_date'] as Timestamp).toDate()
        : null;
    final customerId = jobData['customer'] ?? '';

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      shadowColor: Colors.blue.withOpacity(0.2),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Job #$jobNumber',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'PENDING',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FutureBuilder<Map<String, dynamic>>(
                future: _getCustomerDetails(customerId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildInfoRow(
                        Icons.person, 'Customer', 'Loading...');
                  }
                  final customerData = snapshot.data ?? {};
                  final customerName =
                      customerData['name'] ?? 'Unknown Customer';
                  final phoneNumber = customerData['phone'] ?? 'Not available';

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(Icons.person, 'Customer', customerName),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.phone, 'Phone', phoneNumber),
                      const SizedBox(height: 8),
                      if (phoneNumber != 'Not available')
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _handleCallButtonPressed(phoneNumber),
                            icon: const Icon(Icons.call),
                            label: const Text('CALL CUSTOMER'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                    ],
                  );
                },
              ),
              _buildInfoRow(
                  Icons.calendar_today,
                  'Required Date',
                  requiredDate != null
                      ? DateFormat('dd/MM/yyyy').format(requiredDate)
                      : 'Not specified'),
              const SizedBox(height: 8),
              _buildInfoRow(Icons.description, 'Details', text),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showAcceptConfirmation(jobId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal[600],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'ACCEPT',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showRejectConfirmation(jobId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'REJECT',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleCallButtonPressed(String phoneNumber) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Customer Phone Number',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                phoneNumber,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: phoneNumber));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Phone number copied to clipboard'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: const Text('COPY'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Calling $phoneNumber...'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: const Text('CALL'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showAcceptConfirmation(String jobId) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 60,
                  color: Colors.teal,
                ),
                const SizedBox(height: 16),
                Text(
                  "Accept Job?",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Are you sure you want to accept this job?",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "NO",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _updateJobStatus(jobId, "accepted");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal[600],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: Text(
                        "YES",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRejectConfirmation(String jobId) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 60,
                  color: Colors.orange,
                ),
                const SizedBox(height: 16),
                Text(
                  "Reject Job?",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Are you sure you want to reject this job?",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "NO",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _updateJobStatus(jobId, "rejected");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: Text(
                        "YES",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xff0060D0)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 3,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 16.0,
            ),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _updateJobStatus(String jobId, String status) async {
    try {
      await _firestore.collection("jobs").doc(jobId).update({
        "status": status,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Job status updated to ${status.toUpperCase()}'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: status == "accepted" ? Colors.teal : Colors.red,
        ),
      );

      // Refresh the page after status update
      _fetchUserDocument();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating job: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (documentId == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xff0060D0)),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'New Job Requests',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xff0060D0),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchUserDocument,
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _userStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              _isLoading) {
            return _buildShimmerLoading();
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No profile data found',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            );
          }

          var userData = snapshot.data!;
          String name = userData["name"] ?? "Unknown";
          String jobTitle = userData["jobTitle"] ?? "Worker";

          if (jobTitle == "User") {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.block,
                    size: 60,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "You are not a service provider",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildProfileHeader(name, jobTitle),
                const SizedBox(height: 24),
                FutureBuilder<QuerySnapshot>(
                  future: _firestore
                      .collection("jobs")
                      .where("worker", isEqualTo: userData["userId"])
                      .where("status", isEqualTo: "pending")
                      .get(),
                  builder: (context, jobSnapshot) {
                    if (jobSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!jobSnapshot.hasData ||
                        jobSnapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.work_outline,
                              size: 80,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'No pending job requests',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    var jobDocs = jobSnapshot.data!.docs;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: jobDocs.length,
                      itemBuilder: (context, index) {
                        var jobData =
                            jobDocs[index].data() as Map<String, dynamic>;
                        jobData['id'] = jobDocs[index].id;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _buildJobCard(jobData),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _getCustomerDetails(String userId) async {
    try {
      // First check in users collection
      QuerySnapshot customerSnapshot = await _firestore
          .collection("users")
          .where("userId", isEqualTo: userId)
          .limit(1)
          .get();

      if (customerSnapshot.docs.isNotEmpty) {
        DocumentSnapshot customerDoc = customerSnapshot.docs.first;
        return {
          'name': customerDoc["name"] ?? "Unknown Customer",
          'phone': customerDoc["phone"] ?? "Not available"
        };
      }

      // If not found in users, check in workerregister collection
      QuerySnapshot workerSnapshot = await _firestore
          .collection("workerregister")
          .where("userId", isEqualTo: userId)
          .limit(1)
          .get();

      if (workerSnapshot.docs.isNotEmpty) {
        DocumentSnapshot workerDoc = workerSnapshot.docs.first;
        return {
          'name': workerDoc["name"] ?? "Unknown Customer",
          'phone': workerDoc["phone"] ?? "Not available"
        };
      }

      return {'name': 'Customer Not Found', 'phone': 'Not available'};
    } catch (e) {
      print("Error fetching customer details: $e");
      return {'name': 'Error Loading Customer', 'phone': 'Not available'};
    }
  }
}
