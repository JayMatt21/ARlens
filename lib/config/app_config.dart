class AppConfig {
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String appName;
  final String companyName;
  final String version;
  final double defaultCeilingHeight;
  final double btuPerSqMeter;
  final int connectionTimeout;
  final int receiveTimeout;
  final String environment;

  const AppConfig._internal({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.appName,
    required this.companyName,
    required this.version,
    required this.defaultCeilingHeight,
    required this.btuPerSqMeter,
    required this.connectionTimeout,
    required this.receiveTimeout,
    required this.environment,
  });

  /// 🛠 Development Config
  static const dev = AppConfig._internal(
    supabaseUrl: 'https://dnjfkyokmqqrpazprwwt.supabase.co',
    supabaseAnonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRuamZreW9rbXFxcnBhenByd3d0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUwNzkwNTgsImV4cCI6MjA3MDY1NTA1OH0.nqYuNIFrC2fQuWiaj4_e2ggJEJTVHfguUsnPNnrk9O4',
    appName: 'AR Lens Calculator (DEV)',
    companyName: 'Senfrost Aircon Services',
    version: '1.0.0-dev',
    defaultCeilingHeight: 2.8,
    btuPerSqMeter: 500,
    connectionTimeout: 30000,
    receiveTimeout: 30000,
    environment: "dev",
  );

  /// 🚀 Production Config
  static const prod = AppConfig._internal(
    supabaseUrl: 'https://your-prod-project.supabase.co',
    supabaseAnonKey: 'PROD-ANON-KEY-HERE',
    appName: 'AR Lens Calculator',
    companyName: 'Senfrost Aircon Services',
    version: '1.0.0',
    defaultCeilingHeight: 2.8,
    btuPerSqMeter: 500,
    connectionTimeout: 30000,
    receiveTimeout: 30000,
    environment: "prod",
  );

  /// ✅ Set the current environment here
  static const current = dev; // 🔄 switch to prod when deploying
}
