import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../services/feed_code_service.dart';
import 'package:get_storage/get_storage.dart';

class FeedUseController extends GetxController {
  // Simpan draft timbang lokal sebelum submit ke Firebase
  final boxDraft = GetStorage('draft');

  // Ambil draft timbang lokal
  List<Map<String, dynamic>> get draftHistory {
    final list = boxDraft.read<List>('draftHistory') ?? [];
    return List<Map<String, dynamic>>.from(list);
  }

  void addDraftHistory(String feedCode, String kilo) {
    final newDraft = {
      'feedCode': feedCode,
      'kilo': kilo,
      'timestamp': DateTime.now().toIso8601String(),
    };
    final list = draftHistory;
    list.add(newDraft);
    boxDraft.write('draftHistory', list);
  }

  void clearDraftHistory() {
    boxDraft.remove('draftHistory');
  }

  // Simpan ke draft, bukan ke Firebase
  Future<void> saveFeedUseDraft() async {
    if (selectedFeedCode.value.isEmpty || kilo.value.isEmpty) {
      Get.snackbar('Gagal', 'Feed code dan kilo harus diisi');
      return;
    }
    addDraftHistory(selectedFeedCode.value, kilo.value);
    Get.snackbar('Sukses', 'Data timbang berhasil ditambahkan');
  }

  // Submit semua draft ke Firebase
  Future<void> submitDraftToFirebase() async {
    final drafts = draftHistory;
    if (drafts.isEmpty) {
      Get.snackbar('Info', 'Tidak ada data timbang untuk disubmit');
      return;
    }
    for (final draft in drafts) {
      final feedCode = draft['feedCode'] ?? '';
      final kilo = draft['kilo'] ?? '';
      final timestamp = draft['timestamp'] ?? DateTime.now().toIso8601String();
      try {
        final query = await FirebaseFirestore.instance
            .collection('data')
            .where('feedCode', isEqualTo: feedCode)
            .get();
        if (query.docs.isEmpty) continue;
        final docId = query.docs.first.id;
        await FirebaseFirestore.instance.collection('data').doc(docId).update({
          'history': FieldValue.arrayUnion([
            {'kilo': kilo, 'timestamp': timestamp},
          ]),
        });
      } catch (_) {}
    }
    clearDraftHistory();
    Get.snackbar('Sukses', 'Semua data timbang berhasil disimpan ke Firebase');
  }

  final box = GetStorage();

  var kilo = ''.obs;
  var avg = 0.0.obs;
  var feedCodes = <String>[].obs;
  var selectedFeedCode = ''.obs;

  void addKilo(String value) {
    kilo.value += value;
    calculateAvg();
  }

  void removeLast() {
    if (kilo.value.isNotEmpty) {
      kilo.value = kilo.value.substring(0, kilo.value.length - 1);
      calculateAvg();
    }
  }

  void clear() {
    kilo.value = '';
    avg.value = 0.0;
  }

  void calculateAvg() {
    if (kilo.value.isNotEmpty) {
      avg.value = double.tryParse(kilo.value) ?? 0.0;
    } else {
      avg.value = 0.0;
    }
  }

  final FeedCodeRepository _repo = FeedCodeRepository();

  Future<void> fetchFeedCodes() async {
    final data = await _repo.fetchFeedCodes();
    feedCodes.assignAll(data);
    box.write('feedCodes', data);
  }

  @override
  void onInit() {
    super.onInit();
    final savedCodes = box.read<List>('feedCodes');
    if (savedCodes != null) {
      feedCodes.assignAll(savedCodes.cast<String>());
    }

    final savedSelected = box.read('selectedFeedCode');
    if (savedSelected != null) {
      selectedFeedCode.value = savedSelected;
    }

    fetchFeedCodes();
  }

  void selectFeedCode(String code) {
    selectedFeedCode.value = code;
    box.write('selectedFeedCode', code);
  }
}
