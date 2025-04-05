import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sgem/shared/models/fecha.dart';
import 'package:sgem/shared/widgets/table/data.table.dart';
import 'package:sgem/shared/widgets/table/custom.table.text.dart';

class GuardiaDisponibleModal extends StatelessWidget {
  const GuardiaDisponibleModal({super.key, this.guardia, this.fechas});

  final String? guardia;
  final List<Fecha>? fechas;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Fechas disponibles para Guardia ${guardia ?? ''}',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        // Divider(color: Colors.grey,),
        SizedBox(height: 16),
        Container(
          height: 300,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey, // Color del borde
              width: 0.25, // Grosor del borde
            ),
          ),
          child: Center(
            child: DataTable2(
              showBottomBorder: true,
              columnSpacing: 20.0,
              minWidth: 2190.0,
              dataRowHeight: 52.0,
              headingRowHeight: 44.0,
              fixedColumnsColor: Colors.red,
              columns: const [
                DataColumn2(
                  fixedWidth: 140,
                  size: ColumnSize.L,
                  label: CustomText(
                    title: "Fecha Inicio",
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                DataColumn2(
                  fixedWidth: 170,
                  size: ColumnSize.L,
                  label: CustomText(
                    title: "Fecha Fin",
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ],
              rows: List.generate(
                fechas!.length,
                (index) {
                  return DataRow(
                    color: MaterialStateProperty.all(
                        index % 2 == 0 + 1 ? Colors.grey.shade100 : null),
                    cells: [
                      DataCell(CustomText(
                        title: DateFormat('dd/MM/yyyy')
                            .format(fechas![index].fechaInicio),
                      )),
                      DataCell(CustomText(
                        title: DateFormat('dd/MM/yyyy')
                            .format(fechas![index].fechaFin),
                      )),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        // Table(
        //   border: TableBorder.all(),
        //   columnWidths: const {
        //     0: FlexColumnWidth(1),
        //     1: FlexColumnWidth(2),
        //     2: FlexColumnWidth(1),
        //   },
        //   children: [
        //     TableRow(
        //       children: [
        //         // Padding(
        //         //   padding: const EdgeInsets.all(8.0),
        //         //   child: Text(
        //         //     'Guardia',
        //         //     style: TextStyle(fontWeight: FontWeight.bold),
        //         //   ),
        //         // ),
        //         Padding(
        //           padding: const EdgeInsets.all(8.0),
        //           child: Text(
        //             'Fecha Inicio',
        //             style: TextStyle(fontWeight: FontWeight.bold),
        //           ),
        //         ),
        //         Padding(
        //           padding: const EdgeInsets.all(8.0),
        //           child: Text(
        //             'Fecha fin',
        //             style: TextStyle(fontWeight: FontWeight.bold),
        //           ),
        //         ),
        //       ],
        //     ),
        //     // ...List.generate(fechas!.length, (index) {
        //     //   var item = fechas![index];
        //     //   return TableRow(
        //     //     children: [
        //     //       // Padding(
        //     //       //   padding: const EdgeInsets.all(8.0),
        //     //       //   child: Text('${index + 1}'),
        //     //       // ),
        //     //       Padding(
        //     //         padding: const EdgeInsets.all(8.0),
        //     //         child: Text(DateFormat('dd/MM/yyyy').format(item.fechaInicio)),
        //     //       ),
        //     //       Padding(
        //     //         padding: const EdgeInsets.all(8.0),
        //     //         child: Text(DateFormat('dd/MM/yyyy').format(item.fechaFin)),
        //     //       ),
        //     //     ],
        //     //   );
        //     // }),

        //   ],
        // ),
        SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cerrar'),
          ),
        ),
      ],
    );
  }
}
