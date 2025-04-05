import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:sgem/config/Repository/auth_repository.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    required this.token,
    super.key,
  });

  factory LoginPage.routeBuilder(_, GoRouterState state) {
    return LoginPage(
      key: const Key('login_page'),
      token: state.uri.queryParameters['token'] ?? '',
    );
  }

  final String token;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    final auth = Get.find<AuthRepository>()..code = widget.token;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      auth.init(context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
