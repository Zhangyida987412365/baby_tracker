import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/styles.dart';

// ── Bottle illustration with animated fill level ──────────────────────────────
class BottleIllustration extends StatelessWidget {
  final int ml;
  final int max;
  const BottleIllustration({super.key, required this.ml, this.max = 240});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: CustomPaint(
        painter: _BottlePainter(fillPct: (ml / max).clamp(0.0, 1.0)),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _BottlePainter extends CustomPainter {
  final double fillPct;
  _BottlePainter({required this.fillPct});

  @override
  void paint(Canvas canvas, Size s) {
    final cx = s.width / 2;
    // Glow
    canvas.drawCircle(Offset(cx, s.height * 0.55),
      s.width * 0.38,
      Paint()..shader = RadialGradient(colors: [const Color(0x99F7C9A8), Colors.transparent])
        .createShader(Rect.fromCircle(center: Offset(cx, s.height * 0.55), radius: s.width * 0.38)));

    // Nipple
    final nipplePath = Path()
      ..moveTo(cx - 14, s.height * 0.22)
      ..quadraticBezierTo(cx, s.height * 0.1, cx + 14, s.height * 0.22)
      ..close();
    canvas.drawPath(nipplePath, Paint()..color = const Color(0xD9CDB39A));
    canvas.drawRRect(
      RRect.fromLTRBR(cx - 18, s.height * 0.22, cx + 18, s.height * 0.28, const Radius.circular(3)),
      Paint()..color = const Color(0xFFB89A82));

    // Bottle body outline
    final bodyLeft = cx - 27, bodyRight = cx + 27;
    final bodyTop = s.height * 0.28, bodyBot = s.height * 0.92;
    final bodyPath = Path()
      ..moveTo(bodyLeft, bodyTop)
      ..quadraticBezierTo(bodyLeft - 2, bodyTop + 10, bodyLeft - 2, bodyTop + 20)
      ..lineTo(bodyLeft - 2, bodyBot - 12)
      ..quadraticBezierTo(bodyLeft - 2, bodyBot, bodyLeft + 10, bodyBot)
      ..lineTo(bodyRight - 10, bodyBot)
      ..quadraticBezierTo(bodyRight + 2, bodyBot, bodyRight + 2, bodyBot - 12)
      ..lineTo(bodyRight + 2, bodyTop + 20)
      ..quadraticBezierTo(bodyRight + 2, bodyTop + 10, bodyRight, bodyTop)
      ..close();

    canvas.drawPath(bodyPath, Paint()..color = Colors.white);
    canvas.drawPath(bodyPath, Paint()..color = const Color(0xFFD9C7B2)..style = PaintingStyle.stroke..strokeWidth = 1.5);

    // Milk fill with clip
    canvas.save();
    canvas.clipPath(bodyPath);
    final milkY = bodyBot - (bodyBot - bodyTop) * fillPct;
    final milkRect = Rect.fromLTRB(bodyLeft - 4, milkY, bodyRight + 4, bodyBot);
    canvas.drawRect(milkRect,
      Paint()..shader = LinearGradient(
        colors: [const Color(0xFFFFF6EC), const Color(0xFFF2D8B8)],
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
      ).createShader(milkRect));
    // Wave at top of milk
    final wavePath = Path()
      ..moveTo(bodyLeft - 4, milkY)
      ..quadraticBezierTo(cx - 8, milkY - 4, cx, milkY)
      ..quadraticBezierTo(cx + 8, milkY + 4, bodyRight + 4, milkY)
      ..lineTo(bodyRight + 4, milkY + 6)
      ..lineTo(bodyLeft - 4, milkY + 6)
      ..close();
    canvas.drawPath(wavePath, Paint()..color = const Color(0xE6FFF6EC));
    canvas.restore();

    // Scale marks
    final scalePaint = Paint()..color = const Color(0xFFA89A8C)..strokeWidth = 1;
    for (final v in [60, 120, 180, 240]) {
      final y = bodyBot - (bodyBot - bodyTop) * (v / max);
      canvas.drawLine(Offset(bodyRight + 4, y), Offset(bodyRight + 9, y), scalePaint);
    }
  }

  double get max => 240;
  @override bool shouldRepaint(_BottlePainter old) => old.fillPct != fillPct;
}

// ── Diaper illustration with dynamic color ────────────────────────────────────
class DiaperIllustration extends StatelessWidget {
  final String status;
  const DiaperIllustration({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final tint = status == 'pee' ? const Color(0xFFFFE9B8)
               : status == 'poo' ? const Color(0xFFD4A87A)
               : const Color(0xFFE8C597);
    return SizedBox(
      height: 150,
      child: CustomPaint(painter: _DiaperPainter(tint: tint, status: status)),
    );
  }
}

class _DiaperPainter extends CustomPainter {
  final Color tint;
  final String status;
  _DiaperPainter({required this.tint, required this.status});

  @override
  void paint(Canvas canvas, Size s) {
    final cx = s.width / 2;
    final cy = s.height * 0.5;

    // glow
    canvas.drawCircle(Offset(cx, cy), s.width * 0.4,
      Paint()..shader = RadialGradient(colors: [const Color(0x80F7DDB8), Colors.transparent])
        .createShader(Rect.fromCircle(center: Offset(cx, cy), radius: s.width * 0.4)));

    // Diaper body
    final dPath = Path()
      ..moveTo(cx - s.width * 0.38, s.height * 0.28)
      ..lineTo(cx + s.width * 0.38, s.height * 0.28)
      ..quadraticBezierTo(cx + s.width * 0.3, s.height * 0.72,
        cx + s.width * 0.1, s.height * 0.82)
      ..quadraticBezierTo(cx, s.height * 0.88, cx - s.width * 0.1, s.height * 0.82)
      ..quadraticBezierTo(cx - s.width * 0.3, s.height * 0.72, cx - s.width * 0.38, s.height * 0.28)
      ..close();
    canvas.drawPath(dPath, Paint()..color = Colors.white);
    canvas.drawPath(dPath, Paint()..color = const Color(0xFFD9C7B2)..style = PaintingStyle.stroke..strokeWidth = 1.5);

    // Absorption zone
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, s.height * 0.55), width: s.width * 0.42, height: s.height * 0.28),
      Paint()..color = tint.withOpacity(0.7));

    // Indicator
    if (status == 'pee') {
      final p = Path()..moveTo(cx, s.height * 0.55)..quadraticBezierTo(cx - 6, s.height * 0.44, cx, s.height * 0.35)..quadraticBezierTo(cx + 6, s.height * 0.44, cx, s.height * 0.55)..close();
      canvas.drawPath(p, Paint()..color = const Color(0xFF7DA9C9));
    } else if (status == 'poo') {
      canvas.drawCircle(Offset(cx, s.height * 0.55), 8, Paint()..color = const Color(0xFF8A5D3B));
    } else {
      canvas.drawCircle(Offset(cx - 8, s.height * 0.57), 6, Paint()..color = const Color(0xFF8A5D3B));
      final p = Path()..moveTo(cx + 10, s.height * 0.55)..quadraticBezierTo(cx + 4, s.height * 0.44, cx + 10, s.height * 0.35)..quadraticBezierTo(cx + 16, s.height * 0.44, cx + 10, s.height * 0.55)..close();
      canvas.drawPath(p, Paint()..color = const Color(0xFF7DA9C9));
    }
  }

