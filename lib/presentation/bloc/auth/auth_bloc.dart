import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  const LoginRequested({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class LogoutRequested extends AuthEvent {}

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  const RegisterRequested({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class CheckAuthStatus extends AuthEvent {}

class ForgotPasswordRequested extends AuthEvent {
  final String email;
  const ForgotPasswordRequested({required this.email});
  @override
  List<Object?> get props => [email];
}

/// States
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final String userEmail;
  const Authenticated(this.userEmail);
  @override
  List<Object?> get props => [userEmail];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

class EmailVerificationSent extends AuthState {}

class PasswordResetSent extends AuthState {}

/// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SupabaseClient supabaseClient;
  final FlutterSecureStorage secureStorage;

  AuthBloc({
    required this.supabaseClient,
    required this.secureStorage,
  }) : super(AuthInitial()) {
    /// 🔑 Login
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final res = await supabaseClient.auth.signInWithPassword(
          email: event.email,
          password: event.password,
        );
        // Success
        if (res.user != null) {
          await secureStorage.write(key: 'user_email', value: event.email);
          emit(Authenticated(event.email));
        } else {
          emit(const AuthError('Login failed'));
        }
      } on AuthException catch (e) {
        emit(AuthError(e.message));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    /// 🚪 Logout
    on<LogoutRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await supabaseClient.auth.signOut();
        await secureStorage.delete(key: 'user_email');
        emit(Unauthenticated());
      } on AuthException catch (e) {
        emit(AuthError(e.message));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    /// 📝 Register
    on<RegisterRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final res = await supabaseClient.auth.signUp(
          email:event.email,
          password:event.password,
        );
        if (res.user != null || res.user == null) {
          // Supabase may require email verification
          emit(EmailVerificationSent());
        }
      } on AuthException catch (e) {
        emit(AuthError(e.message));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    /// 🔄 Check Session
    on<CheckAuthStatus>((event, emit) async {
      final user = supabaseClient.auth.currentUser;
      if (user != null) {
        final email = await secureStorage.read(key: 'user_email');
        emit(Authenticated(email ?? user.email ?? ''));
      } else {
        emit(Unauthenticated());
      }
    });

    /// 🔐 Forgot Password
    on<ForgotPasswordRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await supabaseClient.auth.resetPasswordForEmail(event.email);
        emit(PasswordResetSent());
      } on AuthException catch (e) {
        emit(AuthError(e.message));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });
  }
}
