// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class JobHistoryPage extends StatefulWidget {
  final String userId;

  const JobHistoryPage({Key? key, required this.userId}) : super(key: key);

  @override
  _JobsHistoryState createState() => _JobsHistoryState();
}

class _JobsHistoryState extends State<JobHistoryPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  bool _isWorkerView = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _fetchJobs() async {
    try {
      Query query;

      if (_isWorkerView) {
        // Worker view - show completed and rejected jobs
        query = _firestore
            .collection('jobs')
            .where('worker', isEqualTo: widget.userId)
            .where('status', whereIn: ['completed', 'rejected']);
      } else {
        // Customer view - show completed and cancelled jobs
        query = _firestore
            .collection('jobs')
            .where('customer', isEqualTo: widget.userId)
            .where('status', whereIn: ['completed', 'cancelled', 'rejected']);
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
    final completedDate = jobData['completedAt'] != null
        ? (jobData['completedAt'] as Timestamp).toDate()
        : null;
    final cancelledDate = jobData['cancelledAt'] != null
        ? (jobData['cancelledAt'] as Timestamp).toDate()
        : null;
    final details = jobData['text'] ?? 'No details provided';
    final jobStatus = jobData['status'] ?? 'completed';
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
                  _isWorkerView ? Icons.person : Icons.work,
                  _isWorkerView ? 'Customer' : 'Worker',
                  _isWorkerView ? customerName : workerName,
                ),
                const SizedBox(height: 8),
                if (!_isWorkerView)
                  _buildInfoRow(
                      Icons.location_on, 'Worker Location', workerLocation),
                if (!_isWorkerView) const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.calendar_today,
                  'Required Date',
                  requiredDate != null
                      ? DateFormat('dd/MM/yyyy').format(requiredDate)
                      : 'Not specified',
                ),
                const SizedBox(height: 8),
                if (jobStatus == 'completed' && completedDate != null)
                  _buildInfoRow(
                    Icons.check_circle,
                    'Completed On',
                    DateFormat('dd/MM/yyyy').format(completedDate),
                  ),
                if (jobStatus == 'cancelled' && cancelledDate != null)
                  _buildInfoRow(
                    Icons.cancel,
                    'Cancelled On',
                    DateFormat('dd/MM/yyyy').format(cancelledDate),
                  ),
                if (jobStatus == 'rejected')
                  _buildInfoRow(
                    Icons.block,
                    'Status',
                    'Rejected by worker',
                  ),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.description, 'Details', details),
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
            'No job history found',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _isWorkerView
                ? 'You have no completed or rejected jobs'
                : 'You have no completed or cancelled jobs',
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
          'Job History',
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
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _isWorkerView = value == 'worker';
              });
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'customer',
                child: Text('Customer View'),
              ),
              const PopupMenuItem<String>(
                value: 'worker',
                child: Text('Worker View'),
              ),
            ],
            icon: const Icon(Icons.switch_account),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  'All',
                  'Completed',
                  if (!_isWorkerView) 'Cancelled',
                  if (_isWorkerView) 'Rejected',
                ]
                    .map((filter) => Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(
                              filter,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                color: _selectedFilter == filter
                                    ? Colors.white
                                    : const Color(0xff0060D0),
                              ),
                            ),
                            selected: _selectedFilter == filter,
                            selectedColor: const Color(0xff0060D0),
                            backgroundColor: Colors.white,
                            shape: const StadiumBorder(
                              side: BorderSide(color: Color(0xff0060D0)),
                            ),
                            onSelected: (selected) {
                              setState(() {
                                _selectedFilter = selected ? filter : 'All';
                              });
                            },
                          ),
                        ))
                    .toList(),
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
