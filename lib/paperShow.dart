import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaperShow extends StatefulWidget {
  final int grade;
  final String subject;
  final int term;

  const PaperShow({
    Key? key,
    required this.grade,
    required this.subject,
    required this.term,
  }) : super(key: key);

  @override
  State<PaperShow> createState() => _PaperShowState();
}

class _PaperShowState extends State<PaperShow> {
  List<dynamic> papers = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPapers();
  }

  Future<void> _fetchPapers() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final uri = Uri.parse(
        'http://localhost:8081/api/v1/paper/get_papers_by_grade_and_subject'
        '?grade=${widget.grade}&subject=${Uri.encodeComponent(widget.subject)}&term=${widget.term}',
      );
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          papers = data is List ? data : [];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load papers (${response.statusCode})';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F2FF),
      appBar: AppBar(
        title: Text(
          'Term ${widget.term} Papers',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF6C47FF),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEDE9FF), Color(0xFFF9F9FF)],
          ),
        ),
        child: Column(
          children: [
            // Info banner
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C47FF).withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C47FF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.library_books_rounded,
                      color: Color(0xFF6C47FF),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Grade ${widget.grade}  •  ${widget.subject}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Term ${widget.term} Past Papers',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF888888),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF6C47FF),
                      ),
                    )
                  : errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  color: Color(0xFF6C47FF),
                                  size: 56,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFF555555),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: _fetchPapers,
                                  icon: const Icon(Icons.refresh_rounded),
                                  label: const Text('Retry'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF6C47FF),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 28,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : papers.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.folder_open_rounded,
                                    color: Color(0xFFB0A0FF),
                                    size: 56,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'No papers found',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF888888),
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Check back later for updated papers.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFFAAAAAA),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              itemCount: papers.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final paper = papers[index];
                                final paperName =
                                    paper['paperName']?.toString() ??
                                        paper['name']?.toString() ??
                                        'Paper ${index + 1}';
                                final year = paper['year']?.toString() ?? '';
                                return _PaperCard(
                                  paperName: paperName,
                                  year: year,
                                  index: index,
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaperCard extends StatelessWidget {
  final String paperName;
  final String year;
  final int index;

  const _PaperCard({
    required this.paperName,
    required this.year,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFF6C47FF),
      const Color(0xFF2E7CF6),
      const Color(0xFF00BFA5),
    ];
    final color = colors[index % colors.length];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.description_rounded,
            color: color,
            size: 26,
          ),
        ),
        title: Text(
          paperName,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D2D2D),
          ),
        ),
        subtitle: year.isNotEmpty
            ? Text(
                'Year: $year',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF888888),
                ),
              )
            : null,
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.arrow_forward_ios_rounded,
            color: color,
            size: 16,
          ),
        ),
        onTap: () {
          // TODO: open paper PDF viewer
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opening: $paperName')),
          );
        },
      ),
    );
  }
}
