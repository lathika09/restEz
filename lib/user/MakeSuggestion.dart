import 'package:flutter/material.dart';

class MakeSuggestion extends StatefulWidget {
  const MakeSuggestion({super.key});

  @override
  State<MakeSuggestion> createState() => _MakeSuggestionState();
}

class _MakeSuggestionState extends State<MakeSuggestion> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            elevation: 3,
            title: const Text("Suggest Restroom", style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),)
        ),
        body:Container(),
    );
  }
}
