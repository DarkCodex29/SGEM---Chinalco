import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sgem/shared/modules/option.value.dart';
import 'package:sgem/shared/utils/model_converter.dart';

part 'maestro.g.dart';

@JsonSerializable(fieldRename: FieldRename.pascal)
class Maestro extends OptionValue with EquatableMixin {
  const Maestro({
    required super.key,
    required super.nombre,
    required this.activo,
    this.descripcion,
    this.usuarioRegistro,
    this.usuarioModifica,
    this.fechaRegistro,
    this.fechaModifica,
    this.maestroRelacion,
  });

  factory Maestro.fromJson(Map<String, dynamic> json) =>
      _$MaestroFromJson(json);

  final String? descripcion;

  final String? usuarioRegistro;
  final String? usuarioModifica;

  @ajaxDateConverter
  final DateTime? fechaRegistro;

  @ajaxDateConverter
  final DateTime? fechaModifica;

  @charBoolConverter
  final bool activo;

  final OptionValue? maestroRelacion;

  Map<String, dynamic> toJson() => _$MaestroToJson(this);

  @override
  List<Object?> get props => [
        key,
        nombre,
        descripcion,
        usuarioRegistro,
        usuarioModifica,
        fechaRegistro,
        fechaModifica,
        activo,
        maestroRelacion,
      ];
}
