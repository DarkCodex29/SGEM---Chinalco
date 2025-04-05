import 'package:sgem/shared/modules/option.value.dart';
import 'package:sgem/shared/widgets/dropDown/custom.dropdown.global.dart';

class Fecha implements DropdownElement {
  Fecha({
    required this.key,
    required this.nombre,
    required this.guardia,
    required this.fechaInicio,
    required this.fechaFin,
    required this.usuarioModifica,
    required this.fechaRegistro,
    required this.activo,
  });

  factory Fecha.fromJson(Map<String, dynamic> json) {
    return Fecha(
      key: (json['Key'] as int?) ?? 0,
      nombre: (json['Nombre'] as String?) ?? 'Desconocido',
      guardia: OptionValue.fromJson(json['Guardia'] as Map<String, dynamic>),
      fechaInicio: DateTime.parse(json['FechaInicio'] as String),
      fechaFin: DateTime.parse(json['FechaFin'] as String),
      usuarioModifica: (json['UsuarioModifica'] as String?) ?? 'Desconocido',
      fechaRegistro: DateTime.parse(json['FechaModifica'] as String),
      activo: (json['Estado'] as int?) == 1,
    );
  }

  int? key;
  String nombre;
  OptionValue guardia;
  DateTime fechaInicio;
  DateTime fechaFin;
  String usuarioModifica;
  DateTime fechaRegistro;
  bool activo;

  @override
  String get value => nombre;

  @override
  int? get id => key;

  Map<String, dynamic> toJson() {
    return {
      'Key': key,
      'Nombre': nombre,
      'Guardia': guardia.toJson(),
      'FechaInicio': fechaInicio.toIso8601String(),
      'FechaFin': fechaFin.toIso8601String(),
      'UsuarioModifica': usuarioModifica,
      'FechaModifica': fechaRegistro.toIso8601String(),
      'Estado': activo ? 1 : 0,
    };
  }

  @override
  String toString() {
    return 'FechaDetalle(key: $key, nombre: $nombre, guardia: $guardia, fechaInicio: $fechaInicio, fechaFin: $fechaFin, usuarioModifica: $usuarioModifica, fechaRegistro: $fechaRegistro, activo: $activo)';
  }
}
