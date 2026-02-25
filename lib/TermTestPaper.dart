import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'paperShow.dart';

class TermTestPaper extends StatefulWidget {
  final int term;
  const TermTestPaper({Key? key, required this.term}) : super(key: key);

  @override
  State<TermTestPaper> createState() => _TermTestPaperState();
}

class _TermTestPaperState extends State<TermTestPaper> {
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

  List<String> subjects = [];
  bool isLoading = false;
  String? selectedGrade;

  Future<void> _fetchSubjects(String grade) async {
    setState(() {
      isLoading = true;
      selectedGrade = grade;
      subjects = [];
    });

    try {
      // Extract grade number from "Grade XX"
      final int gradeNum = int.parse(grade.split(' ').last);
      final response = await http.get(
        Uri.parse('http://localhost:8081/api/v1/paper/get_subjects_by_grade?grade=$gradeNum'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          subjects = data.map((item) => item.toString()).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load subjects');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedGrade == null ? 'Term ${widget.term} Papers' : 'Subjects for $selectedGrade (Term ${widget.term})'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (selectedGrade != null) {
              setState(() {
                selectedGrade = null;
                subjects = [];
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  selectedGrade == null ? 'Select Your Grade' : 'Select Subject',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
              if (isLoading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.5,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: selectedGrade == null ? grades.length : subjects.length,
                    itemBuilder: (context, index) {
                      if (selectedGrade == null) {
                        return _buildGradeButton(context, grades[index]);
                      } else {
                        return _buildSubjectButton(context, subjects[index]);
                      }
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
      onTap: () => _fetchSubjects(grade),
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

  Widget _buildSubjectButton(BuildContext context, String subject) {
    final int gradeNum = int.parse(selectedGrade!.split(' ').last);
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaperShow(
              grade: gradeNum,
              subject: subject,
              term: widget.term,
            ),
          ),
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
              const Icon(Icons.book, color: Colors.deepPurple, size: 30),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  subject,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
