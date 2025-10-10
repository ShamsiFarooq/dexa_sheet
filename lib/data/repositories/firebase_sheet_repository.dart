import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dexa_sheet/data/datasources/firebase_sheet_datasource.dart';
import 'package:dexa_sheet/domain/entities/sheet.dart';
import 'package:dexa_sheet/domain/repositories/sheet_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseSheetRepository implements SheetRepository {
  final FirebaseSheetDataSource ds;
  final FirebaseAuth _auth;

  FirebaseSheetRepository({
    required this.ds,
    FirebaseAuth? auth,
  }) : _auth = auth ?? FirebaseAuth.instance;

  // -------- GRID ENCODING (fix nested arrays) --------
  // Firestore forbids arrays-of-arrays. We store each row as Map<colIndex,value>.
  // Example: [["A1","B1"], ["A2","B2"]]  =>
  //          [{"0":"A1","1":"B1"}, {"0":"A2","1":"B2"}]
  List<Map<String, String>> _encodeGrid(List<List<String>> grid) {
    return grid.map((row) {
      final m = <String, String>{};
      for (var c = 0; c < row.length; c++) {
        m['$c'] = row[c];
      }
      return m;
    }).toList();
  }

  List<List<String>> _decodeGrid(List<dynamic>? raw, int rows, int cols) {
    if (raw == null) {
      return List.generate(rows, (_) => List.generate(cols, (_) => ''));
    }
    final out = <List<String>>[];
    for (var r = 0; r < raw.length; r++) {
      final rowMap = Map<String, dynamic>.from(raw[r] as Map);
      out.add(List.generate(cols, (c) => (rowMap['$c'] ?? '').toString()));
    }
    while (out.length < rows) {
      out.add(List.generate(cols, (_) => ''));
    }
    return out;
  }
  // ---------------------------------------------------

  Map<String, dynamic> _toJson(Sheet s, {bool forRename = false}) {
    return <String, dynamic>{
      'id': s.id,
      'name': s.name,
      if (!forRename) 'rows': s.rows,
      if (!forRename) 'cols': s.cols,
      if (!forRename) 'dataRows': _encodeGrid(s.data), // <— IMPORTANT
      'ownerId': s.ownerId,
      if (!forRename && s.columnWidths != null) 'columnWidths': s.columnWidths,
      if (!forRename && s.rowHeights != null) 'rowHeights': s.rowHeights,
      // timestamps handled by provider/datasource
    };
  }

  Sheet _fromJson(Map<String, dynamic> j) {
    final rows = (j['rows'] as num?)?.toInt() ?? 30;
    final cols = (j['cols'] as num?)?.toInt() ?? 10;
    final dataRows = j['dataRows'] as List<dynamic>?; // <— IMPORTANT
    return Sheet(
      id: j['id'] as String,
      name: (j['name'] as String?) ?? 'Untitled',
      rows: rows,
      cols: cols,
      ownerId: (j['ownerId'] as String?) ?? '',
      lastModified: (j['lastModified'] is Timestamp)
          ? (j['lastModified'] as Timestamp).toDate()
          : DateTime.now(),
      data: _decodeGrid(dataRows, rows, cols), // <— IMPORTANT
      columnWidths: (j['columnWidths'] as List?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
      rowHeights: (j['rowHeights'] as List?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
    );
  }

  @override
  Future<Sheet> loadSheet(String id) async => _fromJson(await ds.getById(id));

  @override
  Future<void> saveSheet(Sheet s) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) throw StateError('Not logged in');
    s.ownerId = uid;
    await ds.upsert(_toJson(s));
  }

  @override
  Future<String> createSheet({String? name, int rows = 30, int cols = 10}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) throw StateError('Not logged in');
    final sheet = Sheet.empty(
      name: name ?? 'Untitled Sheet',
      rows: rows,
      cols: cols,
      ownerId: uid,
    );
    await ds.upsert(_toJson(sheet));
    return sheet.id;
  }

  @override
  Future<void> renameSheet(String id, String newName) async {
    await ds.upsert({'id': id, 'name': newName});
  }

  @override
  Future<void> deleteSheet(String id) => ds.delete(id);

  @override
  Future<List<SheetMeta>> getAllSheets() async {
    final list = await ds.listAll();
    return list.map((m) {
      final ts = m['lastModified'];
      final lm = (ts is Timestamp) ? ts.toDate() : DateTime.now();
      return SheetMeta(
        id: (m['id'] as String?) ?? '',
        name: (m['name'] as String?) ?? 'Untitled',
        lastModified: lm,
      );
    }).toList();
  }
}
