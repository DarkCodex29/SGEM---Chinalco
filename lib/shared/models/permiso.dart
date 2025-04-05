import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sgem/shared/modules/option.value.dart';
import 'package:sgem/shared/utils/model_converter.dart';

part 'permiso.g.dart';

@JsonSerializable()
class Permiso extends Equatable {
  Permiso({
    required this.module,
    required this.code,
    this.userRegister = '',
    this.userUpdate = '',
    this.key = -1,
    DateTime? dateRegister,
    DateTime? dateUpdate,
    this.actived = false,
  })  : dateRegister = dateRegister ?? DateTime.now(),
        dateUpdate = dateUpdate ?? DateTime.now();

  factory Permiso.fromJson(Map<String, dynamic> json) =>
      _$PermisoFromJson(json);

  @JsonKey(name: 'Key')
  final int key;

  @JsonKey(name: 'Codigo')
  final String code;

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

  @JsonKey(name: 'ModuloPermiso')
  final OptionValue module;

  Map<String, dynamic> toJson() => _$PermisoToJson(this);

  @override
  List<Object?> get props => [
        key,
        module,
        code,
        userRegister,
        dateRegister,
        userUpdate,
        dateUpdate,
        actived,
      ];
}
