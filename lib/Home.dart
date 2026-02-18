import 'package:bank_a_plus/Grade5ScholarshipPassPaper.dart';
import 'package:bank_a_plus/OlPassPaper.dart';
import 'package:bank_a_plus/TermTestPaper.dart';
import 'package:flutter/material.dart';


class Home extends StatelessWidget {
  const Home({Key? key, required String title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('edica'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Term Test Paper
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TermTestPaper(),
                  ),
                );
              },
              child: const Text('Term test paper'),
            ),

            const SizedBox(height: 20),

            // OL Pass Paper
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OlPassPaper(),
                  ),
                );
              },
              child: const Text('OL pass paper'),
            ),

            const SizedBox(height: 20),

            // Grade 5 Scholarship
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const Grade5ScholarshipPassPaper(),
                  ),
                );
              },
              child: const Text('Grade 5 scholarship pass paper'),
            ),
          ],
        ),
      ),
    );
  }
}
