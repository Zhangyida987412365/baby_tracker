import 'package:flutter/material.dart';
import '../utils/styles.dart';
import '../main.dart';
import 'dart:math';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500));
    _ctrl.forward();

    // Navigate to AppShell after 2.8 seconds
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const AppShell(),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.bgApp,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Aurora
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => CustomPaint(painter: _SplashAuroraPainter(anim: _ctrl.value)),
            ),
          ),
          
          // Center content
          Center(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) {
                // Logo bounce animation (clamped to avoid 0 scale matrix which crashes Impeller shadows)
                final rawScale = Curves.elasticOut.transform((_ctrl.value * 2).clamp(0.0, 1.0));
                final scale = rawScale.clamp(0.001, 2.0);
                
                // Text fade up animation
                final textOpacity = Curves.easeOut.transform((_ctrl.value * 2 - 1).clamp(0.0, 1.0));
                final textY = 20 * (1 - textOpacity);

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          shape: BoxShape.circle,
                          boxShadow: AppStyles.shadowPop,
                        ),
                        child: const Icon(
                          Icons.child_care_rounded,
                          size: 64,
                          color: AppStyles.brand,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Transform.translate(
                      offset: Offset(0, textY),
                      child: Opacity(
                        opacity: textOpacity,
                        child: Column(
                          children: [
                            const Text(
                              'BybyApp',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppStyles.ink,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '记录宝贝的美好瞬间',
                              style: TextStyle(
                                fontSize: 15,
                                color: AppStyles.ink.withOpacity(0.6),
                                letterSpacing: 2.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashAuroraPainter extends CustomPainter {
  final double anim;
  _SplashAuroraPainter({required this.anim});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    void radial(Offset center, double radius, Color color) {
      canvas.drawCircle(center, radius, Paint()
        ..shader = RadialGradient(
          colors: [color, color.withOpacity(0)],
        ).createShader(Rect.fromCircle(center: center, radius: radius)));
    }

    // Slow rotation of aurora gradients based on anim
    final c1 = Offset(w * 0.5 + w * 0.4 * cos(anim * pi * 2), h * 0.2 + h * 0.2 * sin(anim * pi * 2));
    final c2 = Offset(w * 0.8 + w * 0.2 * cos(anim * pi * 2 + pi), h * 0.8 + h * 0.2 * sin(anim * pi * 2 + pi));
    final c3 = Offset(w * 0.2 + w * 0.3 * cos(anim * pi * 2 + pi/2), h * 0.8 + h * 0.2 * sin(anim * pi * 2 + pi/2));

    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = AppStyles.bgApp);
    radial(c1, w * 1.2, const Color(0x99FFB4C8));
    radial(c2, w * 1.2, const Color(0x99FFD2AA));
    radial(c3, w * 1.2, const Color(0x80DCB4FF));
  }

  @override
  bool shouldRepaint(_SplashAuroraPainter old) => old.anim != anim;
}
