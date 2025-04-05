// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rol.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Rol _$RolFromJson(Map<String, dynamic> json) => Rol(
      name: json['Nombre'] as String,
      userRegister: json['UsuarioRegistro'] as String? ?? '',
      userUpdate: json['UsuarioModificacion'] as String? ?? '',
      dateRegister: _$JsonConverterFromJson<String, DateTime>(
          json['FechaRegistro'], ajaxDateConverter.fromJson),
      dateUpdate: _$JsonConverterFromJson<String, DateTime>(
          json['FechaModificacion'], ajaxDateConverter.fromJson),
      key: (json['Key'] as num?)?.toInt() ?? -1,
      actived: json['Estado'] == null
          ? false
          : intBoolConverter.fromJson((json['Estado'] as num).toInt()),
    );

Map<String, dynamic> _$RolToJson(Rol instance) => <String, dynamic>{
      'Key': instance.key,
      'Nombre': instance.name,
      'UsuarioRegistro': instance.userRegister,
      'FechaRegistro': ajaxDateConverter.toJson(instance.dateRegister),
      'UsuarioModificacion': instance.userUpdate,
      'FechaModificacion': ajaxDateConverter.toJson(instance.dateUpdate),
      'Estado': intBoolConverter.toJson(instance.actived),
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);
