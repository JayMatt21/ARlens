import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

// Pages
import 'presentation/pages/splash_page.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/customer/customer_home_page.dart';

// Bloc
import 'presentation/bloc/auth/auth_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://dnjfkyokmqqrpazprwwt.supabase.co',
    anonKey: 'YOUR_SUPABASE_ANON_KEY', // replace with your key
  );

  final secureStorage = const FlutterSecureStorage();

  runApp(
    BlocProvider(
      create: (context) => AuthBloc(
        supabaseClient: Supabase.instance.client,
        secureStorage: secureStorage,
      )..add(CheckAuthStatus()),
      child: const ARLensApp(),
    ),
  );
}

class ARLensApp extends StatelessWidget {
  const ARLensApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // GoRouter configuration
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
          path: '/customer-home',
          builder: (context, state) => const CustomerHomePage(), // no userEmail needed
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

