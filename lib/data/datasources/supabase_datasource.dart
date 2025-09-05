import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SupabaseDataSource {
  Future<List<Map<String, dynamic>>> fetchTable(String table);

  Future<void> insert(String table, Map<String, dynamic> data);

  Future<void> update(String table, Map<String, dynamic> data, String id);

  Future<void> delete(String table, String id);

  Future<AuthResponse> signIn(String email, String password);

  Future<void> signOut();
}
