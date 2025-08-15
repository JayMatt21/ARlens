import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

final sl = GetIt.instance;

@injectableInit
Future<void> init() async {
  // Normally dito natin i-register yung dependencies
  // Kapag meron ka nang injectable config, tatawagin mo:
  // await $initGetIt(sl);

  // For now, placeholder lang para ma-run mo yung app
}
