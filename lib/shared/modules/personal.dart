import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:sgem/shared/modules/option.value.dart';
import 'package:sgem/shared/utils/functions/parse.date.time.dart';
import 'package:sgem/shared/widgets/dropDown/custom.dropdown.global.dart';

class Personal implements DropdownElement {
  Personal({
    this.key,
    this.tipoPersona,
    this.inPersonalOrigen,
    this.fechaIngresoMina,
    this.licenciaConducir,
    this.operacionMina,
    this.zonaPlataforma,
    this.restricciones,
    this.usuarioRegistro,
    this.usuarioModifica,
    this.codigoMcp,
    this.nombreCompleto,
    this.cargo,
    this.numeroDocumento,
    this.guardia,
    this.estado,
    this.eliminado,
    this.motivoElimina,
    this.usuarioElimina,
    this.apellidoPaterno,
    this.apellidoMaterno,
    this.primerNombre,
    this.segundoNombre,
    this.fechaIngreso,
    this.licenciaCategoria,
    this.fechaRevalidacion,
    this.gerencia,
    this.area,
    this.correo,
  });

  factory Personal.fromJson(Map<String, dynamic> json) {
    log('Key: ${json['Key'] ?? 0}');
    log('Tipo Persona: ${json['TipoPersona'] ?? ""}');
    return Personal(
      key: json['Key'] ?? 0,
      tipoPersona: json['TipoPersona'] ?? "",
      inPersonalOrigen: json['InPersonalOrigen'] ?? 0,
      fechaIngresoMina: json['FechaIngresoMina'] != null
          ? FnDateTime.fromDotNetDate(json['FechaIngresoMina'])
          : null,
      licenciaConducir: json['LicenciaConducir'] ?? "",
      operacionMina: json['OperacionMina'] ?? "S",
      zonaPlataforma: json['ZonaPlataforma'] ?? "S",
      restricciones: json['Restricciones'] ?? "",
      usuarioRegistro: json['UsuarioRegistro'] ?? "",
      usuarioModifica: json['UsuarioModifica'] ?? "",
      codigoMcp: json['CodigoMcp'] ?? "",
      nombreCompleto: json['NombreCompleto'] ?? "",
      cargo: OptionValue.fromJson(json['Cargo'] ?? {}),
      numeroDocumento: json['NumeroDocumento'] ?? "",
      guardia: OptionValue.fromJson(json['Guardia'] ?? {}),
      estado: OptionValue.fromJson(json['Estado'] ?? {}),
      eliminado: json['Eliminado'] ?? "S",
      motivoElimina: json['MotivoElimina'] ?? "",
      usuarioElimina: json['UsuarioElimina'] ?? "",
      apellidoPaterno: json['ApellidoPaterno'] ?? "",
      apellidoMaterno: json['ApellidoMaterno'] ?? "",
      primerNombre: json['PrimerNombre'] ?? "",
      segundoNombre: json['SegundoNombre'] ?? "",
      fechaIngreso: json['FechaIngreso'] != null
          ? FnDateTime.fromDotNetDate(json['FechaIngreso'])
          : null,
      //licenciaCategoria: json['LicenciaCategoria'] ?? "",

      //licenciaCategoria: OptionValue.fromJson(json['LicenciaCategoria'] ?? {}),
      // licenciaVencimiento: json['LicenciaVencimiento'] != null
      //     ? FnDateTime.fromDotNetDate(json['LicenciaVencimiento']),

      licenciaCategoria: OptionValue.fromJson(json['LicenciaCategoria'] ?? {}),
      //licenciaCategoria: licenciaCategoria,
      fechaRevalidacion: json['FechaRevalidacion'] != null
          ? FnDateTime.fromDotNetDate(json['FechaRevalidacion'])
          : null,
      gerencia: json['Gerencia'] ?? "",
      area: json['Area'] ?? "",
      correo: json['Correo'] ?? "",
    );
  }

