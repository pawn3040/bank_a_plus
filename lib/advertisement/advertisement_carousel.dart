import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdvertisementCarousel extends StatefulWidget {
  const AdvertisementCarousel({Key? key}) : super(key: key);

  @override
  State<AdvertisementCarousel> createState() => _AdvertisementCarouselState();
}

class _AdvertisementCarouselState extends State<AdvertisementCarousel> with WidgetsBindingObserver, TickerProviderStateMixin {
  final String _apiUrl = 'http://192.168.8.117:8081/api/v1/advertisement/get_active';
  final String _baseImageUrl = 'http://192.168.8.117:8081/addvertiesment/';
  
  List<dynamic> _ads = [];
  bool _isLoading = true;
  late PageController _pageController;
  Timer? _timer;
  Timer? _pollTimer;
  int _currentPage = 0;
  late AnimationController _blinkController;
  late Animation<Color?> _borderColorAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController(initialPage: 0);

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _borderColorAnimation = ColorTween(
      begin: const Color.fromARGB(255, 255, 0, 0).withOpacity(0.2),
      end: const Color.fromARGB(255, 183, 58, 58).withOpacity(1.0),
    ).animate(_blinkController);

    _fetchAds();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _fetchAds());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _pollTimer?.cancel();
    _pageController.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchAds();
    }
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
          if (_ads.isNotEmpty && _timer == null) {
            _startTimer();
            _triggerBlink();
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
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
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

  void _triggerBlink() {
    _blinkController.repeat(reverse: true);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _blinkController.stop();
        _blinkController.value = 0.0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _borderColorAnimation,
      builder: (context, child) {
        final boxDecoration = BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(0),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 239, 3, 3).withOpacity(0.1),
              blurRadius: 0,
              offset: const Offset(0, 0),
            ),
          ],
          border: Border.all(
            color: _borderColorAnimation.value ?? const Color.fromARGB(255, 255, 2, 2).withOpacity(0.2),
            width: _blinkController.isAnimating ? 2.5 : 1.0,
          ),
        );

        if (_isLoading) {
          return Container(
            height: 100,
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: boxDecoration,
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Color.fromARGB(255, 255, 0, 0),
              ),
            ),
          );
        }

        if (_ads.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          height: 100,
          margin: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 1.0),
          decoration: boxDecoration,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: _ads.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                    _triggerBlink(); // Blink on every page change too
                  },
                  itemBuilder: (context, index) {
                    final ad = _ads[index];
                    final imageName = ad['imageName'] ?? '';
                    final imageUrl = Uri.encodeFull('$_baseImageUrl$imageName');
                    
                    return Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
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
                                  color: const Color.fromARGB(255, 255, 0, 0).withOpacity(0.3), 
                                  size: 32),
                                const SizedBox(height: 1),
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
                            color: const Color.fromARGB(255, 255, 0, 0).withOpacity(0.5),
                          ),
                        );
                      },
                    );
                  },
                ),
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
      },
    );
  }
}
