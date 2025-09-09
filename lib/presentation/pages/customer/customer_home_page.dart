import 'package:flutter/material.dart';
import 'services_page.dart';
import 'products_page.dart';
import 'settings_page.dart';
import 'area_calculator_page.dart'; // Your camera equivalent

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomeTab(),
    ServicesPage(),
    AreaCalculatorPage(), // Camera page added here
    ProductsPage(),
    SettingsPage(),
  ];

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onNavTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.miscellaneous_services),
              label: "Services",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.photo_camera), // Camera icon here
              label: "Camera",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: "Products",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: "Settings",
            ),
          ],
        ),
      ),
      floatingActionButton: null, // No floating action button
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/background1.jpg',
            height: 120,
          ),
          const SizedBox(height: 20),
          const Text(
            "Welcome to Senfrost!",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text("Your trusted partner for cooling solutions."),
        ],
      ),
    );
  }
}
