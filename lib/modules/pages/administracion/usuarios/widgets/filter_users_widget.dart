import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sgem/modules/pages/administracion/usuarios/usuarios.dart';
import 'package:sgem/shared/widgets/app_button.dart';
import 'package:sgem/shared/widgets/custom.textfield.dart';
import 'package:sgem/shared/widgets/dropDown/maestra_app_dropdown.dart';

class FilterUsersWidget extends StatelessWidget {
  const FilterUsersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ctr = Get.find<UsuariosController>();
    final width = MediaQuery.of(context).size.width * 0.2;

    return ExpansionTile(
      title: const Text(
        "Filtro de Búsqueda",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      initiallyExpanded: true,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(width: 20),
                      SizedBox(
                        width: width,
                        child: CustomTextField(
                          label: 'Usuario',
                          controller: ctr.user,
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: MaestraAppDropdown(
                          label: 'Rol',
                          options: (ctr) => ctr.roles,
                          key: const Key('maestro_dropdown_maestro'),
                          hasAllOption: true,
                          controller: ctr.rol,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 40.0),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: width,
                        child: CustomTextField(
                          label: 'Nombres',
                          controller: ctr.name,
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: MaestraAppDropdown(
                          label: 'Estado',
                          options: (ctr) => ctr.estados,
                          controller: ctr.estado,
                          hasAllOption: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 40.0),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: width,
                        child: CustomTextField(
                          label: 'Apellidos',
                          controller: ctr.lastName,
                        ),
                      ),
                      SizedBox(width: width, height: 65),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton.white(
                    onPressed: ctr.clear,
                    icon: Icons.cleaning_services,
                    text: 'Limpiar',
                  ),
                  const SizedBox(width: 10),
                  AppButton.blue(
                    onPressed: ctr.search,
                    icon: Icons.cleaning_services,
                    text: 'Buscar',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
