import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:package_chinalco_flutter/package_chinalco_flutter.dart';
import 'package:sgem/config/api/api.dart';
import 'package:sgem/shared/models/permiso.dart';
import 'package:sgem/shared/models/usuario.dart';
import 'package:sgem/shared/modules/option.value.dart';

enum AuthStatus { unknown, authenticated, unauthorized }

class AuthRepository extends GetxController {
  AuthRepository({
    required UsuarioService api,
    required RolPermisoService rolPermisoApi,
    required bool computeSession,
  })  : _api = api,
        _rolPermisoApi = rolPermisoApi,
        _computeSession = computeSession;

  final Logger _logger = Logger('AuthRepository');

  final UsuarioService _api;
  final RolPermisoService _rolPermisoApi;

  final user = Rxn<Usuario>();
  final principalName = RxnString();
  final roles = Rx<List<OptionValue>>(const []);

  final status = AuthStatus.unknown.obs;

  final errorMessage = RxnString();
  final _code = RxnString();

  set code(String? value) {
    status.value = AuthStatus.unknown;
    if (value?.isEmpty == false) {
      _code.value = value;
    }
  }

  String? get code => _code.value;
  final bool _computeSession;

  bool hasAccess(String code) =>
      roles.value.any((element) => element.nombre == code);

  bool get isUnauthorized => status.value == AuthStatus.unauthorized;
  bool get isAuthenticated => status.value == AuthStatus.authenticated;

  Future<void> Function() initaliceServices = () async {};

  void logout() {
    status.value = AuthStatus.unknown;
    user.value = null;
    principalName.value = null;
    roles.value = const [];
    errorMessage.value = null;
    code = null;
  }

  Future<bool> _validateCode() async {
    _logger.info('Validating code: $code');
    if (code?.isEmpty ?? true) {
      errorMessage.value = 'No tiene permisos para acceder a la aplicación';
      return false;
    }

    final String inPersonal;

    try {
      if (_computeSession) {
        _logger.info('Computing session for code: $code');
        final session =
            await McpApiAuth.getSesion(pstrToken: code!, isDev: true);
        if (session == null) {
          errorMessage.value = 'No tiene permisos para acceder a la aplicación';
          return false;
        }

        inPersonal = session.inPersona;
      } else {
        inPersonal = code!;
      }

      final response = await _api.getUser(personal: inPersonal);

      if (!response.success) {
        errorMessage.value = response.message ?? 'El personal no tiene acceso';
        return false;
      }

      final user = response.data!;
      principalName.value = user.personal.nombre;
      _logger.info('User: ${user.personal.nombre}');

      this.user.value = user;
      return true;
    } catch (e, stackTrace) {
      _logger.severe('Error validating code', e, stackTrace);
      return false;
    }
  }

  Future<bool> _getPermisos() async {
    try {
      final ResponseHandler<List<Permiso>> response;
      if (user.value?.key == -1) {
        response = await _rolPermisoApi.getPermisos();
      } else {
        response =
            await _rolPermisoApi.getPermisosPorRol(rol: user.value!.rol.key!);
      }

      if (response.success) {
        roles.value = response.data!
            .map(
              (e) => OptionValue(
                key: e.key,
                nombre: e.code,
              ),
            )
            .toList();
        return true;
      } else {
        errorMessage.value = response.message;
        return false;
      }
    } catch (e, stackTrace) {
      _logger.severe('Error getting permisos', e, stackTrace);
      return false;
    }
  }

  Future<void> init(BuildContext context) async {
    // status.value = AuthStatus.unknown;
    if (!await _validateCode()) {
      status.value = AuthStatus.unauthorized;
      if (context.mounted) context.go('/unauthorized');
      return;
    }

    if (await _getPermisos()) {
      await initaliceServices();
      status.value = AuthStatus.authenticated;
      if (context.mounted) context.go('/');
    } else {
      status.value = AuthStatus.unauthorized;
      if (context.mounted) context.go('/unauthorized');
    }
  }

  static void Function(AuthStatus status) onStatusChange(BuildContext context) {
    return (AuthStatus status) {
      Logger('Auth').info('Status: $status');
      switch (status) {
        case AuthStatus.authenticated:
        case AuthStatus.unauthorized:
          context.go('/unauthorized');
        case AuthStatus.unknown:
      }
    };
  }
}
