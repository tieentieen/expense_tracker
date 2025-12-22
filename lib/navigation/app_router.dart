import 'package:go_router/go_router.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/main/home_screen.dart';
import '../screens/main/report_screen.dart';
import '../screens/main/profile_screen.dart';
import '../screens/add_transaction_screen.dart';

class AppRouter {
  static GoRouter get router => _router;

  static final _router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) {
          final userId = state.extra as int;
          return HomeScreen(userId: userId);
        },
      ),
      GoRoute(
        path: '/report',
        name: 'report',
        builder: (context, state) {
          final userId = state.extra as int;
          return ReportScreen(userId: userId);
        },
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return ProfileScreen(
            userId: args['userId'],
            userName: args['userName'],
            userEmail: args['userEmail'],
          );
        },
      ),
      GoRoute(
        path: '/add-transaction',
        name: 'add-transaction',
        builder: (context, state) => const AddTransactionScreen(),
      ),
      GoRoute(
        path: '/edit-transaction',
        name: 'edit-transaction',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return AddTransactionScreen(
            transaction: args['transaction'],
            isEditing: true,
          );
        },
      ),
    ],
  );
}
