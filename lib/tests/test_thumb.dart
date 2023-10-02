import 'package:color_parser/color_parser.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/widgets/w_thumb_slider.dart';

class TestThumb extends StatefulWidget {
  const TestThumb({super.key});

  @override
  State<TestThumb> createState() => _TestThumbState();
}

class _TestThumbState extends State<TestThumb> {
  FilePickerResult? result;
  @override
  Widget build(BuildContext context) {
     return MaterialApp(
       debugShowCheckedModeBanner: false,
       home: Scaffold(
          appBar: AppBar(
            title: const Text("File picker demo"),
         ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if(result != null)
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         const Text('Selected file:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: result?.files.length ?? 0,
                            itemBuilder: (context, index) {
                          return Text(result?.files[index].name ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold));
                        })
                      ],
                    ),),
              Center(
                child: ElevatedButton(
                  onPressed: () async{
                     
                  },
                  child: const Text("File Picker"),
                ),
              ),
 
            ],
          ),
        ),
     );
    }

}
