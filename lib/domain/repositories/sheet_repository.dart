

import 'package:dexa_sheet/domain/entities/sheet.dart';

abstract class SheetRepository {
 Future<Sheet> loadSheet(String id);
  Future<void> saveSheet(Sheet sheet);
  Future<String> createSheet({String? name, int rows = 30, int cols = 10});
  Future<void> renameSheet(String id, String newName);
  Future<void> deleteSheet(String id);
  Future<List<SheetMeta>> getAllSheets();
}
