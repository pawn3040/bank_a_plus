import 'package:flutter/material.dart';

class TermTestPaper extends StatelessWidget {
  const TermTestPaper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Term test paper'),
        backgroundColor: Colors.deepPurple,
      ),
      body: const Center(
        child: Text('Term test paper Page'),
      ),
    );
  }
}
