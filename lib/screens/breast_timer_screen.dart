import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/styles.dart';
import '../utils/formatters.dart';
import '../widgets/shared.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';

class BreastTimerScreen extends StatefulWidget {
  final VoidCallback onClose;
  const BreastTimerScreen({super.key, required this.onClose});

  @override
  State<BreastTimerScreen> createState() => _BreastTimerScreenState();
}

class _BreastTimerScreenState extends State<BreastTimerScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<AppState>(context, listen: false);
      if (!state.breastTimerActive) {
        state.startBreastTimer();
      }
    });
  }

  @override
  void dispose() { _pulseCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (_, state, __) {
      final currentSec = (state.breastTimerSide == 'left' ? state.breastLeftSec : state.breastRightSec).round();
      final total = (state.breastLeftSec + state.breastRightSec).round();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFCF5F5), Color(0xFFFDE8E8), Color(0xFFFDE0E5)],
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // ── Nav bar ────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TapBounce(onTap: widget.onClose, child: _navCircle(Icons.chevron_left_rounded, 22)),
                  const Text('母乳亲喂', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppStyles.ink)),
                  _navCircle(Icons.edit_outlined, 16),
                ],
              ),
            ),

            // ── Side tabs ──────────────────────────────
            Container(
              margin: const EdgeInsets.fromLTRB(22, 20, 22, 0),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.45),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  _SideTab(label: '左侧', active: state.breastTimerSide == 'left', onTap: () => state.switchBreastTimerSide('left')),
                  _SideTab(label: '右侧', active: state.breastTimerSide == 'right', onTap: () => state.switchBreastTimerSide('right')),
                ],
              ),
            ),

            // ── Central area: illustration + timer ─────
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Mom + baby figure
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      if (state.breastTimerRunning)
                        FadeTransition(
                          opacity: Tween(begin: 0.3, end: 1.0).animate(_pulseCtrl),
                          child: Container(
                            width: 250, height: 250,
                            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppStyles.cMilk.withOpacity(0.3), width: 2)),
                          ),
                        ),
                      if (state.breastTimerRunning)
                        FadeTransition(
                          opacity: Tween(begin: 1.0, end: 0.0).animate(_pulseCtrl),
                          child: Container(
                            width: 280, height: 280,
                            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppStyles.cMilk.withOpacity(0.1), width: 1)),
                          ),
                        ),
                      SizedBox(
                        width: 230, height: 230,
                        child: AnimatedBuilder(
                          animation: _pulseCtrl,
                          builder: (_, __) => CustomPaint(
                            painter: _MomBabyPainter(
                              side: state.breastTimerSide,
                              running: state.breastTimerRunning,
                              pulseValue: _pulseCtrl.value,
                            ),
                            child: const SizedBox.expand(),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Big timer
                  const SizedBox(height: 0),
                  Text(
                    fmtDuration(currentSec),
                    style: const TextStyle(
                      fontSize: 64, fontWeight: FontWeight.w500,
                      color: AppStyles.ink, height: 1,
                      letterSpacing: -2.5, fontFamily: 'Quicksand',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(state.breastTimerSide == 'left' ? 'L · 当前左侧' : 'R · 当前右侧',
                    style: const TextStyle(fontSize: 13, color: AppStyles.ink2, fontWeight: FontWeight.w500, letterSpacing: 0.5)),
                  const SizedBox(height: 14),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppStyles.brand.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Text(state.breastTimerRunning ? '正在记录' : '已暂停',
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppStyles.brand, letterSpacing: 0.6)),
                  ),

                  const SizedBox(height: 36),

                  // Split row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36),
                    child: Row(
                      children: [
                        Expanded(child: Column(children: [
                          const Text('左 LEFT', style: TextStyle(fontSize: 11.5, color: AppStyles.ink2, letterSpacing: 1.2, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 4),
                          Text(fmtDuration(state.breastLeftSec.round()),
                            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w500, color: AppStyles.ink, fontFamily: 'Quicksand')),
                        ])),
                        Container(width: 1, height: 38, color: AppStyles.line.withOpacity(0.5)),
                        Expanded(child: Column(children: [
                          const Text('总计 TOTAL', style: TextStyle(fontSize: 11.5, color: AppStyles.ink2, letterSpacing: 1.2, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 4),
                          Text(fmtDuration(total),
                            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w500, color: AppStyles.ink, fontFamily: 'Quicksand')),
                        ])),
                        Container(width: 1, height: 38, color: AppStyles.line.withOpacity(0.5)),
                        Expanded(child: Column(children: [
                          const Text('右 RIGHT', style: TextStyle(fontSize: 11.5, color: AppStyles.ink2, letterSpacing: 1.2, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 4),
                          Text(fmtDuration(state.breastRightSec.round()),
                            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w500, color: AppStyles.ink, fontFamily: 'Quicksand')),
                        ])),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Controls ───────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 32),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.55), borderRadius: BorderRadius.circular(18)),
                    child: const Row(children: [
                      Icon(Icons.edit_outlined, size: 15, color: AppStyles.ink3),
                      SizedBox(width: 10),
                      Text('添加备注 · 例如：宝宝右侧吃得多', style: TextStyle(fontSize: 13.5, color: AppStyles.ink2)),
                    ]),
                  ),
                  Row(
                    children: [
                      TapBounce(
                        onTap: () {
                          if (state.breastTimerRunning) state.pauseBreastTimer();
                          else state.startBreastTimer();
                        },
                        child: Container(
                          width: 60, height: 60,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.7),
                            border: Border.all(color: Colors.black.withOpacity(0.06))),
                          child: Icon(state.breastTimerRunning ? Icons.pause_rounded : Icons.play_arrow_rounded, color: AppStyles.cMilk, size: 26),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TapBounce(
                          onTap: () {
                            state.stopAndSaveBreastTimer();
                            widget.onClose();
                          },
                          child: Container(
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppStyles.cMilk, borderRadius: BorderRadius.circular(22),
                              boxShadow: [BoxShadow(color: AppStyles.cMilk.withOpacity(0.35), blurRadius: 24, offset: const Offset(0, 10))],
                            ),
                            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Icon(Icons.stop_rounded, color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text('结束并保存', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
                            ]),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      TapBounce(
                        onTap: widget.onClose,
                        child: Container(
                          width: 60, height: 60,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.7),
                            border: Border.all(color: Colors.black.withOpacity(0.06))),
                          child: const Icon(Icons.close_rounded, color: AppStyles.ink2, size: 22),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    });
  }

  Widget _navCircle(IconData icon, double size) => Container(
    width: 36, height: 36,
    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.55)),
    child: Icon(icon, color: AppStyles.ink, size: size),
  );
}

