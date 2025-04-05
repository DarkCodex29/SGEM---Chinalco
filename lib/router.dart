import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:sgem/config/Repository/auth_repository.dart';
import 'package:sgem/modules/pages/home/home.page.dart';
import 'package:sgem/modules/pages/login/login.dart';
import 'package:sgem/shared/modules/unauthorized_page.dart';

import 'modules/pages/consulta.personal/entrenamiento/entrenamiento.personal.qr.dart';

final router = GoRouter(
  initialLocation: '/home',
  errorBuilder: UnauthorizedPage.routeBuilder,
  routes: [
    GoRoute(
      path: '/login',
      builder: LoginPage.routeBuilder,
      redirect: (context, state) async {
        final q = state.uri.queryParameters;
        if (!q.containsKey('token')) {
          return '/unauthorized';
        }
        return null;
      },
    ),
    GoRoute(
      path: '/',
      redirect: (_, __) => '/home',
    ),
    GoRoute(
      path: '/qr',
      redirect: (context, state) async {
        final q = state.uri.queryParameters;
        if ((q['id']?.isEmpty ?? true) ||
            (q['inPersonalOrigen']?.isEmpty ?? true)) {
          return '/unauthorized';
        }
        return null;
      },
      builder: EntrenamientoPersonalQr.routeBuilder,
    ),
    GoRoute(
      path: '/home',
      builder: HomePage.routeBuilder,
      redirect: (context, state) async {
        if (!Get.find<AuthRepository>().isAuthenticated) {
          return '/unauthorized';
        }
        return null;
      },
    ),
    GoRoute(
      path: '/unauthorized',
      builder: (context, state) => const UnauthorizedPage(),
    ),
    GoRoute(
      path: '/logout',
      redirect: (context, state) async {
        Get.find<AuthRepository>().logout();
        return '/unauthorized';
      },
    ),
  ],
);
