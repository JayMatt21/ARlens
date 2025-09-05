import 'package:get_it/get_it.dart';
import 'domain/usecases/create_appointment.dart';
import 'domain/usecases/get_services.dart';
import 'domain/usecases/get_products.dart';
// import 'domain/repositories/app_repository.dart';
import 'package:arlens/data/repositories/app_repository_impl.dart';
import 'package:arlens/data/datasources/supabase_datasource.dart';
import 'package:arlens/data/datasources/supabase_datasource_impl.dart';



final sl = GetIt.instance;

Future<void> init() async {
  // ✅ Register SupabaseDataSource first
  
  sl.registerLazySingleton<SupabaseDataSource>(() => SupabaseDataSourceImpl());

  // ✅ Pass it into AppRepositoryImpl
  sl.registerLazySingleton<AppRepositoryImpl>(
    () => AppRepositoryImpl(datasource: sl<SupabaseDataSource>()),
  );

  // Use Cases
  sl.registerLazySingleton(() => CreateAppointment(sl()));
  sl.registerLazySingleton(() => GetProduct(sl()));
  sl.registerLazySingleton(() => GetServices(sl()));
}