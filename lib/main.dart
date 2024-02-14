import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:pdfviewer/viewer/pdfViewer.dart';
import 'package:receive_intent/receive_intent.dart';
import 'package:uri_to_file/uri_to_file.dart';

void main() {
  runApp(  const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {

  late File file;



  @override
  void initState() {
    super.initState();
    IntentHandler();
  }




  void IntentHandler() async{
    await _initReceiveIntent()?Timer(const Duration(seconds: 0),
            () =>
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder:
                    (context) =>

                    PdfViewer(file: file))
            )
    ):Timer(const Duration(seconds: 1),
            () =>
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder:
                    (context) =>
                    PdfViewer())

            )
    );
  }


  Future<bool> _initReceiveIntent() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {

      final receivedIntent = await ReceiveIntent.getInitialIntent();

      if(receivedIntent!.isNotNull){

        File file_ = await toFile(receivedIntent.data.toString());
        file=file_;




        return true;


      }

      return false;

      // Validate receivedIntent and warn the user, if it is not correct,
      // but keep in mind it could be `null` or "empty"(`receivedIntent.isNull`).
    } on PlatformException {
      // Handle exception
      return false;
    }
  }






  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child:Image.asset("assets/icon.jpg")
    );
  }
}
