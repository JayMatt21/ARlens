import 'package:flutter_bloc/flutter_bloc.dart';

// Dummy Events
abstract class AuthEvent {}
class AuthDummyEvent extends AuthEvent {}

// Dummy State
abstract class AuthState {}
class AuthInitial extends AuthState {}

// Dummy Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AuthDummyEvent>((event, emit) {
      // No-op
    });
  }
}
