// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:gofinder/screnns/home/home.dart';
import 'package:gofinder/screnns/otherscreens/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BottomNavigatorBar extends StatefulWidget {
  final int currentIndex;
  const BottomNavigatorBar({Key? key, required this.currentIndex})
      : super(key: key);

  @override
  State<BottomNavigatorBar> createState() => _BottomNavigatorBarState();
}

class _BottomNavigatorBarState extends State<BottomNavigatorBar> {
  late int _selectedIndex;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: Colors.grey.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xff0060D0),
            unselectedItemColor: Colors.grey[500],
            selectedLabelStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
            showSelectedLabels: true,
            showUnselectedLabels: true,
            elevation: 0,
            iconSize: 26,
            onTap: (index) {
              setState(() => _selectedIndex = index);
              if (index == 0) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Home()),
                );
              } else if (index == 4) {
                final userId = _auth.currentUser?.uid ?? '';
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(),
                  ),
                );
              }
            },
            items: [
              _buildBottomNavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_filled,
                label: 'Home',
              ),
              _buildBottomNavItem(
                icon: Icons.favorite_outline,
                activeIcon: Icons.favorite,
                label: 'Saved',
              ),
              _buildBottomNavItem(
                icon: Icons.work_outline,
                activeIcon: Icons.work,
                label: 'Jobs',
              ),
              _buildBottomNavItem(
                icon: Icons.calendar_today_outlined,
                activeIcon: Icons.calendar_today,
                label: 'Calendar',
              ),
              _buildBottomNavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildBottomNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Icon(icon),
      ),
      activeIcon: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Icon(activeIcon),
      ),
      label: label,
    );
  }
}
