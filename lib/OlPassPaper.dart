import 'package:flutter/material.dart';

class OlPassPaper extends StatelessWidget {
  const OlPassPaper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('O/L Pass Papers'),
        backgroundColor: Colors.blue,
      ),
      body: const Center(
        child: Text('O/L Pass Papers Page Content'),
      ),
    );
  }
}
