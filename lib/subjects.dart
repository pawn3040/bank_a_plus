import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'paperShow.dart';
import 'package:bank_a_plus/advertisement/advertisement_carousel.dart';
import 'package:bank_a_plus/widgets/network_error_widget.dart';

class Subjects extends StatefulWidget {
  final int term;
  final int? fixedGrade;

  const Subjects({
    Key? key,
    required this.term,
    this.fixedGrade,
  }) : super(key: key);

  @override
  State<Subjects> createState() => _SubjectsState();
}

class _SubjectsState extends State<Subjects> {
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

  List<String> subjectsList = [];
  bool isLoading = false;
  bool hasError = false;
  String? selectedGrade;

  @override
  void initState() {
    super.initState();
    if (widget.fixedGrade != null) {
      _fetchSubjects('Grade ${widget.fixedGrade}');
    }
  }

  Future<void> _fetchSubjects(String grade) async {
    setState(() {
      isLoading = true;
      hasError = false;
      selectedGrade = grade;
      subjectsList = [];
    });

    try {
      // Extract grade number from "Grade XX"
      final int gradeNum = int.parse(grade.split(' ').last);
      final response = await http.get(
        Uri.parse('http://192.168.8.117:8081/api/v1/paper/get_subjects_by_grade?grade=$gradeNum'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          subjectsList = data.map((item) => item.toString()).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // If it's a fixed grade, we use a nice title, otherwise we use the selected grade
    String getTitle() {
      if (widget.fixedGrade != null) {
        String base = "";
        if (widget.fixedGrade == 22) base = "A/L";
        else if (widget.fixedGrade == 21) base = "O/L";
        else if (widget.fixedGrade == 20) base = "Grade 5";
        else base = "Grade ${widget.fixedGrade}";
        return "$base Subjects (Term ${widget.term})";
      }
      return selectedGrade == null 
        ? 'Term ${widget.term} Papers' 
        : 'Subjects for $selectedGrade (Term ${widget.term})';
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        title: Text(
          getTitle(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.white),
          onPressed: () {
            if (selectedGrade != null && widget.fixedGrade == null) {
              setState(() {
                selectedGrade = null;
                subjectsList = [];
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Column(
        children: [
          const AdvertisementCarousel(),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(255, 107, 144, 232),
                    Color.fromARGB(255, 37, 111, 189),
                    Color.fromARGB(255, 119, 3, 148),
                    Color.fromARGB(255, 17, 216, 67),
                  ],
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
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          shadows: [
                            Shadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4)),
                          ]
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
                    if (hasError)
                      Expanded(
                        child: NetworkErrorWidget(
                          onRetry: () => _fetchSubjects(selectedGrade!),
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
                          itemCount: selectedGrade == null ? grades.length : subjectsList.length,
                          itemBuilder: (context, index) {
                            if (selectedGrade == null) {
                              return _buildGradeButton(context, grades[index]);
                            } else {
                              return _buildSubjectButton(context, subjectsList[index]);
                            }
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeButton(BuildContext context, String grade) {
    return InkWell(
      onTap: () => _fetchSubjects(grade),
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 30, 30, 30).withOpacity(0.85),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.school_rounded, color: Color(0xFF6366F1), size: 32),
              ),
              const SizedBox(height: 10),
              Text(
                grade,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.5,
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
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 30, 30, 30).withOpacity(0.85),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C47FF).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.menu_book_rounded, color: Color(0xFF6C47FF), size: 32),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  subject,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.3,
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
