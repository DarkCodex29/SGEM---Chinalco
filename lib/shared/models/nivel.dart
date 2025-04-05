import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'nivel.g.dart';

Nivel nivelFromJson(String str) => Nivel.fromJson(json.decode(str));

String nivelToJson(Nivel data) => json.encode(data.toJson());

@JsonSerializable()
class Nivel extends Equatable {
  Nivel({this.key = '', this.nombre = ''});

  factory Nivel.fromJson(Map<String, dynamic> json) => _$NivelFromJson(json);
  @JsonKey(name: 'Key')
  final String key;

  @JsonKey(name: 'Nombre')
  final String nombre;

  Map<String, dynamic> toJson() => _$NivelToJson(this);

  List<Object?> get props => [
        key,
        nombre,
      ];
}
