import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:sgem/shared/utils/model_converter.dart';

part 'rol.g.dart';

@immutable
@JsonSerializable()
class Rol extends Equatable {
  Rol({
    required this.name,
    this.userRegister = '',
    this.userUpdate = '',
    DateTime? dateRegister,
    DateTime? dateUpdate,
    this.key = -1,
    this.actived = false,
  })  : dateRegister = dateRegister ?? DateTime.now(),
        dateUpdate = dateUpdate ?? DateTime.now();

  factory Rol.fromJson(Map<String, dynamic> json) => _$RolFromJson(json);

  @JsonKey(name: 'Key')
  final int key;

  @JsonKey(name: 'Nombre')
  final String name;

  @JsonKey(name: 'UsuarioRegistro')
  final String userRegister;

  @JsonKey(name: 'FechaRegistro')
  @ajaxDateConverter
  final DateTime dateRegister;

  @JsonKey(name: 'UsuarioModificacion')
  final String userUpdate;

  @JsonKey(name: 'FechaModificacion')
  @ajaxDateConverter
  final DateTime dateUpdate;

  @JsonKey(name: 'Estado')
  @intBoolConverter
  final bool actived;

  Map<String, dynamic> toJson() => _$RolToJson(this);

  @override
  List<Object?> get props => [
        key,
        name,
        userRegister,
        dateRegister,
        dateUpdate,
        userUpdate,
        actived,
      ];
}
