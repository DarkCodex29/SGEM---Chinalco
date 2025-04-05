import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';

typedef TConverter<T> = List<String> Function(T item);

class ExcelUtils {
  static CellStyle headerStyle = CellStyle(
    backgroundColorHex: ExcelColor.blue,
    fontColorHex: ExcelColor.white,
    bold: true,
    horizontalAlign: HorizontalAlign.Center,
    verticalAlign: VerticalAlign.Center,
  );

  static Excel convertToExcel<T>(
    List<T> data, {
    required String sheetName,
    required TConverter<T> converter,
    List<String>? headers,
  }) {
    final excel = Excel.createExcel();
    excel.rename('Sheet1', sheetName);

    if (headers != null) {
      for (var i = 0; i < headers.length; i++) {
        excel.updateCell(
          sheetName,
          CellIndex.indexByColumnRow(rowIndex: 0, columnIndex: i),
          TextCellValue(headers[i]),
          cellStyle: headerStyle,
        );
      }
    }

    for (var i = 0; i < data.length; i++) {
      final row = converter(data[i]);
      for (var j = 0; j < row.length; j++) {
        excel.updateCell(
          sheetName,
          CellIndex.indexByColumnRow(rowIndex: i + 1, columnIndex: j),
          TextCellValue(row[j]),
        );
      }
    }

    return excel;
  }
}

extension ExcelFile on Excel {
  Future<void> download({
    required String name,
    bool addTimestamp = true,
  }) async {
    final bytes = Uint8List.fromList(this.encode()!);

    final fileName;
    if (addTimestamp) {
      final now = DateTime.now();
      final day = now.day.toString().padLeft(2, '0');
      final month = now.month.toString().padLeft(2, '0');
      final year = now.year.toString().substring(2);
      final hour = now.hour.toString().padLeft(2, '0');
      final minute = now.minute.toString().padLeft(2, '0');
      final second = now.second.toString().padLeft(2, '0');
      fileName = '${name}_$year$month$day-$hour$minute$second';
    } else {
      fileName = '$name';
    }

    await FileSaver.instance.saveFile(
        name: fileName,
        bytes: bytes,
        ext: "xlsx",
        mimeType: MimeType.microsoftExcel);
  }
}
