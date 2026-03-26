import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myfarm/pages/feed_use_view.dart';
import '../controller/history_controller.dart';
import '../controller/feed_use_controller.dart';
import '../controller/draft_controller.dart';
import '../controller/morta_controller.dart';
import 'summary_page.dart';

class HistoryPage extends StatefulWidget {
  final bool isMorta;
  const HistoryPage({super.key, this.isMorta = false});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  void _updateUI() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    DraftController? feedDraftCtrl;
    FeedUseController? feedUseCtrl;
    MortaController? mortaCtrl;

    if (widget.isMorta) {
      mortaCtrl = Get.find<MortaController>();
    } else {
      Get.put(HistoryController('ALL'));
      feedDraftCtrl = Get.put(DraftController());
      feedUseCtrl = Get.find<FeedUseController>();
    }

    final draftHistory = widget.isMorta
        ? mortaCtrl!.draftHistory
        : feedDraftCtrl!.draftHistory;

    draftHistory.sort((a, b) {
      final aTime = DateTime.tryParse(a['timestamp'] ?? '') ?? DateTime(0);
      final bTime = DateTime.tryParse(b['timestamp'] ?? '') ?? DateTime(0);
      return aTime.compareTo(bTime);
    });

    final totalTimbang = draftHistory.length;
    final valueKey = widget.isMorta ? 'ekor' : 'kilo';
    final codeKey = widget.isMorta ? 'mortaCode' : 'feedCode';
    final labelQty = widget.isMorta ? 'EKOR' : 'KILO';
    final labelCode = widget.isMorta ? 'ALASAN' : 'PROD';
    final title = widget.isMorta ? 'Riwayat Morta' : 'Riwayat Feed';

    final totalValue = draftHistory.fold<double>(
      0.0,
      (sum, item) =>
          sum + (double.tryParse(item[valueKey]?.toString() ?? '0') ?? 0.0),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.off(() => FeedUseView()),
        ),
        actions: [
          Builder(
            builder: (context) {
              final canDelete = widget.isMorta
                  ? (mortaCtrl!.canDeleteDraft)
                  : (feedDraftCtrl!.canDeleteDraft);
              final isActive = draftHistory.isNotEmpty && canDelete;

              return IconButton(
                icon: Icon(
                  Icons.delete,
                  color: isActive ? Colors.black : Colors.grey,
                ),
                tooltip: isActive ? 'Hapus data terbaru' : null,
                onPressed: isActive
                    ? () {
                        final itemToDelete = draftHistory.last;
                        bool isDeleted = false;
                        if (widget.isMorta) {
                          isDeleted = mortaCtrl!.removeDraftItem(itemToDelete);
                        } else {
                          isDeleted = feedDraftCtrl!.removeDraftItem(
                            itemToDelete,
                          );
                        }
                        if (isDeleted) {
                          _updateUI();
                        }
                      }
                    : null,
              );
            },
          ),
        ],
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: draftHistory.isEmpty
          ? const Center(child: Text('Tidak ada data history'))
          : Column(
              children: [
                if (widget.isMorta)
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 15, color: Colors.black),
                      children: [
                        const TextSpan(text: 'Total '),
                        TextSpan(
                          text: '${totalValue.toInt()}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(text: ' Ekor'),
                      ],
                    ),
                  )
                else ...[
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 15, color: Colors.black),
                      children: [
                        const TextSpan(text: 'Total '),
                        TextSpan(
                          text: '$totalTimbang',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(text: ' Timbang'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$labelQty ',
                          style: const TextStyle(color: Colors.black54),
                        ),
                        Text(
                          totalValue.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
                if (draftHistory.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Divider(thickness: 1),
                  ),
                if (draftHistory.isNotEmpty) ...[
                  ...draftHistory.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final item = entry.value;
                    final isLast = idx == draftHistory.length - 1;
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 4,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '${widget.isMorta ? 'Morta' : 'Feed'} ${idx + 1}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                _formatDateTime(item['timestamp']),
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Row(
                            children: [
                              Text(
                                '$labelQty ',
                                style: const TextStyle(color: Colors.black54),
                              ),
                              Text(
                                widget.isMorta
                                    ? (double.tryParse(
                                            item[valueKey]?.toString() ?? '0',
                                          )?.toInt().toString() ??
                                          '0')
                                    : (double.tryParse(
                                            item[valueKey]?.toString() ?? '0',
                                          )?.toStringAsFixed(1) ??
                                          '0.0'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 12),
                              if (!widget.isMorta)
                                Text(
                                  '$labelCode ',
                                  style: const TextStyle(color: Colors.black54),
                                ),
                              Text(
                                item[codeKey] ?? '-',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isLast)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.0),
                            child: Divider(thickness: 1),
                          ),
                      ],
                    );
                  }),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Divider(thickness: 1),
                  ),
                ],
              ],
            ),
      bottomNavigationBar: draftHistory.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 25),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B4AC3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                  ),
                  onPressed: () async {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: Colors.white,
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                widget.isMorta
                                    ? Icons.warning_amber_rounded
                                    : Icons.warning_amber_outlined,
                                color: widget.isMorta
                                    ? const Color(0xFFF44336)
                                    : Colors.red,
                                size: widget.isMorta ? 72 : 48,
                              ),
                              SizedBox(height: widget.isMorta ? 16 : 8),
                              if (widget.isMorta)
                                Text(
                                  'TOTAL : ${totalValue.toInt()} EKOR',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              else
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const SizedBox(
                                          width: 48,
                                          child: Text(
                                            'JMLH',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 18,
                                          child: Text(
                                            ':',
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          totalTimbang.toString(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 48,
                                          child: Text(
                                            labelQty,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 18,
                                          child: Text(
                                            ':',
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          totalValue.toStringAsFixed(1),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              SizedBox(height: widget.isMorta ? 16 : 12),
                              Text(
                                widget.isMorta
                                    ? 'Apabila sudah submit, maka tidak bisa edit/revisi data Mortality ini kembali !!!'
                                    : 'Apabila sudah submit, maka tidak bisa edit/revisi data Feed ini kembali !!!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: widget.isMorta
                                      ? FontWeight.w500
                                      : FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      if (widget.isMorta) {
                                        await mortaCtrl!
                                            .submitDraftToFirebase();
                                      } else {
                                        await feedUseCtrl!
                                            .submitDraftToFirebase();
                                        feedDraftCtrl!.clearDraftHistory();
                                      }
                                      _updateUI();
                                    },
                                    child: const Text(
                                      'Submit',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: Text(
                    'SUBMIT ${widget.isMorta ? 'MORTALITY' : 'FEED'}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  String _formatDateTime(String? isoString) {
    if (isoString == null) return '';
    try {
      final dt = DateTime.parse(isoString);
      return '${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year} | ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoString;
    }
  }
}
