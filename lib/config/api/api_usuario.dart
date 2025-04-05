import 'package:sgem/config/api/api_chinalco.dart';
import 'package:sgem/config/api/response.handler.dart';
import 'package:sgem/shared/models/usuario.dart';

class UsuarioService extends ApiChinalco {
  UsuarioService();

  @override
  String get endpoint => 'Usuario';

  Future<ResponseHandler<bool>> registrateUsuario(Usuario usuario) async {
    try {
      await client.post<dynamic>(
        '/RegistrarUsuario',
        data: usuario.toJson(),
      );

      return ResponseHandler.handleSuccess(true);
    } catch (error, stackTrace) {
      return ResponseHandler.fromError(
        error,
        stackTrace,
        'Error al registrar el usuario',
      );
    }
  }

  Future<ResponseHandler<Usuario>> searchUsuario({
    String query = '',
  }) async {
    try {
      final response = await client.get<Map<String, dynamic>>(
        '/BuscarUsuario',
        queryParameters: <String, dynamic>{
          'query': query,
        },
      );

      return ResponseHandler(
        success: true,
        data: Usuario.fromJson(response.data!),
      );
    } catch (error, stackTrace) {
      return ResponseHandler.fromError(
        error,
        stackTrace,
        'Error al buscar el usuario',
      );
    }
  }

  Future<ResponseHandler<Usuario>> getUser({
    required String personal,
  }) async {
    try {
      print('personal: $personal');
      final response = await client.get<Map<String, dynamic>>(
        '/ObtenerUsuario',
        queryParameters: <String, dynamic>{
          'personal': personal,
        },
      );

      print('response: $response');

      return ResponseHandler(
        success: true,
        data: Usuario.fromJson(response.data!),
      );
    } catch (error, stackTrace) {
      print('error: $error');
      return ResponseHandler.fromError(
        error,
        stackTrace,
        'Error al obtener el usuario',
      );
    }
  }

  Future<ResponseHandler<List<Usuario>>> searchUsuarios({
    int? rol,
    String? name,
    String? lastName,
    String? userCode,
    int? state,
  }) async {
    try {
      final params = <String, dynamic>{
        'rol': rol,
        'nombres': name,
        'apellidos': lastName,
        'usuario': userCode,
        'estado': state,
      };

      final response = await client.get<List<dynamic>>(
        '/BuscarUsuarios',
        queryParameters: params,
      );

      return ResponseHandler.handleSuccess(
        response.data!
            .map((e) => Usuario.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } catch (error, stackTrace) {
      return ResponseHandler.fromError(
        error,
        stackTrace,
        'Error al buscar los usuarios',
      );
    }
  }

  Future<ResponseHandler<bool>> updateUsuario(Usuario usuario) async {
    try {
      await client.put<dynamic>(
        '/ActualizarUsuario',
        data: usuario.toJson(),
      );

      return ResponseHandler.handleSuccess(true);
    } catch (error, stackTrace) {
      return ResponseHandler.fromError(
        error,
        stackTrace,
        'Error al registrar el usuario',
      );
    }
  }
}
