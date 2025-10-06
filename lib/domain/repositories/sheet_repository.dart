
import 'package:excel_planner/domain/entities/sheet.dart';

abstract class SheetRepository {
  Future<List<SheetMeta>> getAllSheets();
  Future<Sheet> loadSheet(String id);
  Future<void> saveSheet(Sheet sheet);
  Future<void> deleteSheet(String id);
  Future<void> renameSheet(String id, String newName);
}
