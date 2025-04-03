import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'job_history.dart';

class JobsPage extends StatefulWidget {
  final String userId;

  const JobsPage({Key? key, required this.userId}) : super(key: key);

  @override
  _JobsPageState createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  bool _isCustomer = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    // Check if the user is a customer by seeing if their ID exists in any job's customer field
    try {
      final customerQuery = await _firestore
          .collection('jobs')
          .where('customer', isEqualTo: widget.userId)
          .limit(1)
          .get();

      setState(() {
        _isCustomer = customerQuery.docs.isNotEmpty;
      });
    } catch (e) {
      print("Error checking user role: $e");
    }
  }

  Future<List<Map<String, dynamic>>> _fetchJobs() async {
    try {
      Query query;

      if (_isCustomer) {
        // For customers, fetch jobs where they are the customer and status is 'complete'
        query = _firestore
            .collection('jobs')
            .where('customer', isEqualTo: widget.userId)
            .where('status', isEqualTo: 'complete');
      } else {
        // For workers, fetch jobs where they are the worker and status is 'accepted'
        query = _firestore
            .collection('jobs')
            .where('worker', isEqualTo: widget.userId)
            .where('status', isEqualTo: 'accepted');
      }

      QuerySnapshot querySnapshot = await query.get();

      List<Map<String, dynamic>> jobs = [];
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> jobData = doc.data() as Map<String, dynamic>;
        jobData['id'] = doc.id;
        jobs.add(jobData);
      }
      return jobs;
    } catch (e) {
      print("Error fetching jobs: $e");
      return [];
    }
  }

  Future<void> _updateJobStatus(String jobId, String status) async {
    try {
      await _firestore.collection('jobs').doc(jobId).update({
        'status': status,
        if (status == 'completed') 'completedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Job status updated to $status successfully!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Refresh the jobs list
      setState(() {
        _isLoading = true;
      });
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating job status: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<Map<String, dynamic>> _filterJobs(List<Map<String, dynamic>> jobs) {
    List<Map<String, dynamic>> filtered = jobs.where((job) {
      if (_searchQuery.isEmpty) return true;
      final jobNumber = job['jobNumber']?.toString().toLowerCase() ?? '';
      final workerName = job['worker_name']?.toString().toLowerCase() ?? '';
      final customerName = job['customer_name']?.toString().toLowerCase() ?? '';
      final details = job['text']?.toString().toLowerCase() ?? '';
      final status = job['status']?.toString().toLowerCase() ?? '';
      return jobNumber.contains(_searchQuery) ||
          workerName.contains(_searchQuery) ||
          customerName.contains(_searchQuery) ||
          details.contains(_searchQuery) ||
          status.contains(_searchQuery);
    }).toList();

    if (_selectedFilter != 'All') {
      filtered = filtered.where((job) {
        return job['status']?.toString().toLowerCase() ==
            _selectedFilter.toLowerCase();
      }).toList();
    }

    return filtered;
  }

  Widget _buildJobCard(Map<String, dynamic> jobData) {
    final jobNumber = jobData['jobNumber'] ?? 'N/A';
    final workerName = jobData['worker_name'] ?? 'No worker assigned';
    final customerName = jobData['customer_name'] ?? 'No customer assigned';
    final workerLocation =
        jobData['worker_location'] ?? 'Location not specified';
    final requiredDate = jobData['required_date'] != null
        ? (jobData['required_date'] as Timestamp).toDate()
        : null;
    final details = jobData['text'] ?? 'No details provided';
    final jobStatus = jobData['status'] ?? 'accepted';
    final jobId = jobData['id'];

    final statusColor = _getStatusColor(jobStatus);
    final statusIcon = _getStatusIcon(jobStatus);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                statusColor.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: statusColor.withOpacity(0.2),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
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
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: statusColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            statusIcon,
                            size: 16,
                            color: statusColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            jobStatus.toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.person,
                  'Customer',
                  customerName,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                    Icons.location_on, 'Worker Location', workerLocation),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.calendar_today,
                  'Required Date',
                  requiredDate != null
                      ? DateFormat('dd/MM/yyyy').format(requiredDate)
                      : 'Not specified',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.description, 'Details', details),
                const SizedBox(height: 16),
                if (_isCustomer && jobStatus == 'complete')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _updateJobStatus(jobId, 'completed'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'CONFIRM COMPLETION',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                if (!_isCustomer && jobStatus == 'accepted')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _updateJobStatus(jobId, 'complete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'JOB DONE',
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
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.blue,
        ),
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
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'complete':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'cancelled':
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle;
      case 'complete':
        return Icons.hourglass_bottom;
      case 'accepted':
        return Icons.thumb_up;
      case 'cancelled':
        return Icons.cancel;
      case 'rejected':
        return Icons.block;
      default:
        return Icons.help_outline;
    }
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 16.0,
            ),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoJobsFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/no_jobs.png',
            width: 200,
            height: 200,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.work_outline,
                size: 100,
                color: Colors.grey[300],
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            _isCustomer
                ? 'No jobs awaiting your confirmation'
                : 'No accepted jobs at the moment',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _isCustomer
                ? 'You have no completed jobs waiting for confirmation'
                : 'You have no jobs assigned to you currently',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoMatchingJobs() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off,
            size: 60,
            color: Colors.grey,
          ),
          const SizedBox(height: 20),
          Text(
            'No matching jobs found',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              setState(() {
                _searchQuery = '';
                _selectedFilter = 'All';
                _searchController.clear();
              });
            },
            child: Text(
              'Clear filters',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: const Color(0xff0060D0),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          _isCustomer ? 'Jobs Awaiting Confirmation' : 'My Jobs',
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
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => JobHistoryPage(userId: widget.userId),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              Future.delayed(const Duration(milliseconds: 500), () {
                setState(() {
                  _isLoading = false;
                });
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(30),
              shadowColor: Colors.blue.withOpacity(0.2),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextField(
                          controller: _searchController,
                          style: GoogleFonts.poppins(fontSize: 16),
                          decoration: InputDecoration(
                            hintText: "Search jobs...",
                            hintStyle: GoogleFonts.poppins(color: Colors.grey),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _searchQuery.isNotEmpty ? 100 : 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xff0060D0),
                            Color(0xff0080F0),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: () {
                            setState(() {
                              _searchQuery =
                                  _searchController.text.toLowerCase();
                            });
                          },
                          child: Center(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: _searchQuery.isNotEmpty
                                  ? Text(
                                      'SEARCH',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    )
                                  : const Icon(Icons.search,
                                      color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchJobs(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    _isLoading) {
                  return _buildShimmerLoading();
                }

                if (snapshot.hasError) {
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
                          'Error loading jobs',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {});
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff0060D0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            'Retry',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildNoJobsFound();
                }

                final filteredJobs = _filterJobs(snapshot.data!);

                if (filteredJobs.isEmpty) {
                  return _buildNoMatchingJobs();
                }

                return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: filteredJobs.length,
                  itemBuilder: (context, index) {
                    var jobData = filteredJobs[index];
                    return _buildJobCard(jobData);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
