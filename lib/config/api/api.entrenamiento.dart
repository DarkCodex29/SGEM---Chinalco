import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:sgem/config/api/api_chinalco.dart';
import 'package:sgem/config/api/response.handler.dart';
import 'package:sgem/config/constants/config.dart';
import 'package:sgem/shared/modules/entrenamiento.actualizacion.masiva.dart';
import 'package:sgem/shared/modules/entrenamiento.consulta.dart';
import 'package:sgem/shared/modules/entrenamiento.modulo.dart';

class EntrenamientoService extends ApiChinalco {
  EntrenamientoService();

  @override
  String get endpoint => 'Entrenamiento';

  Future<ResponseHandler<bool>> registerTraining(
    EntrenamientoModulo entrenamiento,
  ) async {
    final url = '${ConfigFile.apiUrl}/Entrenamiento/RegistrarEntrenamiento';
    try {
      final response = await client.post(
        url,
        data: jsonEncode(entrenamiento.toJson()),
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data is bool) {
          if (response.data) {
            return ResponseHandler.handleSuccess<bool>(true);
          } else {
            return const ResponseHandler(
              success: false,
              message:
                  'La operación no fue exitosa. El servidor devolvió false.',
            );
          }
        } else if (response.data is Map<String, dynamic> &&
            response.data.containsKey('Message')) {
          return ResponseHandler(
            success: false,
            message: response.data['Message'] ?? 'Error desconocido',
          );
        } else {
          return const ResponseHandler(
            success: false,
            message:
                'Formato de respuesta inesperado al registrar el entrenamiento',
          );
        }
      } else {
        return ResponseHandler(
          success: false,
          message:
              'Error al registrar entrenamiento: Código de estado ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      return ResponseHandler.handleFailure(e);
    }
  }

  Future<ResponseHandler<EntrenamientoModulo>>
      obtenerUltimoModuloPorEntrenamiento(int entrenamientoId) async {
    final url =
        '${ConfigFile.apiUrl}/Entrenamiento/ObtenerUltimoModuloPorEntrenamiento?inEntrenamiento=$entrenamientoId';
    try {
      final response = await client.get(url);

      if (response.statusCode == 200 && response.data != null) {
        try {
          final ultimoModulo = EntrenamientoModulo.fromJson(response.data);
          return ResponseHandler<EntrenamientoModulo>(
            success: true,
            data: ultimoModulo,
          );
        } catch (e) {
          return const ResponseHandler<EntrenamientoModulo>(
            success: false,
            message: 'Error al mapear los datos a EntrenamientoModulo.',
          );
        }
      } else if (response.statusCode == 200 && response.data == null) {
        final EntrenamientoModulo? ultimoModulo = EntrenamientoModulo();
        return ResponseHandler<EntrenamientoModulo>(
          success: true,
          data: ultimoModulo,
        );
      } else {
        logger.info(
          'Error en la respuesta del servidor: ${response.statusCode}, Datos: ${response.data}',
        );
        return const ResponseHandler<EntrenamientoModulo>(
          success: false,
          message: 'Error al obtener el último módulo',
        );
      }
    } on DioException catch (e) {
      logger.info(
        'Error al obtener el último módulo para el entrenamiento con ID: $entrenamientoId. Error: ${e.response?.data}',
      );
      return ResponseHandler.handleFailure<EntrenamientoModulo>(e);
    }
  }

  Future<ResponseHandler<List<dynamic>>> listarEntrenamientoPorPersona(
    int id,
  ) async {
    final url =
        '${ConfigFile.apiUrl}/Entrenamiento/ListarEntrenamientoPorPersona?id=$id';
    try {
      final response = await client.get(url);
      if (response.statusCode == 200 && response.data != null) {
        return ResponseHandler.handleSuccess<List<dynamic>>(response.data);
      } else {
        return const ResponseHandler(
          success: false,
          message: 'Error al listar entrenamientos',
        );
      }
    } on DioException catch (e) {
      logger.info(
        'Error al listar entrenamientos para la persona con ID: $id. Error: ${e.response?.data}',
      );
      return ResponseHandler.handleFailure(e);
    }
  }

  Future<ResponseHandler<bool>> updateEntrenamiento(
    EntrenamientoModulo data,
  ) async {
    try {
      await client.put<dynamic>(
        '/ActualizarEntrenamiento',
        data: data.toJson(),
      );

      return ResponseHandler.handleSuccess(true);
    } catch (e, stackTrace) {
      return ResponseHandler.fromError(
        e,
        stackTrace,
        'Error al actualizar el entrenamiento',
      );
    }
  }

  @Deprecated('Use updateEntrenamiento instead')
  Future<ResponseHandler<bool>> actualizarEntrenamiento(
    EntrenamientoModulo training,
  ) async {
    final url = '${ConfigFile.apiUrl}/Entrenamiento/ActualizarEntrenamiento';
    try {
      logger
          .info('Actualizando entrenamiento: ${jsonEncode(training.toJson())}');
      final response = await client.put(
        url,
        data: jsonEncode(training.toJson()),
      );
      // logger.info('RESPONSE PUT: $response');
      if (response.statusCode == 200 && response.data != null) {
        return ResponseHandler.handleSuccess<bool>(true);
      } else {
        return const ResponseHandler(
          success: false,
          message: 'Error al actualizar el entrenamiento',
        );
      }
    } on DioException catch (e) {
      logger.info(
        'Error al actualizar el entrenamiento. Datos: ${jsonEncode(training.toJson())}, Error: ${e.response?.data}',
      );
      return ResponseHandler.handleFailure(e);
    }
  }

  Future<ResponseHandler<bool>> eliminarEntrenamiento(
    EntrenamientoModulo training,
  ) async {
    final url = '${ConfigFile.apiUrl}/Entrenamiento/EliminarEntrenamiento';
    try {
      logger.info('Eliminando entrenamiento');
      final response = await client.delete(
        url,
        data: jsonEncode(training.toJson()),
      );
      logger.info('RESPONSE DELETE: $response');

      if (response.statusCode == 200 && response.data != null) {
        return ResponseHandler.handleSuccess<bool>(true);
      } else {
        return const ResponseHandler(
          success: false,
          message: 'Error al eliminar el entrenamiento',
        );
      }
    } on DioException catch (e) {
      logger.info(
        'Error al eliminar el entrenamiento. Error: ${e.response?.data}',
      );
      return ResponseHandler.handleFailure(e);
    }
  }

  Future<ResponseHandler<Map<String, dynamic>>> consultarEntrenamientoPaginado({
    String? codigoMcp,
    int? inEquipo,
    int? inModulo,
    int? inGuardia,
    int? inEstadoEntrenamiento,
    int? inCondicion,
    DateTime? fechaInicio,
    DateTime? fechaTermino,
    String? nombres,
    int? pageSize,
    int? pageNumber,
  }) async {
    logger.info("Llamando al endpoint entrenamiento paginado");
    final url =
        '${ConfigFile.apiUrl}/Entrenamiento/EntrenamientoConsultarPaginado';
    final queryParams = <String, dynamic>{
      'parametros.codigoMcp': codigoMcp,
      'parametros.inEquipo': inEquipo,
      'parametros.inModulo': inModulo,
      'parametros.inGuardia': inGuardia,
      'parametros.inEstadoEntrenamiento': inEstadoEntrenamiento,
      'parametros.inCondicion': inCondicion,
      'parametros.fechaInicio': fechaInicio,
      'parametros.fechaTermino': fechaTermino,
      'parametros.nombres': nombres,
      'parametros.pageSize': pageSize,
      'parametros.pageNumber': pageNumber,
    };
    try {
      logger.info(
        'Listando personal de entrenamiento paginado con parámetros: $queryParams',
      );
      final response = await client.get(
        url,
        queryParameters: queryParams,
        //..removeWhere((key, value) => value == null),
      );

      // logger.info(
      //   'Respuesta recibida para consultarEntrenamientoPaginado: ${response.data}',
      // );

      final result = response.data as Map<String, dynamic>;

      final items = result['Items'] as List;
      final entrenamientoList = items
          .map(
            (entrenamientoJson) =>
                EntrenamientoConsulta.fromJson(entrenamientoJson),
          )
          .toList();

      final responseData = {
        'Items': entrenamientoList,
        'PageNumber': result['PageNumber'],
        'TotalPages': result['TotalPages'],
        'TotalRecords': result['TotalRecords'],
        'PageSize': result['PageSize'],
      };

      return ResponseHandler.handleSuccess<Map<String, dynamic>>(responseData);
    } on DioException catch (e) {
      logger.info(
        'Error al consultar entrenamientos paginado. Error: ${e.response?.data}',
      );
      return ResponseHandler.handleFailure(e);
    }
  }

  Future<ResponseHandler<Map<String, dynamic>>> actualizacionMasivaPaginado({
    String? codigoMcp,
    String? numeroDocumento,
    int? inGuardia,
    String? nombres,
    String? apellidos,
    int? inEquipo,
    int? inModulo,
    int? pageSize,
    int? pageNumber,
  }) async {
    logger.info('Llamando al endpoint actuaalizacion masiva');
    final url =
        '${ConfigFile.apiUrl}/Entrenamiento/EntrenamientoActualizacionMasivaPaginado';
    final queryParams = <String, dynamic>{
      'parametros.codigoMcp': codigoMcp,
      'parametros.numeroDocumento': numeroDocumento,
      'parametros.inGuardia': inGuardia,
      'parametros.nombres': nombres,
      'parametros.apellidos': apellidos,
      'parametros.inEquipo': inEquipo,
      'parametros.inModulo': inModulo,
      'parametros.pageSize': pageSize,
      'parametros.pageNumber': pageNumber,
    };
    try {
      logger.info(
        'Listando personal de entrenamiento paginado con parámetros: $queryParams',
      );
      final response = await client.get(
        url,
        queryParameters: queryParams
          ..removeWhere((key, value) => value == null),
      );

      // logger.info(
      //   'Respuesta recibida para actualizacion masiva Paginado: ${response.data}',
      // );

      final result = response.data as Map<String, dynamic>;

      final items = result['Items'] as List;
      final entrenamientoList = items
          .map(
            (entrenamientoJson) =>
                EntrenamientoActualizacionMasiva.fromJson(entrenamientoJson),
          )
          .toList();

      final responseData = {
        'Items': entrenamientoList,
        'PageNumber': result['PageNumber'],
        'TotalPages': result['TotalPages'],
        'TotalRecords': result['TotalRecords'],
        'PageSize': result['PageSize'],
      };

      return ResponseHandler.handleSuccess<Map<String, dynamic>>(responseData);
    } on DioException catch (e) {
      logger.info(
        'Error al consultar entrenamientos paginado. Error: ${e.response?.data}',
      );
      return ResponseHandler.handleFailure(e);
    }
  }

  Future<ResponseHandler<EntrenamientoModulo>> obtenerEntrenamientoPorId(
    int entrenamientoId,
  ) async {
    final url =
        '${ConfigFile.apiUrl}/Entrenamiento/ObtenerEntrenamientoPorId?inEntrenamiento=$entrenamientoId';
    logger.info(
      'Api entrenamiento obtener entrenamiento por id $entrenamientoId',
    );
    try {
      logger.info('Api: $url');
      final response = await client.get(
        url,
      );

      if (response.statusCode == 200 && response.data != null) {
        logger.info('Api entrenamiento, obtenido con exito');

        final entrenamiento = EntrenamientoModulo.fromJson(response.data);
        // logger.info('Api entrenamiento, ${response.data}');
        return ResponseHandler.handleSuccess<EntrenamientoModulo>(
          entrenamiento,
        );
      } else {
        logger.info('Api entrenamiento, error al obtener modulo por id');

        return const ResponseHandler(
          success: false,
          message: 'Error al obtener el módulo por ID',
        );
      }
    } on DioException catch (e) {
      return ResponseHandler.handleFailure<EntrenamientoModulo>(e);
    }
  }

  Future<ResponseHandler<EntrenamientoModulo>>
      obtenerUltimoEntrenamientoPorPersona(int personaId) async {
    logger.info(
      'Api Entrenamiento: Obteniendo entrenamiento maestro por ID: $personaId',
    );
    final url =
        '${ConfigFile.apiUrl}/Entrenamiento/ObtenerUltimoEntrenamientoPorPersona?inPersona=$personaId';

    try {
      final response = await client.get(
        url,
      );
      // logger.info('Response: ${response.data}');
      if (response.statusCode == 200 && response.data != null) {
        return ResponseHandler.handleSuccess<EntrenamientoModulo>(
          response.data,
        );
      } else {
        return const ResponseHandler(
          success: false,
          message: 'Error al obtener el ultimo entrenamiento por persona',
        );
      }
    } on DioException catch (e) {
      return ResponseHandler.handleFailure<EntrenamientoModulo>(e);
    }
  }
}
