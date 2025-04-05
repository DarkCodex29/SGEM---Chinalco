// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'puesto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Puesto _$PuestoFromJson(Map<String, dynamic> json) => Puesto(
      key: (json['Key'] as num?)?.toInt() ?? -1,
      nombre: json['Nombre'] as String? ?? '',
    );

Map<String, dynamic> _$PuestoToJson(Puesto instance) => <String, dynamic>{
      'Key': instance.key,
      'Nombre': instance.nombre,
    };
