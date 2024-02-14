import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:receive_intent/receive_intent.dart';

class PdfViewer extends StatefulWidget {
  const PdfViewer({super.key, this.file = null});
  final file;

  @override
  State<PdfViewer> createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  bool isFilePicked = false;
  late Uint8List bytes;
  PdfViewerController pdfViewerController = PdfViewerController();
  String? selectedTextLines;
  bool isSearch = false;
  TextEditingController Controller = TextEditingController();
  dynamic prefs;
  @override
  void initState() {
    super.initState();

    setState(() {
      if (widget.file != null) {
        bytes = widget.file.readAsBytesSync();
        isFilePicked = true;
        _loadCounter();

      }
    });
  }
  Future<void> _loadCounter() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    prefs=_prefs;
      setState(() {
        pdfViewerController.jumpToPage(10);
      });

      //print('page no ${prefs.getInt(widget.file.path)}');




  }

  @override
  void dispose() {
    prefs.setInt(widget.file.path, pdfViewerController.pageNumber);

    super.dispose();
  }


  Future<dynamic> fetchAlbum(String text) async {
    try {
      final response = await http.get(Uri.parse(
          "https://api.dictionaryapi.dev/api/v2/entries/en/${text.replaceAll(new RegExp(r'[^\w\s]+'), '')}"));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse;
      } else {
        // Handle HTTP error
        return null;
      }
    } catch (e) {}
  }

  void _showToast(BuildContext context, String text) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 20),
        content: FutureBuilder<dynamic>(
          future: fetchAlbum(text),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasError) {
              print("something has wrong");
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            try {
              dynamic data = snapshot.data[0]["meanings"];
              dynamic definitions = data[0]["definitions"];
              dynamic partOfSpeech = data[0]['partOfSpeech'];
              dynamic synonyms = data[0]["synonyms"];

              return SizedBox(
                width: 180,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "partOfSpeech :${partOfSpeech!}",
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    if (synonyms != null) ...[
                      Text(
                        "synonyms :$synonyms",
                        maxLines: 4,
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                    ],
                    if (definitions[1]['definition'] != null) ...[
                      Text(
                        "definition :${definitions[1]['definition']!}",
                        maxLines: 4,
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                    ],
                    if (definitions[0]['example'] != null) ...[
                      Text(
                        "example :${definitions[0]['example']!}",
                        maxLines: 4,
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                    ],
                    if (definitions[0]['definition'] != null) ...[
                      Text(
                        "definition :${definitions[0]['definition']!}",
                        maxLines: 4,
                      ),
                    ]
                  ],
                ),
              );
            } catch (e) {
              return const Column(
                children: [
                  Text("Api responce is null"),
                ],
              );
            }
          },
        ),
        action: SnackBarAction(
            label: 'UNDO', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }

  void HandlePickedFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      setState(() {
        bytes = file.readAsBytesSync();
        isFilePicked = true;
      });
    } else {
      print("picked fail");
      // User canceled the picker
    }
  }




  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: InkWell(child:Text('PDF Viewer'),onTap: (){Navigator.pop(context);},),
        actions: <Widget>[
          isSearch
              ? SizedBox(
            height: 30,
                width: 200,
                child: Padding(
                  padding: const EdgeInsets.only(left: 0),
                  child: TextField(
                    controller: Controller,
                    onSubmitted: (text){
                      _showToast(context,text );
                    },

                    ),
                ),
              )
              : IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () async {
                    if (selectedTextLines != null) {

                      try {
                        _showToast(context, selectedTextLines!);
                      } catch (e) {
                      }
                    } else {
                      setState(() {
                        isSearch = true;
                      });

                    }
                    ;
                  })
        ],
      ),
      body: isFilePicked
          ? SfPdfViewer.memory(
            bytes,
            pageSpacing: 4,
            key: _pdfViewerKey,
            controller: pdfViewerController,
            onTextSelectionChanged: (PdfTextSelectionChangedDetails text) {
              String? Text = text.selectedText;
              selectedTextLines = Text;
            },
            onTap: (PdfGestureDetails){
              setState(() {
                isSearch=false;
                Controller.clear();
              });

            },

            canShowHyperlinkDialog: false,
            canShowPageLoadingIndicator: false,
            canShowPaginationDialog: false,
            enableDocumentLinkAnnotation: false,


          )
          : Center(
              heightFactor: 10,
              widthFactor: 10,
              child: ElevatedButton(
                child: const Text("Select .pdf file"),
                onPressed: () {
                  HandlePickedFile();
                },
              ),
            ),
    );
  }
}
