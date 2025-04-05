// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'maestro_detalle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Detalle _$DetalleFromJson(Map<String, dynamic> json) => Detalle(
      maestro: OptionValue.fromJson(json['Maestro'] as Map<String, dynamic>),
      nombre: json['Valor'] as String,
      activo: charBoolConverter.fromJson(json['Activo'] as String),
      usuarioRegistro: json['UsuarioRegistro'] as String?,
      usuarioModifica: json['UsuarioModifica'] as String?,
      fechaRegistro: _$JsonConverterFromJson<String, DateTime>(
          json['FechaRegistro'], ajaxDateConverter.fromJson),
      fechaModifica: _$JsonConverterFromJson<String, DateTime>(
          json['FechaModifica'], ajaxDateConverter.fromJson),
      descripcion: json['Descripcion'] as String?,
      detalleRelacion: json['DetalleRelacion'] == null
          ? null
          : OptionValue.fromJson(
              json['DetalleRelacion'] as Map<String, dynamic>),
      valorString: json['ValorString'] as String?,
      valorInt: (json['ValorInt'] as num?)?.toInt(),
      valorChar: json['ValorChar'] as String?,
      valorStringAdicional: json['ValorStringAdicional'] as String?,
      key: (json['Key'] as num?)?.toInt() ?? -1,
    );

Map<String, dynamic> _$DetalleToJson(Detalle instance) => <String, dynamic>{
      'Key': instance.key,
      'Maestro': instance.maestro,
      'Valor': instance.nombre,
      'Descripcion': instance.descripcion,
      'ValorString': instance.valorString,
      'ValorInt': instance.valorInt,
      'ValorChar': instance.valorChar,
      'ValorStringAdicional': instance.valorStringAdicional,
      'UsuarioRegistro': instance.usuarioRegistro,
      'UsuarioModifica': instance.usuarioModifica,
      'FechaRegistro': _$JsonConverterToJson<String, DateTime>(
          instance.fechaRegistro, ajaxDateConverter.toJson),
      'FechaModifica': _$JsonConverterToJson<String, DateTime>(
          instance.fechaModifica, ajaxDateConverter.toJson),
      'Activo': charBoolConverter.toJson(instance.activo),
      'DetalleRelacion': instance.detalleRelacion,
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
