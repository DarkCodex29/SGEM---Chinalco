import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:sgem/config/api/api_chinalco.dart';
import 'package:sgem/config/api/response.handler.dart';
import 'package:sgem/config/constants/config.dart';
import 'package:sgem/shared/models/maestro.dart';
import 'package:sgem/shared/modules/maestro.dart';

class MaestroService extends ApiChinalco {
  MaestroService();

  @override
  String get endpoint => 'Maestro';

  Future<ResponseHandler<List<Maestro>>> getMaestros() async {
    try {
      final response =
          await client.get<List<dynamic>>('/ListarMaestrosEditables');

      return ResponseHandler.handleSuccess(
        response.data
                ?.map((e) => Maestro.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );
    } catch (e, stackTrace) {
      return ResponseHandler.fromError(
        e,
        stackTrace,
        'Error al listar maestros',
      );
    }
  }

  @Deprecated('Usar getMaestros')
  Future<ResponseHandler<List<MaestroCompleto>>> listarMaestros() async {
    final url = '${ConfigFile.apiUrl}/Maestro/ListarMaestros';

    try {
      final response = await client.get(
        url,
      );

      if (response.statusCode == 200 && response.data != null) {
        List<MaestroCompleto> maestros = List<MaestroCompleto>.from(
          response.data.map((json) => MaestroCompleto.fromJson(json)),
        );
        return ResponseHandler.handleSuccess<List<MaestroCompleto>>(maestros);
      } else {
        return ResponseHandler(
          success: false,
          message: 'Error al listar maestros',
        );
      }
    } on DioException catch (e) {
      return ResponseHandler.handleFailure<List<MaestroCompleto>>(e);
    }
  }

  Future<ResponseHandler<bool>> registrarMaestro(
    MaestroCompleto maestro,
  ) async {
    final url = '${ConfigFile.apiUrl}/Maestro/RegistrarMaestro';

    try {
      final response = await client.post(
        url,
        data: jsonEncode(maestro.toJson()),
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data['Codigo'] == 200 && response.data['Valor'] == 'OK') {
          return ResponseHandler.handleSuccess<bool>(true);
        } else {
          return ResponseHandler(
            success: false,
            message: response.data['Message'] ?? 'Error desconocido',
          );
        }
      } else {
        return ResponseHandler(
          success: false,
          message: 'Error al registrar maestro',
        );
      }
    } on DioException catch (e) {
      return ResponseHandler.handleFailure<bool>(e);
    }
  }

  Future<ResponseHandler<bool>> actualizarMaestro(
    MaestroCompleto maestro,
  ) async {
    final url = '${ConfigFile.apiUrl}/Maestro/ActualizarMaestro';

    try {
      final response = await client.put(
        url,
        data: jsonEncode(maestro.toJson()),
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data['Codigo'] == 200 && response.data['Valor'] == 'OK') {
          return ResponseHandler.handleSuccess<bool>(true);
        } else {
          return ResponseHandler(
            success: false,
            message: response.data['Message'] ?? 'Error desconocido',
          );
        }
      } else {
        return ResponseHandler(
          success: false,
          message: 'Error al actualizar maestro',
        );
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data['Message'] != null) {
        final errorMessage = e.response!.data['Message'];
        log('Error al actualizar: $errorMessage');
        return ResponseHandler(
          success: false,
          message: 'Error al actualizar maestro: $errorMessage',
        );
      } else {
        return ResponseHandler.handleFailure<bool>(e);
      }
    }
  }
}
