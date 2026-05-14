import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../utils/styles.dart';
import '../utils/categories.dart';
import '../widgets/shared.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> with TickerProviderStateMixin {
  String _range = 'week';
  late AnimationController _barCtrl;

  @override
  void initState() {
    super.initState();
    _barCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _barCtrl.forward();
  }

  @override
  void dispose() { _barCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (_, state, __) {
      final baby = state.baby;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      List<Map<String, dynamic>> buildData(String typeFilter) {
        final res = <Map<String, dynamic>>[];

        if (_range == 'day') {
          // Last 7 days
          for (int i = 6; i >= 0; i--) {
            final date = today.subtract(Duration(days: i));
            final nextDate = date.add(const Duration(days: 1));
            final dailyRecs = state.records.where((r) => r.time.isAfter(date) && r.time.isBefore(nextDate)).toList();
            
            double val = 0;
            if (typeFilter == 'milk') val = dailyRecs.where((r) => r.type == 'breast' || r.type == 'bottle').length.toDouble();
            else if (typeFilter == 'sleep') val = dailyRecs.where((r) => r.type == 'sleep').fold(0, (s, r) => s + (r.value ?? 0)) / 3600.0;
            else if (typeFilter == 'diaper') val = dailyRecs.where((r) => r.type == 'diaper').length.toDouble();
            
            String label = i == 0 ? '今天' : ['周一','周二','周三','周四','周五','周六','周日'][date.weekday - 1];
            res.add({'label': label, 'v': val});
          }
        } else if (_range == 'week') {
          // Last 7 weeks
          for (int i = 6; i >= 0; i--) {
            final startDate = today.subtract(Duration(days: i * 7 + today.weekday - 1));
            final endDate = startDate.add(const Duration(days: 7));
            final weekRecs = state.records.where((r) => r.time.isAfter(startDate) && r.time.isBefore(endDate)).toList();

            double val = 0;
            if (typeFilter == 'milk') val = weekRecs.where((r) => r.type == 'breast' || r.type == 'bottle').length.toDouble();
            else if (typeFilter == 'sleep') val = weekRecs.where((r) => r.type == 'sleep').fold(0, (s, r) => s + (r.value ?? 0)) / 3600.0;
            else if (typeFilter == 'diaper') val = weekRecs.where((r) => r.type == 'diaper').length.toDouble();

            String label = i == 0 ? '本周' : '${startDate.month}/${startDate.day}';
            res.add({'label': label, 'v': val});
          }
        } else {
          // month or all: Last 6 months
          for (int i = 5; i >= 0; i--) {
            final startDate = DateTime(today.year, today.month - i, 1);
            final endDate = DateTime(today.year, today.month - i + 1, 1);
            final monthRecs = state.records.where((r) => r.time.isAfter(startDate.subtract(const Duration(milliseconds: 1))) && r.time.isBefore(endDate)).toList();

            double val = 0;
            if (typeFilter == 'milk') val = monthRecs.where((r) => r.type == 'breast' || r.type == 'bottle').length.toDouble();
            else if (typeFilter == 'sleep') val = monthRecs.where((r) => r.type == 'sleep').fold(0, (s, r) => s + (r.value ?? 0)) / 3600.0;
            else if (typeFilter == 'diaper') val = monthRecs.where((r) => r.type == 'diaper').length.toDouble();

            String label = i == 0 ? '本月' : '${startDate.month}月';
            res.add({'label': label, 'v': val});
          }
        }
        return res;
      }

      final milkData = buildData('milk');
      final sleepData = buildData('sleep');
      final diaperData = buildData('diaper');
      
      double _avg(List<Map<String, dynamic>> data) => data.fold(0.0, (s, d) => s + (d['v'] as double)) / 7.0;
      final milkAvg = _avg(milkData);
      final sleepAvg = _avg(sleepData);
      final diaperAvg = _avg(diaperData);

      return SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            PageHeaderWidget(
              title: '统计', 
              subtitle: _range == 'day' ? '近7日趋势' : _range == 'week' ? '近7周趋势' : '近6月趋势',
            ),

            // Segment
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: AppStyles.bgPill, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [['day','日'],['week','周'],['month','月']].map((item) {
                    final isActive = _range == item[0];
                    return Expanded(
                      child: TapBounce(
                        onTap: () { setState(() => _range = item[0]); _barCtrl.forward(from: 0); },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                            color: isActive ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: isActive ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4, offset: const Offset(0, 1))] : null,
                          ),
                          child: Text(item[1], textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                              color: isActive ? AppStyles.ink : AppStyles.ink2)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Bar charts
            _ChartCard(
              label: _range == 'day' ? '母乳与瓶喂 · 每日次数' : _range == 'week' ? '母乳与瓶喂 · 每周次数' : '母乳与瓶喂 · 每月次数', 
              big: milkAvg.toStringAsFixed(1), 
              unit: _range == 'day' ? '次/日 平均' : _range == 'week' ? '次/周 平均' : '次/月 平均', 
              delta: '→ 趋势平稳',
              icon: Icons.water_drop_outlined, color: AppStyles.cMilk, bg: AppStyles.cMilk2,
              data: milkData, anim: _barCtrl,
            ),
            _ChartCard(
              label: _range == 'day' ? '睡眠时长 · 每日总时长' : _range == 'week' ? '睡眠时长 · 每周总时长' : '睡眠时长 · 每月总时长', 
              big: sleepAvg.toStringAsFixed(1), 
              unit: _range == 'day' ? '小时/日 平均' : _range == 'week' ? '小时/周 平均' : '小时/月 平均', 
              delta: '→ 趋势平稳',
              icon: Icons.bedtime_outlined, color: AppStyles.cSleep, bg: AppStyles.cSleep2,
              data: sleepData, anim: _barCtrl, max: _range == 'day' ? 16 : _range == 'week' ? 112 : 480, 
              labelFmt: (v) => '${v.toStringAsFixed(1)}h',
            ),
            _ChartCard(
              label: _range == 'day' ? '尿布 · 每日次数' : _range == 'week' ? '尿布 · 每周次数' : '尿布 · 每月次数', 
              big: diaperAvg.toStringAsFixed(1), 
              unit: _range == 'day' ? '次/日 平均' : _range == 'week' ? '次/周 平均' : '次/月 平均', 
              delta: '→ 趋势平稳',
              icon: Icons.child_care_outlined, color: AppStyles.cDiaper, bg: AppStyles.cDiaper2,
              data: diaperData, anim: _barCtrl,
            ),

            // Weight card
            FadeUpWidget(
              child: GlassCard(
                margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                padding: const EdgeInsets.all(18),
                radius: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('体重曲线 · WHO 对照', style: TextStyle(fontSize: 13, color: AppStyles.ink2, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
                              const SizedBox(height: 4),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text('${baby.weightKg}', style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w600, color: AppStyles.ink, height: 1, fontFamily: 'Quicksand')),
                                  const SizedBox(width: 4),
                                  const Text('kg · P 52', style: TextStyle(fontSize: 13, color: AppStyles.ink3)),
                                ],
                              ),
                              const Text('↗ 处于健康区间', style: TextStyle(fontSize: 12, color: AppStyles.cGrowth)),
                            ],
                          ),
                        ),
                        CategoryIconWidget(icon: Icons.straighten_outlined, color: AppStyles.cGrowth, bg: AppStyles.cGrowth2, size: 32),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 160,
                      child: CustomPaint(
                        painter: _WeightChartPainter(
                          baby: baby,
                          records: state.records.where((r) => r.type == 'growth').toList(),
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _LegendItem(color: AppStyles.ink, label: baby.name, isLine: true),
                        const SizedBox(width: 14),
                        _LegendItem(color: AppStyles.cGrowth.withOpacity(0.6), label: 'WHO P50', isLine: true),
                        const SizedBox(width: 14),
                        _LegendItem(color: AppStyles.cGrowth2, label: 'P15-P85', isLine: false),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool isLine;
  const _LegendItem({required this.color, required this.label, required this.isLine});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(width: 14, height: isLine ? 2 : 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 5),
      Text(label, style: const TextStyle(fontSize: 11, color: AppStyles.ink2)),
    ],
  );
}

