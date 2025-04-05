import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logging/logging.dart';
import 'package:sgem/config/api/api_usuario.dart';
import 'package:sgem/shared/models/usuario.dart';
import 'package:sgem/shared/utils/Extensions/format_extension.dart';
import 'package:sgem/shared/utils/Extensions/get_snackbar.dart';
import 'package:sgem/shared/utils/excel_converter.dart';
import 'package:sgem/shared/widgets/alert/widget.alert.dart';
import 'package:sgem/shared/widgets/dropDown/maestra_app_dropdown.dart';

class UsuariosController extends GetxController {
  UsuariosController({
    UsuarioService? personalService,
  }) : _usuarioService = personalService ?? UsuarioService();

  final UsuarioService _usuarioService;

  final TextEditingController user = TextEditingController();
  final TextEditingController name = TextEditingController();
  final TextEditingController lastName = TextEditingController();
  final DropdownController estado = DropdownController();
  final DropdownController rol = DropdownController();

  final Logger _logger = Logger('UsuariosController');

  @override
  Future<void> onInit() async {
    super.onInit();
    await search();
  }

  @override
  Future<void> onClose() async {
    super.onClose();
    user.dispose();
  }

  void clear() {
    user.clear();
    name.clear();
    estado.clear();
    rol.clear();
    lastName.clear();
    search();
  }

  final result = RxList<Usuario>();

  Future<void> search([BuildContext? context]) async {
    try {
      final response = await _usuarioService.searchUsuarios(
        userCode: user.text,
        name: name.text,
        lastName: lastName.text,
        state: estado.value,
        rol: rol.value,
      );

      if (response.success) {
        result.assignAll(response.data ?? []);
      } else {
        result.clear();
        _logger.warning('Error al buscar usuarios: ${response.message}');
        if (context != null && context.mounted) {
          MensajeValidacionWidget.single(
            response.message ?? 'Error al buscar usuarios',
          ).show(context);
        }
      }
    } catch (error, stackTrace) {
      _logger.severe('Error al buscar usuarios', error, stackTrace);
      if (context != null && context.mounted) {
        MensajeValidacionWidget.single('Error al buscar usuarios')
            .show(context);
      }
    }
  }

  Future<void> excel(
    BuildContext context,
  ) async {
    final response = await _usuarioService.searchUsuarios();

    if (!response.success) {
      context.errorSnackbar(response.message ?? 'Error al exportar');
      return;
    }

    final data = response.data ?? [];
    await (ExcelUtils.convertToExcel(
      data,
      sheetName: 'Usuarios',
      converter: usuarioFormat,
      headers: const [
        'USUARIO',
        'NOMBRES_APELLIDOS',
        'CORREO_ELECTRONICO',
        'ROL_USUARIO',
        'USUARIO_FECHA_REGISTRO',
        'FECHA_REGISTRO',
        'USUARIO_FECHA_MODIFICACION',
        'FECHA_MODIFICACION',
        'ESTADO',
      ],
    )).download(name: 'USUARIOS_MINA', addTimestamp: true);
  }
}

List<String> usuarioFormat(Usuario item) {
  return [
    item.personal.nombre ?? '-',
    item.fullName,
    item.email,
    item.rol.nombre ?? '-',
    item.userRegister,
    item.dateRegister.formatExtended,
    item.userModify,
    item.dateModify.formatExtended,
    item.state ? 'Activo' : 'Inactivo',
  ];
}
