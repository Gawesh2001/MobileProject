import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gofinder/screnns/otherscreens/settings.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:gofinder/screnns/authentication/sign_in.dart';
import 'package:gofinder/screnns/otherscreens/ongoingjobs.dart';
import 'package:gofinder/screnns/otherscreens/provider_profile.dart';
import 'package:gofinder/screnns/otherscreens/workreg.dart';
import 'package:gofinder/screnns/otherscreens/jobs.dart';

class ProfilePage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to show logout confirmation dialog
  void _confirmLogout(BuildContext context) {
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
                  "Log Out?",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Are you sure you want to log out?",
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
                        _logOut(context);
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

  void _logOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Sign_In()),
      );
    } catch (e) {
      print("Error logging out: $e");
    }
  }

  Future<String> _fetchUserName(String userId) async {
    try {
      // First try to get from users collection
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists && userDoc.data() != null) {
        final userData = userDoc.data() as Map<String, dynamic>;
        if (userData.containsKey('userName') && userData['userName'] != null) {
          return userData['userName'];
        }
      }

      // If not found in users collection, try workerregister
      DocumentSnapshot workerDoc =
          await _firestore.collection('workerregister').doc(userId).get();

      if (workerDoc.exists && workerDoc.data() != null) {
        final workerData = workerDoc.data() as Map<String, dynamic>;
        if (workerData.containsKey('worker_name') &&
            workerData['worker_name'] != null) {
          return workerData['worker_name'];
        }
      }

      return 'No Name Available';
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
              backgroundColor: Colors.white,
              appBar: AppBar(
                title: Text(
                  'Profile',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                backgroundColor: const Color(0xff0079C2),
                elevation: 0,
                centerTitle: true,
              ),
              body: const Center(
                child: CircularProgressIndicator(
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Color(0xff0079C2)),
                ),
              ));
        }

        final userName = snapshot.data ?? 'No Name Available';

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: Text(
              'Controller Page',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: const Color(0xff0079C2),
            elevation: 0,
            centerTitle: true,
            actions: [],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Profile Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: const NetworkImage(
                            'https://i.pinimg.com/736x/03/eb/d6/03ebd625cc0b9d636256ecc44c0ea324.jpg',
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user?.email ?? 'Not Available',
                                style: GoogleFonts.poppins(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Register Button
                  _buildSectionCard(
                    child: _buildListTile(
                      icon: Icons.app_registration,
                      iconColor: Colors.blue,
                      title: "Register",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => WorkReg()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Jobs Button
                  _buildSectionCard(
                    child: _buildListTile(
                      icon: Icons.work,
                      iconColor: Colors.green,
                      title: "Jobs",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => JobsPage(
                              userId: user?.uid ?? '',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Provider Profile Button
                  _buildSectionCard(
                    child: _buildListTile(
                      icon: Icons.settings_accessibility,
                      iconColor: Colors.green,
                      title: "Provider Profile",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WorkerProfile(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // On Going Jobs Button
                  _buildSectionCard(
                    child: _buildListTile(
                      icon: Icons.flag,
                      iconColor: Colors.green,
                      title: "On Going Jobs",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OngoingJobsPage(
                              userId: user?.uid ?? '',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Settings Button
                  _buildSectionCard(
                    child: _buildListTile(
                      icon: Icons.settings,
                      iconColor: const Color.fromARGB(255, 209, 114, 5),
                      title: "Settings",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SettingsPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Income Button
                  _buildSectionCard(
                    child: _buildListTile(
                      icon: Icons.attach_money,
                      iconColor: Colors.orange,
                      title: "Income",
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Log Out Button
                  _buildSectionCard(
                    child: _buildListTile(
                      icon: Icons.logout,
                      iconColor: Colors.red,
                      title: "Log Out",
                      onTap: () => _confirmLogout(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[500]),
      onTap: onTap,
    );
  }
}
