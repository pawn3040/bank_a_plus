import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:bank_a_plus/advertisement/advertisement_carousel.dart';
import 'package:bank_a_plus/widgets/network_error_widget.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';
import 'package:bank_a_plus/utils/web_download_helper.dart'
    if (dart.library.io) 'package:bank_a_plus/utils/web_download_helper_stub.dart';

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
  final String? discussionUrl;

  _Paper({
    required this.id,
    required this.pdfName,
    required this.medium,
    this.discussionUrl,
  });

  factory _Paper.fromJson(Map<String, dynamic> json) {
    return _Paper(
      id: json['id'] ?? 0,
      pdfName: json['pdfName']?.toString() ?? 'Paper',
      medium: json['medium']?.toString() ?? 'Unknown',
      discussionUrl: json['discussionUrl']?.toString(),
    );
  }
}

// ── State ─────────────────────────────────────────────────────────────────────
class _PaperShowState extends State<PaperShow> {
  static const String _baseUrl = 'http://192.168.8.117:8081/api/v1/paper';

  // medium order: Sinhala first, Tamil second, English third
  static const List<String> _mediumOrder = ['Sinhala', 'Tamil', 'English'];

  // medium colours
  static const Map<String, Color> _mediumColor = {
    'Sinhala': Color.fromARGB(255, 106, 69, 255),
    'Tamil': Color.fromARGB(255, 155, 5, 255),
    'English': Color.fromARGB(255, 87, 225, 77),
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
        errorMessage = 'Unable to fetch papers. Please try again later.';
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
      final uri = Uri.parse('$_baseUrl/download_paper?id=${paper.id}');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        // Ensure filename has .pdf extension
        String fileName = paper.pdfName;
        if (!fileName.toLowerCase().endsWith('.pdf')) {
          fileName += '.pdf';
        }

        if (kIsWeb) {
          // Web platform: Use blob URL to trigger download
          await downloadFileWeb(response.bodyBytes, fileName);
          _showSnack('Download started');
        } else {
          // Mobile/Desktop platforms: Use file system
          io.Directory? dir;
          try {
            // Try to get temporary directory
            dir = await getTemporaryDirectory();
          } catch (e) {
            // Fallback: try application documents directory
            try {
              dir = await getApplicationDocumentsDirectory();
            } catch (e2) {
              // Last resort: use system temp directory
              dir = io.Directory.systemTemp;
            }
          }
          
          final filePath = p.join(dir.path, fileName);
          final file = io.File(filePath);
          
          // Write the file
          await file.writeAsBytes(response.bodyBytes);
          
          // Use Share to open/save the file
          final result = await Share.shareXFiles(
            [XFile(filePath)],
            text: 'Sharing $fileName',
            subject: 'Edica Past Paper: ${widget.subject}',
          );

          if (result.status == ShareResultStatus.success) {
            _showSnack('File opened successfully');
          }
        }
      } else {
        _showSnack('Download failed (${response.statusCode})');
      }
    } catch (e) {
      String errorMsg = 'Download failed';
      if (e.toString().contains('MissingPluginException') || 
          e.toString().contains('_Namespace') ||
          e.toString().contains('Unsupported operation')) {
        errorMsg = 'Download error: ${e.toString()}';
      } else {
        errorMsg = 'Error: ${e.toString()}';
      }
      _showSnack(errorMsg);
    } finally {
      setState(() => _downloading[paper.id] = false);
    }
  }

  Future<void> _launchUrl(String? urlString) async {
    if (urlString == null || urlString.isEmpty) return;
    try {
      final Uri uri = Uri.parse(urlString);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        _showSnack('Could not open video link');
      }
    } catch (e) {
      _showSnack('Invalid video link');
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        toolbarHeight: 40,
        title: Text(
          'Papers',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: Colors.white,
            letterSpacing: 1.0,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.white),
          onPressed: () => Navigator.pop(context),
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
              child: Column(
                children: [
                 
                  Expanded(child: _buildBody()),
                ],
              ),
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
      return NetworkErrorWidget(
        onRetry: _fetchAllPapers,
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 38,
                  child: isDownloading
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: color),
                          ),
                        )
                      : ElevatedButton.icon(
                          onPressed: () => _downloadPaper(paper),
                          icon: const Icon(Icons.download_rounded, size: 16),
                          label: const Text('Download',
                              style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 0),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                ),
                if (paper.discussionUrl != null &&
                    paper.discussionUrl!.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 36,
                    child: OutlinedButton.icon(
                      onPressed: () => _launchUrl(paper.discussionUrl),
                      icon: const Icon(Icons.play_circle_fill_rounded,
                          size: 16, color: Colors.red),
                      label: const Text('Discussion',
                          style: TextStyle(fontSize: 12, color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red, width: 1.2),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