  @override bool shouldRepaint(_DiaperPainter old) => old.status != status;
}

// ── Sleep illustration ────────────────────────────────────────────────────────
class SleepIllustration extends StatefulWidget {
  const SleepIllustration({super.key});
  @override State<SleepIllustration> createState() => _SleepIllustrationState();
}
class _SleepIllustrationState extends State<SleepIllustration> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override void initState() { super.initState(); _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true); }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 150,
    child: AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(painter: _SleepPainter(zAnim: _ctrl.value)),
    ),
  );
}
class _SleepPainter extends CustomPainter {
  final double zAnim;
  _SleepPainter({required this.zAnim});
  @override
  void paint(Canvas canvas, Size s) {
    final cx = s.width / 2;
    canvas.drawCircle(Offset(cx, s.height * 0.6), s.width * 0.38,
      Paint()..shader = RadialGradient(colors: [const Color(0x73B8C8E0), Colors.transparent])
        .createShader(Rect.fromCircle(center: Offset(cx, s.height * 0.6), radius: s.width * 0.38)));
    // Moon
    final moonPath = Path()..addOval(Rect.fromCenter(center: Offset(cx + s.width * 0.28, s.height * 0.2), width: 50, height: 50));
    canvas.drawPath(moonPath, Paint()..color = const Color(0xFFDCE0EA));
    canvas.drawCircle(Offset(cx + s.width * 0.28 + 10, s.height * 0.2 - 8), 18, Paint()..color = const Color(0xFFF5F0E8));
    // Bed
    final bedPath = Path()
      ..moveTo(cx - s.width * 0.38, s.height * 0.82)
      ..quadraticBezierTo(cx - s.width * 0.35, s.height * 0.65, cx - s.width * 0.12, s.height * 0.64)
      ..lineTo(cx + s.width * 0.12, s.height * 0.64)
      ..quadraticBezierTo(cx + s.width * 0.35, s.height * 0.65, cx + s.width * 0.38, s.height * 0.82)
      ..close();
    canvas.drawPath(bedPath, Paint()..color = const Color(0xFFE8DECD));
    // Pillow
    final pillowPath = Path()
      ..moveTo(cx - s.width * 0.25, s.height * 0.64)
      ..quadraticBezierTo(cx - s.width * 0.22, s.height * 0.54, cx - s.width * 0.05, s.height * 0.53)
      ..lineTo(cx + s.width * 0.05, s.height * 0.53)
      ..quadraticBezierTo(cx + s.width * 0.22, s.height * 0.54, cx + s.width * 0.25, s.height * 0.64)
      ..close();
    canvas.drawPath(pillowPath, Paint()..color = const Color(0xFFFFF6EC));
    // Baby head
    canvas.drawCircle(Offset(cx, s.height * 0.61), 20, Paint()..color = const Color(0xFFFFD8B8));
    // Closed eyes
    final eyePaint = Paint()..color = const Color(0xFF1C1814)..style = PaintingStyle.stroke..strokeWidth = 1.5..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCenter(center: Offset(cx - 6, s.height * 0.6), width: 10, height: 8), 0, pi, false, eyePaint);
    canvas.drawArc(Rect.fromCenter(center: Offset(cx + 6, s.height * 0.6), width: 10, height: 8), 0, pi, false, eyePaint);
    // ZZZ floating
    final textStyle = TextStyle(fontSize: 12 + zAnim * 4, color: const Color(0xFF6E7DA0).withOpacity(0.6 + zAnim * 0.4), fontWeight: FontWeight.w600);
    for (int i = 0; i < 3; i++) {
      final tp = TextPainter(text: TextSpan(text: i == 2 ? 'Z' : 'z', style: textStyle.copyWith(fontSize: 10.0 + i * 4 + zAnim * 3)), textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(cx + 24 + i * 10, s.height * 0.38 - i * 12 - zAnim * 4));
    }
  }
  @override bool shouldRepaint(_SleepPainter old) => old.zAnim != zAnim;
}

