import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sgem/shared/modules/option.value.dart';
import 'package:sgem/shared/utils/model_converter.dart';

part 'maestro_detalle.g.dart';

@JsonSerializable(fieldRename: FieldRename.pascal)
class Detalle extends OptionValue with EquatableMixin {
  const Detalle({
    required this.maestro,
    required String nombre,
    required this.activo,
    this.usuarioRegistro,
    this.usuarioModifica,
    this.fechaRegistro,
    this.fechaModifica,
    this.descripcion,
    this.detalleRelacion,
    this.valorString,
    this.valorInt,
    this.valorChar,
    this.valorStringAdicional,
    int key = -1,
  })  : _key = key,
        _nombre = nombre;

  factory Detalle.fromJson(Map<String, dynamic> json) =>
      _$DetalleFromJson(json);

  final int _key;
  @override
  int get key => _key;

  final OptionValue maestro;

  final String _nombre;

  @JsonKey(name: 'Valor')
  @override
  String get nombre => _nombre;

  final String? descripcion;

  final String? valorString;
  final int? valorInt;
  final String? valorChar;
  final String? valorStringAdicional;

  final String? usuarioRegistro;
  final String? usuarioModifica;

  @ajaxDateConverter
  final DateTime? fechaRegistro;

  @ajaxDateConverter
  final DateTime? fechaModifica;

  @charBoolConverter
  final bool activo;

  final OptionValue? detalleRelacion;

  Map<String, dynamic> toJson() => _$DetalleToJson(this);

  @override
  List<Object?> get props => [
        key,
        maestro,
        nombre,
        activo,
        usuarioRegistro,
        usuarioModifica,
        fechaRegistro,
        fechaModifica,
        descripcion,
        detalleRelacion,
        valorString,
        valorInt,
        valorChar,
        valorStringAdicional,
      ];
}
