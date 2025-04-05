import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:sgem/config/theme/app_theme.dart';
import 'package:sgem/modules/pages/administracion/usuarios/usuarios.dart';
import 'package:sgem/shared/models/usuario.dart';
import 'package:sgem/shared/widgets/app_button.dart';
import 'package:sgem/shared/widgets/custom.textfield.dart';
import 'package:sgem/shared/widgets/dropDown/dropdown.dart';

class UsuarioDialog extends StatefulWidget {
  const UsuarioDialog({super.key, this.user});

  final Usuario? user;

  Future<bool?> show(BuildContext context) => showDialog<bool>(
        context: context,
        builder: (_) => this,
      );

  @override
  State<UsuarioDialog> createState() => _UsuarioDialogState();
}

class _UsuarioDialogState extends State<UsuarioDialog> {
  bool get isEdit => widget.user != null;

  @override
  void initState() {
    Get.put(UsuarioController(user: widget.user));
    super.initState();
  }

  @override
  void dispose() {
    Get.delete<UsuarioController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctr = Get.find<UsuarioController>();

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: constraints.maxWidth * 0.5,
              maxWidth: constraints.maxWidth * 0.5,
              minHeight: constraints.maxHeight * 0.5,
              maxHeight: constraints.maxHeight * 0.5,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.backgroundBlue,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEdit ? 'Editar usuario' : 'Nuevo usuario',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          color: Colors.white,
                          onPressed: context.pop,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 48, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              CustomTextField(
                                label: 'Usuario',
                                isRequired: !isEdit,
                                icon: !isEdit ? Icon(Icons.search) : null,
                                isReadOnly: isEdit,
                                onIconPressed: () => ctr.searchUser(context),
                                controller: ctr.userCode,
                              ),
                              const SizedBox(height: 12),
                              MaestraAppDropdown(
                                label: 'Rol',
                                isRequired: true,
                                controller: ctr.rol,
                                options: (ctr) => ctr.roles,
                              ),
                              const SizedBox(height: 12),
                              ActiveDropdownField(
                                value: ctr.estado.value,
                                onChanged: (value) => ctr.estado.value = value,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Obx(() {
                            final person = ctr.user.value;

                            return Padding(
                              padding: EdgeInsets.only(left: 50),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Apellidos y Nombres',
                                  ),
                                  if (person == null)
                                    SizedBox(height: 16)
                                  else
                                    Text(
                                      person.fullName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Correo electrónico',
                                  ),
                                  if (person == null)
                                    SizedBox(height: 16)
                                  else
                                    Text(
                                      person.email,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    AppButton.white(
                      onPressed: context.pop,
                      text: 'Cerrar',
                    ),
                    AppButton.blue(
                      onPressed: () =>
                          (isEdit ? ctr.updateUser : ctr.saveUser)(context),
                      text: 'Guardar',
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}
