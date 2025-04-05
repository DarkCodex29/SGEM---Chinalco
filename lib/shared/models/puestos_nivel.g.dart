// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'puestos_nivel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PuestosNivel _$PuestosNivelFromJson(Map<String, dynamic> json) => PuestosNivel(
      nivel: OptionValue.fromJson(json['Nivel'] as Map<String, dynamic>),
      puesto: OptionValue.fromJson(json['Puesto'] as Map<String, dynamic>),
      activo: json['Activo'] as String,
      key: (json['Key'] as num?)?.toInt() ?? -1,
      usuarioModifica: json['UsuarioModifica'] as String? ?? '',
      userRegister: json['UsuarioRegistro'] as String? ?? '',
      fechaRegistro: _$JsonConverterFromJson<String, DateTime>(
          json['FechaModifica'], ajaxDateConverter.fromJson),
      dateRegister: _$JsonConverterFromJson<String, DateTime>(
          json['FechaRegistro'], ajaxDateConverter.fromJson),
      registro: json['Registro'] as String? ?? '',
    );

Map<String, dynamic> _$PuestosNivelToJson(PuestosNivel instance) =>
    <String, dynamic>{
      'Key': instance.key,
      'UsuarioRegistro': instance.userRegister,
      'FechaRegistro': ajaxDateConverter.toJson(instance.dateRegister),
      'UsuarioModifica': instance.usuarioModifica,
      'FechaModifica': ajaxDateConverter.toJson(instance.fechaRegistro),
      'Nivel': instance.nivel,
      'Puesto': instance.puesto,
      'Activo': instance.activo,
      'Registro': instance.registro,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);
