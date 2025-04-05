import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:sgem/config/api/api_chinalco.dart';
import 'package:sgem/config/api/response.handler.dart';
import 'package:sgem/config/constants/config.dart';
import 'package:sgem/shared/modules/capacitacion.carga.masiva.excel.dart';
import 'package:sgem/shared/modules/capacitacion.carga.masiva.validado.dart';
import 'package:sgem/shared/modules/capacitacion.consulta.dart';
import 'package:sgem/shared/modules/entrenamiento.modulo.dart';

class CapacitacionService extends ApiChinalco {
  CapacitacionService();

  @override
  String get endpoint => 'Capacitacion';

  Future<ResponseHandler<Map<String, dynamic>>> capacitacionConsulta({
    String? codigoMcp,
    String? numeroDocumento,
    int? inGuardia,
    String? nombres,
    String? apellidoPaterno,
    String? apellidoMaterno,
    int? inCapacitacion,
    int? inCategoria,
    int? inEmpresaCapacitacion,
    int? inEntrenador,
    DateTime? fechaInicio,
    DateTime? fechaTermino,
    int? pageSize,
    int? pageNumber,
  }) async {
    logger.info('Llamando al endpoint consulta paginado');
    final url = '${ConfigFile.apiUrl}/Capacitacion/CapacitacionConsulta';
    final queryParams = <String, dynamic>{
      'parametros.codigoMcp': codigoMcp,
      'parametros.numeroDocumento': numeroDocumento,
      'parametros.inGuardia': inGuardia,
      'parametros.nombres': nombres,
      'parametros.apellidoPaterno': apellidoPaterno,
      'parametros.apellidoMaterno': apellidoMaterno,
      'parametros.inCapacitacion': inCapacitacion,
      'parametros.inCategoria': inCategoria,
      'parametros.inEmpresaCapacitacion': inEmpresaCapacitacion,
      'parametros.inEntrenador': inEntrenador,
      'parametros.fechaInicio': fechaInicio,
      'parametros.fechaTermino': fechaTermino,
      'parametros.pageSize': pageSize,
      'parametros.pageNumber': pageNumber,
    };
    try {
      logger.info('Listando capacitacion con parámetros: $queryParams');
      final response = await client.get(
        url,
        queryParameters: queryParams
          ..removeWhere((key, value) => value == null),
      );

      logger.info('Respuesta recibida para capacitacion: ${response.data}');

      //final result = response.data as Map<String, dynamic>;
      final result = response.data as List;
      //final items = result['Items'] as List;
      final capacitacionList = result
          .map(
            (entrenamientoJson) =>
                CapacitacionConsulta.fromJson(entrenamientoJson),
          )
          .toList();

      final responseData = {
        'Items': capacitacionList,
      };

      return ResponseHandler.handleSuccess<Map<String, dynamic>>(responseData);
    } on DioException catch (e) {
      logger.info(
        'Error al consultar capacitaciones. Error: ${e.response?.data}',
      );
      return ResponseHandler.handleFailure(e);
    }
  }

