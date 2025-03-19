// main.dart
// ignore_for_file: use_key_in_widget_constructors, use_super_parameters, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_constructors_in_immutables, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:gofinder/servicecatogary/car.dart';
import 'package:gofinder/servicecatogary/cleaners.dart';
import 'package:gofinder/servicecatogary/electrician.dart';
import 'package:gofinder/servicecatogary/electronics.dart';
import 'package:gofinder/servicecatogary/furniture.dart';
import 'package:gofinder/servicecatogary/gardner.dart';
import 'package:gofinder/servicecatogary/homecaregory.dart';
import 'package:gofinder/servicecatogary/painter.dart';
import 'package:gofinder/servicecatogary/plumber.dart';
import 'package:gofinder/navigators/bottomnavigatorbar.dart';
import 'package:gofinder/screnns/otherscreens/profile.dart'; // Fixed typo in the file path

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final VoidCallback onTap;

  const ServiceCard({
    Key? key,
    required this.title,
    required this.imageUrl,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0), // Reduced card roundness
        ),
        elevation: 5, // Reduced shadow
        margin: EdgeInsets.all(10.0), // Reduced space outside the card
        child: Container(
          height: 150, // Increased card height
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(10.0), // Rounded corners for image
                child: Image.network(
                  imageUrl,
                  height: 120, // Image height stays the same
                  width: 150,
                  fit: BoxFit.cover, // Adjusts image scaling
                ),
              ),
              SizedBox(height: 10), // Reduced spacing
              Text(
                title,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500), // Reduced text size
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff0079C2),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text(
                'What are you looking for?',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(width: 10),
            Spacer(), // Add spacing between text and profile icon
            GestureDetector(
              onTap: () {
                // Navigate to the profile page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  'https://i.pinimg.com/736x/dd/14/05/dd1405df5ed7203c530fbdd0cc21cb24.jpg',
                ),
                radius: 20, // Adjust the size of the profile circle
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8.0, // Reduce vertical gap
              crossAxisSpacing: 8.0, // Reduce horizontal gap
              padding: EdgeInsets.all(8.0), // Reduce padding around grid
              children: [
                ServiceCard(
                  title: 'Electronics',
                  imageUrl:
                      'https://i.pinimg.com/736x/e7/9e/85/e79e8518106c63dfe4868e36f5323527.jpg',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ElectronicsListScreen()),
                    );
                  },
                ),
                ServiceCard(
                  title: 'Home',
                  imageUrl:
                      'https://i.pinimg.com/736x/b3/97/41/b39741b041d904006c846ef8b604fc68.jpg',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => WorkerListScreen()),
                    );
                  },
                ),
                ServiceCard(
                  title: 'Car',
                  imageUrl:
                      'https://i.pinimg.com/736x/ab/bc/c4/abbcc4a8a481cf577dcb5c9fe29fd506.jpg',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CarListScreen()),
                    );
                  },
                ),
                ServiceCard(
                  title: 'Electrician',
                  imageUrl:
                      'https://i.pinimg.com/736x/21/4e/03/214e03a1bff1d663f1f9dfd8c5c3d1fe.jpg',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ElectricianListScreen()),
                    );
                  },
                ),
                ServiceCard(
                  title: 'Furniture',
                  imageUrl:
                      'https://i.pinimg.com/736x/6f/28/c5/6f28c51ab2664cbaf5aeffef563d80e7.jpg',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FurnitureListScreen()),
                    );
                  },
                ),
                ServiceCard(
                  title: 'Plumber',
                  imageUrl:
                      'https://i.pinimg.com/736x/c0/fc/a9/c0fca9f9fb740c5f3538a438de5d7432.jpg',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PlumberListScreen()),
                    );
                  },
                ),
                ServiceCard(
                  title: 'Painter',
                  imageUrl:
                      'https://i.pinimg.com/736x/bc/e2/5a/bce25aca4942720ce8d866f755dc511c.jpg',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PainterListScreen()),
                    );
                  },
                ),
                ServiceCard(
                  title: 'Gardener',
                  imageUrl:
                      'https://i.pinimg.com/736x/0d/0b/7e/0d0b7e3fc5c45bfaa672334d9b1f9545.jpg',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => GardnerListScreen()),
                    );
                  },
                ),
                ServiceCard(
                  title: 'Cleaner',
                  imageUrl:
                      'https://i.pinimg.com/736x/77/e5/7e/77e57e5a09caf5d188cfbf02502154c6.jpg',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CleanerListScreen()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigatorBar(),
    );
  }
}

class ServiceImage extends StatelessWidget {
  final String imageUrl;

  ServiceImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.network(
          imageUrl,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

// Example pages for each service
class ElectronicsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Electronics'),
      ),
      body: Center(
        child: Text('Electronics Page'),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Text('Home Page'),
      ),
    );
  }
}

class CarPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Car'),
      ),
      body: Center(
        child: Text('Car Page'),
      ),
    );
  }
}

class ElectricianPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Electrician'),
      ),
      body: Center(
        child: Text('Electrician Page'),
      ),
    );
  }
}

class FurniturePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Furniture'),
      ),
      body: Center(
        child: Text('Furniture Page'),
      ),
    );
  }
}

class PlumberPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plumber'),
      ),
      body: Center(
        child: Text('Plumber Page'),
      ),
    );
  }
}

class PainterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Painter'),
      ),
      body: Center(
        child: Text('Painter Page'),
      ),
    );
  }
}

class GardenerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gardener'),
      ),
      body: Center(
        child: Text('Gardener Page'),
      ),
    );
  }
}

class CleanerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cleaner'),
      ),
      body: Center(
        child: Text('Cleaner Page'),
      ),
    );
  }
}
