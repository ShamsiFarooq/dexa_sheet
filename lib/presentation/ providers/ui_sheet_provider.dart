import 'package:flutter/material.dart';
import '../../core/constants.dart';

class UiSheetProvider extends ChangeNotifier {
  List<List<String>> data = List.generate(
    Constants.defaultRows,
    (_) => List.generate(Constants.defaultCols, (_) => ''),
  );

  bool isLoading = false;

  String cellAt(int r, int c) => data[r][c];

  void updateCell(int r, int c, String value) {
    data[r][c] = value;
    notifyListeners();
  }

  void addRow({int at = -1}) {
    final cols = data.isNotEmpty ? data[0].length : Constants.defaultCols;
    final row = List.generate(cols, (_) => '');
    if (at < 0 || at >= data.length) {
      data.add(row);
    } else {
      data.insert(at, row);
    }
    notifyListeners();
  }

  void addColumn({int at = -1}) {
    for (var row in data) {
      if (at < 0 || at >= row.length) row.add('');
      else row.insert(at, '');
    }
    notifyListeners();
  }

  void removeRow(int index) {
    if (data.length <= 1) return;
    data.removeAt(index);
    notifyListeners();
  }

  void removeColumn(int index) {
    final cols = data[0].length;
    if (cols <= 1) return;
    for (var row in data) row.removeAt(index);
    notifyListeners();
  }
}
