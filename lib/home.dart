import 'package:flutter/material.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: ButtonBar(
            alignment: MainAxisAlignment.center,
            buttonHeight: 20,
            buttonMinWidth: 600,


          ),
        ),
      ),
    );
  }
}
