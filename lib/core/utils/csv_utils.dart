import 'package:csv/csv.dart';

class CsvUtils {
  CsvUtils._();

  static String listToCsv(List<List<dynamic>> rows) {
    return csv.encode(rows);
  }
}
