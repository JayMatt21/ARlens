import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import 'domain/usecases/create_appointment.dart';
import 'domain/usecases/get_services.dart';
import 'domain/usecases/get_products.dart';
import 'domain/repositories/app_repository.dart';

import 'package:arlens/data/repositories/app_repository_impl.dart';
import 'package:arlens/data/datasources/supabase_datasource.dart';
import 'package:arlens/data/datasources/supabase_datasource_impl.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ✅ External
  sl.registerLazySingleton<http.Client>(() => http.Client());

  // ✅ DataSources
  sl.registerLazySingleton<SupabaseDataSource>(
    () => SupabaseDataSourceImpl(client: sl()),
  );

  // ✅ Repository
  sl.registerLazySingleton<AppRepository>(
    () => AppRepositoryImpl(remoteDataSource: sl<SupabaseDataSource>()),
  );

  // ✅ Use Cases
  sl.registerLazySingleton(() => CreateAppointment(sl()));
  sl.registerLazySingleton(() => GetProducts(sl())); 
  sl.registerLazySingleton(() => GetServices(sl()));
}
