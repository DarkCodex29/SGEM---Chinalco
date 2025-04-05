import 'dart:convert';

import 'package:sgem/shared/modules/option.value.dart';
import 'package:sgem/shared/utils/functions/parse.date.time.dart';

part 'entrenamiento_enum.dart';

EntrenamientoModulo entrenamientoModuloFromJson(String str) =>
    EntrenamientoModulo.fromJson(json.decode(str));

String entrenamientoModuloToJson(EntrenamientoModulo data) =>
    json.encode(data.toJson());

class EntrenamientoModulo {
  int? key;
  int? inTipoActividad;
  int? inCapacitacion;
  int? inModulo;
  OptionValue? modulo;
  String? tipoPersona;
  int? inPersona;
  int? inActividadEntrenamiento;
  int? inCategoria;
  int? inEquipo;
  OptionValue? equipo;
  int? inEntrenador;
  OptionValue? entrenador;
  int? inEmpresaCapacitadora;
  int? inCondicion;
  OptionValue? condicion;
  DateTime? fechaInicio;
  DateTime? fechaTermino;
  DateTime? fechaExamen;
  DateTime? fechaRealMonitoreo;
  DateTime? fechaProximoMonitoreo;
  int? inNotaTeorica;
  int? inNotaPractica;
  int? inTotalHoras;
  int? inHorasAcumuladas;
  int? inHorasMinestar;
  int? inEstado;
  OptionValue? estadoEntrenamiento;
  //OptionValue? estadoModulo;
  String? comentarios;
  String? eliminado;
  String? motivoEliminado;
  String? observaciones;

  EntrenamientoModulo({
    this.key,
    this.inTipoActividad,
    this.inCapacitacion,
    this.inModulo,
    this.modulo,
    this.tipoPersona,
    this.inPersona,
    this.inActividadEntrenamiento,
    this.inCategoria,
    this.inEquipo,
    this.equipo,
    this.inEntrenador,
    this.entrenador,
    this.inEmpresaCapacitadora,
    this.inCondicion,
    this.condicion,
    this.fechaInicio,
    this.fechaTermino,
    this.fechaExamen,
    this.fechaRealMonitoreo,
    this.fechaProximoMonitoreo,
    this.inNotaTeorica,
    this.inNotaPractica,
    this.inTotalHoras,
    this.inHorasAcumuladas,
    this.inHorasMinestar,
    this.inEstado,
    this.estadoEntrenamiento,
    //this.estadoModulo,
    this.comentarios,
    this.eliminado,
    this.motivoEliminado,
    this.observaciones,
  });

  void actualizarConUltimoModulo(EntrenamientoModulo ultimoModulo) {
    if (ultimoModulo.entrenador!.nombre!.isNotEmpty) {
      entrenador = ultimoModulo.entrenador;
    }
    if (ultimoModulo.estadoEntrenamiento!.nombre!.isNotEmpty) {
      //estadoEntrenamiento = ultimoModulo.estadoEntrenamiento;
    }
    inNotaTeorica = ultimoModulo.inNotaTeorica;
    inNotaPractica = ultimoModulo.inNotaPractica;
    inHorasAcumuladas = ultimoModulo.inHorasAcumuladas;
    inTotalHoras = ultimoModulo.inTotalHoras;
    modulo = ultimoModulo.modulo;
  }

