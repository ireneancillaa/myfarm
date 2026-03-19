import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FeedHistoryController extends GetxController {
  // Stream untuk semua feedCode (all history)
  Stream<List<Map<String, dynamic>>> get allHistoryStream {
    return FirebaseFirestore.instance.collection('data').snapshots().map((
      query,
    ) {
      final List<Map<String, dynamic>> all = [];
      for (final doc in query.docs) {
        final data = doc.data();
        final code = data['feedCode'] ?? '-';
        if (data['history'] != null) {
          final List<dynamic> history = data['history'];
          for (final h in history) {
            if (h is Map<String, dynamic>) {
              all.add({...h, 'feedCode': code});
            }
          }
        }
      }
      // Urutkan berdasarkan timestamp descending (terbaru di atas)
      all.sort((a, b) {
        final tA = DateTime.tryParse(a['timestamp'] ?? '') ?? DateTime(0);
        final tB = DateTime.tryParse(b['timestamp'] ?? '') ?? DateTime(0);
        return tB.compareTo(tA);
      });
      return all;
    });
  }

  Future<void> deleteHistoryItem(Map<String, dynamic> item) async {
    final query = await FirebaseFirestore.instance
        .collection('data')
        .where('feedCode', isEqualTo: item['feedCode'])
        .get();

    if (query.docs.isEmpty) return;

    final docRef = query.docs.first.reference;

    final data = query.docs.first.data();
    final List<dynamic> history = List.from(data['history'] ?? []);

    // cari item yang benar-benar sama
    final target = history.firstWhere(
      (h) {
        final t1 = h['timestamp']?.toString();
        final t2 = item['timestamp']?.toString();

        final k1 = h['kilo']?.toString();
        final k2 = item['kilo']?.toString();

        return t1 == t2 && k1 == k2;
      },
      orElse: () => null,
    );

    if (target == null) return;
    debugPrint('DELETE TARGET: $target');

    await docRef.update({
      'history': FieldValue.arrayRemove([Map<String, dynamic>.from(target)]),
    });
  }

  final String feedCode;
  FeedHistoryController(this.feedCode);

  Stream<List<Map<String, dynamic>>> get historyStream {
    return FirebaseFirestore.instance
        .collection('data')
        .where('feedCode', isEqualTo: feedCode)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return [];
          final doc = snapshot.docs.first;
          final List<dynamic> history = doc['history'] ?? [];
          return history.cast<Map<String, dynamic>>();
        });
  }
}