// ── Food illustration with steam ──────────────────────────────────────────────
class FoodIllustration extends StatefulWidget {
  final String food;
  final String amount;
  const FoodIllustration({super.key, required this.food, required this.amount});
  @override State<FoodIllustration> createState() => _FoodIllustrationState();
}
class _FoodIllustrationState extends State<FoodIllustration> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override void initState() { super.initState(); _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500))..repeat(); }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  double _getFill() {
    if (widget.amount == '10g') return 0.25;
    if (widget.amount == '30g') return 0.50;
    if (widget.amount == '50g') return 0.75;
    return 1.0;
  }

  static const _colors = {
    '米糊': Color(0xFFF2E2C7), '香蕉': Color(0xFFF5D575), '苹果泥': Color(0xFFE89F8E),
    '南瓜泥': Color(0xFFE89668), '蛋黄': Color(0xFFF5C842), '胡萝卜': Color(0xFFE08660),
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: _getFill()),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutBack,
        builder: (context, fillVal, _) => TweenAnimationBuilder<Color?>(
          tween: ColorTween(begin: _colors[widget.food], end: _colors[widget.food]),
          duration: const Duration(milliseconds: 400),
          builder: (context, colorVal, _) => AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => CustomPaint(
              painter: _FoodPainter(color: colorVal ?? const Color(0xFFF2E2C7), fill: fillVal, anim: _ctrl.value),
            )
          )
        )
      )
    );
  }
}
class _FoodPainter extends CustomPainter {
  final Color color;
  final double fill;
  final double anim;
  _FoodPainter({required this.color, required this.fill, required this.anim});

  @override
  void paint(Canvas canvas, Size s) {
    final cx = s.width / 2;
    canvas.drawCircle(Offset(cx, s.height * 0.6), s.width * 0.4,
      Paint()..shader = RadialGradient(colors: [const Color(0x80F7C9A8), Colors.transparent])
        .createShader(Rect.fromCircle(center: Offset(cx, s.height * 0.6), radius: s.width * 0.4)));

    // Bowl back
    final bowlPath = Path()
      ..moveTo(cx - s.width * 0.35, s.height * 0.52)
      ..lineTo(cx + s.width * 0.35, s.height * 0.52)
      ..quadraticBezierTo(cx + s.width * 0.28, s.height * 0.9, cx, s.height * 0.9)
      ..quadraticBezierTo(cx - s.width * 0.28, s.height * 0.9, cx - s.width * 0.35, s.height * 0.52)..close();
    
    // Food fill
    if (fill > 0) {
      canvas.save();
      canvas.clipPath(bowlPath);
      final foodTop = s.height * 0.9 - (s.height * 0.9 - s.height * 0.52) * fill;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, foodTop), width: s.width * 0.65 * fill, height: 20 * fill),
        Paint()..color = color.withOpacity(0.8));
      canvas.drawRect(Rect.fromLTRB(0, foodTop, s.width, s.height), Paint()..color = color);
      canvas.restore();
    }

    // Bowl front outline
    canvas.drawPath(bowlPath, Paint()..color = const Color(0xFFD9C7B2)..style = PaintingStyle.stroke..strokeWidth = 2);

    // Spoon sticking out
    canvas.save();
    canvas.translate(cx + s.width * 0.25, s.height * 0.4);
    canvas.rotate(0.4);
    final spoonPath = Path()..moveTo(0,0)..lineTo(0, 30)..quadraticBezierTo(5, 45, -5, 50)..quadraticBezierTo(-15, 45, -10, 30)..lineTo(-10, 0)..close();
    canvas.drawPath(spoonPath, Paint()..color = const Color(0xFFE8DCCA));
    canvas.restore();

    // Steam
    if (fill > 0.1) {
      final steamPaint = Paint()..color = const Color(0xFFCDB39A)..strokeWidth = 1.5..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
      for (int i = 0; i < 3; i++) {
        final phase = (anim + i * 0.33) % 1.0;
        final opacity = (sin(phase * pi)).clamp(0.0, 1.0);
        final steamPath = Path()
          ..moveTo(cx - 16 + i * 16, s.height * 0.5 - phase * 30)
          ..quadraticBezierTo(cx - 10 + i * 16, s.height * 0.44 - phase * 30, cx - 16 + i * 16, s.height * 0.38 - phase * 30);
        canvas.drawPath(steamPath, steamPaint..color = const Color(0xFFCDB39A).withOpacity(opacity * 0.6));
      }
    }
  }
  @override bool shouldRepaint(_FoodPainter old) => old.color != color || old.fill != fill || old.anim != anim;
}

