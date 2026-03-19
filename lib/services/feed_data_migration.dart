import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> migrateOldFeedDataToHistory() async {
  final dataCollection = FirebaseFirestore.instance.collection('data');
  final snapshot = await dataCollection.get();
  for (final doc in snapshot.docs) {
    final data = doc.data();
    final kilo = data['kilo'];
    final timestamp = data['timestamp'];
    final history = (data['history'] ?? []) as List;
    if (kilo != null && timestamp != null) {
      final alreadyInHistory = history.any(
        (item) =>
            item is Map &&
            item['kilo'] == kilo &&
            item['timestamp'] == timestamp,
      );
      if (!alreadyInHistory) {
        await dataCollection.doc(doc.id).update({
          'history': FieldValue.arrayUnion([
            {'kilo': kilo, 'timestamp': timestamp},
          ]),
        });
      }
    }
  }
}
