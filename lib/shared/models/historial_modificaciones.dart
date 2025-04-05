import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sgem/shared/modules/option.value.dart';
import 'package:sgem/shared/utils/model_converter.dart';

part 'historial_modificaciones.g.dart';

HistorialModificaciones historialFromJson(String str) =>
    HistorialModificaciones.fromJson(json.decode(str));

String historialToJson(HistorialModificaciones data) =>
    json.encode(data.toJson());

@JsonSerializable()
class HistorialModificaciones extends Equatable {
  HistorialModificaciones({
    required this.fechaRegistro,
    required this.tabla,
    required this.accion,
    this.key = -1,
    this.usuarioRegistro = '',
    this.registro = '',
  });

  factory HistorialModificaciones.fromJson(Map<String, dynamic> json) =>
      _$HistorialModificacionesFromJson(json);
  @JsonKey(name: 'Key')
  final int key;

  @JsonKey(name: 'UsuarioRegistro')
  final String usuarioRegistro;

  @JsonKey(name: 'FechaRegistro')
  @ajaxDateConverter
  final DateTime fechaRegistro;

  @JsonKey(name: 'Tabla')
  final OptionValue tabla;

  @JsonKey(name: 'Accion')
  final OptionValue accion;

  @JsonKey(name: 'Registro')
  final String registro;

  Map<String, dynamic> toJson() => _$HistorialModificacionesToJson(this);

  List<Object?> get props => [
        key,
        usuarioRegistro,
        fechaRegistro,
        tabla,
        accion,
        registro,
      ];
}
