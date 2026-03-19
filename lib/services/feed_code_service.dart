import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FeedCodeRepository {
  Future<List<String>> fetchFeedCodes() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('data')
          .get();
      debugPrint('Jumlah dokumen: ${snapshot.docs.length}');
      debugPrint('Isi dokumen: ${snapshot.docs.map((d) => d.data())}');
      return snapshot.docs
          .map((doc) => doc['feedCode'] as String? ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint("FIRESTORE ERROR: $e");
      return [];
    }
  }
}
