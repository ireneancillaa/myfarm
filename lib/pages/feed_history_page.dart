import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/feed_history_controller.dart';
import '../controller/feed_use_controller.dart';
import '../controller/feed_draft_controller.dart';

class FeedHistoryPage extends StatelessWidget {
  const FeedHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FeedHistoryController controller = Get.put(
      FeedHistoryController('ALL'),
    );
    final FeedDraftController draftController = Get.put(FeedDraftController());
    return GetBuilder<FeedDraftController>(
      builder: (_) {
        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: controller.allHistoryStream,
          builder: (context, snapshot) {
            final draftHistory = draftController.draftHistory;
            draftHistory.sort((a, b) {
              final aTime =
                  DateTime.tryParse(a['timestamp'] ?? '') ?? DateTime(0);
              final bTime =
                  DateTime.tryParse(b['timestamp'] ?? '') ?? DateTime(0);
              return bTime.compareTo(aTime);
            });
            final totalTimbang = draftHistory.length;
            final totalKilo = draftHistory.fold<double>(
              0.0,
              (sum, item) =>
                  sum + (double.tryParse(item['kilo'].toString()) ?? 0.0),
            );
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Get.back(),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.black),
                    tooltip: 'Hapus data terbaru',
                    onPressed: () async {
                      if (draftHistory.length > 1) {
                        final lastItem = draftHistory.last;
                        draftController.removeDraftItem(lastItem);
                      } else {
                        Get.snackbar(
                          'Info',
                          'Harus ada lebih dari satu item untuk menghapus.',
                        );
                      }
                    },
                  ),
                ],
                title: const Text(
                  'Riwayat Feed',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
                centerTitle: true,
              ),
              body: () {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (draftHistory.isEmpty) {
                  return const Center(child: Text('Tidak ada data history'));
                }
                return Column(
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                        ),
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
                          const Text(
                            'KILO ',
                            style: TextStyle(color: Colors.black54),
                          ),
                          Text(
                            totalKilo.toStringAsFixed(1),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Feed ${idx + 1}',
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                              ),
                              child: Row(
                                children: [
                                  const Text(
                                    'KILO ',
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                  Text(
                                    (double.tryParse(
                                          item['kilo'].toString(),
                                        )?.toStringAsFixed(1) ??
                                        '0.0'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'PROD ',
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                  Text(
                                    item['feedCode'] ?? '-',
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
                );
              }(),
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
                            final feedUseController =
                                Get.find<FeedUseController>();
                            final jmlh = draftHistory.length;
                            final kilo = draftHistory.fold<double>(
                              0.0,
                              (sum, item) =>
                                  sum +
                                  (double.tryParse(item['kilo'].toString()) ??
                                      0.0),
                            );
                            // final avg = jmlh > 0 ? kilo / jmlh : 0.0;
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) {
                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.warning,
                                        color: Colors.red,
                                        size: 48,
                                      ),
                                      const SizedBox(height: 8),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                                jmlh.toString(),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              const SizedBox(
                                                width: 48,
                                                child: Text(
                                                  'KILO',
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
                                                kilo.toStringAsFixed(1),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          // Row(
                                          //   children: [
                                          //     const SizedBox(
                                          //       width: 48,
                                          //       child: Text(
                                          //         'AVG',
                                          //         style: TextStyle(
                                          //           fontWeight: FontWeight.bold,
                                          //         ),
                                          //       ),
                                          //     ),
                                          //     const SizedBox(
                                          //       width: 18,
                                          //       child: Text(
                                          //         ':',
                                          //         textAlign: TextAlign.right,
                                          //       ),
                                          //     ),
                                          //     const SizedBox(width: 8),
                                          //     Text(
                                          //       avg.toStringAsFixed(1),
                                          //       style: const TextStyle(
                                          //         fontWeight: FontWeight.bold,
                                          //       ),
                                          //     ),
                                          //   ],
                                          // ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'Apabila sudah submit, maka tidak bisa edit/revisi data Feed ini kembali !!!',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          TextButton(
                                            onPressed: () async {
                                              Navigator.of(context).pop();
                                              await feedUseController
                                                  .submitDraftToFirebase();
                                              draftController
                                                  .clearDraftHistory();
                                              draftController.update();
                                            },

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
                                              await feedUseController
                                                  .submitDraftToFirebase();
                                              draftController
                                                  .clearDraftHistory();
                                              draftController.update();
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
                          child: const Text(
                            'SUBMIT FEED',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    )
                  : null,
            );
          },
        );
      },
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
