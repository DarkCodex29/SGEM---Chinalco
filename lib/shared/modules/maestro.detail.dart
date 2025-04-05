import 'package:sgem/shared/modules/maestro.dart';
import 'package:sgem/shared/modules/option.value.dart';
import 'package:sgem/shared/widgets/dropDown/custom.dropdown.global.dart';

class MaestroDetalle implements DropdownElement {
  MaestroDetalle({
    required this.key,
    required this.maestro,
    required this.valor,
    required this.fechaRegistro,
    required this.activo,
    this.usuarioRegistro,
    this.usuarioModifica,
    this.fechaModifica,
    this.descripcion,
    this.detalleRelacion,
  });

  factory MaestroDetalle.fromJson(Map<String, dynamic> json) {
    return MaestroDetalle(
      key: (json['Key'] as int?) ?? 0,
      maestro: MaestroBasico.fromJson(json['Maestro'] as Map<String, dynamic>),
      valor: (json['Valor'] as String?) ?? 'Desconocido',
      usuarioRegistro: (json['UsuarioRegistro'] as String?) ?? 'Desconocido',
      descripcion: json['Descripcion'] as String?,
      fechaRegistro:
          MaestroCompleto.parseDateNullable(json['FechaRegistro'] as String?),
      usuarioModifica: (json['UsuarioModifica'] as String?)?.isNotEmpty ?? false
          ? (json['UsuarioModifica'] as String?)
          : 'Desconocido',
      fechaModifica: json['FechaModifica'] != null
          ? MaestroCompleto.parseDate((json['FechaModifica'] as String?) ?? '')
          : null,
      activo: (json['Activo'] as String?) ?? 'N',
      detalleRelacion: json['DetalleRelacion'] != null
          ? OptionValue.fromJson(
              json['DetalleRelacion'] as Map<String, dynamic>)
          : null,
    );
  }

  int? key;
  MaestroBasico maestro;
  String? valor;
  String? usuarioRegistro;
  String? descripcion;
  DateTime? fechaRegistro;
  String? usuarioModifica;
  DateTime? fechaModifica;
  String? activo;
  OptionValue? detalleRelacion;

  @override
  String get value => valor ?? 'none';

  @override
  int? get id => key;

  Map<String, dynamic> toJson() {
    return {
      'Key': key,
      'Maestro': maestro.toJson(),
      'Valor': valor,
      'Descripcion': descripcion ?? '',
      'UsuarioRegistro': usuarioRegistro,
      'FechaRegistro': MaestroCompleto.toJsonDateNullable(fechaRegistro),
      'UsuarioModifica': usuarioModifica,
      'FechaModifica': MaestroCompleto.toJsonDateNullable(fechaModifica),
      'Activo': activo,
      'DetalleRelacion': detalleRelacion?.toJson(),
    };
  }

  @override
  String toString() {
    return 'MaestroDetalle(key: $key, maestro: $maestro, valor: $valor, usuarioRegistro: $usuarioRegistro, descripcion: $descripcion, fechaRegistro: $fechaRegistro, usuarioModifica: $usuarioModifica, fechaModifica: $fechaModifica, activo: $activo, detalleRelacion: $detalleRelacion)';
  }
}
