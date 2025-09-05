import 'package:arlens/domain/entities/room_measurement.dart';
import 'package:arlens/domain/entities/appointment.dart';
import 'package:arlens/domain/entities/ac_recommendation.dart';
import 'package:arlens/domain/entities/service.dart';
import 'package:arlens/domain/entities/product.dart';


abstract class AppRepository {
  // 🗓️ Appointments
  Future<List<Appointment>> getAppointments();
  Future<void> createAppointment(Appointment appointment);
  Future<void> updateAppointment(Appointment appointment);
  Future<void> deleteAppointment(String id);

  // 📐 Room measurements
  Future<void> createRoomMeasurement(RoomMeasurement entity);
  Future<void> updateRoomMeasurement(RoomMeasurement entity);
  Future<void> deleteRoomMeasurement(String id);

  // ❄️ AC Recommendations
  Future<List<ACRecommendation>> getACRecommendations();

  // 🛠️ Services
  Future<List<Service>> getServices();

  // 🧾 Products
  Future<List<Product>> getProducts();

 
  Future<void> signIn(String email, String password);
  Future<void> signOut();
}
