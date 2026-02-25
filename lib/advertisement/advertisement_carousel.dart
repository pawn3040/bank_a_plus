import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdvertisementCarousel extends StatefulWidget {
  const AdvertisementCarousel({Key? key}) : super(key: key);

  @override
  State<AdvertisementCarousel> createState() => _AdvertisementCarouselState();
}

class _AdvertisementCarouselState extends State<AdvertisementCarousel> {
  final String _apiUrl = 'http://localhost:8081/api/v1/advertisement/get_active';
  final String _baseImageUrl = 'http://localhost:8081/addvertiesment/';
  
  List<dynamic> _ads = [];
  bool _isLoading = true;
  late PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _fetchAds();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchAds() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _ads = data;
            _isLoading = false;
          });
          if (_ads.isNotEmpty) {
            _startTimer();
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      debugPrint('Error fetching advertisements: $e');
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_ads.isEmpty) return;
      if (_pageController.hasClients) {
        _currentPage++;
        if (_currentPage >= _ads.length) {
          _currentPage = 0;
          _pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutSine,
          );
        } else {
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Styling to match "Term Test Papers" card
    final boxDecoration = BoxDecoration(
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
    );

    if (_isLoading) {
      return Container(
        height: 120,
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: boxDecoration,
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: Colors.deepPurple,
          ),
        ),
      );
    }

    if (_ads.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 120, // Equal to term test papers card height estimate
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: boxDecoration,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: _ads.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                final ad = _ads[index];
                final imageName = ad['imageName'] ?? '';
                final imageUrl = '$_baseImageUrl$imageName';
                
                return Image.network(
                  imageUrl,
                  fit: BoxFit.cover, // Scale to box size
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade50,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image_not_supported_outlined, 
                              color: Colors.deepPurple.withOpacity(0.3), 
                              size: 32),
                            const SizedBox(height: 4),
                            Text(
                              'Ad not available',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                        strokeWidth: 2,
                        color: Colors.deepPurple.withOpacity(0.5),
                      ),
                    );
                  },
                );
              },
            ),
            // Page Indicator dots
            if (_ads.length > 1)
              Positioned(
                bottom: 8,
                right: 12,
                child: Row(
                  children: List.generate(_ads.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      height: 6,
                      width: _currentPage == index ? 16 : 6,
                      decoration: BoxDecoration(
                        color: _currentPage == index 
                          ? Colors.white 
                          : Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
