import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/styles.dart';

// ── Glass card container ─────────────────────────────────────────────────────
class GlassCard extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;

  const GlassCard({
    super.key,
    required this.child,
    this.radius = AppStyles.rLg,
    this.padding,
    this.margin,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: color ?? AppStyles.bgCard,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: Colors.white.withOpacity(0.7), width: 1),
              boxShadow: AppStyles.shadowCard,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ── Category icon circle ──────────────────────────────────────────────────────
class CategoryIconWidget extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bg;
  final double size;

  const CategoryIconWidget({
    super.key,
    required this.icon,
    required this.color,
    required this.bg,
    this.size = 38,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}

// ── Mini ring progress ────────────────────────────────────────────────────────
class MiniRing extends StatelessWidget {
  final double pct;
  final Color color;
  final double size;
  final double stroke;

  const MiniRing({super.key, required this.pct, required this.color, this.size = 32, this.stroke = 4});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size, height: size,
      child: CustomPaint(painter: _RingPainter(pct: pct, color: color, stroke: stroke)),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double pct;
  final Color color;
  final double stroke;

  const _RingPainter({required this.pct, required this.color, required this.stroke});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = (size.width - stroke) / 2;
    final bg = Paint()
      ..color = AppStyles.line
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    final fg = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, r, bg);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      -3.14159 / 2,
      2 * 3.14159 * pct.clamp(0, 1),
      false, fg,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.pct != pct || old.color != color;
}

// ── Tap bounce wrapper ────────────────────────────────────────────────────────
class TapBounce extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const TapBounce({super.key, required this.child, this.onTap, this.onLongPress});

  @override
  State<TapBounce> createState() => _TapBounceState();
}

class _TapBounceState extends State<TapBounce> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTapDown: (_) => _ctrl.forward(),
    onTapUp: (_) { _ctrl.reverse(); widget.onTap?.call(); },
    onTapCancel: () => _ctrl.reverse(),
    onLongPress: () { _ctrl.reverse(); widget.onLongPress?.call(); },
    child: ScaleTransition(scale: _scale, child: widget.child),
  );
}

// ── Fade-up entrance wrapper ─────────────────────────────────────────────────
class FadeUpWidget extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const FadeUpWidget({super.key, required this.child, this.delay = Duration.zero});

  @override
  State<FadeUpWidget> createState() => _FadeUpWidgetState();
}

class _FadeUpWidgetState extends State<FadeUpWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    Future.delayed(widget.delay, () { if (mounted) _ctrl.forward(); });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _opacity,
    child: SlideTransition(position: _slide, child: widget.child),
  );
}

// ── Bottom Sheet slide-up wrapper ─────────────────────────────────────────────
class AppSheet extends StatelessWidget {
  final bool open;
  final VoidCallback onClose;
  final Widget child;

  const AppSheet({super.key, required this.open, required this.onClose, required this.child});

  @override
  Widget build(BuildContext context) {
    if (!open) return const SizedBox.shrink();
    return AnimatedOpacity(
      opacity: open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      child: Stack(
        children: [
          GestureDetector(
            onTap: onClose,
            child: Container(color: Colors.black.withOpacity(0.35)),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 1.0, end: 0.0),
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              builder: (_, v, c) => Transform.translate(
                offset: Offset(0, v * 300),
                child: c,
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                  child: Container(
                    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.75),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                      border: const Border(top: BorderSide(color: Colors.white, width: 1)),
                      boxShadow: [BoxShadow(color: const Color(0x66DCA0B4), blurRadius: 60, offset: const Offset(0, -20))],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 36, height: 5, margin: const EdgeInsets.only(top: 10),
                          decoration: BoxDecoration(color: AppStyles.ink4, borderRadius: BorderRadius.circular(3))),
                        Flexible(child: SingleChildScrollView(child: child)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Page header ───────────────────────────────────────────────────────────────
class PageHeaderWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? right;

  const PageHeaderWidget({super.key, required this.title, this.subtitle, this.right});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 86, 24, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (subtitle != null) Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(subtitle!.toUpperCase(), style: const TextStyle(
                    fontSize: 12.5, color: AppStyles.ink3, letterSpacing: 0.4,
                  )),
                ),
                Text(title, style: const TextStyle(
                  fontSize: 32, fontWeight: FontWeight.w600,
                  color: AppStyles.ink, height: 1.1,
                  fontFamily: 'Quicksand',
                )),
              ],
            ),
          ),
          if (right != null) right!,
        ],
      ),
    );
  }
}