// ── Thermometer illustration ───────────────────────────────────────────────────
class TempIllustration extends StatelessWidget {
  final double temp;
  const TempIllustration({super.key, required this.temp});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 36.0, end: temp),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutBack,
        builder: (context, val, _) => CustomPaint(painter: _TempPainter(temp: val, isFever: val >= 37.5)),
      ),
    );
  }
}

class _TempPainter extends CustomPainter {
  final double temp;
  final bool isFever;
  _TempPainter({required this.temp, required this.isFever});

  @override
  void paint(Canvas canvas, Size s) {
    final cx = s.width / 2;
    final mercuryColor = isFever ? const Color(0xFFE08667) : const Color(0xFFC77B5E);
    final min = 35.0, max = 40.0;
    final pct = ((temp - min) / (max - min)).clamp(0.0, 1.0);
    final bodyTop = s.height * 0.12, bodyBot = s.height * 0.78;
    final mercuryY = bodyBot - pct * (bodyBot - bodyTop);

    canvas.drawCircle(Offset(cx, s.height * 0.55), s.width * 0.35,
      Paint()..shader = RadialGradient(colors: [isFever ? const Color(0x66F7A8A8) : const Color(0x66F7C9A8), Colors.transparent])
        .createShader(Rect.fromCircle(center: Offset(cx, s.height * 0.55), radius: s.width * 0.35)));

    canvas.drawRRect(
      RRect.fromLTRBR(cx - 7, bodyTop, cx + 7, bodyBot + 5, const Radius.circular(7)),
      Paint()..color = Colors.white);
    canvas.drawRRect(
      RRect.fromLTRBR(cx - 7, bodyTop, cx + 7, bodyBot + 5, const Radius.circular(7)),
      Paint()..color = const Color(0xFFD9C7B2)..style = PaintingStyle.stroke..strokeWidth = 1.5);

    canvas.drawCircle(Offset(cx, bodyBot + 14), 14, Paint()..color = mercuryColor);
    canvas.drawRRect(
      RRect.fromLTRBR(cx - 3.5, mercuryY, cx + 3.5, bodyBot + 14, const Radius.circular(3.5)),
      Paint()..color = mercuryColor);

    final scalePaint = Paint()..color = const Color(0xFFA89A8C)..strokeWidth = 1;
    for (int v = 36; v <= 39; v++) {
      final y = bodyBot - ((v - min) / (max - min)) * (bodyBot - bodyTop);
      canvas.drawLine(Offset(cx + 8, y), Offset(cx + 14, y), scalePaint);
      final tp = TextPainter(text: TextSpan(text: '$v', style: const TextStyle(fontSize: 9, color: Color(0xFFA89A8C))), textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(cx + 16, y - 5));
    }
  }
  @override bool shouldRepaint(_TempPainter old) => old.temp != temp;
}

// ── Water drop illustration ───────────────────────────────────────────────────
class WaterIllustration extends StatefulWidget {
  final int ml;
  const WaterIllustration({super.key, required this.ml});
  @override State<WaterIllustration> createState() => _WaterIllState();
}
class _WaterIllState extends State<WaterIllustration> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override void initState() { super.initState(); _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat(); }
  @override void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: widget.ml / 180.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
        builder: (context, fill, _) => AnimatedBuilder(
          animation: _c, 
          builder: (_, __) => CustomPaint(painter: _WaterPainter(fill: fill.clamp(0.0, 1.0), anim: _c.value))
        )
      )
    );
  }
}
class _WaterPainter extends CustomPainter {
  final double fill; 
  final double anim;
  _WaterPainter({required this.fill, required this.anim});
  
