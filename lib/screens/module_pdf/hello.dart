import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

class PdfViewerPage extends StatefulWidget {
  const PdfViewerPage({super.key});

  @override
  _PdfViewerPageState createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  List<File> pdfFiles = [];

  @override
  void initState() {
    super.initState();
    loadPdfFiles();
  }

  Future<void> loadPdfFiles() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final directory = Directory(documentsDirectory.path);

    if (await directory.exists()) {
      final pdfFilesList = directory.listSync().where((file) {
        return file.path.endsWith('.pdf');
      }).toList();

      setState(() {
        pdfFiles = pdfFilesList.cast<File>();
      });
      pdfFiles.forEach((element) async {
        print('pdfFiles.length ${await element.length()}');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Future.wait([]);
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer'),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Số cột trong grid view
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
        ),
        itemCount: pdfFiles.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PdfViewPage(pdfFile: pdfFiles[index]),
                ),
              );
            },
            child: Card(
              elevation: 4.0,
              child: Center(
                child: Text(
                  'PDF ${index + 1}',
                  style: const TextStyle(fontSize: 18.0),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class PdfViewPage extends StatelessWidget {
  final File pdfFile;

  const PdfViewPage({super.key, required this.pdfFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer'),
      ),
      body: PDFView(
        filePath: pdfFile.path,
      ),
    );
  }
}
