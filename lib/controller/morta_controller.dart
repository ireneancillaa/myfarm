import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class MortaController extends GetxController {
  final boxDraft = GetStorage('draft_morta');

  bool get canDeleteDraft => boxDraft.read('canDeleteDraft') == true;

  List<Map<String, dynamic>> get draftHistory {
    final list = boxDraft.read<List>('draftHistory') ?? [];
    return List<Map<String, dynamic>>.from(list);
  }

  void addDraftHistory(String jenis, String ekor) {
    final newDraft = {
      'jenis': jenis,
      'ekor': ekor,
      'timestamp': DateTime.now().toIso8601String(),
    };
    final list = draftHistory;
    list.add(newDraft);
    boxDraft.write('draftHistory', list);
    boxDraft.write('canDeleteDraft', true);
  }

  void clearDraftHistory() {
    boxDraft.remove('draftHistory');
    boxDraft.remove('canDeleteDraft');
  }

  bool removeDraftItem(Map<String, dynamic> item) {
    if (boxDraft.read('canDeleteDraft') == false) {
      return false;
    }
    final list = draftHistory;
    list.removeWhere((h) {
      final t1 = h['timestamp']?.toString();
      final t2 = item['timestamp']?.toString();
      final e1 = h['ekor']?.toString();
      final e2 = item['ekor']?.toString();
      final j1 = h['jenis']?.toString();
      final j2 = item['jenis']?.toString();
      return t1 == t2 && e1 == e2 && j1 == j2;
    });
    boxDraft.write('draftHistory', list);
    boxDraft.write('canDeleteDraft', false);
    update();
    return true;
  }

  Future<void> saveMortaDraft() async {
    if (selectedJenis.value.isEmpty || ekor.value.isEmpty) {
      Get.snackbar('Gagal', 'Jenis dan ekor harus diisi');
      return;
    }
    addDraftHistory(selectedJenis.value, ekor.value);
    Get.snackbar('Sukses', 'Data morta berhasil ditambahkan');
  }

  Future<void> submitDraftToFirebase() async {
    final drafts = draftHistory;
    if (drafts.isEmpty) {
      Get.snackbar('Info', 'Tidak ada data morta untuk disubmit');
      return;
    }
    for (final draft in drafts) {
      final jenis = draft['jenis'] ?? '';
      final ekor = draft['ekor'] ?? '';
      final timestamp = draft['timestamp'] ?? DateTime.now().toIso8601String();
      String typeCollection = '';
      Map<String, dynamic> dataToAdd = {'ekor': ekor, 'timestamp': timestamp};
      if (jenis.toUpperCase() == 'MORT') {
        typeCollection = 'Type 1';
      } else if (jenis.toUpperCase() == 'CULL') {
        typeCollection = 'Type 2';
        dataToAdd['jenis'] = 'Cull';
      } else {
        continue;
      }
      try {
        final docRef = FirebaseFirestore.instance
            .collection('data')
            .doc('Feed 1')
            .collection('morta')
            .doc(typeCollection);
        await docRef.set({
          'history': FieldValue.arrayUnion([dataToAdd]),
        }, SetOptions(merge: true));
      } catch (e) {
        Get.snackbar('Error', 'Gagal menyimpan data ke Firebase: $e');
        return;
      }
    }
    clearDraftHistory();
    Get.snackbar('Sukses', 'Semua data morta berhasil disimpan ke Firebase');
  }

  final box = GetStorage();

  var ekor = ''.obs;
  var draftCount = 0.obs;
  var jenisList = <String>['MORT', 'CULL'].obs;
  var selectedJenis = ''.obs;

  void addEkor(String value) {
    if (value == '.' && ekor.value.contains('.')) return;
    ekor.value += value;
  }

  void removeLast() {
    if (ekor.value.isNotEmpty) {
      ekor.value = ekor.value.substring(0, ekor.value.length - 1);
    }
  }

  void clear() {
    ekor.value = '';
  }

  @override
  void onInit() {
    super.onInit();
    draftCount.value = draftHistory.length;
    boxDraft.listenKey('draftHistory', (value) {
      if (value != null) {
        draftCount.value = (value as List).length;
      } else {
        draftCount.value = 0;
      }
    });

    final savedSelected = box.read('selectedJenis');
    if (savedSelected != null) {
      selectedJenis.value = savedSelected;
    } else if (jenisList.isNotEmpty) {
      selectedJenis.value = jenisList.first;
    }
  }

  void selectJenis(String jenis) {
    selectedJenis.value = jenis;
    box.write('selectedJenis', jenis);
  }
}
