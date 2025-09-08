import 'package:arlens/domain/entities/appointment.dart';
import 'package:arlens/domain/entities/product.dart';
import 'package:arlens/domain/entities/service.dart';
import 'package:arlens/domain/entities/ac_recommendation.dart';
import 'package:arlens/domain/entities/room_measurement.dart';
import 'package:arlens/domain/repositories/app_repository.dart';
import 'package:arlens/data/datasources/supabase_datasource.dart';

class AppRepositoryImpl implements AppRepository {
  final SupabaseDataSource remoteDataSource;

  AppRepositoryImpl({required this.remoteDataSource});

  // ===== Appointments =====
  @override
  Future<List<Appointment>> getAppointments() => remoteDataSource.getAppointments();

  @override
  Future<void> createAppointment(Appointment appointment) => remoteDataSource.createAppointment(appointment);

  @override
  Future<void> updateAppointment(Appointment appointment) => remoteDataSource.updateAppointment(appointment);

  @override
  Future<void> deleteAppointment(String id) => remoteDataSource.deleteAppointment(id);

  // ===== Room measurements =====
  @override
  Future<void> createRoomMeasurement(RoomMeasurement entity) => remoteDataSource.createRoomMeasurement(entity);

  @override
  Future<void> updateRoomMeasurement(RoomMeasurement entity) => remoteDataSource.updateRoomMeasurement(entity);

  @override
  Future<void> deleteRoomMeasurement(String id) => remoteDataSource.deleteRoomMeasurement(id);

  // ===== AC Recommendations =====
  @override
  Future<List<ACRecommendation>> getACRecommendations() => remoteDataSource.getACRecommendations();

  // ===== Services & Products =====
  @override
  Future<List<Service>> getServices() => remoteDataSource.getServices();

  @override
  Future<List<Product>> getProducts() => remoteDataSource.getProducts();

  // ===== Auth =====
  @override
  Future<void> signIn(String email, String password) => remoteDataSource.signIn(email, password);

  @override
  Future<void> signOut() => remoteDataSource.signOut();

  @override
  Future<void> signUp(String email, String password) => remoteDataSource.signUp(email, password);

  @override
  Future<void> resetPassword(String email) => remoteDataSource.resetPassword(email);
}