  Future<ResponseHandler<Map<String, dynamic>>> capacitacionConsultaPaginado({
    String? codigoMcp,
    String? numeroDocumento,
    int? inGuardia,
    String? nombres,
    String? apellidoPaterno,
    String? apellidoMaterno,
    int? inCapacitacion,
    int? inCategoria,
    int? inEmpresaCapacitacion,
    int? inEntrenador,
    DateTime? fechaInicio,
    DateTime? fechaTermino,
    int? pageSize,
    int? pageNumber,
  }) async {
    logger.info('Llamando al endpoint consulta paginado');
    final url =
        '${ConfigFile.apiUrl}/Capacitacion/CapacitacionConsultaPaginado';
    final queryParams = <String, dynamic>{
      'parametros.codigoMcp': codigoMcp,
      'parametros.numeroDocumento': numeroDocumento,
      'parametros.inGuardia': inGuardia,
      'parametros.nombres': nombres,
      'parametros.apellidoPaterno': apellidoPaterno,
      'parametros.apellidoMaterno': apellidoMaterno,
      'parametros.inCapacitacion': inCapacitacion,
      'parametros.inCategoria': inCategoria,
      'parametros.inEmpresaCapacitacion': inEmpresaCapacitacion,
      'parametros.inEntrenador': inEntrenador,
      'parametros.fechaInicio': fechaInicio,
      'parametros.fechaTermino': fechaTermino,
      'parametros.pageSize': pageSize,
      'parametros.pageNumber': pageNumber,
    };
    try {
      logger
          .info('Listando capacitacion paginado con parámetros: $queryParams');
      final response = await client.get(
        url,
        queryParameters: queryParams
          ..removeWhere((key, value) => value == null),
      );

      // logger.info(
      //   'Respuesta recibida para capacitacion Paginado: ${response.data}',
      // );
      // Logger('Api Capacitacion:').info('${response.data}');
      final result = response.data as Map<String, dynamic>;

      final items = result['Items'] as List;
      final capacitacionList = items
          .map(
            (entrenamientoJson) =>
                CapacitacionConsulta.fromJson(entrenamientoJson),
          )
          .toList();

      final responseData = {
        'Items': capacitacionList,
        'PageNumber': result['PageNumber'],
        'TotalPages': result['TotalPages'],
        'TotalRecords': result['TotalRecords'],
        'PageSize': result['PageSize'],
      };

      return ResponseHandler.handleSuccess<Map<String, dynamic>>(responseData);
    } on DioException catch (e) {
      logger.info(
        'Error al consultar capacitaciones paginado. Error: ${e.response?.data}',
      );
      return ResponseHandler.handleFailure(e);
    }
  }

  Future<ResponseHandler<bool>> _manageCapacitacion(
    String url,
    String method,
    EntrenamientoModulo capacitacion,
  ) async {
    logger.info('$method capacitación: ${jsonEncode(capacitacion.toJson())}');

    try {
      Response response;

      if (method == 'POST') {
        response =
            await client.post(url, data: jsonEncode(capacitacion.toJson()));
      } else if (method == 'PUT') {
        response =
            await client.put(url, data: jsonEncode(capacitacion.toJson()));
      } else if (method == 'DELETE') {
        response =
            await client.delete(url, data: jsonEncode(capacitacion.toJson()));
      } else {
        return ResponseHandler(
          success: false,
          message: 'Método HTTP no soportado',
        );
      }

      if (response.statusCode == 200 && response.data != null) {
        if (response.data is bool) {
          return ResponseHandler.handleSuccess<bool>(true);
        } else if (response.data is Map<String, dynamic> &&
            response.data.containsKey('Valor')) {
          return ResponseHandler.handleSuccess<bool>(true);
        } else if (response.data is Map<String, dynamic> &&
            response.data.containsKey('Message')) {
          return ResponseHandler(
            success: false,
            message: response.data['Message'] ?? 'Error desconocido',
          );
        } else {
          return ResponseHandler(
            success: false,
            message:
                'Formato de respuesta inesperado al manejar la capacitación',
          );
        }
      } else {
        return ResponseHandler(
          success: false,
          message: 'Error al manejar el capacitación',
        );
      }
    } on DioException catch (e) {
      logger.info(
        'Error al manejar el capacitación. Datos: ${jsonEncode(capacitacion.toJson())}, Error: ${e.response?.data}',
      );
      return ResponseHandler.handleFailure<bool>(e);
    }
  }

  Future<ResponseHandler<bool>> registrarCapacitacion(
    EntrenamientoModulo capacitacion,
  ) async {
    final url = '${ConfigFile.apiUrl}/Capacitacion/RegistrarCapacitacion';
    return _manageCapacitacion(url, 'POST', capacitacion);
  }

  Future<ResponseHandler<bool>> actualizarCapacitacion(
    EntrenamientoModulo capacitacion,
  ) async {
    final url = '${ConfigFile.apiUrl}/Capacitacion/ActualizarCapacitacion';
    return _manageCapacitacion(url, 'PUT', capacitacion);
  }

