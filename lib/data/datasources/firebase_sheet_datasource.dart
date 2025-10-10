import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseSheetDataSource {
  final FirebaseFirestore _db;
  final String uid;
  FirebaseSheetDataSource({required this.uid}) : _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('users').doc(uid).collection('sheets');

  Future<void> upsert(Map<String, dynamic> json) async {
    final id = json['id'] as String;
    await _col.doc(id).set(json, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>> getById(String id) async {
    final snap = await _col.doc(id).get();
    if (!snap.exists) throw Exception('Sheet not found');
    return snap.data()!;
  }

  Future<void> delete(String id) => _col.doc(id).delete();

  Future<List<Map<String, dynamic>>> listAll() async {
    final q = await _col.orderBy('lastModified', descending: true).get();
    return q.docs.map((d) => d.data()).toList();
  }
}
