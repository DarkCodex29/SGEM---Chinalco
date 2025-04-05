import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:sgem/config/api/api.dart';
import 'package:sgem/config/constants/config.dart';
import 'package:sgem/shared/modules/archivo.dart';

class ArchivoService extends ApiChinalco {
  ArchivoService();

  @override
  String get endpoint => 'Archivo';

  Future<ResponseHandler<bool>> registrarArchivo({
    required int key,
    required String nombre,
    required String extension,
    required String mime,
    required String datos,
    required int inTipoArchivo,
    required int inOrigen,
    required int inOrigenKey,
  }) async {
    final url = '${ConfigFile.apiUrl}/Archivo/RegistrarArchivo';

    final requestBody = <String, dynamic>{
      'Key': key,
      'Nombre': nombre,
      'Extension': extension,
      'Mime': mime,
      'Datos': datos,
      'InTipoArchivo': inTipoArchivo,
      'InOrigen': inOrigen,
      'InOrigenKey': inOrigenKey,
    };

    try {
      logger.info('Registrando archivo: $requestBody');
      final response = await client.post(
        url,
        data: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 && response.data != null) {
        return ResponseHandler.handleSuccess<bool>(true);
      } else {
        return ResponseHandler(
          success: false,
          message: 'Error al registrar archivo',
        );
      }
    } on DioException catch (e) {
      logger.info(
        'Error al registrar archivo. Datos: $requestBody, Error: ${e.response?.data}',
      );
      return ResponseHandler.handleFailure(e);
    }
  }

  Future<ResponseHandler<List<Archivo>>> getFilesByOrigin({
    required int origin,
    required int originKey,
    int? fileType,
  }) async {
    try {
      final response = await client.get<List<dynamic>>(
        '/ObtenerArchivosPorOrigen',
        queryParameters: <String, dynamic>{
          'idOrigen': origin,
          'idOrigenKey': originKey,
          'idTipoArchivo': fileType,
        },
      );
      Logger('ArchivoService').info(
        'Response /ObtenerArchivosPorOrigen with idOrigen: $origin, '
        'idOrigenKey: $originKey, idTipoArchivo: $fileType, '
        'length: ${response.data?.length}',
      );

      return ResponseHandler(
        success: true,
        data: response.data
                ?.map((e) => Archivo.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
    } catch (e, stacktrace) {
      return ResponseHandler.fromError(
        e,
        stacktrace,
        'Error al obtener archivos por origen',
      );
    }
  }

  Future<ResponseHandler<List<dynamic>>> obtenerArchivosPorOrigen({
    required int idOrigen,
    required int idOrigenKey,
    int? idTipoArchivo,
  }) async {
    final url = '${ConfigFile.apiUrl}/Archivo/ObtenerArchivosPorOrigen';

    try {
      final response = await client.get(
        url,
        queryParameters: {
          'idOrigen': idOrigen,
          'idOrigenKey': idOrigenKey,
          'idTipoArchivo': idTipoArchivo,
        },
      );
      logger.info(response.data.toString());
      if (response.statusCode == 200 && response.data != null) {
        return ResponseHandler.handleSuccess<List<dynamic>>(response.data);
      } else {
        return ResponseHandler(
          success: false,
          message: 'Error al obtener archivos por origen',
        );
      }
    } on DioException catch (e) {
      logger.info(
        'Error al obtener archivos por origen. Error: ${e.response?.data}',
      );
      return ResponseHandler.handleFailure(e);
    }
  }

  Future<ResponseHandler<bool>> eliminarArchivo({
    required int key,
    required String nombre,
    required String extension,
    required String mime,
    required String? datos,
    required int inTipoArchivo,
    required int inOrigen,
    required int inOrigenKey,
  }) async {
    final url = '${ConfigFile.apiUrl}/Archivo/EliminarArchivo';

    final requestBody = <String, dynamic>{
      'Key': key,
      'Nombre': nombre,
      'Extension': extension,
      'Mime': mime,
      'Datos': datos,
      'InTipoArchivo': inTipoArchivo,
      'InOrigen': inOrigen,
      'InOrigenKey': inOrigenKey,
    };

    try {
      logger.info('Eliminando archivo: $requestBody');
      final response = await client.delete(
        url,
        data: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 && response.data != null) {
        return ResponseHandler.handleSuccess<bool>(true);
      } else {
        return ResponseHandler(
          success: false,
          message: 'Error al eliminar archivo',
        );
      }
    } on DioException catch (e) {
      logger.info(
        'Error al eliminar archivo. Datos: $requestBody, Error: ${e.response?.data}',
      );
      return ResponseHandler.handleFailure(e);
    }
  }
}
