import 'package:flutter/material.dart';
import 'package:gofinder/screnns/home/home.dart';
import 'package:gofinder/screnns/otherscreens/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BottomNavigatorBar extends StatefulWidget {
  final int currentIndex;
  const BottomNavigatorBar({Key? key, required this.currentIndex}) : super(key: key);

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Container(
        height: 91,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          selectedItemColor: const Color(0xff0060D0),
          unselectedItemColor: Colors.grey[400],
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 0,
          iconSize: 26,
          onTap: (index) {
            setState(() => _selectedIndex = index);
            if (index == 0) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Home()),
              );
            }
            else if (index == 4) { // Profile icon index
              final userId = _auth.currentUser?.uid ?? '';
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(),
                  // If your ProfilePage constructor requires userId, pass it like this:
                  // builder: (context) => ProfilePage(userId: userId),
                ),
              );
            }
            // Other buttons intentionally left non-functional
          },
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(top: 6),
                child: Icon(Icons.home_outlined),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(top: 6),
                child: Icon(Icons.home_filled),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(top: 6),
                child: Icon(Icons.favorite_outline),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(top: 6),
                child: Icon(Icons.favorite),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(top: 6),
                child: Icon(Icons.work_outline),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(top: 6),
                child: Icon(Icons.work),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(top: 6),
                child: Icon(Icons.calendar_today_outlined),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(top: 6),
                child: Icon(Icons.calendar_today),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(top: 6),
                child: Icon(Icons.person_outline),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(top: 6),
                child: Icon(Icons.person),
              ),
              label: '',
            ),
          ],
        ),
      ),
    );
  }
}