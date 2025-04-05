import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:sgem/config/api/api.dart';
import 'package:sgem/shared/models/models.dart';

class RolPermisoService extends ApiChinalco {
  RolPermisoService();

  @override
  String get endpoint => 'RolPermiso';

  Future<ResponseHandler<List<Rol>>> getRoles() async {
    try {
      final response = await client.get<List<dynamic>>('/VerRoles');

      return ResponseHandler.handleSuccess(
        response.data
                ?.map((e) => Rol.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );
    } catch (error, stackTrace) {
      return ResponseHandler.fromError(
        error,
        stackTrace,
        'Error al listar roles',
      );
    }
  }

  Future<ResponseHandler<List<Permiso>>> getPermisos() async {
    try {
      final response = await client.get<List<dynamic>>('/VerPermisos');

      return ResponseHandler.handleSuccess(
        response.data
                ?.map((e) => Permiso.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );
    } catch (error, stackTrace) {
      return ResponseHandler.fromError(
        error,
        stackTrace,
        'Error al listar permisos',
      );
    }
  }

  Future<ResponseHandler<List<Permiso>>> getPermisosPorRol({
    required int rol,
  }) async {
    try {
      final params = <String, dynamic>{
        'rol': rol,
      };

      final response = await client.get<List<dynamic>>(
        '/VerPermisosPorRol',
        queryParameters: params,
      );

      return ResponseHandler.handleSuccess(
        response.data
                ?.map((e) => Permiso.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );
    } catch (error, stackTrace) {
      return ResponseHandler.fromError(
        error,
        stackTrace,
        'Error al listar permisos',
      );
    }
  }

  Future<ResponseHandler<bool>> registrateRol(
    Rol data,
  ) async {
    try {
      Logger('RolPermisoService')
          .info('Registrando rol ${jsonEncode(data.toJson())}');
      await client.post<dynamic>(
        '/RegistrarRol',
        data: data.toJson(),
      );

      return ResponseHandler.handleSuccess(true);
    } catch (e, stackTrace) {
      return ResponseHandler.fromError(
        e,
        stackTrace,
        'Error al registrar rol',
      );
    }
  }

  Future<ResponseHandler<bool>> registratePermiso(
    Permiso data,
  ) async {
    try {
      Logger('RolPermisoService')
          .info('Registrando rol ${jsonEncode(data.toJson())}');
      await client.post<dynamic>(
        '/RegistrarPermiso',
        data: data.toJson(),
      );

      return ResponseHandler.handleSuccess(true);
    } catch (e, stackTrace) {
      return ResponseHandler.fromError(
        e,
        stackTrace,
        'Error al registrar permiso',
      );
    }
  }

  Future<ResponseHandler<bool>> updateRol(
    Rol data,
  ) async {
    try {
      await client.put<dynamic>(
        '/ActualizarRol',
        data: data.toJson(),
      );

      return ResponseHandler.handleSuccess(true);
    } catch (e, stackTrace) {
      return ResponseHandler.fromError(
        e,
        stackTrace,
        'Error al actualizar rol',
      );
    }
  }

  Future<ResponseHandler<bool>> updatePermiso(
    Permiso data,
  ) async {
    try {
      await client.put<dynamic>(
        '/ActualizarPermiso',
        data: data.toJson(),
      );

      return ResponseHandler.handleSuccess(true);
    } catch (e, stackTrace) {
      return ResponseHandler.fromError(
        e,
        stackTrace,
        'Error al actualizar permiso',
      );
    }
  }

  Future<ResponseHandler<bool>> updateRolPermisos({
    required int rol,
    required List<int> toAdd,
    required List<int> toRemove,
  }) async {
    try {
      final data = <String, dynamic>{
        'Rol': rol,
        'PermisosActivos': toAdd,
        'PermisosInactivos': toRemove,
      };

      Logger('RolPermisoService')
          .info('Actualizando permisos ${jsonEncode(data)}');
      await client.put<dynamic>(
        '/ActualizarRolPermiso',
        data: data,
      );

      return ResponseHandler.handleSuccess(true);
    } catch (e, stackTrace) {
      return ResponseHandler.fromError(
        e,
        stackTrace,
        'Error al actualizar permisos',
      );
    }
  }
}
