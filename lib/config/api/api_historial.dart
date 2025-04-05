import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:sgem/config/api/api_chinalco.dart';
import 'package:sgem/config/api/response.handler.dart';
import 'package:sgem/shared/models/historial_modificaciones.dart';

class HistorialModificacionesService extends ApiChinalco {
  HistorialModificacionesService();

  @override
  String get endpoint => 'Historial';

  Future<ResponseHandler<HistorialModificaciones>>
      searchHistorialModificacione({
    String query = '',
  }) async {
    try {
      final response = await client.get<Map<String, dynamic>>(
        '/BuscarHistorial',
        queryParameters: <String, dynamic>{
          'query': query,
        },
      );

      return ResponseHandler(
        success: true,
        data: HistorialModificaciones.fromJson(response.data!),
      );
    } catch (error, stackTrace) {
      return ResponseHandler.fromError(
        error,
        stackTrace,
        'Error al buscar el usuario',
      );
    }
  }

  Future<ResponseHandler<Map<String, dynamic>>> searchHistorialModificaciones(
      {DateTime? fechaInicio,
      DateTime? fechaFin,
      String? usuarioRegistro,
      int? idTabla,
      int? idAccion,
      int offset = 0,
      int limit = 1000,
      bool isPaginate = true}) async {
    String url = "/BuscarHistorial";
    if (!isPaginate) {
      url = '/BuscarHistorial';
    }
    Map<String, dynamic> queryParams = {
      'parametros.fechaInicio': fechaInicio,
      'parametros.fechaFin': fechaFin,
      'parametros.usuarioRegistro': usuarioRegistro,
      'parametros.tabla': idTabla,
      'parametros.accion': idAccion,
      'parametros.offset': offset,
      'parametros.limit': limit,
    };
    try {
      final response = await client.get(
        url,
        queryParameters: queryParams
          ..removeWhere((key, value) => value == null),
      );
      List<HistorialModificaciones> historialList = [];
      Map<String, dynamic> responseData;
      if (isPaginate) {
        final result = response.data as Map<String, dynamic>;

        final items = result['Items'] as List;
        historialList = items
            .map((historialJson) =>
                HistorialModificaciones.fromJson(historialJson))
            .toList();
        responseData = {
          'Items': historialList,
          'PageNumber': result['PageNumber'],
          'TotalPages': result['TotalPages'],
          'TotalRecords': result['TotalRecords'],
          'PageSize': result['PageSize'],
        };
        return ResponseHandler.handleSuccess<Map<String, dynamic>>(
            responseData);
      }
      final result = response.data['Items'] as List;
      historialList = result
          .map((historialJson) =>
              HistorialModificaciones.fromJson(historialJson))
          .toList();
      responseData = {
        'Items': historialList,
      };

      return ResponseHandler.handleSuccess<Map<String, dynamic>>(responseData);
    } on DioException catch (e) {
      log('Error al listar historial paginado. Error: ${e.response?.data}');
      return ResponseHandler.handleFailure(e);
    }
  }
}
