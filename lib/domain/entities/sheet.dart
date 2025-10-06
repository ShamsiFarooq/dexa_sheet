import 'package:uuid/uuid.dart';

class Sheet {
  final String id;
  String name;
  List<List<String>> data;
  DateTime lastModified;

  Sheet({
    required this.id,
    required this.name,
    required this.data,
    required this.lastModified,
  });

  factory Sheet.empty({String? name, int rows = 20, int cols = 8}) {
    return Sheet(
      id: const Uuid().v4(),
      name: name ?? 'Untitled Sheet',
      data: List.generate(rows, (_) => List.generate(cols, (_) => '')),
      lastModified: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'data': data,
        'lastModified': lastModified.toIso8601String(),
      };

  factory Sheet.fromJson(Map<String, dynamic> json) => Sheet(
        id: json['id'],
        name: json['name'],
        data: (json['data'] as List)
            .map<List<String>>((row) =>
                (row as List).map<String>((cell) => cell.toString()).toList())
            .toList(),
        lastModified: DateTime.parse(json['lastModified']),
      );
}

class SheetMeta {
  final String id;
  String name;
  DateTime lastModified;

  SheetMeta({
    required this.id,
    required this.name,
    required this.lastModified,
  });

  factory SheetMeta.fromSheet(Sheet sheet) => SheetMeta(
        id: sheet.id,
        name: sheet.name,
        lastModified: sheet.lastModified,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'lastModified': lastModified.toIso8601String(),
      };

  factory SheetMeta.fromJson(Map<String, dynamic> json) => SheetMeta(
        id: json['id'],
        name: json['name'],
        lastModified: DateTime.parse(json['lastModified']),
      );
}
