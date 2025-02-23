// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors

import 'package:gofinder/screnns/home/home.dart';
import 'package:flutter/material.dart';
// Import the Home page

class BottomNavigatorBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 4.0), // Reduced vertical padding to lift the background
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30), // Rounded edges
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(1, 4), // Shadow for a lifted effect
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Color(0xff0079C2),

            selectedItemColor: Colors.white, // Selected icon color
            unselectedItemColor: Colors.white70, // Unselected icon color
            iconSize: 24, // Keep the original icon size
            selectedFontSize:
                12, // Optional: Reduce label size for a more compact look
            unselectedFontSize:
                12, // Optional: Reduce label size for a more compact look
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home', // Added label
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite),
                label: 'Favorite', // Added label
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today),
                label: 'Calendar', // Added label
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.store),
                label: 'Market', // Added label
              ),
            ],
            currentIndex: 0, // Set the initial selected index
            onTap: (index) {
              if (index == 0) {
                // If the Home icon is tapped, navigate to the Home page
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Home()),
                );
              } else if (index == 1) {
                // Navigate to the Favorite page (you can replace this with your actual page)
              } else if (index == 2) {
                // Navigate to the Calendar page (replace with your actual page)
              } else if (index == 3) {
                // Navigate to the Market page (replace with your actual page)
              }
            },
          ),
        ),
      ),
    );
  }
}
