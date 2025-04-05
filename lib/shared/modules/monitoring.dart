// To parse this JSON data, do
//
//     final monitoing = monitoingFromJson(jsonString);

import 'dart:convert';

import 'package:sgem/shared/modules/option.value.dart';
import 'package:sgem/shared/utils/functions/parse.date.time.dart';

Monitoring monitoingFromJson(String str) =>
    Monitoring.fromJson(json.decode(str));

String monitoingToJson(Monitoring data) => json.encode(data.toJson());

class Monitoring {
  int? key;
  String? codigoMcp;
  String? primerNombre;
  String? segundoNombre;
  String? apellidoPaterno;
  String? apellidoMaterno;
  OptionValue? guardia;
  OptionValue? equipo;
  OptionValue? estadoEntrenamiento;
  OptionValue? entrenador;
  OptionValue? condicion;
  DateTime? fechaRealMonitoreo;
  DateTime? fechaProximoMonitoreo;
  int? totalHoras;
  int? estado;

  Monitoring({
    this.key,
    this.codigoMcp,
    this.primerNombre,
    this.segundoNombre,
    this.apellidoPaterno,
    this.apellidoMaterno,
    this.guardia,
    this.equipo,
    this.entrenador,
    this.condicion,
    this.fechaRealMonitoreo,
    this.estadoEntrenamiento,
    this.totalHoras,
    this.fechaProximoMonitoreo,
    this.estado,
  });

  factory Monitoring.fromJson(Map<String, dynamic> json) => Monitoring(
        key: json["Key"],
        codigoMcp: json["CodigoMcp"],
        primerNombre: json["PrimerNombre"],
        segundoNombre: json["SegundoNombre"],
        apellidoPaterno: json["ApellidoPaterno"],
        apellidoMaterno: json["ApellidoMaterno"],
        totalHoras: json["TotalHoras"] ?? 0,
        estado: json["Estado"] ?? 1,
        guardia: json["Guardia"] == null
            ? null
            : OptionValue.fromJson(json["Guardia"]),
        equipo: json["Equipo"] == null
            ? null
            : OptionValue.fromJson(json["Equipo"]),
        estadoEntrenamiento: json["EstadoEntrenamiento"] == null
            ? null
            : OptionValue.fromJson(json["EstadoEntrenamiento"]),
        entrenador: json["Entrenador"] == null
            ? null
            : OptionValue.fromJson(json["Entrenador"]),
        condicion: json["Condicion"] == null
            ? null
            : OptionValue.fromJson(json["Condicion"]),
        fechaRealMonitoreo: json["FechaRealMonitoreo"] == null
            ? null
            : FnDateTime.fromDotNetDate(json["FechaRealMonitoreo"]),
        fechaProximoMonitoreo: json["FechaProximoMonitoreo"] == null
            ? null
            : FnDateTime.fromDotNetDate(json["FechaProximoMonitoreo"]),
      );

  Map<String, dynamic> toJson() => {
        "Key": key,
        "CodigoMcp": codigoMcp,
        "PrimerNombre": primerNombre,
        "SegundoNombre": segundoNombre,
        "ApellidoPaterno": apellidoPaterno,
        "ApellidoMaterno": apellidoMaterno,
        "TotalHoras": totalHoras,
        "Estado": estado,
        "Guardia": guardia?.toJson(),
        "Equipo": equipo?.toJson(),
        "Entrenador": entrenador?.toJson(),
        "Condicion": condicion?.toJson(),
        "FechaRealMonitoreo": fechaRealMonitoreo,
        "FechaProximoMonitoreo": fechaProximoMonitoreo,
        "estadoEntrenamiento": estadoEntrenamiento,
      };
}
