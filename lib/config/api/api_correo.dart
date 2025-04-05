import 'dart:convert';

import 'package:sgem/config/api/api_chinalco.dart';
import 'package:sgem/config/api/response.handler.dart';
import 'package:sgem/shared/modules/mail.dart';

class MailService extends ApiChinalco {
  MailService();

  @override
  String get endpoint => 'Correo';
  Future<ResponseHandler<bool>> sendMail(Mail mail) async {
    try {
      print(jsonEncode(mail.toJson()..remove('Adjuntos')));
      await client.post<dynamic>(
        '/EnviarCorreo',
        data: mail.toJson(),
      );

      return ResponseHandler.handleSuccess(true);
    } catch (error, stackTrace) {
      return ResponseHandler.fromError(
        error,
        stackTrace,
        'Error al regisrar el correo',
      );
    }
  }
}
