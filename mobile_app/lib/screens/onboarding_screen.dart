import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: "Welcome to SAI Scout",
      subtitle: "Discover your sporting potential with AI-powered assessment",
      animation: "https://assets2.lottiefiles.com/packages/lf20_touohxv0.json",
      color: const Color(0xFF2563EB),
    ),
    OnboardingData(
      title: "AR-Guided Testing",
      subtitle: "Use your camera to set up tests correctly with virtual markers",
      animation: "https://assets2.lottiefiles.com/packages/lf20_8wpmh4fl.json",
      color: const Color(0xFF10B981),
    ),
    OnboardingData(
      title: "Blockchain Verification",
      subtitle: "Your achievements are permanently recorded and tamper-proof",
      animation: "https://assets2.lottiefiles.com/packages/lf20_8wpmh4fl.json",
      color: const Color(0xFFF59E0B),
    ),
    OnboardingData(
      title: "Gamified Experience",
      subtitle: "Earn badges, climb leaderboards, and unlock your potential",
      animation: "https://assets2.lottiefiles.com/packages/lf20_8wpmh4fl.json",
      color: const Color(0xFF8B5CF6),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _pages[_currentPage].color.withOpacity(0.1),
              _pages[_currentPage].color.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index]);
                  },
                ),
              ),
              _buildBottomSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 300,
            child: Lottie.network(
              data.animation,
              repeat: true,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            data.title,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: data.color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            data.subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF64748B),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          // Page indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? _pages[_currentPage].color
                      : _pages[_currentPage].color.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Action buttons
          Row(
            children: [
              if (_currentPage > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: _pages[_currentPage].color),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Previous',
                      style: TextStyle(color: _pages[_currentPage].color),
                    ),
                  ),
                ),
              if (_currentPage > 0) const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _pages[_currentPage].color,
                        _pages[_currentPage].color.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: _pages[_currentPage].color.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentPage < _pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        Navigator.pushReplacementNamed(context, '/login');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      _currentPage < _pages.length - 1 ? 'Next' : 'Get Started',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Skip button
          TextButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: Text(
              'Skip Introduction',
              style: TextStyle(
                color: _pages[_currentPage].color.withOpacity(0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String subtitle;
  final String animation;
  final Color color;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.animation,
    required this.color,
  });
}
