// ignore_for_file: prefer_const_constructors, unused_field

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
import 'package:gofinder/screnns/otherscreens/profile.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showWelcomeInfo = false;
  int _currentFeaturedIndex = 0;
  final PageController _featuredController = PageController(
    viewportFraction: 0.85,
    initialPage: 0,
  );

  // Featured services
  final List<Map<String, dynamic>> _featuredServices = [
    {
      'title': 'Premium Home Cleaning',
      'description':
          'Professional cleaning services with eco-friendly products',
      'image':
          'https://images.unsplash.com/photo-1484154218962-a197022b5858?w=600&auto=format&fit=crop',
      'screen': CleanerListScreen(),
    },
    {
      'title': '24/7 Electrician',
      'description': 'Certified electricians for all your urgent needs',
      'image':
          'https://images.unsplash.com/photo-1605170439002-90845e8c0137?w=600&auto=format&fit=crop',
      'screen': ElectricianListScreen(),
    },
    {
      'title': 'Auto Detailing',
      'description': 'Complete interior and exterior car cleaning',
      'image':
          'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?w=600&auto=format&fit=crop',
      'screen': CarListScreen(),
    },
  ];

  // All services
  final List<Map<String, dynamic>> _allServices = [
    {
      'title': 'Electronics',
      'image':
          'https://images.unsplash.com/photo-1550009158-9ebf69173e03?w=600&auto=format&fit=crop',
      'screen': ElectronicsListScreen(),
    },
    {
      'title': 'Home',
      'image':
          'https://images.unsplash.com/photo-1484154218962-a197022b5858?w=600&auto=format&fit=crop',
      'screen': WorkerListScreen(),
    },
    {
      'title': 'Auto Mechanic',
      'image':
          'https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?w=600&auto=format&fit=crop',
      'screen': CarListScreen(),
    },
    {
      'title': 'Electrician',
      'image':
          'https://images.unsplash.com/photo-1605152276897-4f618f831968?w=600&auto=format&fit=crop',
      'screen': ElectricianListScreen(),
    },
    {
      'title': 'Furniture',
      'image':
          'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=600&auto=format&fit=crop',
      'screen': FurnitureListScreen(),
    },
    {
      'title': 'Plumbing',
      'image':
          'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?ixlib=rb-1.2.1&auto=format&fit=crop&w=600&q=80',
      'screen': PlumberListScreen(),
    },
    {
      'title': 'Painting',
      'image':
          'https://images.unsplash.com/photo-1600607687920-4e2a09cf159d?ixlib=rb-1.2.1&auto=format&fit=crop&w=600&q=80',
      'screen': PainterListScreen(),
    },
    {
      'title': 'Gardening',
      'image':
          'https://images.unsplash.com/photo-1585320806297-9794b3e4eeae?w=600&auto=format&fit=crop',
      'screen': GardnerListScreen(),
    },
    {
      'title': 'Cleaning',
      'image':
          'https://images.unsplash.com/photo-1600566752355-35792bedcfea?w=600&auto=format&fit=crop',
      'screen': CleanerListScreen(),
    },
  ];

  @override
  void initState() {
    super.initState();
    _checkFirstVisit();
    _featuredController.addListener(() {
      setState(() {
        _currentFeaturedIndex = _featuredController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _featuredController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkFirstVisit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasVisited = prefs.getBool('hasVisited') ?? false;

    if (!hasVisited) {
      await prefs.setBool('hasVisited', true);
      if (mounted) {
        setState(() => _showWelcomeInfo = true);
        _showWelcomeDialog();
      }
    }
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  void _showWelcomeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.handyman,
                size: 80,
                color: Color(0xFF0060D0),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Welcome to GoFinder!',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0060D0),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Find trusted professionals for all your service needs. Book instantly and get quality work done with ease.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0060D0),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    'GET STARTED',
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
    );
  }

  Widget _buildFeaturedServiceCard(Map<String, dynamic> service, int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => service['screen']),
          );
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                child: Container(
                  height: 180,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      Image.network(
                        service['image'],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(color: Colors.grey[200]),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.7),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 15,
                        left: 15,
                        right: 15,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service['title'],
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Text(
                              service['description'],
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => service['screen']),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF0060D0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'Book Now',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => service['screen']),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                height: 101,
                width: double.infinity,
                child: Image.network(
                  service['image'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(color: Colors.grey[200]),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service['title'],
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => service['screen']),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF0060D0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text(
                        'Book Now',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showWelcomeInfo) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showWelcomeDialog());
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 248, 248),
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 2,
            ),
            Text(
              '${getGreeting()} !',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: const Color.fromARGB(255, 44, 44, 44),
              ),
            ),
            SizedBox(
              height: 1,
            ),
            Text(
              'Find Your Service Expert',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 15, 15, 15),
              ),
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 216, 217, 218),
        elevation: 0,
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
            child: Padding(
                padding: EdgeInsets.only(right: 16),
                child: Icon(
                  Icons.person_4_outlined,
                  color: Colors.blueGrey,
                  size: 28,
                )),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            // Padding(
            //   padding: EdgeInsets.all(20),
            //   child: Material(
            //     elevation: 4,
            //     borderRadius: BorderRadius.circular(30),
            //     shadowColor: Color(0xFF0060D0).withOpacity(0.1),
            //     child: TextField(
            //       controller: _searchController,
            //       decoration: InputDecoration(
            //         hintText: 'Search for services...',
            //         hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
            //         prefixIcon: Icon(Icons.search, color: Colors.grey),
            //         border: InputBorder.none,
            //         filled: true,
            //         fillColor: Colors.white,
            //         contentPadding:
            //             EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            //       ),
            //       style: GoogleFonts.poppins(fontSize: 16),
            //       onChanged: (value) {
            //         setState(() {
            //           _searchQuery = value;
            //         });
            //       },
            //     ),
            //   ),
            // ),

            // Featured Services Section
            SizedBox(
              height: 16,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Featured Services',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: const Color.fromARGB(221, 44, 44, 44),
                ),
              ),
            ),
            SizedBox(height: 8),

            // Featured Services Carousel
            SizedBox(
              height: 280,
              child: PageView.builder(
                controller: _featuredController,
                scrollDirection: Axis.horizontal,
                itemCount: _featuredServices.length,
                itemBuilder: (context, index) {
                  return _buildFeaturedServiceCard(
                      _featuredServices[index], index);
                },
                padEnds: false,
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _featuredServices.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentFeaturedIndex == index
                        ? Color(0xFF0060D0)
                        : Colors.grey[300],
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),

            // All Services Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'All Services',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: const Color.fromARGB(221, 48, 47, 47),
                ),
              ),
            ),
            SizedBox(height: 16),

            // All Services Grid
            GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: 12),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _allServices.length,
              itemBuilder: (context, index) {
                return _buildServiceCard(_allServices[index]);
              },
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigatorBar(currentIndex: 0),
    );
  }
}
