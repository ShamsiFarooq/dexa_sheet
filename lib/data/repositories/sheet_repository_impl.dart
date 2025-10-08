



import 'package:dexa_sheet/data/datasources/local_datasource.dart';
import 'package:dexa_sheet/domain/entities/sheet.dart';
import 'package:dexa_sheet/domain/repositories/sheet_repository.dart';

class SheetRepositoryImpl implements SheetRepository {
  final LocalDataSource local;
  SheetRepositoryImpl(this.local);

  @override
  Future<List<SheetMeta>> getAllSheets() => local.getMetaList();

  @override
  Future<Sheet> loadSheet(String id) async =>
      await local.loadSheet(id) ?? Sheet.empty(name: 'New Sheet');

  @override
  Future<void> saveSheet(Sheet sheet) async => local.saveSheet(sheet);

  @override
  Future<void> deleteSheet(String id) async => local.deleteSheet(id);

  @override
  Future<void> renameSheet(String id, String newName) async =>
      local.renameSheet(id, newName);
}
