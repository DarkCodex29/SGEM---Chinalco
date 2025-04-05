import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sgem/config/Repository/auth_repository.dart';

class UnauthorizedPage extends StatelessWidget {
  const UnauthorizedPage({super.key});

  factory UnauthorizedPage.routeBuilder(_, __) {
    return const UnauthorizedPage(
      key: Key('unauthorized_page'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthRepository>();

    return Scaffold(
      body: Center(
        child: Text(
          auth.errorMessage.value ??
              'No tienes permisos para acceder a esta página',
        ),
      ),
    );
  }
}
