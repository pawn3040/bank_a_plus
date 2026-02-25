import 'package:flutter/material.dart';

class Grade5ScholarshipPassPaper extends StatelessWidget {
  const Grade5ScholarshipPassPaper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grade 5 Scholarship'),
        backgroundColor: Colors.green,
      ),
      body: const Center(
        child: Text('Grade 5 Scholarship Page Content'),
      ),
    );
  }
}
