import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/history_controller.dart';
import '../controller/feed_use_controller.dart';
import '../controller/morta_controller.dart';
import '../controller/draft_controller.dart';
import '../services/pdf_service.dart';
import 'feed_use_view.dart';
import 'morta_calculator_view.dart';
import 'pdf_preview_page.dart';

class SummaryPage extends StatefulWidget {
  final bool isMorta;
  const SummaryPage({super.key, this.isMorta = false});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  late HistoryController historyController;
  FeedUseController? feedUseCtrl;
  DraftController? feedDraftCtrl;
  MortaController? mortaCtrl;

  @override
  void initState() {
    super.initState();
    historyController = Get.put(HistoryController('ALL'));
    if (widget.isMorta) {
      mortaCtrl = Get.put(MortaController());
    } else {
      feedUseCtrl = Get.put(FeedUseController());
      feedDraftCtrl = Get.put(DraftController());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isMorta ? 'MORTALITY SUMMARY' : 'FEED USED SUMMARY',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const Text(
              'FARM JONI HERMAN 1A_802CF0000...',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
            onPressed: () async {
              try {
                final firebaseData = widget.isMorta
                    ? await historyController.allMortaHistoryStream.first
                    : await historyController.allHistoryStream.first;

                final draftData = widget.isMorta
                    ? (mortaCtrl?.draftHistory ?? [])
                    : (feedDraftCtrl?.draftHistory ?? []);

                final List<Map<String, dynamic>> combined = [
                  ...firebaseData.map((e) => {...e, 'isSubmitted': true}),
                  ...draftData.map((e) => {...e, 'isSubmitted': false}),
                ];

                combined.sort((a, b) {
                  final tA =
                      DateTime.tryParse(a['timestamp'] ?? '') ?? DateTime(0);
                  final tB =
                      DateTime.tryParse(b['timestamp'] ?? '') ?? DateTime(0);
                  return tB.compareTo(tA);
                });

                bool isAllSubmitted = combined.every(
                  (e) => e['isSubmitted'] == true,
                );

                final pdfBytes = await PdfService.generateSummaryPdf(
                  isMorta: widget.isMorta,
                  displayTitle: "All Summary",
                  items: combined,
                  isSubmitted: isAllSubmitted,
                  isAllSummary: true,
                );

                Get.to(
                  () =>
                      PdfPreviewPage(title: "All Summary", pdfBytes: pdfBytes),
                );
              } catch (e) {
                Get.snackbar('Gagal', 'Tidak dapat memuat PDF. Error: $e');
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: widget.isMorta
            ? historyController.allMortaHistoryStream
            : historyController.allHistoryStream,
        builder: (context, snapshot) {
          final firebaseData = snapshot.data ?? [];

          final draftData = widget.isMorta
              ? (mortaCtrl?.draftHistory ?? [])
              : (feedDraftCtrl?.draftHistory ?? []);

          final List<Map<String, dynamic>> combined = [
            ...firebaseData.map((e) => {...e, 'isSubmitted': true}),
            ...draftData.map((e) => {...e, 'isSubmitted': false}),
          ];

          combined.sort((a, b) {
            final tA = DateTime.tryParse(a['timestamp'] ?? '') ?? DateTime(0);
            final tB = DateTime.tryParse(b['timestamp'] ?? '') ?? DateTime(0);
            return tB.compareTo(tA);
          });

          if (combined.isEmpty) {
            return const Center(child: Text("Belum ada data"));
          }

          final Map<String, List<Map<String, dynamic>>> grouped = {};
          for (final item in combined) {
            final dtStr = item['timestamp'] as String?;
            if (dtStr == null) continue;
            String dateOnly = dtStr;
            try {
              final dt = DateTime.parse(dtStr);
              dateOnly =
                  '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
            } catch (_) {}

            if (!grouped.containsKey(dateOnly)) {
              grouped[dateOnly] = [];
            }
            grouped[dateOnly]!.add(item);
          }

          final sortedDates = grouped.keys.toList()
            ..sort((a, b) => b.compareTo(a));

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: sortedDates.length,
            itemBuilder: (context, index) {
              final dateKey = sortedDates[index];
              final items = grouped[dateKey]!;
              final isSubmitted = items.every((e) => e['isSubmitted'] == true);

              double totalNum = 0;
              for (final it in items) {
                totalNum += double.tryParse(_getValue(it)) ?? 0;
              }
              final totalStr = widget.isMorta
                  ? totalNum.toInt().toString()
                  : totalNum.toStringAsFixed(1);

              final firstItemTimestamp = items.last['timestamp'];
              String displayTitle = dateKey;
              if (firstItemTimestamp != null) {
                try {
                  final dt = DateTime.parse(firstItemTimestamp.toString());
                  displayTitle =
                      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
                      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
                } catch (_) {}
              }

              return Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                color: Colors.white,
                child: ExpansionTile(
                  shape: const RoundedRectangleBorder(side: BorderSide.none),
                  collapsedShape: const RoundedRectangleBorder(
                    side: BorderSide.none,
                  ),
                  title: Row(
                    children: [
                      Text(
                        displayTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        isSubmitted ? Icons.check_circle : Icons.remove_circle,
                        color: isSubmitted ? Colors.green : Colors.red,
                        size: 20,
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          Icons.picture_as_pdf,
                          color: Colors.black,
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () async {
                          try {
                            final pdfBytes =
                                await PdfService.generateSummaryPdf(
                                  isMorta: widget.isMorta,
                                  displayTitle: displayTitle,
                                  items: items,
                                  isSubmitted: isSubmitted,
                                );

                            Get.to(
                              () => PdfPreviewPage(
                                title: displayTitle,
                                pdfBytes: pdfBytes,
                              ),
                            );
                          } catch (e) {
                            Get.snackbar(
                              'Gagal Memuat PDF',
                              'Pastikan Anda sudah menghentikan (Stop) lalu nge-Run ulang aplikasinya.\nError: $e',
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                              duration: const Duration(seconds: 5),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.isMorta
                                ? "EKOR : $totalStr"
                                : "KILO : $totalStr",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const Divider(height: 24, thickness: 1),
                          ...items.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final it = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    width: 32,
                                    height: 32,
                                    alignment: Alignment.center,
                                    child: Text(
                                      "${idx + 1}",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    _getCode(it),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    "${_getValue(it)} ${widget.isMorta ? 'Ekor' : 'KG'}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: Colors.blue,
        onPressed: () {
          Get.to(() => const FeedUseView());
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  String _getValue(Map<String, dynamic> item) {
    final key = widget.isMorta ? 'ekor' : 'kilo';
    return item[key]?.toString() ?? '0';
  }

  String _getCode(Map<String, dynamic> item) {
    final key = widget.isMorta ? 'mortaCode' : 'feedCode';
    return item[key]?.toString() ?? '-';
  }
}
