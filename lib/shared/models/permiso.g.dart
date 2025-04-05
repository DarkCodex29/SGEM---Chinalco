// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'permiso.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Permiso _$PermisoFromJson(Map<String, dynamic> json) => Permiso(
      module:
          OptionValue.fromJson(json['ModuloPermiso'] as Map<String, dynamic>),
      code: json['Codigo'] as String,
      userRegister: json['UsuarioRegistro'] as String? ?? '',
      userUpdate: json['UsuarioModificacion'] as String? ?? '',
      key: (json['Key'] as num?)?.toInt() ?? -1,
      dateRegister: _$JsonConverterFromJson<String, DateTime>(
          json['FechaRegistro'], ajaxDateConverter.fromJson),
      dateUpdate: _$JsonConverterFromJson<String, DateTime>(
          json['FechaModificacion'], ajaxDateConverter.fromJson),
      actived: json['Estado'] == null
          ? false
          : intBoolConverter.fromJson((json['Estado'] as num).toInt()),
    );

Map<String, dynamic> _$PermisoToJson(Permiso instance) => <String, dynamic>{
      'Key': instance.key,
      'Codigo': instance.code,
      'UsuarioRegistro': instance.userRegister,
      'FechaRegistro': ajaxDateConverter.toJson(instance.dateRegister),
      'UsuarioModificacion': instance.userUpdate,
      'FechaModificacion': ajaxDateConverter.toJson(instance.dateUpdate),
      'Estado': intBoolConverter.toJson(instance.actived),
      'ModuloPermiso': instance.module,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);
