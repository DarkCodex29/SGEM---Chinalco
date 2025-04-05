import 'dart:async';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:sgem/shared/modules/entrenamiento.modulo.dart';
import 'package:sgem/shared/modules/personal.dart';
import 'package:sgem/shared/utils/Extensions/pdf.extensions.dart';
import 'package:sgem/shared/utils/pdfFuntions/pdf.functions.dart';

Future<pw.Page> generateCertificado(
  Personal? personal,
  EntrenamientoModulo? entrenamiento,
  List<EntrenamientoModulo> modulos,
) async {
  const double heigthCeldastable = 15;
  int totalHoras =
      modulos.fold(0, (sum, modulo) => sum + (modulo.inHorasAcumuladas ?? 0));
  final imageIcon = await loadImage('logo.png');
  modulos.sort((a, b) {
    return a.modulo!.nombre!.compareTo(b.modulo!.nombre!);
  });

  List<Map<String, dynamic>> notasPorCategoria(
    List<EntrenamientoModulo> modulos,
  ) {
    // Ordenar los módulos por nombre
    modulos.sort((a, b) => a.modulo!.nombre!.compareTo(b.modulo!.nombre!));

    // Crear las filas de categorías (Teórico y Práctico)
    return [
      {
        'tipo': 'Teórico',
        'notas': modulos.map((modulo) => modulo.inNotaTeorica ?? 0).toList(),
      },
      {
        'tipo': 'Práctico',
        'notas': modulos.map((modulo) => modulo.inNotaPractica ?? 0).toList(),
      },
    ];
  }

  final page = pw.Page(
    //orientation: pw.PageOrientation.landscape,
    pageFormat: PdfPageFormat.a4.copyWith(
      marginBottom: 0,
      marginLeft: 0,
      marginRight: 0,
      marginTop: 0,
    ),
    build: (pw.Context context) {
      return pw.Container(
        padding:
            const pw.EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
        child: pw.Column(
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Container(
                  height: 60,
                  width: 60,
                  color: const PdfColor.fromInt(0xFF051367),
                  child: pw.Image(
                    pw.MemoryImage(imageIcon),
                    fit: pw.BoxFit.contain,
                  ),
                ),
                pw.SizedBox(width: 10),
                pw.Container(
                  width: 200,
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    'DIPLOMA DE AUTORIZACIÓN PARA USO DE EQUIPOS MÓVILES',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                pw.SizedBox(width: 30),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    userDetailEncabezado('Empresa:', 'Minera Chinalco Peru'),
                    userDetailEncabezado(
                      'Fecha:',
                      DateFormat('dd/MM/yyyy').format(DateTime.now()),
                    ),
                    userDetailEncabezado(
                      'Proceso:',
                      'Entrenamiento de equipos moviles',
                    ),
                  ],
                ),
              ],
            ),
            pw.Container(
              width: double.infinity,
              alignment: pw.Alignment.centerLeft,
              child: pw.Text(
                'Datos del operador autorizado',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ).padding(const pw.EdgeInsets.only(bottom: 10, top: 10)),
            ),
            cardCustom(
              pw.Column(
                children: [
                  pw.Column(
                    children: [
                      userDetail('Código MCP:', personal!.codigoMcp),
                      userDetail(
                          'Nombres y apellidos:', personal.nombreCompleto),
                      userDetail('Guardia:', personal.guardia!.nombre),
                    ],
                  ).padding(const pw.EdgeInsets.only(left: 20)),
                ],
              ),
            ),
            pw.Container(
              width: double.infinity,
              alignment: pw.Alignment.centerLeft,
              child: pw.Text(
                'Datos del entrenamiento',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ).padding(const pw.EdgeInsets.only(bottom: 10, top: 10)),
            ),
            cardCustom(
              pw.Column(
                children: [
                  userDetail('Equipo móvil:', entrenamiento!.equipo!.nombre),
                  userDetail('Condición:', entrenamiento.condicion!.nombre),
                  userDetail(
                    'Entrenador responsable:',
                    entrenamiento.entrenador!.nombre,
                  ),
                ],
              ).padding(const pw.EdgeInsets.only(left: 20)),
            ),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: {
                    0: const pw.FixedColumnWidth(100),
                    1: const pw.FixedColumnWidth(100),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Container(
                          height: heigthCeldastable,
                          alignment: pw.Alignment.center,
                          color: const PdfColor.fromInt(0xFF051367),
                          child: pw.Text(
                            'Módulo',
                            style: const pw.TextStyle(color: PdfColors.white),
                          ),
                        ),
                        pw.Container(
                          height: heigthCeldastable,
                          alignment: pw.Alignment.center,
                          color: const PdfColor.fromInt(0xFF051367),
                          child: pw.Text(
                            'Horas',
                            style: const pw.TextStyle(color: PdfColors.white),
                          ),
                        ),
                      ],
                    ),
                    ...modulos.map((modulo) {
                      return pw.TableRow(
                        children: [
                          pw.Container(
                            padding: const pw.EdgeInsets.all(0),
                            height: heigthCeldastable,
                            alignment: pw.Alignment.center,
                            child: pw.Text(modulo.modulo!.nombre!),
                          ),
                          pw.Container(
                            height: heigthCeldastable,
                            alignment: pw.Alignment.center,
                            child:
                                pw.Text(modulo.inHorasAcumuladas!.toString()),
                          ),
                        ],
                      );
                    }),
                    pw.TableRow(
                      children: [
                        pw.Container(
                          height: heigthCeldastable,
                          alignment: pw.Alignment.center,
                          child: pw.Text('Total'),
                        ),
                        pw.Container(
                          height: heigthCeldastable,
                          alignment: pw.Alignment.center,
                          child: pw.Text('$totalHoras'),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(width: 40),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    userDetailEncabezado(
                      'Fecha inicio:',
                      entrenamiento.fechaInicio != null
                          ? DateFormat('dd/MM/yyyy')
                              .format(entrenamiento.fechaInicio!)
                          : '',
                    ),
                    userDetailEncabezado(
                      'Fecha fin:',
                      entrenamiento.fechaTermino != null
                          ? DateFormat('dd/MM/yyyy')
                              .format(entrenamiento.fechaTermino!)
                          : '',
                    ),
                  ],
                ),
              ],
            ).padding(const pw.EdgeInsets.only(left: 100, right: 20)),
            pw.Container(
              width: double.infinity,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Objetivos',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ).padding(const pw.EdgeInsets.only(top: 10, bottom: 10)),
                  pw.Text(
                    '- Verificar avance de operador en el desarrollo del plan de capacitación y entrenamiento en mensión.',
                  ),
                  pw.Text(
                    '- Identificar las oportunidades de mejora del nuevo operador para su posterior monitoreo en operación del equipo.',
                  ),
                ],
              ),
            ),
            pw.Container(
              width: double.infinity,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Metodología',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ).padding(const pw.EdgeInsets.only(top: 10, bottom: 10)),
                  pw.Text(
                    '- Basado en el Procedimiento Operativo: POP-OPM-002 '
                    'Capacitación y entrenamiento de staff en caso de '
                    'emergencia, todo personal con y sin experiencia que '
                    'inicie entrenamiento desde el 20 de Mayo del 2016 en '
                    'adelante deberá cumplir con el número de horas detalladas '
                    'en el cuadro de información general. El proceso de '
                    'capacitación y entrenamiento consta de evaluaciones '
                    'supervisadas por el Entrenador como son: Conocimientos '
                    'teóricos, evaluaciones en simulador y campo indicadas en '
                    'evaluación del participante',
                  ),
                  pw.Text(
                    '- El porcentaje mínimo aprobatorio es de 80%. '
                    'Siendo el primer módulo pre-registro para el siguiente '
                    'así sucesivamente.',
                  ),
                ],
              ),
            ),
            pw.Container(
              width: double.infinity,
              alignment: pw.Alignment.centerLeft,
              child: pw.Text(
                'Evaluación del participante',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ).padding(const pw.EdgeInsets.only(top: 10, bottom: 10)),
            ),
            pw.Table(
              border: pw.TableBorder.all(),
              children: [
                pw.TableRow(
                  children: [
                    pw.Container(
                      height: heigthCeldastable,
                      alignment: pw.Alignment.center,
                      color: const PdfColor.fromInt(0xFF051367),
                      child: pw.Text(
                        'Notas',
                        style: const pw.TextStyle(color: PdfColors.white),
                      ),
                    ),
                    ...modulos.map((modulo) {
                      return pw.Container(
                        height: heigthCeldastable,
                        alignment: pw.Alignment.center,
                        color: const PdfColor.fromInt(0xFF051367),
                        child: pw.Text(
                          modulo.modulo!.nombre!,
                          style: const pw.TextStyle(color: PdfColors.white),
                        ),
                      );
                    }),
                  ],
                ),
                ...notasPorCategoria(modulos).map((categoria) {
                  return pw.TableRow(
                    children: [
                      pw.Container(
                        height: heigthCeldastable,
                        alignment: pw.Alignment.center,
                        child: pw.Text(categoria['tipo']),
                      ),
                      ...categoria['notas'].map((nota) {
                        return pw.Container(
                          height: heigthCeldastable,
                          alignment: pw.Alignment.center,
                          child: pw.Text(nota.toString()),
                        );
                      }).toList(),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Container(
              width: double.infinity,
              alignment: pw.Alignment.centerLeft,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '- Se concluye que el operador queda APTO para operar '
                    'el equipo ${entrenamiento.equipo!.nombre} en la mina de '
                    'Chinalco Perú.',
                  ),
                  pw.Text('- Para dar conformidad a este documento firman:'),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                userFirm('Superintendente de Operaciones Mina'),
                userFirm(
                  'Superintendente de Mejora Continua y Control de Producción',
                ),
              ],
            ).padding(const pw.EdgeInsets.symmetric(horizontal: 20)),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                userFirm('Jefe de Guardia'),
              ],
            ).padding(const pw.EdgeInsets.symmetric(horizontal: 20)),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                userFirm('Entrenador de Operaciones Mina'),
                userFirm('Operador de Equipo Pesado'),
              ],
            ).padding(const pw.EdgeInsets.symmetric(horizontal: 20)),
          ],
        ),
      );
    },
  );
  return page;
}
