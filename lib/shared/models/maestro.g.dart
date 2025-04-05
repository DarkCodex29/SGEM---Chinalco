// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'maestro.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Maestro _$MaestroFromJson(Map<String, dynamic> json) => Maestro(
      key: (json['Key'] as num?)?.toInt(),
      nombre: json['Nombre'] as String?,
      activo: charBoolConverter.fromJson(json['Activo'] as String),
      descripcion: json['Descripcion'] as String?,
      usuarioRegistro: json['UsuarioRegistro'] as String?,
      usuarioModifica: json['UsuarioModifica'] as String?,
      fechaRegistro: _$JsonConverterFromJson<String, DateTime>(
          json['FechaRegistro'], ajaxDateConverter.fromJson),
      fechaModifica: _$JsonConverterFromJson<String, DateTime>(
          json['FechaModifica'], ajaxDateConverter.fromJson),
      maestroRelacion: json['MaestroRelacion'] == null
          ? null
          : OptionValue.fromJson(
              json['MaestroRelacion'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MaestroToJson(Maestro instance) => <String, dynamic>{
      'Key': instance.key,
      'Nombre': instance.nombre,
      'Descripcion': instance.descripcion,
      'UsuarioRegistro': instance.usuarioRegistro,
      'UsuarioModifica': instance.usuarioModifica,
      'FechaRegistro': _$JsonConverterToJson<String, DateTime>(
          instance.fechaRegistro, ajaxDateConverter.toJson),
      'FechaModifica': _$JsonConverterToJson<String, DateTime>(
          instance.fechaModifica, ajaxDateConverter.toJson),
      'Activo': charBoolConverter.toJson(instance.activo),
      'MaestroRelacion': instance.maestroRelacion,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);
