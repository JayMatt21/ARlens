import 'package:supabase_flutter/supabase_flutter.dart';
import '../datasources/supabase_datasource.dart';

/// A datasource class to handle Supabase operations.
/// This isolates all Supabase calls in one place.
class SupabaseDataSource {
  final SupabaseClient client;

  SupabaseDataSource(this.client);

  /// Fetch all rows from a table
  Future<List<Map<String, dynamic>>> fetchTable(String table) async {
    try {
      final response = await client.from(table).select();
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw ServerException("Failed to fetch data from $table: $e");
    }
  }

  /// Insert a row into a table
  Future<void> insert(String table, Map<String, dynamic> data) async {
    try {
      await client.from(table).insert(data);
    } catch (e) {
      throw ServerException("Failed to insert into $table: $e");
    }
  }

  /// Update a row by id
  Future<void> update(String table, Map<String, dynamic> data, String id) async {
    try {
      await client.from(table).update(data).eq('id', id);
    } catch (e) {
      throw ServerException("Failed to update $table (id=$id): $e");
    }
  }

  /// Delete a row by id
  Future<void> delete(String table, String id) async {
    try {
      await client.from(table).delete().eq('id', id);
    } catch (e) {
      throw ServerException("Failed to delete from $table (id=$id): $e");
    }
  }

  /// Sign in with email & password
  Future<AuthResponse> signIn(String email, String password) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      throw ServerException("Failed to sign in: $e");
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      throw ServerException("Failed to sign out: $e");
    }
  }
}
