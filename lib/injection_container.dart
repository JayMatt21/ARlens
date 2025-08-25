import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'data/datasources/supabase_datasource.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // Data sources
  sl.registerLazySingleton<SupabaseDataSource>(
    () => SupabaseDataSource(sl()),
  );

  // TODO: register repositories, use cases, etc.
}
