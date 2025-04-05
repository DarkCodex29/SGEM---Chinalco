import 'dart:convert';

import 'package:sgem/config/api/api.dart';
import 'package:sgem/shared/models/fecha.dart';

class FechaService extends ApiChinalco {
  FechaService();

  @override
  String get endpoint => 'Fecha';

  Future<ResponseHandler<Map<String, dynamic>>> getFechasPaginado(
      {int? inGuardia,
      int? anio,
      DateTime? fechaInicio,
      DateTime? fechaFin,
      int? pageSize,
      int? pageNumber,
      bool isPaginate = true}) async {
    Map<String, dynamic> queryParams = {
      'parametros.inGuardia': inGuardia,
      'parametros.inAnio': anio,
      'parametros.fechaInicio': fechaInicio,
      'parametros.fechaFin': fechaFin,
      'parametros.pageSize': pageSize,
      'parametros.pageNumber': pageNumber,
    };

    try {
      final response = await client.get(
        '/VerFechasPaginado',
        queryParameters: queryParams
          ..removeWhere((key, value) => value == null),
      ); //<List<Fecha>>

      List<Fecha> fechaList = [];
      Map<String, dynamic> responseData;
      final result = response.data as Map<String, dynamic>;

      final items = result['Items'] as List;
      fechaList =
          items.map((personalJson) => Fecha.fromJson(personalJson)).toList();
      responseData = {
        'Items': fechaList,
        'PageNumber': result['PageNumber'],
        'TotalPages': result['TotalPages'],
        'TotalRecords': result['TotalRecords'],
        'PageSize': result['PageSize'],
      };
      return ResponseHandler.handleSuccess<Map<String, dynamic>>(responseData);
    } catch (error, stackTrace) {
      return ResponseHandler.fromError(
        error,
        stackTrace,
        'Error al listar fechas',
      );
    }
  }

  Future<ResponseHandler<bool>> registrarFecha({
    required List<Fecha> fechas,
  }) async {
    try {
      final response = await client.post<dynamic>(
        '/RegistrarFechaMasivo',
        data: jsonEncode(fechas),
      );

      return ResponseHandler.handleSuccess(true);
    } catch (error, stackTrace) {
      return ResponseHandler.fromError(
        error,
        stackTrace,
        'Error al registrar fecha',
      );
    }
  }

  Future<ResponseHandler<bool>> actualizarFecha({
    required Fecha fecha,
  }) async {
    try {
      final response = await client.put<dynamic>(
        '/ActualizarFecha',
        data: fecha.toJson(),
      );

      return ResponseHandler.handleSuccess(response.data ?? false);
    } catch (error, stackTrace) {
      return ResponseHandler.fromError(
        error,
        stackTrace,
        'Error al actualizar fecha',
      );
    }
  }

  Future<List<Fecha>?> getFechasAnios() async {
    try {
      final response = await client.get(
        '/ObtenerAnios',
      ); //<List<Fecha>>

      if (response.data is List) {
        return (response.data as List)
            .map((item) => Fecha.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      // Si no es una lista, retornar null
      return null;
    } catch (error, stackTrace) {
      return null;
    }
  }
}
