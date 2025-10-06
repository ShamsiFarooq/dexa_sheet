import 'package:excel_planner/core/constants.dart';
import 'package:excel_planner/domain/entities/sheet.dart';
import 'package:hive/hive.dart';
import 'dart:convert';

class LocalDataSource {
  final Box box;
  LocalDataSource(this.box);

  Future<void> saveSheet(Sheet sheet) async {
    await box.put('sheet_${sheet.id}', jsonEncode(sheet.toJson()));
    await _updateMetaList(sheet);
  }

  Future<Sheet?> loadSheet(String id) async {
    final raw = box.get('sheet_$id');
    if (raw == null) return null;
    return Sheet.fromJson(jsonDecode(raw));
  }

  Future<void> deleteSheet(String id) async {
    await box.delete('sheet_$id');
    final list = await getMetaList();
    list.removeWhere((m) => m.id == id);
    await _saveMetaList(list);
  }

  Future<void> renameSheet(String id, String newName) async {
    final sheet = await loadSheet(id);
    if (sheet == null) return;
    sheet.name = newName;
    sheet.lastModified = DateTime.now();
    await saveSheet(sheet);
  }

  Future<List<SheetMeta>> getMetaList() async {
    final raw = box.get(Constants.hiveKeyMeta);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List;
    return decoded.map((e) => SheetMeta.fromJson(e)).toList();
  }

  Future<void> _updateMetaList(Sheet sheet) async {
    final list = await getMetaList();
    list.removeWhere((m) => m.id == sheet.id);
    list.add(SheetMeta.fromSheet(sheet));
    await _saveMetaList(list);
  }

  Future<void> _saveMetaList(List<SheetMeta> list) async {
    final jsonList = list.map((e) => e.toJson()).toList();
    await box.put(Constants.hiveKeyMeta, jsonEncode(jsonList));
  }
}
