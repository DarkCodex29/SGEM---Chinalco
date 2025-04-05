// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fecha.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Fecha _$FechaFromJson(Map<String, dynamic> json) => Fecha(
      key: (json['key'] as num).toInt(),
      fechaInicio: DateTime.parse(json['fechaInicio'] as String),
      fechaFin: DateTime.parse(json['fechaFin'] as String),
      guardia: OptionValue.fromJson(json['guardia'] as Map<String, dynamic>),
      anio: (json['anio'] as num).toInt(),
      fechaModificacion: DateTime.parse(json['fechaModificacion'] as String),
      usuarioModificacion: json['usuarioModificacion'] as String,
    );

Map<String, dynamic> _$FechaToJson(Fecha instance) => <String, dynamic>{
      'key': instance.key,
      'fechaInicio': instance.fechaInicio.toIso8601String(),
      'fechaFin': instance.fechaFin.toIso8601String(),
      'guardia': instance.guardia,
      'anio': instance.anio,
      'fechaModificacion': instance.fechaModificacion.toIso8601String(),
      'usuarioModificacion': instance.usuarioModificacion,
    };
