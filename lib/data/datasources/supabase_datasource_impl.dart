import 'package:http/http.dart' as http;
import 'supabase_datasource.dart';
import 'package:arlens/domain/entities/appointment.dart';
import 'package:arlens/domain/entities/product.dart';
import 'package:arlens/domain/entities/service.dart';
import 'package:arlens/domain/entities/ac_recommendation.dart';
import 'package:arlens/domain/entities/room_measurement.dart';

class SupabaseDataSourceImpl implements SupabaseDataSource {
  final http.Client client;

  SupabaseDataSourceImpl({required this.client});

  // ===== Appointments =====
  @override
  Future<List<Appointment>> getAppointments() async => [];

  @override
  Future<void> createAppointment(Appointment appointment) async {}

  @override
  Future<void> updateAppointment(Appointment appointment) async {}

  @override
  Future<void> deleteAppointment(String id) async {}

  // ===== Room measurements =====
  @override
  Future<void> createRoomMeasurement(RoomMeasurement entity) async {}

  @override
  Future<void> updateRoomMeasurement(RoomMeasurement entity) async {}

  @override
  Future<void> deleteRoomMeasurement(String id) async {}

  // ===== AC recommendations =====
  @override
  Future<List<ACRecommendation>> getACRecommendations() async => [];

  // ===== Services & Products =====
  @override
  Future<List<Service>> getServices() async => [];

  @override
  Future<List<Product>> getProducts() async => [];

  // ===== Auth =====
  @override
  Future<void> signIn(String email, String password) async {
    // TODO: Supabase auth.signInWithPassword
  }

  @override
  Future<void> signOut() async {
    // TODO: Supabase auth.signOut
  }

  @override
  Future<void> signUp(String email, String password) async {
    // TODO: Supabase auth.signUp
  }

  @override
  Future<void> resetPassword(String email) async {
    // TODO: Supabase auth.resetPasswordForEmail
  }
}