  @override
  void paint(Canvas canvas, Size s) {
    final cx = s.width / 2;
    canvas.drawCircle(Offset(cx, s.height * 0.55), s.width * 0.38,
      Paint()..shader = RadialGradient(colors: [const Color(0x6688C8E8), Colors.transparent])
        .createShader(Rect.fromCircle(center: Offset(cx, s.height * 0.55), radius: s.width * 0.38)));
    
    // Sippy Cup body
    final cupL = cx - 24.0, cupR = cx + 24.0;
    final cupT = s.height * 0.35, cupB = s.height * 0.88;
    final cupPath = Path()..moveTo(cupL, cupT)..lineTo(cupL + 4, cupB - 8)
      ..quadraticBezierTo(cupL + 4, cupB, cupL + 14, cupB)..lineTo(cupR - 14, cupB)
      ..quadraticBezierTo(cupR - 4, cupB, cupR - 4, cupB - 8)..lineTo(cupR, cupT)..close();
    
    canvas.drawPath(cupPath, Paint()..color = Colors.white);
    
    // Water fill
    canvas.save(); 
    canvas.clipPath(cupPath);
    final waterY = cupB - (cupB - cupT) * fill;
    if (fill > 0.05) {
      final wave = Path()..moveTo(cupL - 4, waterY);
      for (double x = cupL - 4; x <= cupR + 4; x += 2) {
        wave.lineTo(x, waterY + sin((x / 12) + anim * pi * 2) * 3);
      }
      wave.lineTo(cupR + 4, cupB + 4); wave.lineTo(cupL - 4, cupB + 4); wave.close();
      canvas.drawPath(wave, Paint()..shader = LinearGradient(
        colors: [const Color(0xFFB8E2F8), const Color(0xFF7DC4E8)],
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTRB(cupL, waterY, cupR, cupB)));
    }
    canvas.restore();
    
    canvas.drawPath(cupPath, Paint()..color = const Color(0xFF88C8E8)..style = PaintingStyle.stroke..strokeWidth = 2);

    // Lid
    final lidPath = Path()
      ..moveTo(cupL - 4, cupT)
      ..quadraticBezierTo(cx, cupT - 15, cupR + 4, cupT)
      ..lineTo(cupR + 4, cupT + 8)
      ..lineTo(cupL - 4, cupT + 8)..close();
    canvas.drawPath(lidPath, Paint()..color = const Color(0xFFF07B9E));
    
    // Spout
    canvas.drawRRect(RRect.fromLTRBR(cx - 8, cupT - 22, cx + 2, cupT, const Radius.circular(3)), Paint()..color = const Color(0xFFF07B9E));

    // Handles
    final handlePaint = Paint()..color = const Color(0xFFF07B9E)..style = PaintingStyle.stroke..strokeWidth = 3..strokeCap = StrokeCap.round;
    // Left handle
    canvas.drawPath(Path()..moveTo(cupL + 2, s.height * 0.45)..quadraticBezierTo(cupL - 25, s.height * 0.45, cupL - 20, s.height * 0.65)..quadraticBezierTo(cupL - 10, s.height * 0.75, cupL + 4, s.height * 0.7), handlePaint);
    // Right handle
    canvas.drawPath(Path()..moveTo(cupR - 2, s.height * 0.45)..quadraticBezierTo(cupR + 25, s.height * 0.45, cupR + 20, s.height * 0.65)..quadraticBezierTo(cupR + 10, s.height * 0.75, cupR - 4, s.height * 0.7), handlePaint);
  }
  @override bool shouldRepaint(_WaterPainter old) => old.fill != fill || old.anim != anim;
}

// ── Medicine illustration ─────────────────────────────────────────────────────
class MedIllustration extends StatelessWidget {
  final String name;
  const MedIllustration({super.key, required this.name});
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeOutBack,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: animation,
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: _MedSprite(key: ValueKey(name), name: name),
      ),
    );
  }
}

class _MedSprite extends StatefulWidget {
  final String name;
  const _MedSprite({super.key, required this.name});
  @override State<_MedSprite> createState() => _MedSpriteState();
}
class _MedSpriteState extends State<_MedSprite> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override void initState() { super.initState(); _c = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true); }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => AnimatedBuilder(animation: _c, builder: (_,__) => CustomPaint(painter: _MedPainter(name: widget.name, anim: _c.value)));
}

class _MedPainter extends CustomPainter {
  final String name;
  final double anim;
  _MedPainter({required this.name, required this.anim});

