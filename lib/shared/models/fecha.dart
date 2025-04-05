import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sgem/shared/modules/option.value.dart';
import 'package:sgem/shared/utils/functions/parse.date.time.dart';

part 'fecha.g.dart';

@JsonSerializable()
class Fecha extends Equatable {
  final int key;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final OptionValue guardia;
  final int anio;
  final DateTime fechaModificacion;
  final String usuarioModificacion;

  Fecha({
    required this.key,
    required this.fechaInicio,
    required this.fechaFin,
    required this.guardia,
    required this.anio,
    required this.fechaModificacion,
    required this.usuarioModificacion,
  });

  factory Fecha.fromJson(Map<String, dynamic> json) {
    return Fecha(
      key: json['Key'],
      fechaInicio: FnDateTime.fromDotNetDate(
          json["FechaInicio"]), // == null ? null : json['FechaInicio'],
      fechaFin: FnDateTime.fromDotNetDate(
          json['FechaFin']), // == null ? null : json['FechaFin'],
      guardia: OptionValue.fromJson(json['Guardia']),
      anio: json['Anio'],
      fechaModificacion: FnDateTime.fromDotNetDate(
          json['FechaModifica']), // == null ? null : json['FechaModifica'],
      usuarioModificacion: json['UsuarioModifica'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Key': key,
      'FechaInicio': fechaInicio.toIso8601String(),
      'FechaFin': fechaFin.toIso8601String(),
      'Guardia': guardia.toJson(),
      'Anio': anio,
      'FechaModificacion': fechaModificacion.toIso8601String(),
      'UsuarioModificacion': usuarioModificacion,
    };
  }

  @override
  // TODO: implement props
  List<Object?> get props => [
        key,
        fechaInicio,
        fechaFin,
        guardia,
        anio,
        fechaModificacion,
        usuarioModificacion,
      ];
}
