import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:sgem/config/api/api_chinalco.dart';
import 'package:sgem/config/api/response.handler.dart';
import 'package:sgem/config/constants/config.dart';
import 'package:sgem/shared/models/models.dart';
import 'package:sgem/shared/modules/maestro.detail.dart';

class MaestroDetalleService extends ApiChinalco {
  MaestroDetalleService();

  @override
  String get endpoint => 'MaestroDetalle';

  Future<ResponseHandler<List<Detalle>>> getMaestroDetalles({
    int? maestroKey,
    String? value,
    int? status,
  }) async {
    try {
      final params = <String, dynamic>{
        'maestro': maestroKey,
        'valor': value,
        'estado': status,
      };

      final response = await client.get<List<dynamic>>(
        '/BuscarMaestrosDetalle',
        queryParameters: params,
      );

      return ResponseHandler.handleSuccess(
        response.data
                ?.map((e) => Detalle.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );
    } catch (error, stackTrace) {
      return ResponseHandler.fromError(
        error,
        stackTrace,
        'Error al listar maestros',
      );
    }
  }

  @Deprecated('Usar getMaestroDetalles')
  Future<ResponseHandler<List<MaestroDetalle>>> listarMaestroDetalle({
    String? nombre,
    String? descripcion,
  }) async {
    final url = '${ConfigFile.apiUrl}/MaestroDetalle/ListarMaestrosDetalle';
    Map<String, dynamic> queryParams = {
      'parametros.nombre': nombre,
      'parametros.descripcion': descripcion,
    };

    try {
      final response = await client.get(
        url,
        queryParameters: queryParams
          ..removeWhere((key, value) => value == null),
      );

      if (response.statusCode == 200 && response.data != null) {
        List<MaestroDetalle> detalles = List<MaestroDetalle>.from(
          response.data.map((json) => MaestroDetalle.fromJson(json)),
        );

        return ResponseHandler.handleSuccess<List<MaestroDetalle>>(detalles);
      } else {
        return ResponseHandler(
          success: false,
          message: 'Error al listar maestro detalle',
        );
      }
    } on DioException catch (e) {
      return ResponseHandler.handleFailure<List<MaestroDetalle>>(e);
    }
  }

  Future<ResponseHandler<bool>> registrateMaestroDetalle(
    Detalle data,
  ) async {
    try {
      await client.post<dynamic>(
        '/RegistrarMaestroDetalle',
        data: data.toJson(),
      );

      return ResponseHandler.handleSuccess(true);
    } catch (e, stackTrace) {
      return ResponseHandler.fromError(
        e,
        stackTrace,
        'Error al registrar maestro detalle',
      );
    }
  }

  Future<ResponseHandler<bool>> registrarMaestroDetalle(
      MaestroDetalle data) async {
    final url = '${ConfigFile.apiUrl}/MaestroDetalle/RegistrarMaestroDetalle';

    try {
      final response = await client.post(
        url,
        data: jsonEncode(data.toJson()),
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data['Codigo'] == 200 && response.data['Valor'] == "OK") {
          log('Maestro Detalle registrado correctamente');
          return ResponseHandler(success: true, data: true);
        } else {
          return ResponseHandler(
            success: false,
            message: 'Error inesperado al registrar maestro detalle',
          );
        }
      } else {
        return ResponseHandler(
          success: false,
          message: 'Error al registrar maestro detalle',
        );
      }
    } on DioException catch (e) {
      return ResponseHandler.handleFailure<bool>(e);
    }
  }

  Future<ResponseHandler<bool>> updateMaestroDetalle(
    Detalle data,
  ) async {
    try {
      await client.put<dynamic>(
        '/ActualizarMaestroDetalle',
        data: data.toJson(),
      );

      return ResponseHandler.handleSuccess(true);
    } catch (e, stackTrace) {
      return ResponseHandler.fromError(
        e,
        stackTrace,
        'Error al actualizar maestro detalle',
      );
    }
  }

