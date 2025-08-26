import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:arlens/core/error/exceptions.dart';


class SupabaseDataSource {
  final SupabaseClient client;

  SupabaseDataSource(this.client);

 
Future<List<Map<String, dynamic>>> fetchTable(String table) async {
  try {
    final response = await client.from(table).select();
    return (response as List).cast<Map<String, dynamic>>();
  } catch (e) {
    throw ServerException("Failed to fetch data from $table: $e");
  }
}

  /// Insert a row into a table
  Future<void> insert(String table, Map<String, dynamic> data) async {
    try {
      final response = await client.from(table).insert(data);
      if (response == null) {
        throw ServerException("Insert returned null response in $table");
      }
    } catch (e) {
      throw ServerException("Failed to insert into $table: $e");
    }
  }

  /// Update a row by id
  Future<void> update(String table, Map<String, dynamic> data, String id) async {
    try {
      final response =
          await client.from(table).update(data).eq('id', id).select();
      if (response == null) {
        throw ServerException("Update returned null response in $table");
      }
    } catch (e) {
      throw ServerException("Failed to update $table (id=$id): $e");
    }
  }

  /// Delete a row by id
  Future<void> delete(String table, String id) async {
    try {
      final response = await client.from(table).delete().eq('id', id).select();
      if (response == null) {
        throw ServerException("Delete returned null response in $table");
      }
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
      if (response.user == null) {
        throw ServerException("Invalid login credentials");
      }
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