  @override
  void paint(Canvas canvas, Size s) {
    final cx = s.width / 2;
    canvas.drawCircle(Offset(cx, s.height * 0.55), s.width * 0.35,
      Paint()..shader = RadialGradient(colors: [const Color(0x60F0C8E0), Colors.transparent])
        .createShader(Rect.fromCircle(center: Offset(cx, s.height * 0.55), radius: s.width * 0.35)));

    canvas.translate(0, -anim * 4); // Gentle float

    if (name == '维生素 D') {
      // Orange drop and spoon
      canvas.drawCircle(Offset(cx, s.height * 0.45), 18, Paint()..color = const Color(0xFFFFB82E));
      canvas.drawPath(Path()..moveTo(cx, s.height * 0.2)..quadraticBezierTo(cx - 18, s.height * 0.45, cx, s.height * 0.45 + 18)..quadraticBezierTo(cx + 18, s.height * 0.45, cx, s.height * 0.2)..close(), Paint()..color = const Color(0xFFFFB82E));
      canvas.drawPath(Path()..moveTo(cx - 30, s.height * 0.75)..quadraticBezierTo(cx, s.height * 0.85, cx + 30, s.height * 0.75)..lineTo(cx + 40, s.height * 0.65)..lineTo(cx - 40, s.height * 0.65)..close(), Paint()..color = const Color(0xFFD9C7B2));
    } 
    else if (name == '退烧药') {
      // Syringe
      canvas.drawRRect(RRect.fromLTRBR(cx - 10, s.height * 0.3, cx + 10, s.height * 0.7, const Radius.circular(4)), Paint()..color = Colors.white);
      canvas.drawRRect(RRect.fromLTRBR(cx - 10, s.height * 0.3, cx + 10, s.height * 0.7, const Radius.circular(4)), Paint()..color = const Color(0xFFFF6B9E)..style = PaintingStyle.stroke..strokeWidth = 2);
      canvas.drawRect(Rect.fromLTRB(cx - 8, s.height * 0.5, cx + 8, s.height * 0.68), Paint()..color = const Color(0xFFFF6B9E).withOpacity(0.5));
      canvas.drawRRect(RRect.fromLTRBR(cx - 15, s.height * 0.25, cx + 15, s.height * 0.3, const Radius.circular(2)), Paint()..color = const Color(0xFFFF6B9E));
      canvas.drawLine(Offset(cx, s.height * 0.15), Offset(cx, s.height * 0.25), Paint()..color = const Color(0xFFD9C7B2)..strokeWidth = 4);
      canvas.drawLine(Offset(cx, s.height * 0.7), Offset(cx, s.height * 0.75), Paint()..color = const Color(0xFFD9C7B2)..strokeWidth = 3);
      canvas.drawCircle(Offset(cx, s.height * 0.82), 4, Paint()..color = const Color(0xFFFF6B9E));
    }
    else if (name == '止咳水') {
      // Purple Bottle
      canvas.drawRRect(RRect.fromLTRBR(cx - 20, s.height * 0.4, cx + 20, s.height * 0.8, const Radius.circular(8)), Paint()..color = const Color(0xFFA366FF).withOpacity(0.8));
      canvas.drawRRect(RRect.fromLTRBR(cx - 12, s.height * 0.3, cx + 12, s.height * 0.4, const Radius.circular(2)), Paint()..color = Colors.white);
      canvas.drawRRect(RRect.fromLTRBR(cx - 14, s.height * 0.25, cx + 14, s.height * 0.3, const Radius.circular(2)), Paint()..color = const Color(0xFF876B73));
      canvas.drawRect(Rect.fromLTRB(cx - 14, s.height * 0.5, cx + 14, s.height * 0.7), Paint()..color = Colors.white.withOpacity(0.9));
      canvas.drawLine(Offset(cx - 6, s.height * 0.55), Offset(cx + 6, s.height * 0.55), Paint()..color = const Color(0xFFA366FF)..strokeWidth = 2);
    }
    else {
      // Pill bottle / Generic
      canvas.drawRRect(RRect.fromLTRBR(cx - 22, s.height * 0.35, cx + 22, s.height * 0.8, const Radius.circular(10)), Paint()..color = Colors.white);
      canvas.drawRRect(RRect.fromLTRBR(cx - 22, s.height * 0.35, cx + 22, s.height * 0.8, const Radius.circular(10)), Paint()..color = const Color(0xFF37D699)..style = PaintingStyle.stroke..strokeWidth = 2);
      canvas.drawRRect(RRect.fromLTRBR(cx - 18, s.height * 0.28, cx + 18, s.height * 0.35, const Radius.circular(6)), Paint()..color = const Color(0xFF37D699));
      canvas.drawRRect(RRect.fromLTRBR(cx - 16, s.height * 0.5, cx + 16, s.height * 0.65, const Radius.circular(4)), Paint()..color = const Color(0xFFE6F9F0));
      // Two capsules floating
      canvas.save(); canvas.translate(cx - 30, s.height * 0.4); canvas.rotate(-0.5);
      canvas.drawRRect(RRect.fromLTRBR(-6, -12, 6, 12, const Radius.circular(6)), Paint()..color = const Color(0xFF33C5FF));
      canvas.drawRRect(RRect.fromLTRBR(-6, 0, 6, 12, const Radius.circular(6)), Paint()..color = Colors.white);
      canvas.restore();
      canvas.save(); canvas.translate(cx + 35, s.height * 0.55); canvas.rotate(0.6);
      canvas.drawRRect(RRect.fromLTRBR(-6, -12, 6, 12, const Radius.circular(6)), Paint()..color = const Color(0xFFFFB82E));
      canvas.drawRRect(RRect.fromLTRBR(-6, 0, 6, 12, const Radius.circular(6)), Paint()..color = Colors.white);
      canvas.restore();
    }
  }
  @override bool shouldRepaint(_MedPainter old) => old.name != name || old.anim != anim;
}

