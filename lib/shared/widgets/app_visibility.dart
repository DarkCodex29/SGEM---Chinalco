import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sgem/config/Repository/auth_repository.dart';

class AppVisibility extends StatelessWidget {
  const AppVisibility(
    this.code, {
    required this.child,
    super.key,
  });

  final String code;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ctr = Get.find<AuthRepository>();

    return Visibility(
      visible: ctr.hasAccess(code),
      child: child,
    );
  }
}
