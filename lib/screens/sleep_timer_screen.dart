import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../utils/styles.dart';
import '../utils/formatters.dart';
import '../widgets/shared.dart';

class SleepTimerScreen extends StatefulWidget {
  final VoidCallback onClose;
  const SleepTimerScreen({super.key, required this.onClose});

  @override
  State<SleepTimerScreen> createState() => _SleepTimerScreenState();
}

class _SleepTimerScreenState extends State<SleepTimerScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000))..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<AppState>(context, listen: false);
      if (!state.sleepTimerActive) {
        state.startSleepTimer();
      }
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (_, state, __) {
      final sec = state.sleepSec.round();

      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF4F6FB), Color(0xFFE8EEFC), Color(0xFFDFE7FA)],
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
                    const Text('睡眠记录', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppStyles.ink)),
                    _navCircle(Icons.edit_outlined, 16),
                  ],
                ),
              ),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Moon / sleeping animation
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        if (state.sleepTimerRunning)
                          FadeTransition(
                            opacity: Tween(begin: 0.2, end: 1.0).animate(_pulseCtrl),
                            child: Container(
                              width: 250, height: 250,
                              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppStyles.cSleep.withOpacity(0.4), width: 2)),
                            ),
                          ),
                        if (state.sleepTimerRunning)
                          FadeTransition(
                            opacity: Tween(begin: 1.0, end: 0.0).animate(_pulseCtrl),
                            child: Container(
                              width: 280, height: 280,
                              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppStyles.cSleep.withOpacity(0.15), width: 1)),
                            ),
                          ),
                        SizedBox(
                          width: 230, height: 230,
                          child: AnimatedBuilder(
                            animation: _pulseCtrl,
                            builder: (_, __) => CustomPaint(
                              painter: _SleepPainter(
                                running: state.sleepTimerRunning,
                                pulseValue: _pulseCtrl.value,
                              ),
                              child: const SizedBox.expand(),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Big timer
                    const SizedBox(height: 32),
                    Text(
                      fmtDuration(sec),
                      style: const TextStyle(
                        fontSize: 64, fontWeight: FontWeight.w600, color: AppStyles.ink,
                        fontFamily: 'Quicksand', letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 14),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppStyles.cSleep.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Text(state.sleepTimerRunning ? '宝宝正在呼呼大睡' : '已醒来 / 暂停',
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppStyles.cSleep, letterSpacing: 0.6)),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),

              // ── Bottom Controls ─────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, -6))],
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: const Row(children: [
                          Icon(Icons.edit_outlined, size: 15, color: AppStyles.ink3),
                          SizedBox(width: 10),
                          Text('添加备注 · 例如：宝宝这次睡得很香', style: TextStyle(fontSize: 13.5, color: AppStyles.ink2)),
                        ]),
                      ),
                      Row(
                        children: [
                          TapBounce(
                            onTap: () {
                              if (state.sleepTimerRunning) state.pauseSleepTimer();
                              else state.startSleepTimer();
                            },
                            child: Container(
                              width: 60, height: 60,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.7),
                                border: Border.all(color: Colors.black.withOpacity(0.06))),
                              child: Icon(state.sleepTimerRunning ? Icons.pause_rounded : Icons.play_arrow_rounded, color: AppStyles.cSleep, size: 26),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TapBounce(
                              onTap: () {
                                state.stopAndSaveSleepTimer();
                                widget.onClose();
                              },
                              child: Container(
                                height: 60,
                                decoration: BoxDecoration(
                                  color: AppStyles.cSleep, borderRadius: BorderRadius.circular(22),
                                  boxShadow: [BoxShadow(color: AppStyles.cSleep.withOpacity(0.35), blurRadius: 24, offset: const Offset(0, 10))],
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

// ── Sleep custom painter ───────────────────────────────────────────────
class _SleepPainter extends CustomPainter {
  final bool running;
  final double pulseValue;
  _SleepPainter({required this.running, required this.pulseValue});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    
    // Background glow
    canvas.drawCircle(
      Offset(cx, h * 0.5), w * 0.4,
      Paint()
        ..color = Colors.white
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );

    // Crescent Moon
    final moonPaint = Paint()..color = AppStyles.cSleep;
    canvas.drawCircle(Offset(cx - 15, h * 0.45), w * 0.25, moonPaint);
    moonPaint.color = Colors.white; // Cutout to make it a crescent
    canvas.drawCircle(Offset(cx - 5, h * 0.42), w * 0.22, moonPaint);

    // Zzz texts
    if (running) {
      final zOffset1 = 15.0 * pulseValue;
      final zOffset2 = 25.0 * pulseValue;
      _drawText(canvas, 'Z', Offset(cx + 40 + zOffset1, h * 0.35 - zOffset1), 24, 1.0 - pulseValue);
      _drawText(canvas, 'z', Offset(cx + 60 + zOffset2, h * 0.25 - zOffset2), 16, 1.0 - pulseValue);
    }
  }

  void _drawText(Canvas canvas, String text, Offset offset, double size, double opacity) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: AppStyles.cSleep.withOpacity(opacity.clamp(0.0, 1.0)), fontSize: size, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_SleepPainter old) =>
    old.running != running || old.pulseValue != pulseValue;
}