// ── Bath illustration ─────────────────────────────────────────────────────────
class BathIllustration extends StatefulWidget {
  final List<String> activities;
  const BathIllustration({super.key, required this.activities});
  @override State<BathIllustration> createState() => _BathIllState();
}
class _BathIllState extends State<BathIllustration> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override void initState() { super.initState(); _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))..repeat(); }
  @override void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: widget.activities.contains('bath') ? 1.0 : 0.1),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        builder: (context, waterFill, _) => TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: widget.activities.contains('hair') ? 1.0 : 0.0),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutBack,
          builder: (context, foamScale, _) => TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: widget.activities.contains('touch') ? 1.0 : 0.0),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutBack,
            builder: (context, touchScale, _) => AnimatedBuilder(
              animation: _c,
              builder: (_, __) => CustomPaint(
                painter: _BathPainter(waterFill: waterFill, foamScale: foamScale, touchScale: touchScale, anim: _c.value),
              )
            )
          )
        )
      )
    );
  }
}
class _BathPainter extends CustomPainter {
  final double waterFill;
  final double foamScale;
  final double touchScale;
  final double anim;
  _BathPainter({required this.waterFill, required this.foamScale, required this.touchScale, required this.anim});

  @override
  void paint(Canvas canvas, Size s) {
    final cx = s.width / 2;
    canvas.drawCircle(Offset(cx, s.height * 0.6), s.width * 0.38,
      Paint()..shader = RadialGradient(colors: [const Color(0x5588C8E8), Colors.transparent])
        .createShader(Rect.fromCircle(center: Offset(cx, s.height * 0.6), radius: s.width * 0.38)));
    
    final tubPath = Path()..moveTo(cx - s.width * 0.42, s.height * 0.48)
      ..lineTo(cx + s.width * 0.42, s.height * 0.48)
      ..quadraticBezierTo(cx + s.width * 0.35, s.height * 0.92, cx, s.height * 0.92)
      ..quadraticBezierTo(cx - s.width * 0.35, s.height * 0.92, cx - s.width * 0.42, s.height * 0.48)..close();
    canvas.drawPath(tubPath, Paint()..color = Colors.white);
    
    // Baby head peeking
    canvas.drawCircle(Offset(cx, s.height * 0.46), 18, Paint()..color = const Color(0xFFFFD8B8));
    
    // Hair Foam
    if (foamScale > 0) {
      canvas.save();
      canvas.translate(cx, s.height * 0.32);
      canvas.scale(foamScale);
      final foamP = Paint()..color = Colors.white;
      canvas.drawCircle(const Offset(-10, 0), 12, foamP);
      canvas.drawCircle(const Offset(10, 0), 10, foamP);
      canvas.drawCircle(const Offset(0, -8), 14, foamP);
      canvas.restore();
    }

    // Touch Hearts
    if (touchScale > 0) {
      final heartColor = const Color(0xFFFF6B9E).withOpacity(touchScale * 0.7);
      for(int i = 0; i < 2; i++) {
        final phase = (anim + i * 0.5) % 1.0;
        final hx = cx + (i == 0 ? -40 : 40);
        final hy = s.height * 0.4 - phase * 30;
        canvas.save();
        canvas.translate(hx, hy);
        canvas.scale(touchScale * (1-phase));
        final heartPath = Path()..moveTo(0,5)..quadraticBezierTo(5, 0, 8, 3)..quadraticBezierTo(10, 8, 0, 15)..quadraticBezierTo(-10, 8, -8, 3)..quadraticBezierTo(-5, 0, 0, 5)..close();
        canvas.drawPath(heartPath, Paint()..color = heartColor);
        canvas.restore();
      }
    }

    // Water
    if (waterFill > 0) {
      canvas.save(); canvas.clipPath(tubPath);
      final wTop = s.height * 0.92 - (s.height * 0.92 - s.height * 0.55) * waterFill;
      final waterPath = Path()..moveTo(cx - s.width * 0.45, wTop);
      for (double x = cx - s.width * 0.45; x <= cx + s.width * 0.45; x += 3) {
        waterPath.lineTo(x, wTop + sin((x / 15) + anim * pi * 2) * 3 * waterFill);
      }
      waterPath.lineTo(cx + s.width * 0.45, s.height); waterPath.lineTo(cx - s.width * 0.45, s.height); waterPath.close();
      canvas.drawPath(waterPath, Paint()..color = const Color(0xAAB8E2F8));
      canvas.restore();
    }

    canvas.drawPath(tubPath, Paint()..color = const Color(0xFF88C8E8)..style = PaintingStyle.stroke..strokeWidth = 2);

    // Bubbles
    if (waterFill > 0.5) {
      for (int i = 0; i < 3; i++) {
        final ba = (anim + i * 0.33) % 1.0;
        final bx = cx - 20 + i * 20.0;
        final by = s.height * 0.55 - ba * 25;
        canvas.drawCircle(Offset(bx, by), 3 + ba * 3, Paint()..color = Colors.white.withOpacity(0.7 * (1 - ba))..style = PaintingStyle.stroke..strokeWidth = 1);
      }
    }
  }
  @override bool shouldRepaint(_BathPainter old) => old.waterFill != waterFill || old.foamScale != foamScale || old.touchScale != touchScale || old.anim != anim;
}

