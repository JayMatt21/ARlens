import 'package:equatable/equatable.dart';

/// Failures are higher-level errors returned by repositories/services
/// to the domain or presentation layers.
/// Unlike Exceptions, Failures are not thrown but returned.
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([String message = "Server Failure"]) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure([String message = "Cache Failure"]) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = "Network Failure"]) : super(message);
}
