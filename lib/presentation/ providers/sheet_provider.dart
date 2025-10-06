import 'dart:async';
import 'package:excel_planner/core/constants.dart';
import 'package:excel_planner/domain/entities/sheet.dart';
import 'package:excel_planner/domain/usecases/load_sheet_usecase.dart';
import 'package:excel_planner/domain/usecases/save_sheet_usecase.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';

class SheetProvider extends ChangeNotifier {
  final LoadSheetUseCase loadUseCase;
  final SaveSheetUseCase saveUseCase;

  Sheet _sheet = Sheet.empty(
    rows: Constants.defaultRows,
    cols: Constants.defaultCols,
  );

  String? _activeSheetId;

  Timer? _saveTimer;

  bool isLoading = true;

  SheetProvider({
    required this.loadUseCase,
    required this.saveUseCase,
  });

  Sheet get sheet => _sheet;
  String get activeSheetName => _sheet.name;


  Future<void> load(String id) async {
    try {
      isLoading = true;
      notifyListeners();
      final loadedSheet = await loadUseCase(id);
      _sheet = loadedSheet;
      _activeSheetId = id;
    } catch (e, st) {
      debugPrint('Error loading sheet: $e\n$st');
      _sheet = Sheet.empty(
        rows: Constants.defaultRows,
        cols: Constants.defaultCols,
      );
    } finally {
      isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    }
  }

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

  Future<void> save() async {
    try {
      _sheet.lastModified = DateTime.now();
      await saveUseCase(_sheet);
      debugPrint('✅ SheetProvider: Saved successfully.');
    } catch (e, st) {
      debugPrint('❌ SheetProvider save error: $e\n$st');
    }
  }


  String cellAt(int r, int c) => _sheet.data[r][c];

  void updateCell(int r, int c, String value) {
    _sheet.data[r][c] = value;
    _sheet.lastModified = DateTime.now();
    notifyListeners();

    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(seconds: 2), () async {
      await save();
    });
  }


  void addRow({int? index}) {
    final cols = _sheet.data[0].length;
    final newRow = List.generate(cols, (_) => '');
    if (index == null || index >= _sheet.data.length) {
      _sheet.data.add(newRow);
    } else {
      _sheet.data.insert(index + 1, newRow);
    }
    _sheet.lastModified = DateTime.now();
    notifyListeners();
    
  }

  void removeRow(int index) {
    if (_sheet.data.length <= 1) return;
    _sheet.data.removeAt(index);
    _sheet.lastModified = DateTime.now();
    notifyListeners();

  
  }

  void addColumn({int? index}) {
    for (var row in _sheet.data) {
      if (index == null || index >= row.length) {
        row.add('');
      } else {
        row.insert(index + 1, '');
      }
    }
    _sheet.lastModified = DateTime.now();
    notifyListeners();
   
  }

  void removeColumn(int index) {
    if (_sheet.data[0].length <= 1) return;
    for (var row in _sheet.data) {
      row.removeAt(index);
    }
    _sheet.lastModified = DateTime.now();
    notifyListeners();
  }


  String exportCsv() {
    return const ListToCsvConverter().convert(_sheet.data);
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    super.dispose();
  }
}
