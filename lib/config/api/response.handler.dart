import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:sgem/shared/modules/entrenamiento.modulo.dart';
import 'package:sgem/shared/modules/modulo.maestro.dart';
import 'package:sgem/shared/modules/personal.dart';

class ResponseHandler<T> {
  const ResponseHandler({
    required this.success,
    this.data,
    this.message,
  });

  factory ResponseHandler.fromDioException(
    DioException exception, [
    String? defaultMessage,
  ]) {
    var message = defaultMessage ?? exception.message;

    if (exception.type == DioExceptionType.badResponse) {
      switch (exception.response?.statusCode) {
        case 404:
          final data = exception.response?.data;
          try {
            if (data is Map<String, dynamic> && data.containsKey('Message')) {
              final dataMessage = data['Message'];
              message = (jsonDecode(data['Message'] as String) as List)
                  .map((e) =>
                      (e as Map<String, dynamic>)['Descripcion'] as String)
                  .join('\n');
            }
          } catch (e, stackTrace) {
            Logger('ResponseHandler').warning(
              'Error al mapear el mensaje de error: $data',
              e,
              stackTrace,
            );
          }
        case 500:
          Logger('ResponseHandler').severe(
            'Error interno del servidor',
            exception.error,
            exception.stackTrace,
          );
        default:
      }
    }

    Logger('ResponseHandler').warning(message);

    return ResponseHandler<T>(
      success: false,
      message: message,
    );
  }

  factory ResponseHandler.fromError(
    Object error,
    StackTrace? stackTrace, [
    String? defaultMessage,
  ]) {
    if (error is DioException) {
      return ResponseHandler.fromDioException(
        error,
        defaultMessage,
      );
    }

    final message = defaultMessage ?? error.toString();

    Logger('ResponseHandler').severe(message, error, stackTrace);

    return ResponseHandler<T>(
      success: false,
      message: message,
    );
  }

  final T? data;
  final bool success;
  final String? message;

  bool get hasData => data != null;

  static ResponseHandler<T> handleSuccess<T>(dynamic response) {
    log('Response Handler Caso 1');
    // Caso 1: Booleano
    if (response is bool) {
      log('Operación booleana exitosa');
      return ResponseHandler<T>(success: response, data: response as T);
    }

    log('Response Handler Caso 2');
    // Caso 2: Formato con 'Codigo' y 'Valor'
    if (response is Map<String, dynamic> &&
        response.containsKey('Codigo') &&
        response.containsKey('Valor')) {
      if (response['Codigo'] == 200 && response['Valor'] == 'OK') {
        log('Operación exitosa con Codigo y Valor');
        return ResponseHandler<T>(success: true, data: response as T);
      } else {
        return ResponseHandler<T>(
          success: false,
          message: response['Message'] ?? 'Error desconocido',
        );
      }
    }

    log('Response Handler Caso 3');
    // Caso 3: Lista de Maestros, Maestros Detalles o Personal
    if (response is List) {
      log('Respuesta exitosa con datos de lista');
      return ResponseHandler<T>(success: true, data: response as T);
    }
    log('Response Handler Caso: Personal');
    if (T == Personal) {
      try {
        log('Api: Mapeando personal ');
        final personal = Personal.fromJson(response);
        log('Api: Fin Mapeando personal ');
        return ResponseHandler<T>(success: true, data: personal as T);
      } catch (e) {
        log('Error al mapear la respuesta a Personal: $e');
        return ResponseHandler<T>(
          success: false,
          message: 'Error al mapear la respuesta a Personal.',
        );
      }
    }
    log('Response Handler Caso 4');
    // Caso 4: Mapa genérico
    if (response is Map<String, dynamic>) {
      log('Respuesta exitosa con datos de mapa');
      if (T == Personal) {
        try {
          log('Api: Mapeando personal ');
          final personal = Personal.fromJson(response);
          log('Api: Fin Mapeando personal ');
          return ResponseHandler<T>(success: true, data: personal as T);
        } catch (e) {
          log('Error al mapear la respuesta a Personal: $e');
          return ResponseHandler<T>(
            success: false,
            message: 'Error al mapear la respuesta a Personal.',
          );
        }
      }
      log('Caso 4: entrenamiento modulo');
      if (T == EntrenamientoModulo) {
        try {
          final entrenamientoModulo = EntrenamientoModulo.fromJson(response);
          return ResponseHandler<T>(
            success: true,
            data: entrenamientoModulo as T,
          );
        } catch (e) {
          log('Error al mapear la respuesta a EntrenamientoModulo: $e');
          return ResponseHandler<T>(
            success: false,
            message: 'Error al mapear la respuesta a EntrenamientoModulo.',
          );
        }
      }
      if (T == ModuloMaestro) {
        try {
          final moduloMaestro = ModuloMaestro.fromJson(response);
          return ResponseHandler<T>(success: true, data: moduloMaestro as T);
        } catch (e) {
          log('Error al mapear la respuesta a ModuloMaestro: $e');
          return ResponseHandler<T>(
            success: false,
            message: 'Error al mapear la respuesta a ModuloMaestro.',
          );
        }
      }

      return ResponseHandler<T>(success: true, data: response as T);
    }

    log('Response Handler Caso 5: Entrenamiento Modulo');
    if (T == EntrenamientoModulo) {
      try {
        log('Mapeando EntrenamientoModulo: $T');
        //final entrenamientoModulo = EntrenamientoModulo.fromJson(response);
        return ResponseHandler<T>(success: true, data: response as T);
      } catch (e) {
        log('Error al mapear la respuesta a EntrenamientoModulo: $e');
        return ResponseHandler<T>(
          success: false,
          message: 'Error al mapear la respuesta a EntrenamientoModulo.',
        );
      }
    }
    // Caso no esperado
    return ResponseHandler<T>(
      success: false,
      message: 'Formato de respuesta no esperado',
    );
  }

  static ResponseHandler<T> handleFailure<T>(dynamic error) {
    var errorMessage = 'Error desconocido';

    if (error?.response?.data != null) {
      if (error.response.data is Map<String, dynamic> &&
          error.response.data.containsKey('Message')) {
        errorMessage = error.response.data['Message'];
      } else {
        errorMessage = jsonEncode(error.response.data);
      }
    } else if (error?.message != null) {
      errorMessage = error.message;
    }

    log('Error: $errorMessage');
    return ResponseHandler<T>(
      success: false,
      message: errorMessage,
    );
  }

  @override
  String toString() {
    return 'ResponseHandler{success: $success, data: $data, message: $message}';
  }
}

class ErrorHandler {
  ErrorHandler(this.message);
  final String message;

  @override
  String toString() {
    return message;
  }
}
