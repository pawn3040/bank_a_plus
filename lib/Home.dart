import 'package:bank_a_plus/selectTerm.dart';
import 'package:bank_a_plus/subjects.dart';
import 'package:bank_a_plus/paperShow.dart';
import 'package:bank_a_plus/theme/edica_palette.dart';
import 'package:flutter/material.dart';


class Home extends StatelessWidget {
  const Home({Key? key, required String title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color.fromARGB(255, 107, 144, 232),
             const Color.fromARGB(255, 37, 111, 189),
            const Color.fromARGB(255, 119, 3, 148),
            const Color.fromARGB(255, 17, 216, 67),
          ],
        ),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
         
              const SizedBox(height: 18),
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
