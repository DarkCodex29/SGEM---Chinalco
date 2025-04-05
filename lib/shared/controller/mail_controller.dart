import 'dart:convert';
import 'dart:isolate';

import 'package:get/get.dart';
import 'package:logging/logging.dart';
import 'package:sgem/config/api/api.dart';
import 'package:sgem/config/api/api_correo.dart';
import 'package:sgem/config/constants/config.dart';
import 'package:sgem/shared/models/maestro_detalle.dart';
import 'package:sgem/shared/modules/entrenamiento.modulo.dart';
import 'package:sgem/shared/modules/mail.dart';
import 'package:sgem/shared/modules/option.value.dart';
import 'package:sgem/shared/modules/personal.dart';
import 'package:sgem/shared/modules/string_value.dart';
import 'package:sgem/shared/utils/Extensions/format_extension.dart';
import 'package:sgem/shared/utils/PDFGenerators/generate.autorizacion.operar.dart';
import 'package:sgem/shared/utils/PDFGenerators/generate.certificado.dart';
import 'package:sgem/shared/utils/PDFGenerators/generate.diploma.dart';
import 'package:sgem/shared/utils/pdfFuntions/pdf.descargar.dart';
import 'package:sgem/shared/utils/pdfFuntions/pdf.functions.dart';

import '../utils/PDFGenerators/generate.personal.carnet.dart';

class MailController extends GetxController {
  MailController({
    required MailService mailService,
    required PersonalService personalService,
  })  : _mailService = mailService,
        _personalService = personalService;

  final MailService _mailService;
  final PersonalService _personalService;
  static final _logger = Logger('MailController');

  Future<void> mailNRPER(Personal personal, String guardia) async {
    try {
      final code = personal.codigoMcp ?? '';
      final dni = personal.numeroDocumento ?? '';
      final destinatariosResponse = await _personalService.getMailByRol(3);

      if (!destinatariosResponse.success) {
        throw destinatariosResponse.message ?? '';
      }

      final copiaDestinatarios = await _personalService.getMailByRol(4);
      if (!copiaDestinatarios.success) {
        throw copiaDestinatarios.message ?? '';
      }

      await _mailService.sendMail(
        Mail(
          destinatarios:
              destinatariosResponse.data!.map((e) => e.nombre!).toList(),
          copiaDestinatarios:
              copiaDestinatarios.data!.map((e) => e.nombre!).toList(),
          acronimo: 'NRPER',
          variables: {
            '@NombreCompleto':
                '${personal.primerNombre} ${personal.segundoNombre} ${personal.apellidoPaterno} ${personal.apellidoMaterno}',
            '@DNI_CodigoMCP': "$dni / $code",
            '@GerenciaArea':
                '${personal.gerencia ?? ''} / ${personal.area ?? ''}',
            '@Puesto': personal.cargo?.nombre ?? '',
            '@Guardia': guardia,
            '@URL': ConfigFile.webUrl,
          },
        ),
      );
    } catch (error, stackTrace) {
      _logger.severe('Error al enviar el correo', error, stackTrace);
    }
  }

  Future<void> mailNECOM(
    Personal personal,
    String equipo,
  ) async {
    try {
      final destinatariosResponse = await _personalService.getMailByRol(3);

      if (!destinatariosResponse.success) {
        throw destinatariosResponse.message ?? '';
      }

      final copiaDestinatarios = await _personalService.getMailByRol(4);
      if (!copiaDestinatarios.success) {
        throw copiaDestinatarios.message ?? '';
      }

      await _mailService.sendMail(
        Mail(
          destinatarios:
              destinatariosResponse.data!.map((e) => e.nombre!).toList(),
          copiaDestinatarios:
              copiaDestinatarios.data!.map((e) => e.nombre!).toList(),
          acronimo: 'NECOM',
          variables: {
            '@CodigoMCP': personal.codigoMcp ?? '',
            '@Puesto': personal.cargo?.nombre ?? '',
            '@Equipo': equipo,
            '@URL': ConfigFile.webUrl,
          },
        ),
      );
    } catch (error, stackTrace) {
      _logger.severe('Error al enviar el correo', error, stackTrace);
    }
  }

