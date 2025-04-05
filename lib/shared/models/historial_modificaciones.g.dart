// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'historial_modificaciones.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HistorialModificaciones _$HistorialModificacionesFromJson(
        Map<String, dynamic> json) =>
    HistorialModificaciones(
      fechaRegistro:
          ajaxDateConverter.fromJson(json['FechaRegistro'] as String),
      tabla: OptionValue.fromJson(json['Tabla'] as Map<String, dynamic>),
      accion: OptionValue.fromJson(json['Accion'] as Map<String, dynamic>),
      key: (json['Key'] as num?)?.toInt() ?? -1,
      usuarioRegistro: json['UsuarioRegistro'] as String? ?? '',
      registro: json['Registro'] as String? ?? '',
    );

Map<String, dynamic> _$HistorialModificacionesToJson(
        HistorialModificaciones instance) =>
    <String, dynamic>{
      'Key': instance.key,
      'UsuarioRegistro': instance.usuarioRegistro,
      'FechaRegistro': ajaxDateConverter.toJson(instance.fechaRegistro),
      'Tabla': instance.tabla,
      'Accion': instance.accion,
      'Registro': instance.registro,
    };