// ── Growth (height/weight) illustration ───────────────────────────────────────
class GrowthIllustration extends StatelessWidget {
  final double height;
  final double weight;
  const GrowthIllustration({super.key, required this.height, required this.weight});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 60.0, end: height),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutBack,
        builder: (context, hVal, _) => TweenAnimationBuilder<double>(
          tween: Tween(begin: 5.0, end: weight),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutBack,
          builder: (context, wVal, _) => CustomPaint(painter: _GrowthPainter(h: hVal, w: wVal))
        )
      )
    );
  }
}
class _GrowthPainter extends CustomPainter {
  final double h; final double w;
  _GrowthPainter({required this.h, required this.w});

  @override
  void paint(Canvas canvas, Size s) {
    final cx = s.width / 2;
    canvas.drawCircle(Offset(cx, s.height * 0.55), s.width * 0.38,
      Paint()..shader = RadialGradient(colors: [const Color(0x5588E8A8), Colors.transparent])
        .createShader(Rect.fromCircle(center: Offset(cx, s.height * 0.55), radius: s.width * 0.38)));

    // Height Ruler on the right
    final rulerX = cx + s.width * 0.25;
    canvas.drawRRect(RRect.fromLTRBR(rulerX - 10, s.height * 0.1, rulerX + 10, s.height * 0.9, const Radius.circular(4)), Paint()..color = const Color(0xFFFFF2D9));
    canvas.drawRRect(RRect.fromLTRBR(rulerX - 10, s.height * 0.1, rulerX + 10, s.height * 0.9, const Radius.circular(4)), Paint()..color = const Color(0xFFF0D49C)..style = PaintingStyle.stroke..strokeWidth = 2);
    for (int i = 0; i <= 6; i++) {
      final y = s.height * 0.8 - i * (s.height * 0.6 / 6);
      canvas.drawLine(Offset(rulerX - 10, y), Offset(rulerX - (i%2==0?0:5), y), Paint()..color = const Color(0xFFF0D49C)..strokeWidth = 2);
    }
    
    // Height Slider
    final hPct = ((h - 60) / (75 - 60)).clamp(0.0, 1.0);
    final sliderY = s.height * 0.8 - hPct * (s.height * 0.6);
    final sliderPath = Path()..moveTo(rulerX - 10, sliderY)..lineTo(rulerX - 25, sliderY - 10)..lineTo(rulerX - 25, sliderY + 10)..close();
    canvas.drawPath(sliderPath, Paint()..color = const Color(0xFF37D699));
    
    // Weight Scale on the left
    final scaleX = cx - s.width * 0.2;
    final scaleY = s.height * 0.65;
    canvas.drawOval(Rect.fromCenter(center: Offset(scaleX, scaleY), width: 70, height: 40), Paint()..color = Colors.white);
    canvas.drawOval(Rect.fromCenter(center: Offset(scaleX, scaleY), width: 70, height: 40), Paint()..color = const Color(0xFFA8E8C0)..style = PaintingStyle.stroke..strokeWidth = 2);
    
    // Scale Dial
    canvas.drawArc(Rect.fromCenter(center: Offset(scaleX, scaleY), width: 50, height: 25), pi, pi, false, Paint()..color = const Color(0xFFE6F9F0)..style = PaintingStyle.stroke..strokeWidth = 8);
    final wPct = ((w - 5.0) / (10.0 - 5.0)).clamp(0.0, 1.0);
    final angle = pi + wPct * pi;
    canvas.drawLine(Offset(scaleX, scaleY), Offset(scaleX + 12 * cos(angle), scaleY + 12 * sin(angle)), Paint()..color = const Color(0xFFFF6B9E)..strokeWidth = 2..strokeCap = StrokeCap.round);
    
    // Weight Text
    final tp = TextPainter(text: TextSpan(text: w.toStringAsFixed(1), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF4AA86E))), textDirection: TextDirection.ltr)..layout();
    tp.paint(canvas, Offset(scaleX - tp.width / 2, scaleY + 4));
  }
  @override bool shouldRepaint(_GrowthPainter old) => old.h != h || old.w != w;
}

