/// Defines low-level exceptions for data sources (e.g., Supabase, cache).
class ServerException implements Exception {
  final String message;
  ServerException([this.message = "An unknown server error occurred"]);

  @override
  String toString() => "ServerException: $message";
}

class CacheException implements Exception {
  final String message;
  CacheException([this.message = "An unknown cache error occurred"]);

  @override
  String toString() => "CacheException: $message";
}

class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = "No internet connection"]);

  @override
  String toString() => "NetworkException: $message";
}