  int? key;
  String? tipoPersona;
  int? inPersonalOrigen;
  DateTime? fechaIngresoMina;
  String? licenciaConducir;
  String? operacionMina;
  String? zonaPlataforma;
  String? restricciones;
  String? usuarioRegistro;
  String? usuarioModifica;
  String? codigoMcp;
  String? nombreCompleto;
  OptionValue? cargo;
  String? numeroDocumento;
  OptionValue? guardia;
  OptionValue? estado;
  String? eliminado;
  String? motivoElimina;
  String? usuarioElimina;
  String? apellidoPaterno;
  String? apellidoMaterno;
  String? primerNombre;
  String? segundoNombre;
  DateTime? fechaIngreso;
  //String? licenciaCategoria = ' ';
  OptionValue? licenciaCategoria;
  DateTime? fechaRevalidacion;
  String? gerencia;
  String? area;
  String? correo;

  @override
  String get value => nombreCompleto!;
  @override
  int get id => key!;

  Map<String, dynamic> toJson() {
    return {
      'Key': key,
      'TipoPersona': tipoPersona,
      'InPersonalOrigen': inPersonalOrigen,
      'FechaIngresoMina': fechaIngresoMina != null
          ? FnDateTime.toDotNetDate(fechaIngresoMina!)
          : null,
      'LicenciaConducir': licenciaConducir,
      'OperacionMina': operacionMina,
      'ZonaPlataforma': zonaPlataforma,
      'Restricciones': restricciones,
      'UsuarioRegistro': usuarioRegistro,
      'UsuarioModifica': usuarioModifica,
      'CodigoMcp': codigoMcp,
      'NombreCompleto': nombreCompleto,
      'Cargo': cargo?.toJson(),
      'NumeroDocumento': numeroDocumento,
      'Guardia': guardia!.toJson(),
      'Estado': estado!.toJson(),
      'Eliminado': eliminado,
      'MotivoElimina': motivoElimina,
      'UsuarioElimina': usuarioElimina,
      'ApellidoPaterno': apellidoPaterno,
      'ApellidoMaterno': apellidoMaterno,
      'PrimerNombre': primerNombre,
      'SegundoNombre': segundoNombre,
      'FechaIngreso':
          fechaIngreso != null ? FnDateTime.toDotNetDate(fechaIngreso!) : null,
      //'LicenciaCategoria': licenciaCategoria,
      'LicenciaCategoria': licenciaCategoria!.toJson(),
      'FechaRevalidacion': fechaRevalidacion != null
          ? FnDateTime.toDotNetDate(fechaRevalidacion!)
          : null,
      'Gerencia': gerencia,
      'Area': area,
      'Correo': correo,
    };
  }

  @override
  String toString() {
    return '''
    Personal{key: $key,
     tipoPersona: $tipoPersona,
     inPersonalOrigen: $inPersonalOrigen,
     fechaIngresoMina: $fechaIngresoMina,
     licenciaConducir: $licenciaConducir,
     operacionMina: $operacionMina,
     zonaPlataforma: $zonaPlataforma,
     restricciones: $restricciones,
     usuarioRegistro: $usuarioRegistro,
     usuarioModifica: $usuarioModifica,
     codigoMcp: $codigoMcp,
     nombreCompleto: $nombreCompleto,
     cargo: $cargo,
     numeroDocumento: $numeroDocumento,
     guardia: $guardia,
     estado: $estado,
     eliminado: $eliminado,
     motivoElimina: $motivoElimina,
     usuarioElimina: $usuarioElimina,
     apellidoPaterno: $apellidoPaterno,
     apellidoMaterno: $apellidoMaterno,
     primerNombre: $primerNombre,
     segundoNombre: $segundoNombre,
     fechaIngreso: $fechaIngreso,
     licenciaCategoria: $licenciaCategoria,
     fechaRevalidacion: $fechaRevalidacion,
     gerencia: $gerencia,
     area: $area,
     correo: $correo}
    ''';
  }
}
