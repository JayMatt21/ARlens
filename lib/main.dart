import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://dnjfkyokmqqrpazprwwt.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRuamZreW9rbXFxcnBhenByd3d0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUwNzkwNTgsImV4cCI6MjA3MDY1NTA1OH0.nqYuNIFrC2fQuWiaj4_e2ggJEJTVHfguUsnPNnrk9O4',
  );

  runApp(const ARLensApp(
    appName: 'AR Lens Calculator (DEV)',
    environment: 'dev',
  ));
}

class ARLensApp extends StatelessWidget {
  final String appName;
  final String environment;

  const ARLensApp({
    Key? key,
    this.appName = 'AR Lens',
    this.environment = 'dev',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      debugShowCheckedModeBanner: environment != 'prod',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeWrapper(appName: appName, environment: environment),
    );
  }
}

class HomeWrapper extends StatelessWidget {
  final String appName;
  final String environment;

  const HomeWrapper({
    Key? key,
    required this.appName,
    required this.environment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text(appName),
        actions: [
         
          if (environment != 'prod')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    environment.toUpperCase(),
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: const Center(
        child: Text('Replace HomeWrapper with your LandingPage'),
      ),
    );
  }
}
