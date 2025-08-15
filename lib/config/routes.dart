import 'package:go_router/go_router.dart';
import '../presentation/pages/splash_page.dart';
import '../presentation/pages/login_page.dart';
import '../presentation/pages/register_page.dart';
import '../presentation/pages/customer/customer_home_page.dart';
import '../presentation/pages/customer/products_page.dart';
import '../presentation/pages/customer/services_page.dart';
import '../presentation/pages/customer/book_appointment_page.dart';
import '../presentation/pages/admin/admin_dashboard_page.dart';
import '../presentation/pages/admin/manage_appointments_page.dart';
import '../presentation/pages/technician/technician_dashboard_page.dart';
import '../presentation/pages/technician/area_calculator_page.dart';

class AppRoutes {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      // Splash & Auth
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      
      GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
      ),
      
      // Customer Routes
      GoRoute(
        path: '/customer-home',
        builder: (context, state) => const CustomerHomePage(),
      ),
      GoRoute(
        path: '/products',
        builder: (context, state) => const ProductsPage(),
      ),
      GoRoute(
        path: '/services',
        builder: (context, state) => const ServicesPage(),
      ),
      GoRoute(
        path: '/book-appointment',
        builder: (context, state) {
          final productName = state.extra as String? ?? 'Unknown Product';
          return BookAppointmentPage(productName: productName);
        },
      ),
      
      // Admin Routes
      GoRoute(
        path: '/admin-dashboard',
        builder: (context, state) => const AdminDashboardPage(),
      ),
      GoRoute(
        path: '/manage-appointments',
        builder: (context, state) => const ManageAppointmentsPage(),
      ),
      
      // Technician Routes
      GoRoute(
        path: '/technician-dashboard',
        builder: (context, state) => const TechnicianDashboardPage(),
      ),
      GoRoute(
        path: '/area-calculator',
        builder: (context, state) => const AreaCalculatorPage(),
      ),
    ],
  );
}