import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OngoingJobsPage extends StatefulWidget {
  final String userId;

  const OngoingJobsPage({Key? key, required this.userId}) : super(key: key);

  @override
  _OngoingJobsPageState createState() => _OngoingJobsPageState();
}

class _OngoingJobsPageState extends State<OngoingJobsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch jobs where the customer field equals the userId
  Future<List<Map<String, dynamic>>> _fetchJobs() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('jobs')
          .where('customer',
              isEqualTo: widget.userId) // Filter jobs by customer ID
          .get();

      List<Map<String, dynamic>> jobs = [];
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> jobData = doc.data() as Map<String, dynamic>;
        jobData['id'] = doc.id; // Add document ID to the job data
        jobs.add(jobData);
      }

      return jobs;
    } catch (e) {
      print("Error fetching jobs: $e");
      return [];
    }
  }

  // Fetch worker's name by worker ID
  Future<String> _fetchWorkerName(String workerId) async {
    try {
      DocumentSnapshot workerDoc =
          await _firestore.collection('workerregister').doc(workerId).get();

      if (workerDoc.exists) {
        return workerDoc['name'] ?? 'Unknown Worker';
      } else {
        return 'Unknown Worker';
      }
    } catch (e) {
      print("Error fetching worker name: $e");
      return 'Error fetching worker name';
    }
  }

  // Check if the current user is the worker for the job
  Future<bool> _isCurrentUserWorker(String jobId) async {
    try {
      DocumentSnapshot jobDoc =
          await _firestore.collection('jobs').doc(jobId).get();
      if (jobDoc.exists) {
        String workerId = jobDoc['worker'] ?? '';
        return workerId == widget.userId;
      }
      return false;
    } catch (e) {
      print("Error checking if current user is worker: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ongoing Jobs'),
        backgroundColor: const Color(0xff0079C2),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              "User ID: ${widget.userId}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchJobs(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No jobs found.'));
                }

                var jobs = snapshot.data!;

                return ListView.builder(
                  itemCount: jobs.length,
                  itemBuilder: (context, index) {
                    var jobData = jobs[index];
                    String workerId = jobData['worker'] ?? 'No Worker Assigned';
                    String jobDescription =
                        jobData['text'] ?? 'No Job Description';
                    String jobStatus = jobData['status'] ?? 'No Status';
                    String jobId = jobData['id']; // Document ID of the job

                    return FutureBuilder<String>(
                      future: _fetchWorkerName(workerId),
                      builder: (context, workerSnapshot) {
                        if (workerSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }

                        if (workerSnapshot.hasError) {
                          return Text('Error fetching worker name');
                        }

                        String workerName =
                            workerSnapshot.data ?? 'Unknown Worker';

                        return FutureBuilder<bool>(
                          future: _isCurrentUserWorker(jobId),
                          builder: (context, isWorkerSnapshot) {
                            if (isWorkerSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            }

                            if (isWorkerSnapshot.hasError) {
                              return Text('Error checking worker status');
                            }

                            bool isCurrentUserWorker =
                                isWorkerSnapshot.data ?? false;

                            return _buildJobContainer(
                              workerName,
                              jobDescription,
                              jobStatus,
                              jobId,
                              isCurrentUserWorker,
                            );
                          },
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
    );
  }

  // Build a container to display each job's details
  Widget _buildJobContainer(
    String workerName,
    String jobDescription,
    String jobStatus,
    String jobId,
    bool isCurrentUserWorker,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      padding: const EdgeInsets.all(15),
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
          Text("Worker: $workerName",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          Text("Job Description: $jobDescription",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          Text("Status: $jobStatus",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          if (isCurrentUserWorker)
            ElevatedButton(
              onPressed: () {
                // Handle the job done action here
                _markJobDone(jobId);
              },
              child: const Text("Job Done"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            )
          else
            ElevatedButton(
              onPressed: () {
                // Handle the confirm job action here
                _confirmJob(jobId);
              },
              child: const Text("Confirm"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff0060D0),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
        ],
      ),
    );
  }

  // Function to confirm the job
  void _confirmJob(String jobId) async {
    try {
      await _firestore.collection('jobs').doc(jobId).update({
        'status': 'confirmed',
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Job $jobId confirmed')),
      );
    } catch (e) {
      print("Error confirming job: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error confirming job: $e')),
      );
    }
  }

  // Function to mark the job as done
  void _markJobDone(String jobId) async {
    try {
      await _firestore.collection('jobs').doc(jobId).update({
        'status': 'done',
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Job $jobId marked as done')),
      );
    } catch (e) {
      print("Error marking job as done: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error marking job as done: $e')),
      );
    }
  }
}
