import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:sgem/config/theme/app_theme.dart';
import 'package:sgem/modules/pages/consulta.personal/consulta.personal.controller.dart';
import 'package:sgem/modules/pages/consulta.personal/entrenamiento/entrenamiento.personal.controller.dart';
import 'package:sgem/modules/pages/consulta.personal/entrenamiento/entrenamiento.personal.page.dart';
import 'package:sgem/modules/pages/consulta.personal/personal/nuevo.personal.controller.dart';

import 'package:sgem/shared/widgets/dropDown/generic.dropdown.controller.dart';

class EntrenamientoPersonalQr extends StatelessWidget {
  const EntrenamientoPersonalQr({
    required this.id,
    required this.inPersonalOrigen,
    super.key,
  });

  factory EntrenamientoPersonalQr.routeBuilder(_, GoRouterState state) {
    final id = state.uri.queryParameters['id'] ?? '';
    final inPersonalOrigen =
        state.uri.queryParameters['inPersonalOrigen'] ?? '';
    return EntrenamientoPersonalQr(
      id: id,
      inPersonalOrigen: inPersonalOrigen,
    );
  }

  final String id;
  final String inPersonalOrigen;

  @override
  Widget build(BuildContext context) {
    Get.put(GenericDropdownController());
    final controller = Get.put(PersonalSearchController(
      context,
    ));
    final controllerNuevoPersonal = Get.put(NuevoPersonalController());
    final ctr = Get.put(EntrenamientoPersonalController());

    controller.showPersonal(id);
    controllerNuevoPersonal.showPersonalPhoto(int.parse(inPersonalOrigen));
    ctr.ShowTraining(int.parse(id));

    return Obx(() {
      if (controller.selectedPersonal.value == null) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Gestion de Entrenamiento Mina',
            style: TextStyle(
              color: Color(0xFFF2F6FF),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: AppTheme.backgroundBlue,
          automaticallyImplyLeading: false,
          leading: Image.asset('assets/images/logo.png'),
        ),
        body: EntrenamientoPersonalPage(
          isDeepLink: true,
          controllerPersonal: controller,
          onCancel: () {},
        ),
      );
    });
  }
}
