/// Exceptions are low-level errors usually thrown by data sources
/// (e.g., API calls, local database, cache).
/// These will later be converted into Failures.
class ServerException implements Exception {
  final String message;
  ServerException([this.message = "An unknown server error occurred"]);
}

class CacheException implements Exception {
  final String message;
  CacheException([this.message = "An unknown cache error occurred"]);
}

class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = "No internet connection"]);
}
