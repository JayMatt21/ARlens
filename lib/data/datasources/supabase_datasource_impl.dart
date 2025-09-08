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
  Future<List<Appointment>> getAppointments() async {
    // TODO: implement real API call using `client`
    return [];
  }

  @override
  Future<void> createAppointment(Appointment appointment) async {
    // TODO: POST to backend
  }

  @override
  Future<void> updateAppointment(Appointment appointment) async {
    // TODO: PATCH/PUT
  }

  @override
  Future<void> deleteAppointment(String id) async {
    // TODO: DELETE
  }

  // ===== Room measurements =====
  @override
  Future<void> createRoomMeasurement(RoomMeasurement entity) async {}

  @override
  Future<void> updateRoomMeasurement(RoomMeasurement entity) async {}

  @override
  Future<void> deleteRoomMeasurement(String id) async {}

  // ===== AC recommendations =====
  @override
  Future<List<ACRecommendation>> getACRecommendations() async {
    return [];
  }

  // ===== Services & Products =====
  @override
  Future<List<Service>> getServices() async {
    return [];
  }

  @override
  Future<List<Product>> getProducts() async {
    return [];
  }

  // ===== Auth =====
  @override
  Future<void> signIn(String email, String password) async {}

  @override
  Future<void> signOut() async {}
}