  Future<ResponseHandler<bool>> eliminarCapacitacion(
    EntrenamientoModulo capacitacion,
  ) async {
    final url = '${ConfigFile.apiUrl}/Capacitacion/EliminarCapacitacion';
    return _manageCapacitacion(url, 'DELETE', capacitacion);
  }

  Future<ResponseHandler<EntrenamientoModulo>> obtenerCapacitacionPorId(
    int idCapacitacion,
  ) async {
    final url = '${ConfigFile.apiUrl}/Capacitacion/ObtenerCapacitacionPorId';
    logger.info('Obteniendo capacitación por ID: $idCapacitacion');

    try {
      final response = await client.get(
        url,
        queryParameters: {'idCapacitacion': idCapacitacion},
      );

      logger.info(
        'Respuesta recibida para ObtenerCapacitacionPorId: ${response.data}',
      );

      if (response.statusCode == 200 && response.data != null) {
        final entrenamiento = EntrenamientoModulo.fromJson(response.data);
        return ResponseHandler.handleSuccess(entrenamiento);
      } else {
        return ResponseHandler(
          success: false,
          message: 'Error al obtener la capacitación por ID',
        );
      }
    } on DioException catch (e) {
      logger
          .info('Error al obtener la capacitación por ID: ${e.response?.data}');
      return ResponseHandler.handleFailure(e);
    }
  }

  Future<ResponseHandler<List<CapacitacionCargaMasivaValidado>>>
      validarCargaMasiva({
    required List<CapacitacionCargaMasivaExcel> cargaMasivaList,
  }) async {
    logger.info('Llamando al endpoint carga masiva');
    final url = '${ConfigFile.apiUrl}/Capacitacion/ValidarCargaMasiva';

    final request = cargaMasivaList.map((e) => e.toJson()).toList();
    logger.info(jsonEncode(request));

    try {
      logger.info('Enviando datos de capacitación para validación: $request');
      final response = await client.post(
        url,
        data: request,
      );

      if (response.statusCode == 200 && response.data != null) {
        final cargaMasivaValidada = List<CapacitacionCargaMasivaValidado>.from(
          response.data
              .map((json) => CapacitacionCargaMasivaValidado.fromJson(json)),
        );
        return ResponseHandler.handleSuccess<
            List<CapacitacionCargaMasivaValidado>>(cargaMasivaValidada);
      } else {
        return const ResponseHandler(
          success: false,
          message: 'Error al listar carga masiva',
        );
      }
    } on DioException catch (e) {
      logger.info(
        'Error al consultar capacitaciones paginado. Error: ${e.response?.data}',
      );
      return ResponseHandler.handleFailure(e);
    }
  }

  Future<ResponseHandler<bool>> cargarMasiva({
    required List<CapacitacionCargaMasivaExcel> cargaMasivaList,
  }) async {
    logger.info('Llamando al endpoint carga masiva');
    final url = '${ConfigFile.apiUrl}/Capacitacion/CargaMasiva';

    final request = cargaMasivaList.map((e) => e.toJson()).toList();
    logger.info(jsonEncode(request));
    try {
      logger.info(
        'Api Capacitacion: Enviando datos de capacitación para carga: $request',
      );
      final response = await client.post(
        url,
        data: request,
      );

      if (response.statusCode == 200 && response.data != null) {
        // logger.info('Api Capacitaciones: response ${response.data!}');
        // List<CapacitacionCargaMasivaValidado> cargaMasivaValidada =
        //     List<CapacitacionCargaMasivaValidado>.from(
        //   response.data
        //       .map((json) => CapacitacionCargaMasivaValidado.fromJson(json)),

        return ResponseHandler.handleSuccess<bool>(true);
      } else {
        return ResponseHandler(
          success: false,
          message: 'Error al realizar la carga masiva',
        );
      }
    } on DioException catch (e) {
      logger.info(
        'Error al consultar capacitaciones paginado. Error: ${e.response?.data}',
      );
      return ResponseHandler.handleFailure(e);
    }
  }
}