  factory EntrenamientoModulo.fromJson(Map<String, dynamic> json) =>
      EntrenamientoModulo(
        key: json["Key"] ?? 0,
        inTipoActividad: json["InTipoActividad"] ?? 0,
        inCapacitacion: json["InCapacitacion"] ?? 0,
        inModulo: json["InModulo"] ?? 0,
        modulo: OptionValue.fromJson(json["Modulo"] ?? {}),
        tipoPersona: json["TipoPersona"] ?? '',
        inPersona: json["InPersona"] ?? 0,
        inActividadEntrenamiento: json["InActividadEntrenamiento"] ?? 0,
        inCategoria: json["InCategoria"] ?? 0,
        inEquipo: json["InEquipo"] ?? 0,
        equipo: OptionValue.fromJson(json["Equipo"] ?? {}),
        inEntrenador: json["InEntrenador"] ?? 0,
        entrenador: OptionValue.fromJson(json["Entrenador"] ?? {}),
        inEmpresaCapacitadora: json["InEmpresaCapacitadora"] ?? 0,
        inCondicion: json["InCondicion"] ?? 0,
        condicion: OptionValue.fromJson(json["Condicion"] ?? {}),
        fechaInicio: json["FechaInicio"] != null
            ? FnDateTime.fromDotNetDate(json["FechaInicio"])
            : null,
        fechaTermino: json["FechaTermino"] != null
            ? FnDateTime.fromDotNetDate(json["FechaTermino"])
            : null,
        fechaExamen: json["FechaExamen"] != null
            ? FnDateTime.fromDotNetDate(json["FechaExamen"])
            : null,
        fechaRealMonitoreo: json["FechaRealMonitoreo"] != null
            ? FnDateTime.fromDotNetDate(json["FechaRealMonitoreo"])
            : null,
        fechaProximoMonitoreo: json["FechaProximoMonitoreo"] != null
            ? FnDateTime.fromDotNetDate(json["FechaProximoMonitoreo"])
            : null,
        inNotaTeorica: json["InNotaTeorica"],
        inNotaPractica: json["InNotaPractica"],
        inTotalHoras: json["InTotalHoras"] ?? 0,
        inHorasAcumuladas: json["InHorasAcumuladas"] ?? 0,
        inHorasMinestar: json["InHorasMinestar"] ?? 0,
        inEstado: json["InEstado"] ?? 0,
        estadoEntrenamiento:
            OptionValue.fromJson(json["EstadoEntrenamiento"] ?? {}),
        // estadoModulo:
        // OptionValue.fromJson(json["EstadoModulo"] ?? {}),
        comentarios: json["Comentarios"] ?? '',
        eliminado: json["Eliminado"] ?? '',
        motivoEliminado: json["MotivoEliminado"] ?? '',
        observaciones: json["ObservacionesEntrenamiento"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "Key": key,
        "InTipoActividad": inTipoActividad,
        "InCapacitacion": inCapacitacion,
        "InModulo": inModulo,
        "Modulo": modulo?.toJson(),
        "TipoPersona": tipoPersona,
        "InPersona": inPersona,
        "InActividadEntrenamiento": inActividadEntrenamiento,
        "InCategoria": inCategoria,
        "InEquipo": inEquipo,
        "Equipo": equipo!.toJson(),
        "InEntrenador": inEntrenador,
        "Entrenador": entrenador!.toJson(),
        "InEmpresaCapacitadora": inEmpresaCapacitadora,
        "InCondicion": inCondicion,
        "Condicion": condicion!.toJson(),
        "FechaInicio":
            fechaInicio != null ? FnDateTime.toDotNetDate(fechaInicio!) : null,
        "FechaTermino": fechaTermino != null
            ? FnDateTime.toDotNetDate(fechaTermino!)
            : null,
        "FechaExamen":
            fechaExamen != null ? FnDateTime.toDotNetDate(fechaExamen!) : null,
        "FechaRealMonitoreo": fechaRealMonitoreo != null
            ? FnDateTime.toDotNetDate(fechaRealMonitoreo!)
            : null,
        "FechaProximoMonitoreo": fechaProximoMonitoreo != null
            ? FnDateTime.toDotNetDate(fechaProximoMonitoreo!)
            : null,
        "InNotaTeorica": inNotaTeorica,
        "InNotaPractica": inNotaPractica,
        "InTotalHoras": inTotalHoras,
        "InHorasAcumuladas": inHorasAcumuladas,
        "InHorasMinestar": inHorasMinestar,
        "InEstado": inEstado,
        "EstadoEntrenamiento": estadoEntrenamiento!.toJson(),
        //"EstadoModulo": estadoModulo!.toJson(),
        "Comentarios": comentarios,
        "Eliminado": eliminado,
        "MotivoEliminado": motivoEliminado,
        "ObservacionesEntrenamiento": observaciones,
      };

  bool? get isAuthorized =>
      estadoEntrenamiento?.key == TrainingStatus.authorized.key;
  bool? get isParaliced =>
      estadoEntrenamiento?.key == TrainingStatus.paraliced.key;
  bool? get isTraining =>
      estadoEntrenamiento?.key == TrainingStatus.training.key;
  bool? get isInProgress =>
      estadoEntrenamiento?.key == ActivityStatus.inProgress.key;
  bool? get isCompleted =>
      estadoEntrenamiento?.key == ActivityStatus.completed.key;

  String toString() {
    return '''
    EntrenamientoModulo(
        key: $key,
        inTipoActividad: $inTipoActividad,
        inCapacitacion: $inCapacitacion,
        inModulo: $inModulo,
        modulo: $modulo,
        tipoPersona: $tipoPersona,
        inPersona: $inPersona,
        inActividadEntrenamiento: $inActividadEntrenamiento,
        inCategoria: $inCategoria,
        inEquipo: $inEquipo,
        equipo: $equipo,
        inEntrenador: $inEntrenador,
        entrenador: $entrenador,
        inEmpresaCapacitadora: $inEmpresaCapacitadora,
        inCondicion: $inCondicion,
        condicion: $condicion,
        fechaInicio: $fechaInicio,
        fechaTermino: $fechaTermino,
        fechaExamen: $fechaExamen,
        fechaRealMonitoreo: $fechaRealMonitoreo,
        fechaProximoMonitoreo: $fechaProximoMonitoreo,
        inNotaTeorica: $inNotaTeorica,
        inNotaPractica: $inNotaPractica,
        inTotalHoras: $inTotalHoras,
        inHorasAcumuladas: $inHorasAcumuladas,
        inHorasMinestar: $inHorasMinestar,
        inEstado: $inEstado,
        estadoEntrenamiento: $estadoEntrenamiento,
        comentarios: $comentarios,
        eliminado: $eliminado,
        motivoEliminado: $motivoEliminado,
        observaciones: $observaciones,
    )
    ''';
  }
}

enum TrainingStatus {
  training._(11),
  paraliced._(12),
  authorized._(13);

  const TrainingStatus._(this.key);

  final int key;
}

enum ActivityStatus {
  inProgress._(27),
  completed._(28);

  const ActivityStatus._(this.key);

  final int key;
}