// ── Bar chart card ────────────────────────────────────────────────────────────
class _ChartCard extends StatelessWidget {
  final String label, big, unit, delta;
  final IconData icon;
  final Color color, bg;
  final List<Map<String, dynamic>> data;
  final AnimationController anim;
  final double? max;
  final String Function(double)? labelFmt;

  const _ChartCard({
    required this.label, required this.big, required this.unit, required this.delta,
    required this.icon, required this.color, required this.bg, required this.data,
    required this.anim, this.max, this.labelFmt,
  });

  @override
  Widget build(BuildContext context) {
    return FadeUpWidget(
      child: GlassCard(
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
        padding: const EdgeInsets.all(18),
        radius: 24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: const TextStyle(fontSize: 13, color: AppStyles.ink2, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
                      const SizedBox(height: 4),
                      Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(big, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w600, color: AppStyles.ink, height: 1, fontFamily: 'Quicksand')),
                          const SizedBox(width: 4),
                          Text(unit, style: const TextStyle(fontSize: 13, color: AppStyles.ink3)),
                        ],
                      ),
                      Text(delta, style: TextStyle(fontSize: 12, color: AppStyles.cGrowth)),
                    ],
                  ),
                ),
                CategoryIconWidget(icon: icon, color: color, bg: bg, size: 32),
              ],
            ),
            const SizedBox(height: 12),
            AnimatedBuilder(
              animation: anim,
              builder: (_, __) => _BarChart(data: data, color: color, max: max, labelFmt: labelFmt, progress: anim.value),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final Color color;
  final double? max;
  final String Function(double)? labelFmt;
  final double progress;

  const _BarChart({required this.data, required this.color, this.max, this.labelFmt, required this.progress});

  @override
  Widget build(BuildContext context) {
    final rawMax = data.map((d) => (d['v'] as double)).reduce((a, b) => a > b ? a : b);
    final maxV = max ?? (rawMax == 0 ? 1.0 : rawMax);
    return SizedBox(
      height: 140,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.asMap().entries.map((e) {
          final i = e.key;
          final d = e.value;
          final v = (d['v'] as double);
          final isToday = i == data.length - 1;
          final pct = ((v / maxV) * progress).clamp(0.0, 1.0);

          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isToday)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(labelFmt != null ? labelFmt!(v) : '${v.round()}',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
                  ),
                Flexible(
                  child: LayoutBuilder(builder: (_, c) => Container(
                    width: c.maxWidth * 0.7,
                    height: c.maxHeight * pct,
                    constraints: const BoxConstraints(minHeight: 4),
                    decoration: BoxDecoration(
                      color: isToday ? color : color.withOpacity(0.4),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8), bottom: Radius.circular(4)),
                    ),
                  )),
                ),
                const SizedBox(height: 8),
                Text(d['label'] as String, style: const TextStyle(fontSize: 10.5, color: AppStyles.ink3, fontWeight: FontWeight.w500)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Simple weight chart painter ───────────────────────────────────────────────
class _WeightChartPainter extends CustomPainter {
  final Baby baby;
  final List<Record> records;
  _WeightChartPainter({required this.baby, required this.records});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final pad = const Offset(24, 12);

    // WHO P50 data (approximate kg for 0-24 weeks, every 4 weeks)
    final p15 = [3.0, 4.2, 5.1, 5.8, 6.3, 6.7, 7.0];
    final p50 = [3.4, 4.9, 6.0, 6.8, 7.4, 7.9, 8.3];
    final p85 = [3.8, 5.5, 6.8, 7.8, 8.5, 9.1, 9.6];

    final yMin = 2.5, yMax = 11.0;
    final xCount = p50.length - 1;

    double px(int i) => pad.dx + (i / xCount) * (w - pad.dx * 2);
    double py(double kg) => h - pad.dy - ((kg - yMin) / (yMax - yMin)) * (h - pad.dy * 2);
    double pxWeek(double wk) => pad.dx + (wk.clamp(0.0, 24.0) / 24.0) * (w - pad.dx * 2);

    // Band
    final bandPath = Path();
    for (int i = 0; i < p15.length; i++) {
      i == 0 ? bandPath.moveTo(px(i), py(p85[i])) : bandPath.lineTo(px(i), py(p85[i]));
    }
    for (int i = p15.length - 1; i >= 0; i--) {
      bandPath.lineTo(px(i), py(p15[i]));
    }
    bandPath.close();
    canvas.drawPath(bandPath, Paint()..color = AppStyles.cGrowth2.withOpacity(0.5));

    // P50 dashed
    final p50Paint = Paint()..color = AppStyles.cGrowth.withOpacity(0.6)..strokeWidth = 1.2..style = PaintingStyle.stroke;
    final p50Path = Path();
    for (int i = 0; i < p50.length; i++) {
      i == 0 ? p50Path.moveTo(px(i), py(p50[i])) : p50Path.lineTo(px(i), py(p50[i]));
    }
    canvas.drawPath(p50Path, p50Paint);

    // Build real data points
    final pts = <Map<String, dynamic>>[];
    for (var r in records) {
      double wk = r.time.difference(baby.birthday).inDays / 7.0;
      if (wk < 0) wk = 0;
      final wKg = r.extra['weight'] as double?;
      if (wKg != null) {
        pts.add({'x': pxWeek(wk), 'y': py(wKg), 'kg': wKg});
      }
    }
    pts.sort((a, b) => (a['x'] as double).compareTo(b['x'] as double));

    if (pts.isEmpty) {
      // Fallback: just plot the current weight at current age
      double wk = DateTime.now().difference(baby.birthday).inDays / 7.0;
      if (wk < 0) wk = 0;
      pts.add({'x': pxWeek(wk), 'y': py(baby.weightKg), 'kg': baby.weightKg});
    }

    // Draw lines between points
    final userPath = Path();
    for (int i = 0; i < pts.length; i++) {
      final x = pts[i]['x'] as double;
      final y = pts[i]['y'] as double;
      i == 0 ? userPath.moveTo(x, y) : userPath.lineTo(x, y);
    }
    if (pts.length > 1) {
      canvas.drawPath(userPath, Paint()..color = AppStyles.ink..strokeWidth = 2..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);
    }

    // Draw dots and label for the last point
    for (int i = 0; i < pts.length; i++) {
      final x = pts[i]['x'] as double;
      final y = pts[i]['y'] as double;
      final kg = pts[i]['kg'] as double;
      final isLast = i == pts.length - 1;
      
      canvas.drawCircle(Offset(x, y), isLast ? 5.0 : 3.0,
        Paint()..color = isLast ? AppStyles.ink : Colors.white..style = PaintingStyle.fill);
      if (!isLast) {
        canvas.drawCircle(Offset(x, y), 3.0,
          Paint()..color = AppStyles.ink..style = PaintingStyle.stroke..strokeWidth = 1.8);
      }

      if (isLast) {
        final rrect = RRect.fromRectAndRadius(Rect.fromLTWH(x - 22, y - 26, 44, 18), const Radius.circular(4));
        canvas.drawRRect(rrect, Paint()..color = AppStyles.ink);
        final tp = TextPainter(
          text: TextSpan(text: '${kg}kg', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white)),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x - tp.width / 2, y - 22));
      }
    }

    // X-axis labels
    for (int i = 0; i <= 6; i += 2) {
      final tp2 = TextPainter(
        text: TextSpan(text: '${i * 4}周', style: const TextStyle(fontSize: 9, color: AppStyles.ink3)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp2.paint(canvas, Offset(px(i ~/ 1) - tp2.width / 2, h - 10));
    }
  }

  @override
  bool shouldRepaint(_WeightChartPainter old) => true; // Always repaint for simplicity when records change
}
