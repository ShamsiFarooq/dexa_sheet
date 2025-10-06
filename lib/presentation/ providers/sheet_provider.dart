import 'package:excel_planner/core/constants.dart';
import 'package:excel_planner/domain/entities/sheet.dart';
import 'package:excel_planner/domain/usecases/load_sheet_usecase.dart';
import 'package:excel_planner/domain/usecases/save_sheet_usecase.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';

class SheetProvider extends ChangeNotifier {
  Sheet _sheet = Sheet.empty(
    rows: Constants.defaultRows,
    cols: Constants.defaultCols,
  );
  final LoadSheetUseCase loadUseCase;
  final SaveSheetUseCase saveUseCase;

  bool isLoading = true;

  String? _activeSheetId;
  String get activeSheetName => _sheet.name;

  SheetProvider({required this.loadUseCase, required this.saveUseCase});

  Sheet get sheet => _sheet;

  Future<void> loadById(String id) async {
    try {
      isLoading = true;
      notifyListeners();
      final repository = loadUseCase.repository;
      final loaded = await repository.loadSheet(id);
      _sheet = loaded;
      _activeSheetId = id;
    } catch (e, st) {
      debugPrint('Error loading sheet by ID: $e\n$st');
      _sheet = Sheet.empty(
        rows: Constants.defaultRows,
        cols: Constants.defaultCols,
      );
    } finally {
      isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    }
  }

  Future<void> createNewSheet({String? name}) async {
    _sheet = Sheet.empty(name: name ?? 'Untitled Sheet');
    _activeSheetId = _sheet.id;
    notifyListeners();
  }

  Future<void> renameActiveSheet(String newName) async {
    if (_activeSheetId == null) return;
    _sheet.name = newName;
    _sheet.lastModified = DateTime.now();
    final repo = loadUseCase.repository;
    await repo.renameSheet(_activeSheetId!, newName);
    notifyListeners();
  }

  Future<void> deleteSheet(String id) async {
    final repo = loadUseCase.repository;
    await repo.deleteSheet(id);
    notifyListeners();
  }

  Future<List<SheetMeta>> getAllSheets() async {
    final repo = loadUseCase.repository;
    return repo.getAllSheets();
  }


  Future<void> load(String id) async {
    try {
      isLoading = true;
      notifyListeners();
      final loadedSheet = await loadUseCase(id);
      _sheet = loadedSheet;
    } catch (e, st) {
      debugPrint('Error loading sheet: $e\n$st');
      _sheet = Sheet.empty(
        rows: Constants.defaultRows,
        cols: Constants.defaultCols,
      );
    } finally {
      isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  Future<void> save() async {
    try {
      _sheet.lastModified = DateTime.now(); 
      await saveUseCase(_sheet);
      debugPrint('Provider: saveUseCase completed.');
    } catch (e, st) {
      debugPrint('Provider save error: $e\n$st');
      rethrow;
    }
  }

  String cellAt(int r, int c) => _sheet.data[r][c];

  void updateCell(int r, int c, String value) {
    _sheet.data[r][c] = value;
    notifyListeners();
  }

  void addRow({int at = -1}) {
    final cols =
        _sheet.data.isNotEmpty ? _sheet.data[0].length : Constants.defaultCols;
    final row = List.generate(cols, (_) => '');
    if (at < 0 || at >= _sheet.data.length) {
      _sheet.data.add(row);
    } else {
      _sheet.data.insert(at, row);
    }
    notifyListeners();
  }

  void addColumn({int at = -1}) {
    for (var row in _sheet.data) {
      if (at < 0 || at >= row.length) {
        row.add('');
      } else {
        row.insert(at, '');
      }
    }
    notifyListeners();
  }

  void removeRow(int index) {
    if (_sheet.data.length <= 1) return;
    _sheet.data.removeAt(index);
    notifyListeners();
  }

  void removeColumn(int index) {
    final cols = _sheet.data[0].length;
    if (cols <= 1) return;
    for (var row in _sheet.data) {
      row.removeAt(index);
    }
    notifyListeners();
  }

  String exportCsv() {
    return const ListToCsvConverter().convert(_sheet.data);
  }
}