  Future<ResponseHandler<bool>> actualizarMaestroDetalle(
      MaestroDetalle data) async {
    final url = '${ConfigFile.apiUrl}/MaestroDetalle/ActualizarMaestroDetalle';

    try {
      final response = await client.put(
        url,
        data: jsonEncode(data.toJson()),
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data['Codigo'] == 200 && response.data['Valor'] == "OK") {
          log('Maestro Detalle actualizado correctamente');
          return ResponseHandler(success: true, data: true);
        } else {
          return ResponseHandler(
            success: false,
            message: 'Error inesperado al actualizar maestro detalle',
          );
        }
      } else {
        return ResponseHandler(
          success: false,
          message: 'Error al actualizar maestro detalle',
        );
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data['Message'] != null) {
        var errorMessage = e.response!.data['Message'];
        log('Error al actualizar: $errorMessage');
        return ResponseHandler(
          success: false,
          message: 'Error al actualizar maestro detalle: $errorMessage',
        );
      } else {
        return ResponseHandler.handleFailure<bool>(e);
      }
    }
  }

  Future<ResponseHandler<Detalle?>> getDetail(int id) async {
    try {
      final response = await client.get<Map<String, dynamic>>(
        '/obtenerMaestroDetallePorId',
        queryParameters: {'id': id},
      );

      return ResponseHandler.handleSuccess(
        response.data != null ? Detalle.fromJson(response.data!) : null,
      );
    } catch (error, stackTrace) {
      return ResponseHandler.fromError(
        error,
        stackTrace,
        'Error al obtener detalle',
      );
    }
  }

  @Deprecated('Usar getDetail')
  Future<ResponseHandler<MaestroDetalle>> obtenerMaestroDetallePorId(
      String id) async {
    final url =
        '${ConfigFile.apiUrl}/MaestroDetalle/obtenerMaestroDetallePorId?id=$id';

    try {
      final response = await client.get(
        url,
      );

      if (response.statusCode == 200 && response.data != null) {
        MaestroDetalle detalle = MaestroDetalle.fromJson(response.data);
        return ResponseHandler.handleSuccess<MaestroDetalle>(detalle);
      } else {
        return ResponseHandler(
          success: false,
          message: 'No se encontraron datos para el ID $id',
        );
      }
    } on DioException catch (e) {
      return ResponseHandler.handleFailure<MaestroDetalle>(e);
    }
  }

  Future<ResponseHandler<List<Detalle>>> getDetailsByMaestro(
    int maestro,
  ) async {
    try {
      final response = await client.get<List<dynamic>>(
        '/ListarMaestroDetallePorMaestro',
        queryParameters: {'id': maestro},
      );

      return ResponseHandler.handleSuccess(
        response.data
                ?.map((e) => Detalle.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );
    } catch (e, stackTrace) {
      return ResponseHandler.fromError(
        e,
        stackTrace,
        'Error al listar detalles del maestro con Key $maestro',
      );
    }
  }

  Future<ResponseHandler<List<MaestroDetalle>>> listarMaestroDetallePorMaestro(
      int maestroKey) async {
    var url =
        '${ConfigFile.apiUrl}/MaestroDetalle/ListarMaestroDetallePorMaestro?id=$maestroKey';
    try {
      final response = await client.get(
        url,
      );

      if (response.statusCode == 200 && response.data != null) {
        List<MaestroDetalle> detalles = (response.data as List)
            .map(
                (json) => MaestroDetalle.fromJson(json as Map<String, dynamic>))
            .toList();
        return ResponseHandler.handleSuccess<List<MaestroDetalle>>(detalles);
      } else {
        return ResponseHandler(
          success: false,
          message: 'Error al listar detalles del maestro con Key $maestroKey',
        );
      }
    } on DioException catch (e) {
      log('Error al listar detalles del maestro con Key $maestroKey: $e');
      return ResponseHandler.handleFailure<List<MaestroDetalle>>(e);
    }
  }
}
