import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class DraftController extends GetxController {
  bool get canDeleteDraft => boxDraft.read('canDeleteDraft') == true;

  bool removeDraftItem(Map<String, dynamic> item) {
    if (boxDraft.read('canDeleteDraft') == false) {
      return false;
    }
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
    boxDraft.write('canDeleteDraft', false);
    update();
    return true;
  }

  final boxDraft = GetStorage('draft');

  List<Map<String, dynamic>> get draftHistory {
    final list = boxDraft.read<List>('draftHistory') ?? [];
    return List<Map<String, dynamic>>.from(list);
  }

  void clearDraftHistory() {
    boxDraft.remove('draftHistory');
    boxDraft.remove('canDeleteDraft');
    update();
  }
}
