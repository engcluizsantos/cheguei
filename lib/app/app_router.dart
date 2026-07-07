import 'package:cheguei/screens/splash/splash_page.dart';
import 'package:go_router/go_router.dart';
import 'package:cheguei/screens/auth/login_page.dart';
import 'package:cheguei/screens/auth/register_page.dart';

class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const profile = '/profile';
  static const home = '/home';
  static const recommendations = '/recommendations';
  static const details = '/details';
  static const chat = '/chat';
  static const favorites = '/favorites';
  static const settings = '/settings';
}

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),

      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),

      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),
    ],
  );
}
