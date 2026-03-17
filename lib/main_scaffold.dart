import 'package:flutter/material.dart';
import 'package:bank_a_plus/Home.dart';
import 'package:bank_a_plus/maths/maths_helper.dart';
import 'package:bank_a_plus/maths/add_question.dart';
import 'package:bank_a_plus/advertisement/advertisement_carousel.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({Key? key}) : super(key: key);

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  // Key to communicate with MathsHelper state
  final GlobalKey<MathsHelperState> _mathsHelperKey = GlobalKey();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const Home(title: 'edica'),
      MathsHelper(key: _mathsHelperKey),
    ];
  }

  final List<String> _titles = const [
    'Home',
    'Maths Helper',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.2),
        ),
        backgroundColor: const Color(0xFF001D3D), // Edica Navy
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          const AdvertisementCarousel(),
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddQuestionPage()),
                );
                if (result == true) {
                  // Call refresh on the MathsHelper state
                  _mathsHelperKey.currentState?.refresh();
                }
              },
              backgroundColor: const Color(0xFF6366F1), // Indigo blue from logo
              foregroundColor: const Color.fromARGB(255, 254, 254, 254),
              icon: const Icon(Icons.add),
              label: const Text("Q", style: TextStyle(fontWeight: FontWeight.bold)),
            )
          : null,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: const Color.fromARGB(255, 151, 1, 174),
          unselectedItemColor: const Color.fromARGB(255, 255, 248, 248),
          backgroundColor: const Color.fromARGB(255, 74, 181, 71),
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 14,
          unselectedFontSize: 12,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w900),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.home_rounded, size: 28),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.home_rounded, size: 32),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.calculate_outlined, size: 28),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.calculate_rounded, size: 32),
              ),
              label: 'Maths Helper',
            ),
          ],
        ),
      ),
    );
  }
}
