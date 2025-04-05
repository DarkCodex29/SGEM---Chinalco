import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logging/logging.dart';
import 'package:sgem/config/Repository/auth_repository.dart';
import 'package:sgem/config/theme/app_theme.dart';
import 'package:sgem/modules/pages/consulta.personal/entrenamiento/entrenamiento.personal.qr.dart';

import 'package:sgem/modules/pages/home/home.page.dart';
import 'package:sgem/router.dart';
import 'package:sgem/shared/modules/notfound.dart';
import 'package:sgem/shared/modules/unauthorized_page.dart';
import 'package:sgem/shared/widgets/dropDown/generic.dropdown.controller.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'SGEM',
      theme: AppTheme.lightTheme,
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
      // initialRoute: '/',
      // getPages: [
      //   GetPage(
      //     name: '/',
      //     page: () => const HomePage(),
      //   ),
      // ],
      // unknownRoute:
      //     GetPage(name: '/notfound', page: () => const NotFoundPage()),
      // home: Obx(() {
      //   Logger('Auth').info('Status: ${auth.status.value}');
      //   switch (auth.status.value) {
      //     case AuthStatus.unknown:
      //       return const Scaffold(
      //         body: Center(
      //           child: CircularProgressIndicator(),
      //         ),
      //       );
      //     case AuthStatus.authenticated:
      //       final dropdownController = Get.find<GenericDropdownController>();
      //       return dropdownController.isLoadingControl.value
      //           ? const Center(child: CircularProgressIndicator())
      //           : const HomePage();
      //     case AuthStatus.unauthorized:
      //       return const UnauthorizedPage();
      //   }
      // }),
    );
  }
}

class ViewApp extends StatelessWidget {
  const ViewApp({
    required this.id,
    required this.inPersonalOrigen,
    super.key,
  });

  final String id;
  final String inPersonalOrigen;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SGEM',
      theme: AppTheme.lightTheme,
      home: EntrenamientoPersonalQr(
        id: id,
        inPersonalOrigen: inPersonalOrigen,
      ),
    );
  }
}
