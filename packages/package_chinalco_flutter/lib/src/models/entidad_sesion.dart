// To parse this JSON data, do
//
//     final entidadSesion = entidadSesionFromMap(jsonString);

import 'dart:convert';

class McpEntidadSesion {
  String inSesion;
  String inPersona;
  String vcApellidoPaterno;
  String vcApellidoMaterno;
  String vcPrimerNombre;
  String vcSegundoNombre;
  String vcCorreoInstitucional;
  String vcUsuario;
  String vcToken;
  String dtInicioValidez;
  String dtFinValidez;
  String vcCrea;
  String dtRegistro;

  McpEntidadSesion({
    this.inSesion = '',
    this.inPersona = '',
    this.vcApellidoPaterno = '',
    this.vcApellidoMaterno = '',
    this.vcPrimerNombre = '',
    this.vcSegundoNombre = '',
    this.vcCorreoInstitucional = '',
    this.vcUsuario = '',
    this.vcToken = '',
    this.dtInicioValidez = '',
    this.dtFinValidez = '',
    this.vcCrea = '',
    this.dtRegistro = '',
  });

  McpEntidadSesion copyWith({
    String? inSesion,
    String? inPersona,
    String? vcApellidoPaterno,
    String? vcApellidoMaterno,
    String? vcPrimerNombre,
    String? vcSegundoNombre,
    String? vcCorreoInstitucional,
    String? vcUsuario,
    String? vcToken,
    String? dtInicioValidez,
    String? dtFinValidez,
    String? vcCrea,
    String? dtRegistro,
  }) =>
      McpEntidadSesion(
        inSesion: inSesion ?? this.inSesion,
        inPersona: inPersona ?? this.inPersona,
        vcApellidoPaterno: vcApellidoPaterno ?? this.vcApellidoPaterno,
        vcApellidoMaterno: vcApellidoMaterno ?? this.vcApellidoMaterno,
        vcPrimerNombre: vcPrimerNombre ?? this.vcPrimerNombre,
        vcSegundoNombre: vcSegundoNombre ?? this.vcSegundoNombre,
        vcCorreoInstitucional:
            vcCorreoInstitucional ?? this.vcCorreoInstitucional,
        vcUsuario: vcUsuario ?? this.vcUsuario,
        vcToken: vcToken ?? this.vcToken,
        dtInicioValidez: dtInicioValidez ?? this.dtInicioValidez,
        dtFinValidez: dtFinValidez ?? this.dtFinValidez,
        vcCrea: vcCrea ?? this.vcCrea,
        dtRegistro: dtRegistro ?? this.dtRegistro,
      );

  factory McpEntidadSesion.fromMap(Map<String, dynamic> json) =>
      McpEntidadSesion(
        inSesion: json["inSesion"] ?? "",
        inPersona: json["inPersona"] ?? "",
        vcApellidoPaterno: json["vcApellidoPaterno"] ?? "",
        vcApellidoMaterno: json["vcApellidoMaterno"] ?? "",
        vcPrimerNombre: json["vcPrimerNombre"] ?? "",
        vcSegundoNombre: json["vcSegundoNombre"] ?? "",
        vcCorreoInstitucional: json["vcCorreoInstitucional"] ?? "",
        vcUsuario: json["vcCorreoInstitucional"] ?? ""
          ..replaceFirst(RegExp(r'@chinalco.com.pe'), ''),
        vcToken: json["vcToken"] ?? "",
        dtInicioValidez: json["dtInicioValidez"] ?? "",
        dtFinValidez: json["dtFinValidez"] ?? "",
        vcCrea: json["vcCrea"] ?? "",
        dtRegistro: json["dtRegistro"] ?? "",
      );

  Map<String, dynamic> toMap() => {
        "inSesion": inSesion,
        "inPersona": inPersona,
        "vcApellidoPaterno": vcApellidoPaterno,
        "vcApellidoMaterno": vcApellidoMaterno,
        "vcPrimerNombre": vcPrimerNombre,
        "vcSegundoNombre": vcSegundoNombre,
        "vcCorreoInstitucional": vcCorreoInstitucional,
        "vcUsuario": vcUsuario,
        "vcToken": vcToken,
        "dtInicioValidez": dtInicioValidez,
        "dtFinValidez": dtFinValidez,
        "vcCrea": vcCrea,
        "dtRegistro": dtRegistro,
      };

  factory McpEntidadSesion.fromJson(String str) =>
      McpEntidadSesion.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());
}
