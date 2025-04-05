import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sgem/shared/modules/option.value.dart';
import 'package:sgem/shared/utils/model_converter.dart';

part 'puestos_nivel.g.dart';

PuestosNivel puestosNivelFromJson(String str) =>
    PuestosNivel.fromJson(json.decode(str));

String puestosNivelToJson(PuestosNivel data) => json.encode(data.toJson());

@JsonSerializable()
class PuestosNivel extends Equatable {
  PuestosNivel({
    required this.nivel,
    required this.puesto,
    required this.activo,
    this.key = -1,
    this.usuarioModifica = '',
    this.userRegister = '',
    DateTime? fechaRegistro,
    DateTime? dateRegister,
    this.registro = '',
  }) : fechaRegistro = fechaRegistro ?? DateTime.now(),
        dateRegister = dateRegister ?? DateTime.now();

  factory PuestosNivel.fromJson(Map<String, dynamic> json) =>
      _$PuestosNivelFromJson(json);

  @JsonKey(name: 'Key')
  final int key;

  @JsonKey(name: 'UsuarioRegistro')
  final String userRegister;

  @JsonKey(name: 'FechaRegistro')
  @ajaxDateConverter
  final DateTime dateRegister;

  @JsonKey(name: 'UsuarioModifica')
  final String usuarioModifica;

  @JsonKey(name: 'FechaModifica')
  @ajaxDateConverter
  final DateTime fechaRegistro;

  @JsonKey(name: 'Nivel')
  final OptionValue nivel;

  @JsonKey(name: 'Puesto')
  final OptionValue puesto;

  @JsonKey(name: 'Activo')
  final String activo;

  @JsonKey(name: 'Registro')
  final String registro;

  Map<String, dynamic> toJson() => _$PuestosNivelToJson(this);

  List<Object?> get props => [
        key,
        usuarioModifica,
        fechaRegistro,
        nivel,
        puesto,
        registro,
        activo,
      ];
}
