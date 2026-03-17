import 'package:bank_a_plus/selectTerm.dart';
import 'package:bank_a_plus/subjects.dart';
import 'package:bank_a_plus/paperShow.dart';
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
            const Color(0xFFF0F4FF), // Very soft blue
            Colors.white,
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
              _buildCategoryCard(
                context,
                'Term Test Papers',
                'Grades 06 - 13',
                Icons.assignment_outlined,
                [const Color(0xFFFFD54F), const Color(0xFFFFB300)], 
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
                [const Color(0xFFF28B82), const Color(0xFFEA4335)], 
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Subjects(term: 3, fixedGrade: 22)),
                ),
              ),
              const SizedBox(height: 16),
              _buildCategoryCard(
                context,
                'A/L Model Papers',
                'Target Questions',
                Icons.school_outlined,
                [const Color(0xFF80CBC4), const Color(0xFF4DB6AC)], 
                () {}, // Add link if needed
              ),
              const SizedBox(height: 16),
              _buildCategoryCard(
                context,
                'OL Pass Papers',
                'Ordinary Level',
                Icons.menu_book_rounded,
                [const Color(0xFFAECBFA), const Color(0xFF4285F4)], 
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
                [const Color(0xFFCCFF90), const Color(0xFF689F38)], 
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.35),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [
                  gradientColors[0],
                  gradientColors[1],
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded, 
                  color: Colors.white.withOpacity(0.8), 
                  size: 18
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
