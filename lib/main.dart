import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pdfviewer/viewer/pdfViewer.dart';

void main() {
  runApp( const MyApp());
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 2000),
            ()=>Navigator.pushReplacement(context,
            MaterialPageRoute(builder:
                (context) =>
                const PdfViewer()
            )
        )
    );
  }
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: Image.asset("assets/icon.jpg")
    );
  }
}
