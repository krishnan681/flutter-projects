// lib/utils/splash_screen.dart
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/homepage_shell.dart'; // ← NEW: the shell
import '../screens/onboarding_screen.dart'; // ← keep

class Stage4Splash extends StatefulWidget {
  const Stage4Splash({super.key});

  @override
  State<Stage4Splash> createState() => _Stage4SplashState();
}

class _Stage4SplashState extends State<Stage4Splash>
    with TickerProviderStateMixin {
  late final AnimationController _bgCtrl;
  late final AnimationController _popCtrl;
  Timer? _typingTimer;

  String _typed = '';
  final String _fullTitle = 'Celfon5G+';
  int _charIndex = 0;

  @override
  void initState() {
    super.initState();

    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _popCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _typingTimer = Timer.periodic(const Duration(milliseconds: 120), (timer) {
      if (_charIndex < _fullTitle.length) {
        setState(() => _typed += _fullTitle[_charIndex++]);
      } else {
        timer.cancel();
        _popCtrl.forward();

        // give the “pop” animation a moment to finish
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(const Duration(seconds: 1), _navigateNext);
        });
      }
    });
  }

  Future<void> _navigateNext() async {
    final prefs = await SharedPreferences.getInstance();
    final bool showOnboarding = prefs.getBool('showOnboarding') ?? true;

    if (!mounted) return;

    // ────────────────────────────────────────────────────────
    //  Use the **shell** (bottom navigation) as the home page
    // ────────────────────────────────────────────────────────
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (_, __, ___) => showOnboarding
            ? const OnboardingScreen()
            : const HomePageShell(), // ← HERE
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _popCtrl.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgCtrl,
        builder: (_, __) {
          final angle = _bgCtrl.value * 2 * math.pi;
          return CustomPaint(
            size: size,
            painter: _BackgroundPainter(angle: angle),
            child: Center(
              child: ScaleTransition(
                scale: Tween<double>(
                  begin: 1.0,
                  end: 1.2,
                ).chain(CurveTween(curve: Curves.elasticOut)).animate(_popCtrl),
                child: Text(
                  _typed,
                  style: const TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                    shadows: [
                      Shadow(
                        blurRadius: 14,
                        color: Colors.white70,
                        offset: Offset.zero,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Rotating gradient + sparkles
class _BackgroundPainter extends CustomPainter {
  final double angle;
  _BackgroundPainter({required this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final gradient = SweepGradient(
      startAngle: 0,
      endAngle: 2 * math.pi,
      colors: [
        Colors.blue.shade900,
        Colors.indigo,
        Colors.purple,
        Colors.blue.shade900,
      ],
      transform: GradientRotation(angle),
    );

    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);

    final sparkPaint = Paint()..color = Colors.white.withOpacity(0.2);
    final rand = math.Random();
    for (int i = 0; i < 30; i++) {
      final dx = rand.nextDouble() * size.width;
      final dy = rand.nextDouble() * size.height;
      canvas.drawCircle(
        Offset(dx, dy),
        rand.nextDouble() * 2 + 0.5,
        sparkPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter oldDelegate) => true;
}
