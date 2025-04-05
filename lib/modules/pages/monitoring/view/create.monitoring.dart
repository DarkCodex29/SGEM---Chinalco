import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sgem/config/theme/app_theme.dart';
import 'package:sgem/modules/pages/monitoring/controllers/monitoring.controller.dart';
import 'package:sgem/modules/pages/monitoring/controllers/monitoring.page.controller.dart';
import 'package:sgem/modules/pages/monitoring/widget/form.monitoring.dart';
import 'package:sgem/modules/pages/monitoring/widget/info.person.monitoring.dart';

class CreateMonioringView extends StatefulWidget {
  const CreateMonioringView({
    super.key,
    required this.controller,
    this.isEditing = false,
    this.isViewing = false,
  });
  final MonitoringSearchController controller;
  final bool isEditing;
  final bool isViewing;

  @override
  State<CreateMonioringView> createState() => _CreateMonioringViewState();
}

class _CreateMonioringViewState extends State<CreateMonioringView> {
  @override
  Widget build(BuildContext context) {
    final CreateMonitoringController createMonitoringController =
        Get.put(CreateMonitoringController());
    return LayoutBuilder(builder: (context, constraints) {
      bool isSmallScreen = constraints.maxWidth < 600;
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isEditing
                  ? "Editar Monitoreo"
                  : widget.isViewing
                      ? "Detalle del Monitoreo"
                      : "Nuevo Monitoreo",
              style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.backgroundBlue),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InfoPersonMonitoringWidegt(
                          isEditing: (widget.isEditing || widget.isViewing),
                          isSmallScreen: isSmallScreen,
                          createMonitoringController:
                              createMonitoringController,
                          monitoringSearchController: widget.controller,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        FormMonitoringWidget(
                          isSmallScreen: isSmallScreen,
                          monitoringSearchController: widget.controller,
                          isEditing: widget.isEditing,
                          isView: widget.isViewing,
                          createMonitoringController:
                              createMonitoringController,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
