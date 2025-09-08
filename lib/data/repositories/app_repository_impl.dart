import 'package:arlens/domain/repositories/app_repository.dart';
import 'package:arlens/domain/entities/appointment.dart';
import 'package:arlens/domain/entities/product.dart';
import 'package:arlens/domain/entities/service.dart';
import 'package:arlens/domain/entities/ac_recommendation.dart';
import 'package:arlens/domain/entities/room_measurement.dart';
import 'package:arlens/data/datasources/supabase_datasource.dart';

  class AppRepositoryImpl implements AppRepository {
  final SupabaseDataSource remoteDataSource;
  AppRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Appointment>> getAppointments() async {
    return await remoteDataSource.getAppointments();
  }

  @override
  Future<void> createAppointment(Appointment appointment) async {
  }

  @override
  Future<void> updateAppointment(Appointment appointment) async {}

  @override
  Future<void> deleteAppointment(String id) async {}

  @override
  Future<void> createRoomMeasurement(RoomMeasurement entity) async {}

  @override
  Future<void> updateRoomMeasurement(RoomMeasurement entity) async {}

  @override
  Future<void> deleteRoomMeasurement(String id) async {}

  @override
  Future<List<ACRecommendation>> getACRecommendations() async {
    return [];
  }

  @override
  Future<List<Service>> getServices() async {
    return [];
  }

  @override
  Future<List<Product>> getProducts() async {
    return [];
  }

  @override
  Future<void> signIn(String email, String password) async {}

  @override
  Future<void> signOut() async {}
}
