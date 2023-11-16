import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_to_pdf/helpers/pdf/create_pdf.dart';
import 'package:photo_to_pdf/helpers/pdf/pdf_size.dart';
import 'package:photo_to_pdf/helpers/pdf/save_pdf.dart';

class BasicPage extends StatefulWidget {
  final List<String> listAssetLink;
  const BasicPage({super.key, required this.listAssetLink});

  @override
  State<BasicPage> createState() => _BasicPageState();
}

class _BasicPageState extends State<BasicPage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Hello")),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return Image.file(
            File(widget.listAssetLink[index]),
            height: 100,
            width: MediaQuery.sizeOf(context).width,
          );
        },
        itemCount: widget.listAssetLink.length,
        physics: BouncingScrollPhysics(),
      ),
    );
  }
}
