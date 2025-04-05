import 'package:dio/dio.dart';
import 'package:sgem/config/api/api_chinalco.dart';
import 'package:sgem/config/api/response.handler.dart';
import 'package:sgem/shared/models/puesto.dart';

import 'package:sgem/shared/models/puestos_nivel.dart';

class PuestosNivelService extends ApiChinalco {
  PuestosNivelService();

  @override
  String get endpoint => 'NivelPuesto';

  Future<ResponseHandler<Map<String, dynamic>>> searchPuestosNivel({
    bool isPaginate = true,
  }) async {
    logger.info("Llamando al endpoint VerNivelPuesto");
    String url = "/VerNivelPuesto";
    try {
      final response = await client.get(
        url,
      );

      final result = response.data as List;
      final puestosNivelList = result
          .map(
            (puestoNivelJson) => PuestosNivel.fromJson(puestoNivelJson),
          )
          .toList();

      final responseData = {
        'Items': puestosNivelList,
      };

      return ResponseHandler.handleSuccess<Map<String, dynamic>>(responseData);
    } on DioException catch (e) {
      logger.info(
        'Error al consultar puestos por nivel paginado. Error: ${e.response?.data}',
      );
      return ResponseHandler.handleFailure(e);
    }
  }

  Future<ResponseHandler<Map<String, dynamic>>> searchPuestosApi({
    String query = '',
  }) async {
    logger.info("Llamando al endpoint BuscarPuesto");
    String url = "/BuscarPuesto";
    try {
      final response = await client.get(url, queryParameters: {
        'query': query,
      });

      final result = response.data as List;
      final puestosList = result
          .map(
            (puestoJson) => Puesto.fromJson(puestoJson),
          )
          .toList();

      final responseData = {
        'Items': puestosList,
      };

      return ResponseHandler.handleSuccess<Map<String, dynamic>>(responseData);
    } on DioException catch (e) {
      logger.info(
        'Error al consultar puesto paginado. Error: ${e.response?.data}',
      );
      return ResponseHandler.handleFailure(e);
    }
  }

  Future<ResponseHandler<bool>> updatePuestoNivel(
    PuestosNivel data,
  ) async {
    try {
      await client.put<dynamic>(
        '/ActualizarNivelPuesto',
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

  Future<ResponseHandler<bool>> savePuestoNivel(
    PuestosNivel data,
  ) async {
    try {
      await client.post<dynamic>(
        '/RegistrarNivelPuesto',
        data: data.toJson(),
      );

      return ResponseHandler.handleSuccess(true);
    } catch (e, stackTrace) {
      return ResponseHandler.fromError(
        e,
        stackTrace,
        'Error al registrar puestos por nivel.',
      );
    }
  }
}
