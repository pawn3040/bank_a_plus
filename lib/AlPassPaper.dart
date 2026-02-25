import 'package:flutter/material.dart';

class AlPassPaper extends StatelessWidget {
  const AlPassPaper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('A/L Pass Papers'),
        backgroundColor: Colors.deepPurple,
      ),
      body: const Center(
        child: Text('A/L Pass Papers Page Content'),
      ),
    );
  }
}
