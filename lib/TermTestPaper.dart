import 'package:flutter/material.dart';

class TermTestPaper extends StatelessWidget {
  const TermTestPaper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> grades = [
      'Grade 06',
      'Grade 07',
      'Grade 08',
      'Grade 09',
      'Grade 10',
      'Grade 11',
      'Grade 12',
      'Grade 13',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Term Test Papers'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade50, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  'Select Your Grade',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: grades.length,
                  itemBuilder: (context, index) {
                    return _buildGradeButton(context, grades[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradeButton(BuildContext context, String grade) {
    return InkWell(
      onTap: () {
        // Handle grade selection
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selected $grade')),
        );
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.deepPurple.withOpacity(0.2)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.school, color: Colors.deepPurple, size: 30),
              const SizedBox(height: 8),
              Text(
                grade,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
