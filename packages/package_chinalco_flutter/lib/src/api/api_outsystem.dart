import 'dart:convert';
import 'dart:developer';

import 'package:package_chinalco_flutter/src/constants/const_config.dart';
import 'package:package_chinalco_flutter/src/models/entidad_sesion.dart';
import 'package:http/http.dart' as http;

class McpApiAuth {
  static Future<McpEntidadSesion?> getSesion({
    required String pstrToken,
    bool isDev = false,
  }) async {
    McpEntidadSesion? objSesion;

    try {
      String urlBase =
          isDev ? McpConstConfigFile.apiUrlDev : McpConstConfigFile.apiUrlPrd;

      final response = await http.post(
        Uri.parse("${urlBase}wFluterAPI/api/WASSOSesion/buscarXToken"),
        headers: {
          "API_KEY": McpConstConfigFile.apiAuthXTokenWFlutter,
          "Content-Type": "application/json; charset=UTF-8",
        },
        body: json.encode({"vcToken": pstrToken}),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body.isEmpty) {
          log("Token no valido");
          return null;
        }

        objSesion = McpEntidadSesion.fromMap(body[0]);
      } else {
        log("Error con codigo : ${response.statusCode}");
      }
    } catch (e) {
      log(e.toString());
    }

    return objSesion;
  }
}
