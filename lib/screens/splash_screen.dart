import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/core_constants.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;
  late AnimationController _particleController;
  late AnimationController _pulseController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _textOpacityAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;

  double _loadingProgress = 0.0;
  String _loadingText = 'در حال بارگذاری...';

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _initAnimations();
    _startLoadingSequence();
  }

  void _initAnimations() {
    // Logo Animation
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.elasticOut,
      ),
    );

    _logoRotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeInOut,
      ),
    );

    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Text Animation
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOutCubic,
      ),
    );

    _textOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeIn,
      ),
    );

    // Progress Animation
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOut,
      ),
    );

    // Particle Animation
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    // Pulse Animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  Future<void> _startLoadingSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 800));
    _textController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _progressController.forward();
    for (int i = 0; i <= 100; i += 10) {
      await Future.delayed(const Duration(milliseconds: 150));
      if (mounted) {
        setState(() {
          _loadingProgress = i / 100.0;
          _loadingText = _getLoadingText(i);
        });
      }
    }

    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
          const MainScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  String _getLoadingText(int progress) {
    if (progress < 30) return 'در حال بارگذاری منابع...';
    if (progress < 60) return 'آماده‌سازی رابط کاربری...';
    if (progress < 90) return 'بارگذاری تنظیمات...';
    return 'تقریباً آماده است...';
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    _particleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
              Colors.purple.shade900,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated Background Particles
            _buildAnimatedParticles(),

            // Main Content
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  // Logo Section
                  _buildLogoSection(),
                  const SizedBox(height: 40),
                  // App Name
                  _buildAppNameSection(),
                  const SizedBox(height: 20),
                  // Tagline
                  _buildTaglineSection(),
                  const Spacer(flex: 2),
                  // Loading Progress
                  _buildLoadingSection(),

                  const SizedBox(height: 60),
                ],
              ),
            ),

            // Decorative Elements
            _buildDecorativeElements(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedParticles() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlesPainter(
            animationValue: _particleController.value,
          ),
          child: Container(),
        );
      },
    );
  }

  Widget _buildLogoSection() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _logoController,
        _pulseController,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScaleAnimation.value * _pulseAnimation.value,
          child: Transform.rotate(
            angle: _logoRotationAnimation.value * 0.2,
            child: Opacity(
              opacity: _logoOpacityAnimation.value,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.3),
                      Colors.white.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          Color(0xFFE3F2FD),
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.picture_as_pdf,
                      size: 70,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppNameSection() {
    return SlideTransition(
      position: _textSlideAnimation,
      child: FadeTransition(
        opacity: _textOpacityAnimation,
        child: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Colors.white,
              Color(0xFFE3F2FD),
              Colors.white,
            ],
          ).createShader(bounds),
          child: const Text(
            AppConstants.appNamePersian,
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  offset: Offset(0, 4),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaglineSection() {
    return FadeTransition(
      opacity: _textOpacityAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: const Text(
          'تبدیل حرفه‌ای تصاویر به PDF',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
            letterSpacing: 1,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          // Loading Text
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _loadingText,
              key: ValueKey(_loadingText),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Progress Bar
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      children: [
                        // Background
                        Container(
                          width: double.infinity,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),

                        // Progress
                        FractionallySizedBox(
                          widthFactor: _loadingProgress,
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Colors.white,
                                  Color(0xFFE3F2FD),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.5),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Percentage
                  Text(
                    '${(_loadingProgress * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDecorativeElements() {
    return Stack(
      children: [
        // Top Left Circle
        Positioned(
          top: -50,
          left: -50,
          child: AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1 + (_particleController.value * 0.1),
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Bottom Right Circle
        Positioned(
          bottom: -80,
          right: -80,
          child: AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1 + (_particleController.value * 0.1),
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.purple.withOpacity(0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Floating Icons
        ...List.generate(
          5,
              (index) => _buildFloatingIcon(index),
        ),
      ],
    );
  }

  Widget _buildFloatingIcon(int index) {
    final icons = [
      Icons.image,
      Icons.photo_camera,
      Icons.picture_as_pdf,
      Icons.crop_free,
      Icons.photo_library,
    ];

    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        final offset = (index * 0.2 + _particleController.value) % 1.0;
        final x = 50 + (MediaQuery.of(context).size.width - 100) * offset;
        final y = 100 +
            math.sin(offset * 2 * math.pi) *
                (MediaQuery.of(context).size.height * 0.3);

        return Positioned(
          left: x,
          top: y,
          child: Opacity(
            opacity: 0.1 + (math.sin(offset * 2 * math.pi) * 0.1),
            child: Icon(
              icons[index],
              size: 30 + (index * 5).toDouble(),
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}

class ParticlesPainter extends CustomPainter {
  final double animationValue;

  ParticlesPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 20; i++) {
      final x = (size.width * (i / 20) + animationValue * size.width) % size.width;
      final y = (size.height * math.sin(i + animationValue * 2 * math.pi)) / 2 +
          size.height / 2;
      final radius = 2.0 + (i % 3) * 2.0;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlesPainter oldDelegate) {
    return animationValue != oldDelegate.animationValue;
  }
}