  Future<void> mailNEPER(
    EntrenamientoModulo entrenamiento, {
    required Personal personal,
  }) async {
    try {
      final destinatariosResponse = await _personalService.getMailByRol(3);

      if (!destinatariosResponse.success) {
        throw destinatariosResponse.message ?? '';
      }

      final copiaDestinatarios = await _personalService.getMailByRol(4);
      if (!copiaDestinatarios.success) {
        throw copiaDestinatarios.message ?? '';
      }

      await _mailService.sendMail(
        Mail(
          destinatarios:
              destinatariosResponse.data!.map((e) => e.nombre!).toList(),
          copiaDestinatarios:
              copiaDestinatarios.data!.map((e) => e.nombre!).toList(),
          acronimo: 'NEPER',
          variables: {
            '@CodigoMCP': personal.codigoMcp ?? '',
            '@EntrenamientoId': entrenamiento.key?.toString() ?? '',
            '@Equipo': entrenamiento.equipo?.nombre ?? '',
            '@Condicion': entrenamiento.condicion?.nombre ?? '',
            '@FechaInicio': entrenamiento.fechaInicio?.format ?? '',
            '@URL': ConfigFile.webUrl,
          },
        ),
      );
    } catch (error, stackTrace) {
      _logger.severe('Error al enviar el correo', error, stackTrace);
    }
  }

  Future<void> mailNEFIN(
    EntrenamientoModulo entrenamiento, {
    required Personal personal,
    required List<EntrenamientoModulo> modulos,
  }) async {
    try {
      final copiaDestinatarios = await _personalService.getMailByRol(4);

      if (!copiaDestinatarios.success || copiaDestinatarios.data == null) {
        throw Exception(
          copiaDestinatarios.message ??
              'Error al obtener copia de destinatarios',
        );
      }

      final photoResponse =
          await _personalService.getPersonalPhoto(personal.inPersonalOrigen!);

      if (!photoResponse.success) {
        throw Exception(photoResponse.message ?? 'Error al obtener la foto');
      }

      final photoPerfil = photoResponse.data;

      final last = modulos.last;
      entrenamiento.entrenador = OptionValue(
        key: last.entrenador!.key,
        nombre: last.entrenador!.nombre,
      );

      final images = await Future.wait([
        generateDiploma(personal, entrenamiento.equipo?.nombre ?? ''),
        generateCertificado(personal, entrenamiento, modulos),
        generatePersonalCarnetFrontPdf(
          personal,
          'credencial_verde_front_full.png',
          photoPerfil,
        ),
        generatePersonalCarnetBackPdf(
          personal,
          'credencial_verde_front_full.png',
          'AUTORIZADO PARA OPERAR',
        ),
      ]);

      _logger.info('Images generated');

      final pdfs = await Future.wait([
        pagesToFile([images[0]]),
        pagesToFile([images[1]]),
        pagesToFile([
          images[2],
          images[3],
        ]),
      ]);
      _logger.info('PDFs generated');

      await _mailService.sendMail(
        Mail(
          destinatarios: [personal.correo ?? ''],
          copiaDestinatarios:
              copiaDestinatarios.data!.map((e) => e.nombre!).toList(),
          acronimo: 'NEFIN',
          variables: {
            '@Familia': entrenamiento.equipo?.nombre ?? '',
            '@Equipo': entrenamiento.equipo?.nombre ?? '',
            '@URL': ConfigFile.webUrl,
          },
          adjuntos: [
            StringValue(
              value: base64Encode(pdfs[0]),
              key: 'Diploma.pdf',
            ),
            StringValue(
              value: base64Encode(pdfs[1]),
              key: 'Certificado.pdf',
            ),
            StringValue(
              value: base64Encode(pdfs[2]),
              key: 'Carnet.pdf',
            ),
          ],
        ),
      );
    } catch (error, stackTrace) {
      _logger.severe('Error al enviar el correo', error, stackTrace);
    }
  }
}
