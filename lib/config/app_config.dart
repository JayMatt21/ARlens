class AppConfig {
  // Supabase Configuration
  static const String supabaseUrl = 'https://dnjfkyokmqqrpazprwwt.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRuamZreW9rbXFxcnBhenByd3d0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUwNzkwNTgsImV4cCI6MjA3MDY1NTA1OH0.nqYuNIFrC2fQuWiaj4_e2ggJEJTVHfguUsnPNnrk9O4';
  
  // App Configuration
  static const String appName = 'AR Lens Calculator';
  static const String companyName = 'Senfrost Aircon Services';
  static const String version = '1.0.0';
  
  // Area Calculator Settings
  static const double defaultCeilingHeight = 2.8;
  static const double btuPerSqMeter = 500;
  
  // API Timeouts
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;
}