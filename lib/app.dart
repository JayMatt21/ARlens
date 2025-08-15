import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'config/routes.dart';
import 'config/theme.dart';
import 'injection_container.dart' as di;
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/products/products_bloc.dart';
import 'presentation/bloc/services/services_bloc.dart';
import 'presentation/bloc/appointments/appointments_bloc.dart';
import 'presentation/bloc/area_calculator/area_calculator_bloc.dart';

class ARLensApp extends StatelessWidget {
  const ARLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>(create: (_) => di.sl<AuthBloc>()),
            BlocProvider<ProductsBloc>(create: (_) => di.sl<ProductsBloc>()),
            BlocProvider<ServicesBloc>(create: (_) => di.sl<ServicesBloc>()),
            BlocProvider<AppointmentsBloc>(create: (_) => di.sl<AppointmentsBloc>()),
            BlocProvider<AreaCalculatorBloc>(create: (_) => di.sl<AreaCalculatorBloc>()),
          ],
          child: MaterialApp.router(
            title: 'AR Lens - Senfrost Aircon',
            theme: AppTheme.lightTheme,
            routerConfig: AppRoutes.router,
            debugShowCheckedModeBanner: false,
          ),
        );
      },
    );
  }
}
