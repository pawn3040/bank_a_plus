import 'package:bank_a_plus/selectTerm.dart';
import 'package:bank_a_plus/subjects.dart';
import 'package:bank_a_plus/paperShow.dart';
import 'package:bank_a_plus/theme/edica_palette.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:bank_a_plus/utils/web_download_helper.dart'
    if (dart.library.io) 'package:bank_a_plus/utils/web_download_helper_stub.dart';


class Home extends StatefulWidget {
  const Home({Key? key, required String title}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<dynamic> _specialPapers = [];
  bool _isLoadingSpecial = true;
  final Map<int, bool> _downloading = {};

  @override
  void initState() {
    super.initState();
    _fetchSpecialPapers();
  }

  Future<void> _fetchSpecialPapers() async {
    try {
      final mediums = ['Sinhala', 'Tamil', 'English'];
      final List<dynamic> allFetched = [];
      
      final results = await Future.wait(mediums.map((m) => http.get(
        Uri.parse('http://192.168.8.117:8081/api/v1/paper/search_paper?grade=30&term=1&subject=sp&medium=$m')
      )));

      for (var response in results) {
        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          allFetched.addAll(data);
        }
      }

      if (mounted) {
        setState(() {
          _specialPapers = allFetched;
          _isLoadingSpecial = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingSpecial = false);
      }
    }
  }

  Future<void> _downloadPaper(dynamic paper) async {
    final int paperId = paper['id'];
    final String pdfName = paper['pdfName'] ?? 'Paper';
    
    setState(() => _downloading[paperId] = true);

    try {
      final response = await http.get(Uri.parse('http://192.168.8.117:8081/api/v1/paper/download_paper?id=$paperId'));

      if (response.statusCode == 200) {
        String fileName = pdfName;
        if (!fileName.toLowerCase().endsWith('.pdf')) fileName += '.pdf';

        if (kIsWeb) {
          await downloadFileWeb(response.bodyBytes, fileName);
        } else {
          final dir = await getTemporaryDirectory();
          final filePath = p.join(dir.path, fileName);
          final file = io.File(filePath);
          await file.writeAsBytes(response.bodyBytes);
          await Share.shareXFiles([XFile(filePath)], text: '$pdfName');
        }
      }
    } catch (e) {
      debugPrint('Download error: $e');
    } finally {
      if (mounted) {
        setState(() => _downloading[paperId] = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!_isLoadingSpecial && _specialPapers.isNotEmpty) ...[
                _buildSpecialResourceSection(),
               // const SizedBox(height: 24),
              ],
              const SizedBox(height: 8),
              _buildCategoryCard(
                context,
                'Term Test Papers',
                'Grades 06 - 13',
                Icons.assignment_outlined,
                const [
                  EdicaPalette.indigo,
                  EdicaPalette.sky,
                ],
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SelectTerm()),
                ),
              ),
              const SizedBox(height: 16),
              _buildCategoryCard(
                context,
                'A/L Pass Papers',
                'Advanced Level',
                Icons.history_edu_rounded,
                const [
                  EdicaPalette.purple,
                  EdicaPalette.indigo,
                ],
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Subjects(term: 3, fixedGrade: 22)),
                ),
              ),
  
              const SizedBox(height: 16),
              _buildCategoryCard(
                context,
                'OL Pass Papers',
                'Ordinary Level',
                Icons.menu_book_rounded,
                const [
                  EdicaPalette.sky,
                  EdicaPalette.indigo,
                ],
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Subjects(term: 3, fixedGrade: 21)),
                ),
              ),
              const SizedBox(height: 16),
              _buildCategoryCard(
                context,
                'Grade 5 Scholarship',
                'Primary School',
                Icons.stars_rounded,
                const [
                  EdicaPalette.green,
                  EdicaPalette.purple,
                ],
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PaperShow(grade: 20, subject: "s5", term: 3),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialResourceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
    
        ),
        ..._specialPapers.map((paper) => _buildSpecialPaperCard(paper)).toList(),
      ],
    );
  }

  Widget _buildSpecialPaperCard(dynamic paper) {
    final int paperId = paper['id'];
    final bool isDownloading = _downloading[paperId] ?? false;
    final String medium = paper['medium'] ?? 'Unknown';
    final String pdfName = paper['pdfName'] ?? 'Special Paper';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: EdicaPalette.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [EdicaPalette.surface, EdicaPalette.surface2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFF6366F1), size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pdfName,
                          style: const TextStyle(
                            color: EdicaPalette.onSurface,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          medium,
                          style: const TextStyle(
                            color: EdicaPalette.onSurfaceMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 38,
                    child: isDownloading
                        ? const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6366F1)),
                            ),
                          )
                        : ElevatedButton(
                            onPressed: () => _downloadPaper(paper),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Download', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    List<Color> gradientColors,
    VoidCallback onTap,
  ) {
    final accent1 = gradientColors[0];
    final accent2 = gradientColors[1];
    final accent = Color.lerp(accent1, accent2, 0.5) ?? accent2;

    return Container(
      decoration: BoxDecoration(
        color: EdicaPalette.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.55),
            blurRadius: 26,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // dark surface background + subtle accent glow
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: [
                        EdicaPalette.surface,
                        EdicaPalette.surface2,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
                  ),
                ),
              ),
              // decorative accent glows
              Positioned(
                right: -26,
                top: -18,
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: accent1.withOpacity(0.22),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                right: 18,
                bottom: -22,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: accent2.withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            accent1.withOpacity(0.95),
                            accent2.withOpacity(0.95),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withOpacity(0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Icon(icon, color: EdicaPalette.navy.withOpacity(0.9), size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: EdicaPalette.onSurface,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 12.8,
                              fontWeight: FontWeight.w700,
                              color: EdicaPalette.onSurfaceMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withOpacity(0.08)),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white.withOpacity(0.70),
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
