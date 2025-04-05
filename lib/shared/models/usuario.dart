import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sgem/shared/modules/option.value.dart';
import 'package:sgem/shared/utils/model_converter.dart';

part 'usuario.g.dart';

@JsonSerializable()
class Usuario extends Equatable {
  Usuario({
    required this.rol,
    required this.personal,
    required this.state,
    this.fullName = '',
    this.email = '',
    this.key = -1,
    this.userModify = '',
    this.userRegister = '',
    DateTime? dateRegister,
    DateTime? dateModify,
  })  : dateRegister = dateRegister ?? DateTime.now(),
        dateModify = dateModify ?? DateTime.now();

  factory Usuario.fromJson(Map<String, dynamic> json) =>
      _$UsuarioFromJson(json);

  @JsonKey(name: 'Key')
  final int key;

  @JsonKey(name: 'Rol')
  final OptionValue rol;

  @JsonKey(name: 'Personal')
  final OptionValue personal;

  @JsonKey(name: 'NombreCompleto')
  final String fullName;

  @JsonKey(name: 'Correo')
  final String email;

  @JsonKey(name: 'Estado')
  @intBoolConverter
  final bool state;

  @JsonKey(name: 'UsuarioRegistro')
  final String userRegister;

  @JsonKey(name: 'UsuarioModifica')
  final String userModify;

  @JsonKey(name: 'FechaRegistro')
  @ajaxDateConverter
  final DateTime dateRegister;

  @JsonKey(name: 'FechaModifica')
  @ajaxDateConverter
  final DateTime dateModify;

  Map<String, dynamic> toJson() => _$UsuarioToJson(this);

  Usuario copyWith({
    int? key,
    int? rol,
    int? personal,
    bool? estado,
  }) {
    return Usuario(
      key: key ?? this.key,
      rol: rol != null
          ? OptionValue(key: rol, nombre: this.rol.nombre)
          : this.rol,
      personal: personal != null
          ? OptionValue(key: personal, nombre: this.personal.nombre)
          : this.personal,
      state: estado ?? this.state,
      fullName: fullName,
      email: email,
      userRegister: userRegister,
      userModify: userModify,
      dateRegister: dateRegister,
      dateModify: dateModify,
    );
  }

  List<Object?> get props => [
        key,
        rol,
        personal,
        state,
      ];
}
