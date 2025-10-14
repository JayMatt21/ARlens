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
            colors: [
              Color(0xFFd0e8ff), // light blue
              Color(0xFF9bbddf), // medium blue-grey
              Color(0xFFf9fbfc), // very light grey/white
            ],
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
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.ac_unit, color: Color(0xFF1976D2), size: 42), // blue icon
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Senfrost Air-Conditioning\nSystems Services',
                    style: TextStyle(
                      color: Color(0xFF0D3B66),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            const Text(
              'Services Offered',
              style: TextStyle(
                color: Color(0xFF154360),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(color: Color(0xFF7F8C8D), thickness: 1.2),
            const SizedBox(height: 12),
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
            const SizedBox(height: 20),
            _serviceSection(
              'Refrigerator, Chillers, Water Dispensers',
              [
                'Charging Freon',
                'Minimal Repair',
                'Troubleshooting'
              ],
            ),
            const SizedBox(height: 40),
            InkWell(
              onTap: () => _launchPhone('09171484128'),
              child: const Text(
                '📞 0917 148 4128 / 0922 223 7829',
                style: TextStyle(color: Color(0xFF1976D2), fontSize: 17),
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _launchFacebook('https://facebook.com'),
              child: const Text(
                '📘 Senfrost Aircon Dealer and Installer',
                style: TextStyle(color: Color(0xFF1976D2), fontSize: 17),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '📍 Congressional Road, Brgy Poblacion 5 GMA, Cavite',
              style: TextStyle(color: Color(0xFF5D6D7E), fontSize: 16),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                context.go('/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(35),
                ),
                elevation: 6,
                shadowColor: Colors.blueAccent,
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text(
                '🚀 Start Your Journey',
                style: TextStyle(color: Colors.white),
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
        topLeft: Radius.circular(60),
        bottomLeft: Radius.circular(60),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(seconds: 1),
        child: Image.asset(
          workImages[_currentImageIndex],
          key: ValueKey<int>(_currentImageIndex),
          fit: BoxFit.cover,
          height: double.infinity,
          width: double.infinity,
          colorBlendMode: BlendMode.modulate,
          color: Colors.blueGrey.withOpacity(0.2),
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
            color: Color(0xFF154360),
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((service) => Text(
          '• $service',
          style: const TextStyle(
            color: Color(0xFF566573),
            fontSize: 15,
            height: 1.4,
          ),
        )),
      ],
    );
  }
}
