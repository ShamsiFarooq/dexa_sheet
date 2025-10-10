// lib/domain/entities/sheet.dart
import 'package:uuid/uuid.dart';

class Sheet {
  String id;
  String name;
  int rows;
  int cols;
  List<List<String>> data;
  String ownerId;
  DateTime lastModified;
  List<double>? columnWidths;
  List<double>? rowHeights;

  Sheet({
    required this.id,
    required this.name,
    required this.rows,
    required this.cols,
    required this.data,
    required this.ownerId,
    required this.lastModified,
    this.columnWidths,
    this.rowHeights,
  });

  factory Sheet.empty({
    String? id,
    String name = 'Untitled Sheet',
    int rows = 30,
    int cols = 10,
    String ownerId = '',
  }) {
    final grid = List.generate(rows, (_) => List.generate(cols, (_) => ''));
    return Sheet(
      id: id ?? const Uuid().v4(),
      name: name,
      rows: rows,
      cols: cols,
      data: grid,
      ownerId: ownerId,
      lastModified: DateTime.now(),
    );
  }
}

class SheetMeta {
  final String id;
  final String name;
  final DateTime lastModified;

  SheetMeta({
    required this.id,
    required this.name,
    required this.lastModified,
  });
}
