import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:bank_a_plus/advertisement/advertisement_carousel.dart';

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

// ── Data model ────────────────────────────────────────────────────────────────
class _Paper {
  final int id;
  final String pdfName;
  final String medium;

  _Paper({required this.id, required this.pdfName, required this.medium});

  factory _Paper.fromJson(Map<String, dynamic> json) {
    return _Paper(
      id: json['id'] ?? 0,
      pdfName: json['pdfName']?.toString() ?? 'Paper',
      medium: json['medium']?.toString() ?? 'Unknown',
    );
  }
}

// ── State ─────────────────────────────────────────────────────────────────────
class _PaperShowState extends State<PaperShow> {
  static const String _baseUrl = 'http://localhost:8081/api/v1/paper';

  // medium order: Sinhala first, Tamil second, English third
  static const List<String> _mediumOrder = ['Sinhala', 'Tamil', 'English'];

  // medium colours
  static const Map<String, Color> _mediumColor = {
    'Sinhala': Color(0xFF6C47FF),
    'Tamil': Color(0xFF2E7CF6),
    'English': Color(0xFF00BFA5),
  };

  bool isLoading = true;
  String? errorMessage;

  // grouped papers: { 'Sinhala': [...], 'Tamil': [...], 'English': [...] }
  Map<String, List<_Paper>> groupedPapers = {};

  // download progress per paper id
  Map<int, bool> _downloading = {};

  @override
  void initState() {
    super.initState();
    _fetchAllPapers();
  }

  // ── Fetch ───────────────────────────────────────────────────────────────────
  Future<void> _fetchAllPapers() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      groupedPapers = {};
    });

    try {
      final results = await Future.wait(
        _mediumOrder.map((medium) => _fetchByMedium(medium)),
      );

      final Map<String, List<_Paper>> grouped = {};
      for (int i = 0; i < _mediumOrder.length; i++) {
        if (results[i].isNotEmpty) {
          grouped[_mediumOrder[i]] = results[i];
        }
      }

      setState(() {
        groupedPapers = grouped;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<List<_Paper>> _fetchByMedium(String medium) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/search_paper'
        '?grade=${widget.grade}'
        '&term=${widget.term}'
        '&subject=${Uri.encodeComponent(widget.subject)}'
        '&medium=${Uri.encodeComponent(medium)}',
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map((e) => _Paper.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // ── Download ────────────────────────────────────────────────────────────────
  Future<void> _downloadPaper(_Paper paper) async {
    setState(() => _downloading[paper.id] = true);

    try {
      final uri =
          Uri.parse('$_baseUrl/download_paper?id=${paper.id}');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/${paper.pdfName}');
        await file.writeAsBytes(response.bodyBytes);
        await OpenFilex.open(file.path);
      } else {
        _showSnack('Download failed (${response.statusCode})');
      }
    } catch (e) {
      _showSnack('Error: ${e.toString()}');
    } finally {
      setState(() => _downloading[paper.id] = false);
    }
  }

  void _showSnack(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────────
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
      body: Column(
        children: [
          const AdvertisementCarousel(),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFEDE9FF), Color(0xFFF9F9FF)],
                ),
              ),
              child: Column(
                children: [
                  _buildInfoBanner(),
                  Expanded(child: _buildBody()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(14),
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
              size: 22,
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
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Term ${widget.term} Past Papers',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF6C47FF)),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: Color(0xFF6C47FF), size: 56),
              const SizedBox(height: 16),
              Text(errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF555555))),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _fetchAllPapers,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C47FF),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final bool isEmpty =
        groupedPapers.isEmpty || groupedPapers.values.every((l) => l.isEmpty);

    if (isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open_rounded, color: Color(0xFFB0A0FF), size: 56),
            SizedBox(height: 16),
            Text('No papers found',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF888888))),
            SizedBox(height: 6),
            Text('Check back later for updated papers.',
                style: TextStyle(fontSize: 13, color: Color(0xFFAAAAAA))),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF6C47FF),
      onRefresh: _fetchAllPapers,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          for (final medium in _mediumOrder)
            if (groupedPapers.containsKey(medium)) ...[
              _buildMediumHeader(medium),
              ...groupedPapers[medium]!.map((p) => _buildPaperCard(p, medium)),
              const SizedBox(height: 8),
            ],
        ],
      ),
    );
  }

  // ── Medium section header ───────────────────────────────────────────────────
  Widget _buildMediumHeader(String medium) {
    final color = _mediumColor[medium] ?? const Color(0xFF6C47FF);
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 22,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$medium Medium',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Divider(color: color.withOpacity(0.25), thickness: 1),
          ),
        ],
      ),
    );
  }

  // ── Individual paper card ───────────────────────────────────────────────────
  Widget _buildPaperCard(_Paper paper, String medium) {
    final color = _mediumColor[medium] ?? const Color(0xFF6C47FF);
    final isDownloading = _downloading[paper.id] ?? false;

    // derive a display name (strip extension if present)
    String displayName = paper.pdfName;
    if (displayName.toLowerCase().endsWith('.pdf')) {
      displayName = displayName.substring(0, displayName.length - 4);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // ── Icon ──────────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.picture_as_pdf_rounded, color: color, size: 26),
            ),
            const SizedBox(width: 12),

            // ── Name + badge ──────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      medium,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // ── Download button ───────────────────────────────────────────────
            SizedBox(
              height: 40,
              child: isDownloading
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: color),
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: () => _downloadPaper(paper),
                      icon: const Icon(Icons.download_rounded, size: 17),
                      label: const Text('Download',
                          style: TextStyle(fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
