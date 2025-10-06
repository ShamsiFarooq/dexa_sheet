import 'package:intl/intl.dart';



class Constants {
  static const hiveBoxName = 'excel_box';
  static const hiveKeySheet = 'sheet_data';
    static const hiveKeyMeta = 'sheet_meta';
  static const defaultRows = 20;
  static const defaultCols = 8;
  static const cellWidth = 120.0;
  static const cellHeight = 56.0;
  static const headerHeight = 48.0;
  static const leftHeaderWidth = 72.0;
}


class DateFormatter {
  static String format(DateTime date) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }
}
