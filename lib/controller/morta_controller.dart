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

  void addDraftHistory(String mortaCode, String ekor) {
    final newDraft = {
      'mortaCode': mortaCode,
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
      final m1 = h['mortaCode']?.toString();
      final m2 = item['mortaCode']?.toString();
      return t1 == t2 && e1 == e2 && m1 == m2;
    });
    boxDraft.write('draftHistory', list);
    boxDraft.write('canDeleteDraft', false);
    update();
    return true;
  }

  Future<void> saveMortaDraft() async {
    if (selectedMortaCode.value.isEmpty || ekor.value.isEmpty) {
      Get.snackbar('Gagal', 'Morta code dan ekor harus diisi');
      return;
    }
    addDraftHistory(selectedMortaCode.value, ekor.value);
    Get.snackbar('Sukses', 'Data morta berhasil ditambahkan');
  }

  Future<void> submitDraftToFirebase() async {
    final drafts = draftHistory;
    if (drafts.isEmpty) {
      Get.snackbar('Info', 'Tidak ada data morta untuk disubmit');
      return;
    }
    for (final draft in drafts) {
      final mortaCode = draft['mortaCode'] ?? '';
      final ekor = draft['ekor'] ?? '';
      final timestamp = draft['timestamp'] ?? DateTime.now().toIso8601String();
      // Tentukan type berdasarkan mortaCode
      String typeCollection = '';
      Map<String, dynamic> dataToAdd = {'ekor': ekor, 'timestamp': timestamp};
      if (mortaCode.toUpperCase() == 'MORT') {
        typeCollection = 'Type 1';
      } else if (mortaCode.toUpperCase() == 'CULL') {
        typeCollection = 'Type 2';
        dataToAdd['jenis'] = 'Cull';
      } else {
        continue; // skip jika bukan morta/cull
      }
      try {
        // Cari dokumen morta pada koleksi sesuai type
        final docRef = FirebaseFirestore.instance
            .collection('data')
            .doc('Feed 1')
            .collection('morta')
            .doc(typeCollection);
        await docRef.set({
          'history': FieldValue.arrayUnion([dataToAdd]),
        }, SetOptions(merge: true));
      } catch (e) {
        // Bisa tambahkan log error jika perlu
      }
    }
    clearDraftHistory();
    Get.snackbar('Sukses', 'Semua data morta berhasil disimpan ke Firebase');
  }

  final box = GetStorage();

  var ekor = ''.obs;
  var draftCount = 0.obs;
  var mortaCodes = <String>['MORT', 'CULL'].obs;
  var selectedMortaCode = ''.obs;

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

    final savedSelected = box.read('selectedMortaCode');
    if (savedSelected != null) {
      selectedMortaCode.value = savedSelected;
    } else if (mortaCodes.isNotEmpty) {
      selectedMortaCode.value = mortaCodes.first;
    }
  }

  void selectMortaCode(String code) {
    selectedMortaCode.value = code;
    box.write('selectedMortaCode', code);
  }
}
