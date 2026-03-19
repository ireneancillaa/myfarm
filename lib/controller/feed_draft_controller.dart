import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class FeedDraftController extends GetxController {
  void removeDraftItem(Map<String, dynamic> item) {
    final list = draftHistory;
    list.removeWhere((h) {
      final t1 = h['timestamp']?.toString();
      final t2 = item['timestamp']?.toString();
      final k1 = h['kilo']?.toString();
      final k2 = item['kilo']?.toString();
      final f1 = h['feedCode']?.toString();
      final f2 = item['feedCode']?.toString();
      return t1 == t2 && k1 == k2 && f1 == f2;
    });
    boxDraft.write('draftHistory', list);
    update();
  }

  final boxDraft = GetStorage('draft');

  List<Map<String, dynamic>> get draftHistory {
    final list = boxDraft.read<List>('draftHistory') ?? [];
    return List<Map<String, dynamic>>.from(list);
  }

  void clearDraftHistory() {
    boxDraft.remove('draftHistory');
    update();
  }
}
