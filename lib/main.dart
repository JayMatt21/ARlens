import 'package:arlens/presentation/pages/verify_otp.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'presentation/pages/splash_page.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/register_page.dart';
import 'presentation/pages/customer/customer_home_page.dart';
import 'presentation/pages/admin/admin_dashboard_page.dart';
import 'presentation/pages/technician/technician_dashboard_page.dart';
import 'presentation/pages/customer/schedulling_page.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://dnjfkyokmqqrpazprwwt.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRuamZreW9rbXFxcnBhenByd3d0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUwNzkwNTgsImV4cCI6MjA3MDY1NTA1OH0.nqYuNIFrC2fQuWiaj4_e2ggJEJTVHfguUsnPNnrk9O4',
  );

  final secureStorage = const FlutterSecureStorage();

  runApp(ARLensApp(secureStorage: secureStorage));
}

class ARLensApp extends StatelessWidget {
  final FlutterSecureStorage secureStorage;
  const ARLensApp({super.key, required this.secureStorage});

  @override
  Widget build(BuildContext context) {
    final GoRouter router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: '/verify-otp',
          builder: (context, state) {
            final email = state.extra as String;
            return VerifyOtpPage(email: email);
          },
        ),
        GoRoute(
          path: '/customer-home',
          builder: (context, state) => const CustomerHomePage(),
        ),
        GoRoute(
          path: '/admin',
          builder: (context, state) => const AdminDashboardPage(),
        ),
        GoRoute(
          path: '/technician',
          builder: (context, state) => const TechnicianDashboardPage(),
        ),

        // Scheduling route
        GoRoute(
          path: '/scheduling',
          builder: (context, state) {
            final service =
                state.extra as Map<String, dynamic>?; 
            return SchedulingPage(service: service);
          },
        ),
      ],
    );

    return MaterialApp.router(
      title: 'AR Lens Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routerConfig: router,
    );
  }
}
