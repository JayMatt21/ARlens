import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final List<String> workImages = [
    'assets/images/install.png',
    'assets/images/repair.png',
    'assets/images/PMS.png',
  ];
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();

    Future.delayed(const Duration(seconds: 3), _changeImage);
  }

  void _changeImage() {
    setState(() {
      _currentImageIndex = (_currentImageIndex + 1) % workImages.length;
    });
    Future.delayed(const Duration(seconds: 3), _changeImage);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _launchPhone(String number) async {
    final Uri url = Uri(scheme: 'tel', path: number);
    if (!await launchUrl(url)) throw 'Could not launch $url';
  }

  void _launchFacebook(String url) async {
    if (!await launchUrl(Uri.parse(url))) throw 'Could not launch $url';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 241, 170, 165), Color.fromARGB(255, 204, 51, 51)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: LayoutBuilder(
              builder: (context, constraints) {
                bool isMobile = constraints.maxWidth < 700;
                if (isMobile) {
                  return Column(
                    children: [
                      Expanded(flex: 3, child: _buildLeftContent(context)),
                      Expanded(flex: 2, child: _buildRightImage()),
                    ],
                  );
                } else {
                  return Row(
                    children: [
                      Expanded(flex: 3, child: _buildLeftContent(context)),
                      Expanded(flex: 2, child: _buildRightImage()),
                    ],
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeftContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.ac_unit, color: Colors.white, size: 40),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Senfrost Air-Conditioning\nSystems Services',
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Services Offered',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(color: Colors.white54),
            const SizedBox(height: 10),
            _serviceSection(
              'Residential and Commercial Air-Conditioning',
              [
                'Aircon Installation',
                'Aircon Dismantling',
                'Aircon Repair',
                'Aircon Cleaning',
                'Aircon Relocation',
                'Charging Freon',
                'Aircon Troubleshooting'
              ],
            ),
            const SizedBox(height: 15),
            _serviceSection(
              'Refrigerator, Chillers, Water Dispensers',
              [
                'Charging Freon',
                'Minimal Repair',
                'Troubleshooting'
              ],
            ),
            const SizedBox(height: 30),
            InkWell(
              onTap: () => _launchPhone('09171484128'),
              child: const Text(
                '📞 0917 148 4128 / 0922 223 7829',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _launchFacebook('https://facebook.com'),
              child: const Text(
                '📘 Senfrost Aircon Dealer and Installer',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '📍 Congressional Road, Brgy Poblacion 5 GMA, Cavite',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 30),

            // ✅ Start Your Journey Button
            ElevatedButton(
                onPressed: () {
                  context.go('/login');
                },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                '🚀 Start Your Journey',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRightImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(50),
        bottomLeft: Radius.circular(50),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(seconds: 1),
        child: Image.asset(
          workImages[_currentImageIndex],
          key: ValueKey<int>(_currentImageIndex),
          fit: BoxFit.cover,
          height: double.infinity,
          width: double.infinity,
        ),
      ),
    );
  }

  Widget _serviceSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 5),
        ...items.map((service) => Text(
              '• $service',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            )),
      ],
    );
  }
}
