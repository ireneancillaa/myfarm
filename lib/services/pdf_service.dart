import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:device_info_plus/device_info_plus.dart';

class PdfService {
  static Future<Uint8List> generateSummaryPdf({
    required bool isMorta,
    required String displayTitle,
    required List<Map<String, dynamic>> items,
    required bool isSubmitted,
    bool isAllSummary = false,
  }) async {
    String deviceId = 'Unknown Device';
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? 'Unknown Device';
      }
    } catch (_) {}

    final pdf = pw.Document();

    double totalValue = 0;
    for (var item in items) {
      final key = isMorta ? 'ekor' : 'kilo';
      final valStr = item[key]?.toString() ?? '0';
      totalValue += double.tryParse(valStr) ?? 0;
    }

    final now = DateTime.now();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');
    final cetakStr = dateFormat.format(now);

    final rawTimestamp = items.isNotEmpty
        ? (items.last['timestamp']?.toString() ?? now.toIso8601String())
        : now.toIso8601String();
    DateTime historyDt = now;
    try {
      historyDt = DateTime.parse(rawTimestamp);
    } catch (_) {}
    final historyStr = dateFormat.format(historyDt);

    final statusStr = isSubmitted ? "Online ($cetakStr)" : "Offline";
    final tglSubmitStr = isSubmitted ? cetakStr : "-";

    double baseHeight = 400.0;
    if (!isMorta) baseHeight += 40.0;
    if (isAllSummary) {
      baseHeight += 60.0;
    }

    double itemHeight = isAllSummary ? 25.0 : 18.0;
    double estimatedHeight = baseHeight + (items.length * itemHeight);

    if (estimatedHeight < 800.0) {
      estimatedHeight = 800.0;
    }

    final customFormat = PdfPageFormat(110 * PdfPageFormat.mm, estimatedHeight);

    pdf.addPage(
      pw.Page(
        pageFormat: customFormat.copyWith(
          marginBottom: 12,
          marginTop: 12,
          marginLeft: 12,
          marginRight: 12,
        ),
        build: (pw.Context context) {
          if (isAllSummary) {
            if (isMorta) {
              return _buildMortaAllSummary(
                items,
                totalValue,
                cetakStr,
                deviceId,
                historyStr,
                statusStr,
                tglSubmitStr,
              );
            } else {
              return _buildFeedAllSummary(
                items,
                totalValue,
                cetakStr,
                deviceId,
                historyStr,
                statusStr,
                tglSubmitStr,
              );
            }
          }
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Text(
                isMorta ? 'Mortality' : 'Feed Used',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'FARM JONI HERMAN - SMSJ',
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.Text(
                'Ptk : FARM JONI HERMAN 1A',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 4),

              _buildMetaRow('Siklus', '802CF00006-02 - 2025 - 02'),
              _buildMetaRow(isMorta ? 'Tgl. Morta' : 'Tgl. Feed', historyStr),
              _buildMetaRow('Tgl. DOC In', '-'),
              _buildMetaRow('Doc In', isMorta ? '0' : '0.0'),
              _buildMetaRow('Umur', '1 HARI'),
              pw.SizedBox(height: 4),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 4),

              // --- SELALU TAMPILKAN HEADER 2 KOLOM ---
              pw.Row(
                children: [
                  pw.Expanded(child: _buildHeaderRow(isMorta)),
                  pw.SizedBox(width: 8),
                  pw.Expanded(child: _buildHeaderRow(isMorta)),
                ],
              ),
              pw.SizedBox(height: 4),

              // --- PEMBAGIAN DATA OTOMATIS KIRI KANAN ---
              () {
                final leftCount = (items.length + 1) ~/ 2;
                return pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        children: [
                          for (var i = 0; i < leftCount; i++)
                            _buildItemRow(i, items[i], isMorta),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Expanded(
                      child: pw.Column(
                        children: [
                          for (var i = leftCount; i < items.length; i++)
                            _buildItemRow(i, items[i], isMorta),
                        ],
                      ),
                    ),
                  ],
                );
              }(),

              pw.SizedBox(height: 4),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 4),

              if (!isMorta) ...[
                _buildMetaRow('Total Berat', totalValue.toStringAsFixed(1)),
              ] else ...[
                _buildMetaRow('Total Ekor', totalValue.toInt().toString()),
              ],
              pw.SizedBox(height: 4),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 4),

              _buildMetaRow('Bluetooth', 'Y'),
              _buildMetaRow('Catatan', ''),
              _buildMetaRow('Created By', 'gunawan.susanto@pkt.co.id'),
              _buildMetaRow('PDF Status', statusStr),
              _buildMetaRow('Tgl. Submit', tglSubmitStr),
              _buildMetaRow('Tgl. Cetak', cetakStr),
              pw.SizedBox(height: 4),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 8),
              pw.Text(
                'Terima kasih',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              if (isMorta) ...[
                pw.Text(
                  'Data Mortality yang sudah diinput tidak dapat direvisi',
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ] else ...[
                pw.Text(
                  'Timbangan telah disetujui dengan pin digital approval',
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  'Ayam yang sudah ditimbang tidak dapat ditukar/dikembalikan',
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
              pw.SizedBox(height: 6),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'version 2.0.18 (17 Maret 2026)',
                      style: pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey500,
                        fontStyle: pw.FontStyle.italic,
                      ),
                    ),
                    pw.Text(
                      deviceId,
                      style: pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey500,
                        fontStyle: pw.FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // ---- WIDGET ALL SUMMARY MORTALITY DENGAN 2 KOLOM ----
  static pw.Widget _buildMortaAllSummary(
    List<Map<String, dynamic>> items,
    double totalValue,
    String cetakStr,
    String deviceId,
    String historyStr,
    String statusStr,
    String tglSubmitStr,
  ) {
    final Map<String, Map<String, double>> grouped = {};
    for (var item in items) {
      final ts = item['timestamp']?.toString() ?? '';
      String date = '';
      if (ts.length >= 10) date = ts.substring(0, 10);
      final code = item['mortaCode']?.toString() ?? 'MORT';
      final qty = double.tryParse(item['ekor']?.toString() ?? '0') ?? 0;

      if (!grouped.containsKey(date)) grouped[date] = {};
      grouped[date]![code] = (grouped[date]![code] ?? 0) + qty;
    }

    final sortedDates = grouped.keys.toList()..sort();

    // Flatten data untuk dibagi 2 kolom
    final List<Map<String, dynamic>> flatData = [];
    for (var date in sortedDates) {
      final typesList = grouped[date]!.entries.toList();
      for (var i = 0; i < typesList.length; i++) {
        flatData.add({
          'date': i == 0 ? date : '',
          'type': typesList[i].key,
          'qty': typesList[i].value,
        });
      }
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Text(
          'Summary Mortality',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          'FARM JONI HERMAN - SMSJ',
          style: const pw.TextStyle(fontSize: 10),
        ),
        pw.Text(
          'Ptk : FARM JONI HERMAN 1A',
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Divider(borderStyle: pw.BorderStyle.dashed),
        pw.SizedBox(height: 4),

        _buildMetaRow('Siklus', '802CF00006-02 - 2025 - 02'),
        _buildMetaRow('Tgl. Morta', historyStr),
        _buildMetaRow('Tgl. DOC In', '-'),
        _buildMetaRow('Doc In', '0'),
        _buildMetaRow('Umur', '1 HARI'),

        pw.SizedBox(height: 4),
        pw.Divider(borderStyle: pw.BorderStyle.dashed),
        pw.SizedBox(height: 4),

        // HEADER 2 KOLOM
        pw.Row(
          children: [
            pw.Expanded(child: _buildAllMortaHeader()),
            pw.SizedBox(width: 8),
            pw.Expanded(child: _buildAllMortaHeader()),
          ],
        ),
        pw.SizedBox(height: 4),

        // DATA 2 KOLOM
        () {
          final leftCount = (flatData.length + 1) ~/ 2;
          return pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  children: List.generate(
                    leftCount,
                    (i) => _buildAllMortaItemRow(i, flatData[i]),
                  ),
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: pw.Column(
                  children: List.generate(
                    flatData.length - leftCount,
                    (i) => _buildAllMortaItemRow(
                      leftCount + i,
                      flatData[leftCount + i],
                    ),
                  ),
                ),
              ),
            ],
          );
        }(),

        pw.SizedBox(height: 4),
        pw.Divider(borderStyle: pw.BorderStyle.dashed),
        pw.SizedBox(height: 4),
        _buildMetaRow('Total Ekor', totalValue.toInt().toString()),
        pw.SizedBox(height: 4),
        pw.Divider(borderStyle: pw.BorderStyle.dashed),
        pw.SizedBox(height: 4),
        _buildMetaRow('Bluetooth', 'Y'),
        _buildMetaRow('Catatan', ''),
        _buildMetaRow('Created By', 'gunawan.susanto@pkt.co.id'),
        _buildMetaRow('PDF Status', statusStr),
        _buildMetaRow('Tgl. Submit', tglSubmitStr),
        _buildMetaRow('Tgl. Cetak', cetakStr),
        pw.SizedBox(height: 4),
        pw.Divider(borderStyle: pw.BorderStyle.dashed),
        pw.SizedBox(height: 8),
        pw.Text(
          'Terima kasih',
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          'Data Mortality yang sudah diinput tidak dapat direvisi',
          textAlign: pw.TextAlign.center,
          style: const pw.TextStyle(fontSize: 9),
        ),
        pw.SizedBox(height: 6),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'version 2.0.18 (17 Maret 2026)',
                style: pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey500,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
              pw.Text(
                deviceId,
                style: pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey500,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
              pw.Text(
                'TP1A.220624.014',
                style: pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey500,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---- WIDGET ALL SUMMARY FEED DENGAN 2 KOLOM ----
  static pw.Widget _buildFeedAllSummary(
    List<Map<String, dynamic>> items,
    double totalValue,
    String cetakStr,
    String deviceId,
    String historyStr,
    String statusStr,
    String tglSubmitStr,
  ) {
    final Map<String, Map<String, Map<String, dynamic>>> grouped = {};

    for (var item in items) {
      final ts = item['timestamp']?.toString() ?? '';
      String date = '';
      if (ts.length >= 10) date = ts.substring(0, 10);
      final code = item['feedCode']?.toString() ?? 'PROD';
      final qty = double.tryParse(item['kilo']?.toString() ?? '0') ?? 0;

      if (!grouped.containsKey(date)) grouped[date] = {};
      if (!grouped[date]!.containsKey(code))
        grouped[date]![code] = {'jmlh': 0, 'kilo': 0.0};

      grouped[date]![code]!['jmlh'] =
          (grouped[date]![code]!['jmlh'] as int) + 1;
      grouped[date]![code]!['kilo'] =
          (grouped[date]![code]!['kilo'] as double) + qty;
    }

    final sortedDates = grouped.keys.toList()..sort();

    // Flatten data untuk dibagi 2 kolom
    final List<Map<String, dynamic>> flatData = [];
    for (var date in sortedDates) {
      final typesList = grouped[date]!.entries.toList();
      for (var i = 0; i < typesList.length; i++) {
        flatData.add({
          'date': i == 0 ? date : '',
          'code': typesList[i].key,
          'jmlh': typesList[i].value['jmlh'],
          'kilo': typesList[i].value['kilo'],
        });
      }
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Text(
          'Summary Feed Used',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          'FARM JONI HERMAN - SMSJ',
          style: const pw.TextStyle(fontSize: 10),
        ),
        pw.Text(
          'Ptk : FARM JONI HERMAN 1A',
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Divider(borderStyle: pw.BorderStyle.dashed),
        pw.SizedBox(height: 4),

        _buildMetaRow('Siklus', '802CF00006-02 - 2025 - 02'),
        _buildMetaRow('Tgl. Feed', historyStr),
        _buildMetaRow('Tgl. DOC In', '-'),
        _buildMetaRow('Doc In', '0.0'),
        _buildMetaRow('Umur', '1 HARI'),

        pw.SizedBox(height: 4),
        pw.Divider(borderStyle: pw.BorderStyle.dashed),
        pw.SizedBox(height: 4),

        // HEADER 2 KOLOM
        pw.Row(
          children: [
            pw.Expanded(child: _buildAllFeedHeader()),
            pw.SizedBox(width: 8),
            pw.Expanded(child: _buildAllFeedHeader()),
          ],
        ),
        pw.SizedBox(height: 4),

        // DATA 2 KOLOM
        () {
          final leftCount = (flatData.length + 1) ~/ 2;
          return pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  children: List.generate(
                    leftCount,
                    (i) => _buildAllFeedItemRow(i, flatData[i]),
                  ),
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: pw.Column(
                  children: List.generate(
                    flatData.length - leftCount,
                    (i) => _buildAllFeedItemRow(
                      leftCount + i,
                      flatData[leftCount + i],
                    ),
                  ),
                ),
              ),
            ],
          );
        }(),

        pw.SizedBox(height: 4),
        pw.Divider(borderStyle: pw.BorderStyle.dashed),
        pw.SizedBox(height: 4),
        _buildMetaRow('Total Berat', totalValue.toStringAsFixed(1)),
        pw.SizedBox(height: 4),
        pw.Divider(borderStyle: pw.BorderStyle.dashed),
        pw.SizedBox(height: 4),
        _buildMetaRow('Bluetooth', 'Y'),
        _buildMetaRow('Catatan', ''),
        _buildMetaRow('Created By', 'gunawan.susanto@pkt.co.id'),
        _buildMetaRow('PDF Status', statusStr),
        _buildMetaRow('Tgl. Submit', tglSubmitStr),
        _buildMetaRow('Tgl. Cetak', cetakStr),
        pw.SizedBox(height: 4),
        pw.Divider(borderStyle: pw.BorderStyle.dashed),
        pw.SizedBox(height: 8),
        pw.Text(
          'Terima kasih',
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          'Data Feed yang sudah diinput tidak dapat direvisi',
          textAlign: pw.TextAlign.center,
          style: const pw.TextStyle(fontSize: 9),
        ),
        pw.SizedBox(height: 6),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'version 2.0.18 (17 Maret 2026)',
                style: pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey500,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
              pw.Text(
                deviceId,
                style: pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey500,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
              pw.Text(
                'TP1A.220624.014',
                style: pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey500,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---- HELPER UMUM ----
  static pw.Widget _buildMetaRow(String label, String value) {
    final isPdfStatus = label == 'PDF Status';
    final isOffline = isPdfStatus && value.toLowerCase().contains('offline');
    final displayValue = isOffline ? value.toUpperCase() : value;
    final valueStyle = isOffline
        ? pw.TextStyle(
            fontSize: 10,
            color: PdfColors.red,
            fontWeight: pw.FontWeight.bold,
          )
        : const pw.TextStyle(fontSize: 10);

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 80,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Text(
            ' : ',
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
          pw.Expanded(child: pw.Text(displayValue, style: valueStyle)),
        ],
      ),
    );
  }

  // ---- HELPER TABEL HARIAN ----
  static pw.Widget _buildHeaderRow(bool isMorta) {
    if (isMorta) {
      return pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(
            flex: 1,
            child: pw.Text(
              'No.',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(
            flex: 2,
            child: pw.Text(
              'TYPE',
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(
            flex: 1,
            child: pw.Text(
              'EKOR',
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      );
    } else {
      return pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(
            flex: 1,
            child: pw.Text(
              'No.',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(
            flex: 2,
            child: pw.Text(
              'PROD',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(
            flex: 1,
            child: pw.Text(
              'JMLH',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(
            flex: 1,
            child: pw.Text(
              'KILO',
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      );
    }
  }

  static pw.Widget _buildItemRow(
    int idx,
    Map<String, dynamic> item,
    bool isMorta,
  ) {
    final codeKey = isMorta ? 'jenis' : 'feedCode';
    final valKey = isMorta ? 'ekor' : 'kilo';
    final code = item[codeKey]?.toString() ?? '-';
    final qty = item[valKey]?.toString() ?? '0';

    if (isMorta) {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 2),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Expanded(
              flex: 1,
              child: pw.Text(
                '${idx + 1}.',
                style: const pw.TextStyle(fontSize: 10),
              ),
            ),
            pw.Expanded(
              flex: 2,
              child: pw.Text(
                code,
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(fontSize: 10),
              ),
            ),
            pw.Expanded(
              flex: 1,
              child: pw.Text(
                qty,
                textAlign: pw.TextAlign.right,
                style: const pw.TextStyle(fontSize: 10),
              ),
            ),
          ],
        ),
      );
    } else {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 2),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Expanded(
              flex: 1,
              child: pw.Text(
                '${idx + 1}.',
                style: const pw.TextStyle(fontSize: 10),
              ),
            ),
            pw.Expanded(
              flex: 2,
              child: pw.Text(code, style: const pw.TextStyle(fontSize: 10)),
            ),
            pw.Expanded(
              flex: 1,
              child: pw.Text('1', style: const pw.TextStyle(fontSize: 10)),
            ),
            pw.Expanded(
              flex: 1,
              child: pw.Text(
                qty,
                textAlign: pw.TextAlign.right,
                style: const pw.TextStyle(fontSize: 10),
              ),
            ),
          ],
        ),
      );
    }
  }

  // ---- HELPER TABEL ALL SUMMARY MORTALITY ----
  static pw.Widget _buildAllMortaHeader() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Expanded(
          flex: 1,
          child: pw.Text(
            'No.',
            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Expanded(
          flex: 3,
          child: pw.Text(
            'Tanggal',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Expanded(
          flex: 2,
          child: pw.Text(
            'TYPE',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Expanded(
          flex: 1,
          child: pw.Text(
            'EKOR',
            textAlign: pw.TextAlign.right,
            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildAllMortaItemRow(int idx, Map<String, dynamic> data) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 1,
            child: pw.Text(
              '${idx + 1}.',
              style: const pw.TextStyle(fontSize: 8),
            ),
          ),
          pw.Expanded(
            flex: 3,
            child: pw.Text(
              data['date'],
              textAlign: pw.TextAlign.center,
              style: const pw.TextStyle(fontSize: 8),
            ),
          ),
          pw.Expanded(
            flex: 2,
            child: pw.Text(
              data['type'],
              textAlign: pw.TextAlign.center,
              style: const pw.TextStyle(fontSize: 8),
            ),
          ),
          pw.Expanded(
            flex: 1,
            child: pw.Text(
              (data['qty'] as double).toInt().toString(),
              textAlign: pw.TextAlign.right,
              style: const pw.TextStyle(fontSize: 8),
            ),
          ),
        ],
      ),
    );
  }

  // ---- HELPER TABEL ALL SUMMARY FEED ----
  static pw.Widget _buildAllFeedHeader() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Expanded(
          flex: 1,
          child: pw.Text(
            'No.',
            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Expanded(
          flex: 3,
          child: pw.Text(
            'Tanggal',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Expanded(
          flex: 2,
          child: pw.Text(
            'PROD',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Expanded(
          flex: 1,
          child: pw.Text(
            'JMLH',
            textAlign: pw.TextAlign.right,
            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Expanded(
          flex: 1,
          child: pw.Text(
            'KILO',
            textAlign: pw.TextAlign.right,
            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildAllFeedItemRow(int idx, Map<String, dynamic> data) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 1,
            child: pw.Text(
              '${idx + 1}.',
              style: const pw.TextStyle(fontSize: 8),
            ),
          ),
          pw.Expanded(
            flex: 3,
            child: pw.Text(
              data['date'],
              textAlign: pw.TextAlign.center,
              style: const pw.TextStyle(fontSize: 8),
            ),
          ),
          pw.Expanded(
            flex: 2,
            child: pw.Text(
              data['code'],
              textAlign: pw.TextAlign.center,
              style: const pw.TextStyle(fontSize: 8),
            ),
          ),
          pw.Expanded(
            flex: 1,
            child: pw.Text(
              data['jmlh'].toString(),
              textAlign: pw.TextAlign.right,
              style: const pw.TextStyle(fontSize: 8),
            ),
          ),
          pw.Expanded(
            flex: 1,
            child: pw.Text(
              (data['kilo'] as double).toStringAsFixed(1),
              textAlign: pw.TextAlign.right,
              style: const pw.TextStyle(fontSize: 8),
            ),
          ),
        ],
      ),
    );
  }
}
