// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usuario.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Usuario _$UsuarioFromJson(Map<String, dynamic> json) => Usuario(
      rol: OptionValue.fromJson(json['Rol'] as Map<String, dynamic>),
      personal: OptionValue.fromJson(json['Personal'] as Map<String, dynamic>),
      state: intBoolConverter.fromJson((json['Estado'] as num).toInt()),
      fullName: json['NombreCompleto'] as String? ?? '',
      email: json['Correo'] as String? ?? '',
      key: (json['Key'] as num?)?.toInt() ?? -1,
      userModify: json['UsuarioModifica'] as String? ?? '',
      userRegister: json['UsuarioRegistro'] as String? ?? '',
      dateRegister: _$JsonConverterFromJson<String, DateTime>(
          json['FechaRegistro'], ajaxDateConverter.fromJson),
      dateModify: _$JsonConverterFromJson<String, DateTime>(
          json['FechaModifica'], ajaxDateConverter.fromJson),
    );

Map<String, dynamic> _$UsuarioToJson(Usuario instance) => <String, dynamic>{
      'Key': instance.key,
      'Rol': instance.rol,
      'Personal': instance.personal,
      'NombreCompleto': instance.fullName,
      'Correo': instance.email,
      'Estado': intBoolConverter.toJson(instance.state),
      'UsuarioRegistro': instance.userRegister,
      'UsuarioModifica': instance.userModify,
      'FechaRegistro': ajaxDateConverter.toJson(instance.dateRegister),
      'FechaModifica': ajaxDateConverter.toJson(instance.dateModify),
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);
