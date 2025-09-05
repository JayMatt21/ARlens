import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/error/exceptions.dart';
import '../models/appointment_model.dart'; // <-- gagamitin natin ito
import 'supabase_datasource.dart';

class SupabaseDataSourceImpl implements SupabaseDataSource {
  final SupabaseClient client;

  SupabaseDataSourceImpl() : client = Supabase.instance.client;

  @override
  Future<List<Map<String, dynamic>>> fetchTable(String tableName) async {
    try {
      final response = await client.from(tableName).select();
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      throw ServerException('Failed to fetch data from $tableName: $e');
    }
  }

  @override
  Future<void> insert(String tableName, Map<String, dynamic> data) async {
    try {
      await client.from(tableName).insert(data);
    } catch (e) {
      throw ServerException('Failed to insert into $tableName: $e');
    }
  }

  @override
  Future<void> update(
      String tableName, Map<String, dynamic> data, String id) async {
    try {
      await client.from(tableName).update(data).eq('id', id);
    } catch (e) {
      throw ServerException('Failed to update $tableName (id=$id): $e');
    }
  }

  @override
  Future<void> delete(String tableName, String id) async {
    try {
      await client.from(tableName).delete().eq('id', id);
    } catch (e) {
      throw ServerException('Failed to delete from $tableName (id=$id): $e');
    }
  }

  @override
  Future<AuthResponse> signIn(String email, String password) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) {
        throw ServerException('Invalid login credentials');
      }
      return response;
    } catch (e) {
      throw ServerException('Failed to sign in: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      throw ServerException('Failed to sign out: $e');
    }
  }

  // 🗓 Fetch appointments directly using Appointment.fromJson
  Future<List<Appointment>> getAppointments() async {
    try {
      final response = await client.from('appointments').select();
      final data = response as List;
      return data.map((json) => Appointment.fromJson(json)).toList();
    } catch (e) {
      throw ServerException('Failed to fetch appointments: $e');
    }
  }
}
