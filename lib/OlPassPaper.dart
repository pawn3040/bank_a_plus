import 'package:flutter/material.dart';

class OlPassPaper extends StatelessWidget {
  const OlPassPaper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OL pass paper'),
        backgroundColor: Colors.deepPurple,
      ),
      body: const Center(
        child: Text('OL pass paper Page'),
      ),
    );
  }
}
