import 'package:flutter/material.dart';
import 'subjects.dart';
import 'package:bank_a_plus/advertisement/advertisement_carousel.dart';

class SelectTerm extends StatelessWidget {
  const SelectTerm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> terms = [
      {
        'label': 'Term 1',
        'term': 1,
        'icon': Icons.looks_one_rounded,
        'color': const Color(0xFF6C47FF),
        'gradientColors': [const Color(0xFF6C47FF), const Color(0xFF9B78FF)],
      },
      {
        'label': 'Term 2',
        'term': 2,
        'icon': Icons.looks_two_rounded,
        'color': const Color(0xFF2E7CF6),
        'gradientColors': [const Color(0xFF2E7CF6), const Color(0xFF74AFFF)],
      },
      {
        'label': 'Term 3',
        'term': 3,
        'icon': Icons.looks_3_rounded,
        'color': const Color(0xFF00BFA5),
        'gradientColors': [const Color(0xFF00BFA5), const Color(0xFF64FFDA)],
      },
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        toolbarHeight: 38,
        title: const Text(
          'Select Term',
          style: TextStyle(
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Term buttons
                    Expanded(
                      child: ListView.separated(
                        itemCount: terms.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final term = terms[index];
                          return _TermCard(
                            label: term['label'] as String,
                            termNumber: term['term'] as int,
                            icon: term['icon'] as IconData,
                            gradientColors: term['gradientColors'] as List<Color>,
                          );
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
}

class _TermCard extends StatefulWidget {
  final String label;
  final int termNumber;
  final IconData icon;
  final List<Color> gradientColors;

  const _TermCard({
    required this.label,
    required this.termNumber,
    required this.icon,
    required this.gradientColors,
  });

  @override
  State<_TermCard> createState() => _TermCardState();
}

class _TermCardState extends State<_TermCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.05,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() async {
    await _controller.forward();
    await _controller.reverse();
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Subjects(
            term: widget.termNumber,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: _onTap,
        child: Container(
          height: 85,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 30, 30, 30).withOpacity(0.85),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Subtle accent glow
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: widget.gradientColors.first.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: widget.gradientColors,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: widget.gradientColors.first.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Icon(
                          widget.icon,
                          color: Colors.black.withOpacity(0.7),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 18),
                      Text(
                        widget.label,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white60,
                          size: 14,
                        ),
                      ),
                    ],
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
