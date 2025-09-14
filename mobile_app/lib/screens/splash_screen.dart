import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:easy_localization/easy_localization.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _backgroundController;
  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;
  late Animation<double> _backgroundAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _textAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutBack,
    ));

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _backgroundController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 800));
    _textController.forward();
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Animated gradient background
          AnimatedBuilder(
            animation: _backgroundAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primary.withOpacity(0.1 + _backgroundAnimation.value * 0.9),
                      AppTheme.secondary.withOpacity(0.1 + _backgroundAnimation.value * 0.9),
                      AppTheme.accent.withOpacity(0.1 + _backgroundAnimation.value * 0.9),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              );
            },
          ),

          // Animated background pattern
          AnimatedBuilder(
            animation: _backgroundAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: 0.1 + _backgroundAnimation.value * 0.2,
                child: CustomPaint(
                  painter: BackgroundPatternPainter(
                    animationValue: _backgroundAnimation.value,
                  ),
                ),
              );
            },
          ),

          // Main content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated logo
                AnimatedBuilder(
                  animation: _logoAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoAnimation.value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withOpacity(0.3),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.sports,
                          size: 60,
                          color: AppTheme.textOnPrimary,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // Animated title
                AnimatedBuilder(
                  animation: _textAnimation,
                  builder: (context, child) {
                    return SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _textAnimation,
                        child: Column(
                          children: [
                            Text(
                              'app_name'.tr(),
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1.0,
                                shadows: [
                                  Shadow(
                                    color: AppTheme.primary.withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.primary.withOpacity(0.1),
                                    AppTheme.secondary.withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: AppTheme.primary.withOpacity(0.2),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primary.withOpacity(0.1),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildFeatureChip('AI Assessment'),
                                  const SizedBox(width: 8),
                                  _buildFeatureChip('AR Testing'),
                                  const SizedBox(width: 8),
                                  _buildFeatureChip('Blockchain'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 60),

                // Loading indicator
                AnimatedBuilder(
                  animation: _textAnimation,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _textAnimation,
                      child: Column(
                        children: [
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primary.withOpacity(0.7),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Loading your sports journey...',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Floating animations
          Positioned(
            top: 100,
            right: 30,
            child: AnimatedBuilder(
              animation: _backgroundAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: 0.3 + _backgroundAnimation.value * 0.4,
                  child: Transform.rotate(
                    angle: _backgroundAnimation.value * 0.1,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.secondary.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.secondary.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.directions_run,
                        color: AppTheme.secondary,
                        size: 40,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Positioned(
            bottom: 120,
            left: 40,
            child: AnimatedBuilder(
              animation: _backgroundAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: 0.2 + _backgroundAnimation.value * 0.3,
                  child: Transform.rotate(
                    angle: -_backgroundAnimation.value * 0.15,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.accent.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.fitness_center,
                        color: AppTheme.accent,
                        size: 30,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppTheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppTheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class BackgroundPatternPainter extends CustomPainter {
  final double animationValue;

  BackgroundPatternPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primary.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // Create flowing wave pattern
    for (double i = 0; i < size.width; i += 50) {
      final y = size.height * 0.3 + 
          (sin((i / size.width) * 2 * 3.14159 + animationValue * 2) * 30);
      if (i == 0) {
        path.moveTo(i, y);
      } else {
        path.lineTo(i, y);
      }
    }
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