class _SideTab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _SideTab({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TapBounce(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            boxShadow: active ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 2))] : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 6, height: 6,
                decoration: BoxDecoration(shape: BoxShape.circle, color: active ? AppStyles.cMilk : AppStyles.ink3),
              ),
              const SizedBox(width: 6),
              Text(label,
                style: TextStyle(fontSize: 14.5, fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  color: active ? AppStyles.cMilk : AppStyles.ink2)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Mom-baby silhouette painter ───────────────────────────────────────────────
// Directly replicates the SVG from the prototype: abstract mom + baby figure,
// with glowing dot on the active feeding side and pulse ring animation.
class _MomBabyPainter extends CustomPainter {
  final String side;
  final bool running;
  final double pulseValue;
  _MomBabyPainter({required this.side, required this.running, required this.pulseValue});

  static const _dim = Color(0xFFE8DFE1); // AppStyles.ink4
  static const _active = AppStyles.brand;
  static const _hair = Color(0xFF8E7C80); // AppStyles.ink2
  static const _babySkin = Color(0xFFFFF0F5);
  static const _babyBlanket = Color(0xFFFDE8E8);
  static const _blush = Color(0xFFFF8BA3);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final babyOnLeft = side == 'left';

    // ── Background warm glow ──
    canvas.drawCircle(
      Offset(cx, h * 0.51), w * 0.41,
      Paint()..shader = RadialGradient(
        colors: [const Color(0x66FF5A79), const Color(0x00FF5A79)],
      ).createShader(Rect.fromCircle(center: Offset(cx, h * 0.51), radius: w * 0.41)),
    );

    // ── Pulse ring (when running) ──
    if (running) {
      final r = w * 0.31 + w * 0.1 * pulseValue;
      final opacity = 0.28 * (1.0 - pulseValue);
      canvas.drawCircle(
        Offset(cx, h * 0.51), r,
        Paint()..color = AppStyles.brand.withOpacity(opacity)
          ..style = PaintingStyle.fill,
      );
    }

    // ── Mom body (shoulder trapezoid → rounded) ──
    final bodyPath = Path()
      ..moveTo(cx - w * 0.28, h * 0.93)
      ..cubicTo(cx - w * 0.28, h * 0.72, cx - w * 0.20, h * 0.57, cx, h * 0.57)
      ..cubicTo(cx + w * 0.20, h * 0.57, cx + w * 0.28, h * 0.72, cx + w * 0.28, h * 0.93)
      ..close();
    canvas.drawPath(bodyPath, Paint()..color = _dim.withOpacity(0.55));

    // ── Mom head ──
    canvas.drawCircle(Offset(cx, h * 0.356), w * 0.148, Paint()..color = _dim.withOpacity(0.72));

    // ── Hair/headscarf ──
    final hairPath = Path()
      ..moveTo(cx - w * 0.13, h * 0.34)
      ..cubicTo(cx - w * 0.12, h * 0.24, cx - w * 0.04, h * 0.20, cx, h * 0.20)
      ..cubicTo(cx + w * 0.07, h * 0.20, cx + w * 0.13, h * 0.25, cx + w * 0.13, h * 0.34)
      ..cubicTo(cx + w * 0.13, h * 0.30, cx + w * 0.09, h * 0.28, cx, h * 0.28)
      ..cubicTo(cx - w * 0.09, h * 0.28, cx - w * 0.13, h * 0.30, cx - w * 0.13, h * 0.34)
      ..close();
    canvas.drawPath(hairPath, Paint()..color = _hair.withOpacity(0.65));

    // ── Arm holding baby ──
    if (babyOnLeft) {
      final armPath = Path()
        ..moveTo(cx - w * 0.27, h * 0.72)
        ..cubicTo(cx - w * 0.28, h * 0.61, cx - w * 0.20, h * 0.56, cx - w * 0.07, h * 0.60)
        ..cubicTo(cx + w * 0.02, h * 0.63, cx + w * 0.07, h * 0.70, cx + w * 0.06, h * 0.82)
        ..cubicTo(cx + w * 0.03, h * 0.87, cx - w * 0.09, h * 0.87, cx - w * 0.17, h * 0.85)
        ..cubicTo(cx - w * 0.24, h * 0.84, cx - w * 0.27, h * 0.78, cx - w * 0.27, h * 0.72)
        ..close();
      canvas.drawPath(armPath, Paint()..color = _dim.withOpacity(0.95));
    } else {
      final armPath = Path()
        ..moveTo(cx + w * 0.27, h * 0.72)
        ..cubicTo(cx + w * 0.28, h * 0.61, cx + w * 0.20, h * 0.56, cx + w * 0.07, h * 0.60)
        ..cubicTo(cx - w * 0.02, h * 0.63, cx - w * 0.07, h * 0.70, cx - w * 0.06, h * 0.82)
        ..cubicTo(cx - w * 0.03, h * 0.87, cx + w * 0.09, h * 0.87, cx + w * 0.17, h * 0.85)
        ..cubicTo(cx + w * 0.24, h * 0.84, cx + w * 0.27, h * 0.78, cx + w * 0.27, h * 0.72)
        ..close();
      canvas.drawPath(armPath, Paint()..color = _dim.withOpacity(0.95));
    }

    // ── Baby blanket ──
    final babyCx = babyOnLeft ? cx - w * 0.11 : cx + w * 0.11;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(babyCx, h * 0.77), width: w * 0.26, height: h * 0.19),
      Paint()..color = _babyBlanket.withOpacity(0.95),
    );

    // ── Baby head ──
    final babyHeadCx = babyOnLeft ? cx - w * 0.16 : cx + w * 0.16;
    canvas.drawCircle(Offset(babyHeadCx, h * 0.70), w * 0.078, Paint()..color = _babySkin);

    // ── Baby blush ──
    final blushCx = babyOnLeft ? babyHeadCx - 5 : babyHeadCx + 5;
    canvas.drawCircle(Offset(blushCx, h * 0.72), 2.5, Paint()..color = _blush.withOpacity(0.6));

    // ── Feeding dots (left & right) ──
    final leftDotX = cx - w * 0.087;
    final rightDotX = cx + w * 0.087;
    final dotY = h * 0.66;

    // Left dot
    canvas.drawCircle(
      Offset(leftDotX, dotY), 6,
      Paint()..color = babyOnLeft ? _active : _dim.withOpacity(0.45),
    );
    // Right dot
    canvas.drawCircle(
      Offset(rightDotX, dotY), 6,
      Paint()..color = !babyOnLeft ? _active : _dim.withOpacity(0.45),
    );

    // ── Active side pulse rings ──
    if (running) {
      final activeDotX = babyOnLeft ? leftDotX : rightDotX;
      final pr = 6.0 + 12.0 * pulseValue;
      final po = 0.6 * (1.0 - pulseValue);
      canvas.drawCircle(
        Offset(activeDotX, dotY), pr,
        Paint()..color = _active.withOpacity(po)
          ..style = PaintingStyle.stroke..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(_MomBabyPainter old) =>
    old.side != side || old.running != running || old.pulseValue != pulseValue;
}
