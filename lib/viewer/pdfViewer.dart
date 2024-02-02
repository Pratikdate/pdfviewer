import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';



class PdfViewer extends StatefulWidget {
  const PdfViewer({super.key});


  @override
  State<PdfViewer> createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  bool isFilePicked=false;
  late Uint8List bytes;
  PdfViewerController pdfViewerController= PdfViewerController();
  String? selectedTextLines;



  @override
  void initState() {
    super.initState();
  }

  Future<dynamic> fetchAlbum(String text) async {
    try {
      final response = await http.get(
          Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/$text'));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse;
      } else {
        // Handle HTTP error
        return null;
      }
    }catch(e){}
  }


  void _showToast(BuildContext context, String text) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 15),

        content: FutureBuilder<dynamic>(
          future: fetchAlbum(text),
          builder:  (BuildContext context,AsyncSnapshot<dynamic> snapshot){
            if(snapshot.hasError) {
              print("something has wrong");

            }

            if(snapshot.connectionState==ConnectionState.waiting){
              return Center(child: CircularProgressIndicator());
            }
            try {
              dynamic data = snapshot.data[0]["meanings"];
              dynamic definitions = data[0]["definitions"];


              return Column(

                children: [

                  Text("Definitions 1 : ${definitions[0]['definition']!}"),
                  SizedBox(height: 6,),
                  Text("Definitions 2 : ${definitions[1]['definition']!}"),
                  SizedBox(height: 6,),
                  Text("Definitions 3 : ${definitions[2]['definition']!}"),

                ],
              );
            }catch(e){
              return Column(

                children: [

                  Text("Api responce is null"),

                ],
              );
            }


          },
        ),
        action: SnackBarAction(label: 'UNDO', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }


  void HandlePickedFile()async{
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom,
      allowedExtensions: ['pdf'],);

    if (result != null) {
      File file = File(result.files.single.path!);
      setState(() {

        bytes = file.readAsBytesSync();
        isFilePicked=true;
       });

    } else {
      print("picked fail");
      // User canceled the picker
    }
  }

  @override
  Widget build(BuildContext context) {





    return  Scaffold(
        appBar: AppBar(
          title: const Text('PDF Viewer'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () async {

                if (selectedTextLines != null) {
                  print(selectedTextLines);
                  try {


                    if (kDebugMode) {

                      _showToast(context, selectedTextLines!);

                    }
                  } catch (e) {
                    if (kDebugMode) {
                      print(e);
                    }
                  }


                }
              },
            ),
          ],
        ),

        body: isFilePicked? Container(

          child: SfPdfViewer.memory(
            bytes,
            pageSpacing: 1,
            key: _pdfViewerKey,
            controller: pdfViewerController,
            onTextSelectionChanged: (PdfTextSelectionChangedDetails text){
              String? Text= text.selectedText;
              selectedTextLines=Text;

            },

            interactionMode: PdfInteractionMode.selection,
            canShowHyperlinkDialog: false,
            canShowPageLoadingIndicator: false,
            canShowPaginationDialog: false,
            enableDocumentLinkAnnotation: false,
            initialScrollOffset: Offset.infinite,



          ),
        )
            : Center(
              heightFactor: 10,
              widthFactor: 10,
              child: ElevatedButton(

                child: Text("Select .pdf file"),
                onPressed: () {

                  HandlePickedFile();


                },
              ),
            ),

        
    );


  }
}
