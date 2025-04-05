import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'puesto.g.dart';

Puesto puestoFromJson(String str) => Puesto.fromJson(json.decode(str));

String puestoToJson(Puesto data) => json.encode(data.toJson());

@JsonSerializable()
class Puesto extends Equatable {
  Puesto({this.key = -1, this.nombre = ''});

  factory Puesto.fromJson(Map<String, dynamic> json) => _$PuestoFromJson(json);
  @JsonKey(name: 'Key')
  final int key;

  @JsonKey(name: 'Nombre')
  final String nombre;

  Map<String, dynamic> toJson() => _$PuestoToJson(this);

  List<Object?> get props => [
        key,
        nombre,
      ];
}
