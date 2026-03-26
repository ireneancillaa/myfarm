import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';
import 'dart:io';

class PdfPreviewPage extends StatefulWidget {
  final String title;
  final Uint8List pdfBytes;

  const PdfPreviewPage({
    super.key,
    required this.title,
    required this.pdfBytes,
  });

  @override
  State<PdfPreviewPage> createState() => _PdfPreviewPageState();
}

class _PdfPreviewPageState extends State<PdfPreviewPage> {
  String? localPath;

  @override
  void initState() {
    super.initState();
    loadPDF();
  }

  Future<void> loadPDF() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/preview_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(widget.pdfBytes.buffer.asUint8List(), flush: true);
      
      if (mounted) {
        setState(() => localPath = file.path);
      }
    } catch (e) {
      debugPrint("Error writing pdf file: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
              await Printing.sharePdf(bytes: widget.pdfBytes, filename: '${widget.title}.pdf');
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey.shade200,
      body: localPath != null
          ? PDFView(
              filePath: localPath!,
              enableSwipe: true,
              swipeHorizontal: true,
              autoSpacing: false,
              pageSnap: true,
              onRender: (pages) => debugPrint('Rendered $pages pages'),
              onError: (error) => debugPrint(error.toString()),
              onPageError: (page, error) => debugPrint('Error on page $page: $error'),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

