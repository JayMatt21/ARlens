import 'package:arlens/domain/entities/room_measurement.dart';
import 'package:arlens/domain/entities/appointment.dart';
import 'package:arlens/domain/entities/ac_recommendation.dart';
import 'package:arlens/domain/entities/service.dart';
import 'package:arlens/domain/entities/product.dart';

import '../models/product_model.dart' as product_model;
import '../models/appointment_model.dart' as model;
import '../models/ac_recommendation_model.dart' as ac_model;
import '../models/service_model.dart' as service_model;
import '../models/room_measurement_model.dart';

import '../datasources/supabase_datasource.dart';
import '../../core/error/exceptions.dart';
import '../../domain/repositories/app_repository.dart';

class AppRepositoryImpl implements AppRepository {
  final SupabaseDataSource datasource;

  AppRepositoryImpl({required this.datasource});

    // 🗓️ Appointments
    @override
    Future<List<Appointment>> getAppointments() async {
      try {
        final data = await datasource.fetchTable('appointments');
        // Model -> Entity
        return data
            .map((json) => model.Appointment.fromJson(json).toEntity())
            .toList();
      } catch (e) {
        throw ServerException("Failed to fetch appointments: $e");
      }
    }

    @override
    Future<void> createAppointment(Appointment appointment) async {
      try {
        // Entity -> Model -> Json
        final modelAppointment = model.Appointment.fromEntity(appointment);
        await datasource.insert('appointments', modelAppointment.toJson());
      } catch (e) {
        throw ServerException("Failed to create appointment: $e");
      }
    }

    @override
    Future<void> updateAppointment(Appointment appointment) async {
      try {
        final modelAppointment = model.Appointment.fromEntity(appointment);
        await datasource.update(
          'appointments',
          modelAppointment.toJson(),
          appointment.id,
        );
      } catch (e) {
        throw ServerException("Failed to update appointment: $e");
      }
    }

    @override
    Future<void> deleteAppointment(String id) async {
      try {
        await datasource.delete('appointments', id);
      } catch (e) {
        throw ServerException("Failed to delete appointment: $e");
      }
    }


  // 📐 Room Measurements
  @override
  Future<void> createRoomMeasurement(RoomMeasurement entity) async {
    try {
      final model = RoomMeasurementModel(
        id: entity.id,
        customerId: entity.customerId,
        roomName: entity.roomName,
        lengthMeters: entity.lengthMeters,
        widthMeters: entity.widthMeters,
        heightMeters: entity.heightMeters,
        areaSqm: entity.areaSqm,
        volumeCum: entity.volumeCum,
        roomType: entity.roomType,
        notes: entity.notes,
        createdAt: entity.createdAt,
      );

      await datasource.insert('room_measurements', model.toJson());
    } catch (e) {
      throw ServerException("Failed to create room measurement: $e");
    }
  }

  @override
  Future<void> updateRoomMeasurement(RoomMeasurement entity) async {
    try {
      final model = RoomMeasurementModel(
        id: entity.id,
        customerId: entity.customerId,
        roomName: entity.roomName,
        lengthMeters: entity.lengthMeters,
        widthMeters: entity.widthMeters,
        heightMeters: entity.heightMeters,
        areaSqm: entity.areaSqm,
        volumeCum: entity.volumeCum,
        roomType: entity.roomType,
        notes: entity.notes,
        createdAt: entity.createdAt,
      );

      await datasource.update('room_measurements', model.toJson(), entity.id);
    } catch (e) {
      throw ServerException("Failed to update room measurement: $e");
    }
  }

  @override
  Future<void> deleteRoomMeasurement(String id) async {
    try {
      await datasource.delete('room_measurements', id);
    } catch (e) {
      throw ServerException("Failed to delete room measurement: $e");
    }
  }

// ❄️ AC Recommendations
@override
Future<List<ACRecommendation>> getACRecommendations() async {
  try {
    final data = await datasource.fetchTable('ac_recommendations');
    final list = (data as List).map((json) {
      return ac_model.ACRecommendationModel.fromJson(json as Map<String, dynamic>)
          .toEntity();
    }).toList();
    return list;
  } catch (e) {
    throw ServerException("Failed to fetch AC recommendations: $e");
  }
}


@override
Future<List<Service>> getServices() async {
  try {
    final data = await datasource.fetchTable('services');
  return data
      .map((json) => service_model.ServiceModel.fromJson(json).toEntity())
      .toList();
  } catch (e) {
    throw ServerException("Failed to fetch services: $e");
  }
}

@override
Future<List<Product>> getProducts() async {
  try {
    final data = await datasource.fetchTable('products');
    return data
        .map((json) => product_model.ProductModel.fromJson(json).toEntity())
        .toList();
  } catch (e) {
    throw ServerException("Failed to fetch products: $e");
  }
}

  // 👤 Authentication
  @override
  Future<void> signIn(String email, String password) async {
    try {
      await datasource.signIn(email, password);
    } catch (e) {
      throw ServerException("Failed to sign in: $e");
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await datasource.signOut();
    } catch (e) {
      throw ServerException("Failed to sign out: $e");
    }
  }
}
