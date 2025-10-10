import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirebaseSheetDataSource {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  FirebaseSheetDataSource({
    FirebaseFirestore? db,
    FirebaseAuth? auth,
  })  : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      throw StateError('No authenticated user. Sign in before saving.');
    }
    return uid;
  }

  CollectionReference<Map<String, dynamic>> get _userCollection {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      debugPrint('❌ Dexa DS: UID is null — user not logged in');
      throw Exception('User not logged in');
    }
    debugPrint('✅ Dexa DS: using path users/$uid/sheets');
    return _db.collection('users').doc(uid).collection('sheets');
  }

  Future<Map<String, dynamic>> getById(String id) async {
    final doc = await _userCollection.doc(id).get();
    if (!doc.exists) throw Exception('Sheet not found');
    return doc.data()!..putIfAbsent('id', () => doc.id);
  }

  /// Upsert with server timestamps so SheetListPage can order by `lastModified`
  Future<void> upsert(Map<String, dynamic> json) async {
    final id = json['id'] as String?;
    if (id == null || id.isEmpty) {
      throw ArgumentError('Missing ID in sheet JSON');
    }

    final ref = _userCollection.doc(id);
    debugPrint('📝 Dexa upsert: doc=users/${_auth.currentUser?.uid}/sheets/$id');

    try {
      final snap = await ref.get();
      final base = Map<String, dynamic>.from(json);
      final now = FieldValue.serverTimestamp();

      if (snap.exists) {
        base['lastModified'] = now;
        await ref.set(base, SetOptions(merge: true));
      } else {
        base['createdAt'] = now;
        base['lastModified'] = now;
        await ref.set(base, SetOptions(merge: true));
      }

      debugPrint('✅ Dexa upsert OK');
    } on FirebaseException catch (e) {
      debugPrint('🔥 Dexa upsert FirebaseException [${e.code}] ${e.message}');
      rethrow;
    } catch (e, st) {
      debugPrint('🔥 Dexa upsert error: $e\n$st');
      rethrow;
    }
  }
Future<void> delete(String id) async {
  try {
    final ref = _userCollection.doc(id);
    debugPrint('🗑️ Dexa delete: deleting doc at ${ref.path}');
    await ref.delete();
    debugPrint('✅ Dexa delete success for $id');
  } on FirebaseException catch (e) {
    debugPrint('🔥 Dexa delete Firebase error [${e.code}] ${e.message}');
    rethrow;
  } catch (e, st) {
    debugPrint('🔥 Dexa delete error: $e\n$st');
    rethrow;
  }
}


  /// 👉 Add this: fetch all sheets, prefer ordering by server-stamped `lastModified`.
  Future<List<Map<String, dynamic>>> listAll() async {
    try {
      final snap = await _userCollection
          .orderBy('lastModified', descending: true)
          .get();

      return snap.docs.map((d) {
        final m = d.data();
        m.putIfAbsent('id', () => d.id);
        return m;
      }).toList();
    } on FirebaseException catch (e) {
      // If some old docs miss `lastModified`, fall back and sort client-side.
      debugPrint('⚠️ Dexa listAll orderBy failed [${e.code}] — fallback');
      final snap = await _userCollection.get();
      final list = snap.docs.map((d) {
        final m = d.data();
        m.putIfAbsent('id', () => d.id);
        return m;
      }).toList();

      list.sort((a, b) {
        final ta = a['lastModified'];
        final tb = b['lastModified'];
        final da = (ta is Timestamp) ? ta.toDate() : DateTime.fromMillisecondsSinceEpoch(0);
        final db = (tb is Timestamp) ? tb.toDate() : DateTime.fromMillisecondsSinceEpoch(0);
        return db.compareTo(da);
      });
      return list;
    }
  }
}
