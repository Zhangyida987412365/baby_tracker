import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../utils/styles.dart';
import '../utils/categories.dart';
import '../utils/formatters.dart';
import '../widgets/shared.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onOpenTimer;
  final VoidCallback onOpenSleepTimer;
  final Function(String?) onOpenSheet;
  final VoidCallback onOpenAI;
  final Function(String) onGoTo;

  const HomeScreen({
    super.key,
    required this.onOpenTimer,
    required this.onOpenSleepTimer,
    required this.onOpenSheet,
    required this.onOpenAI,
    required this.onGoTo,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (_, state, __) {
      final records = state.todayRecords;
      final baby = state.baby;

      // compute stats
      final milkRecords = records.where((r) => r.type == 'breast').toList();
      final milkSec = milkRecords.fold(0, (s, r) => s + (r.value ?? 0));
      final bottleRecords = records.where((r) => r.type == 'bottle').toList();
      final bottleMl = bottleRecords.fold(0, (s, r) => s + (r.value ?? 0));
      final sleepRecords = records.where((r) => r.type == 'sleep').toList();
      final sleepSec = sleepRecords.fold(0, (s, r) => s + (r.value ?? 0));
      final diaperRecords = records.where((r) => r.type == 'diaper').toList();
      final lastBreastIter = records.where((r) => r.type == 'breast' || r.type == 'bottle');
      final lastBreast = lastBreastIter.isNotEmpty ? lastBreastIter.first : null;
      final recentTimeline = state.records.take(5).toList();

      int poo = 0;
      int pee = 0;
      for (final r in diaperRecords) {
        if (r.extra != null) {
          if (r.extra!['status'] == 'poo') poo++;
          if (r.extra!['status'] == 'pee') pee++;
          if (r.extra!['status'] == 'mixed') { poo++; pee++; }
        }
      }
      String diaperHint = diaperRecords.isNotEmpty ? '上次 ${relativeTime(diaperRecords.first.time)}' : '尚未记录';
      if (poo > 0 || pee > 0) diaperHint = '${poo > 0 ? "便便$poo次 " : ""}${pee > 0 ? "嘘嘘$pee次" : ""}';

      return SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────────────
            FadeUpWidget(
              child: PageHeaderWidget(
                title: '今天',
                subtitle: todayLabel(),
                right: TapBounce(
                  onTap: onOpenAI,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppStyles.bgPill, borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome, size: 16, color: AppStyles.ink),
                        SizedBox(width: 6),
                        Text('贝贝', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppStyles.ink)),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Baby hero card ─────────────────────────────────────────────────
            FadeUpWidget(
              delay: const Duration(milliseconds: 60),
              child: GlassCard(
                margin: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50, height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF9BBA), Color(0xFFFF7DA5)],
                              begin: Alignment.topLeft, end: Alignment.bottomRight,
                            ),
                            boxShadow: [BoxShadow(color: const Color(0x4DFF7DA5), blurRadius: 12, offset: const Offset(0, 4))],
                          ),
                          child: const Center(child: Text('米', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18))),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(baby.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppStyles.ink)),
                              const SizedBox(height: 2),
                              Text('${ageLabel(baby.birthday)} · ${baby.weightKg} kg · ${baby.heightCm} cm',
                                style: const TextStyle(fontSize: 12.5, color: AppStyles.ink2)),
                            ],
                          ),
                        ),
                        TapBounce(
                          onTap: () => onGoTo('mine'),
                          child: const Icon(Icons.chevron_right_rounded, color: AppStyles.ink3),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Active Timer Prompt (if any)
            if (state.breastTimerActive)
              FadeUpWidget(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                  child: TapBounce(
                    onTap: onOpenTimer,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppStyles.cMilk,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: AppStyles.cMilk.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Row(
                        children: [
                          if (state.breastTimerRunning)
                            const SizedBox(
                              width: 16, height: 16,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          else
                            const Icon(Icons.pause_circle_outline_rounded, color: Colors.white, size: 18),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text('亲喂记录中...', style: TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w600)),
                          ),
                          Text(fmtDuration((state.breastLeftSec + state.breastRightSec).round()), 
                            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600, fontFamily: 'Quicksand')),
                          const SizedBox(width: 6),
                          const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            if (state.sleepTimerActive)
              FadeUpWidget(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                  child: TapBounce(
                    onTap: onOpenSleepTimer,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppStyles.cSleep,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: AppStyles.cSleep.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Row(
                        children: [
                          if (state.sleepTimerRunning)
                            const SizedBox(
                              width: 16, height: 16,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          else
                            const Icon(Icons.pause_circle_outline_rounded, color: Colors.white, size: 18),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text('睡眠记录中...', style: TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w600)),
                          ),
                          Text(fmtDuration(state.sleepSec.round()), 
                            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600, fontFamily: 'Quicksand')),
                          const SizedBox(width: 6),
                          const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // ── Quick record ──────────────────────────────────────────────────
            FadeUpWidget(
              delay: const Duration(milliseconds: 90),
              child: const Padding(
                padding: EdgeInsets.fromLTRB(22, 0, 22, 12),
                child: Text('快捷记录', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppStyles.ink2, letterSpacing: 0.3)),
              ),
            ),
            FadeUpWidget(
              delay: const Duration(milliseconds: 110),
              child: SizedBox(
                height: 72,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  children: [
                    _QuickItem(icon: Icons.water_drop_outlined, color: AppStyles.cMilk, bg: AppStyles.cMilk2, label: '亲喂计时', onTap: onOpenTimer),
                    _QuickItem(icon: Icons.local_drink_outlined, color: AppStyles.cMilk, bg: AppStyles.cMilk2, label: '瓶喂', onTap: () => onOpenSheet('bottle')),
                    _QuickItem(icon: Icons.bedtime_outlined, color: AppStyles.cSleep, bg: AppStyles.cSleep2, label: '睡眠', onTap: onOpenSleepTimer),
                    _QuickItem(icon: Icons.child_care_outlined, color: AppStyles.cDiaper, bg: AppStyles.cDiaper2, label: '换尿布', onTap: () => onOpenSheet('diaper')),
                    _QuickItem(icon: Icons.restaurant_outlined, color: AppStyles.cFood, bg: AppStyles.cMilk2, label: '辅食', onTap: () => onOpenSheet('food')),
                  ],
                ),
              ),
            ),

            if (state.feedReminderEnabled || state.diaperReminderEnabled) ...[
              const SizedBox(height: 24),
              FadeUpWidget(
                delay: const Duration(milliseconds: 130),
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(22, 0, 22, 12),
                  child: Text('智能提醒', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppStyles.ink2, letterSpacing: 0.3)),
                ),
              ),
              FadeUpWidget(
                delay: const Duration(milliseconds: 140),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    children: [
                      if (state.feedReminderEnabled) ...[
                        _buildReminderCard(
                          context: context, state: state,
                          type: 'feed', icon: Icons.water_drop_outlined, title: '喂奶提醒', color: AppStyles.cMilk,
                          interval: state.feedIntervalHours,
                          onTapConfig: () => _showReminderSheet(context, state, 'feed'),
                          records: records.where((r) => r.type == 'breast' || r.type == 'bottle').toList(),
                        ),
                        const SizedBox(height: 10),
                      ],
                      if (state.diaperReminderEnabled) ...[
                        _buildReminderCard(
                          context: context, state: state,
                          type: 'diaper', icon: Icons.child_care_outlined, title: '换尿布提醒', color: AppStyles.cDiaper,
                          interval: state.diaperIntervalHours,
                          onTapConfig: () => _showReminderSheet(context, state, 'diaper'),
                          records: records.where((r) => r.type == 'diaper').toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),

            // ── Today overview label ───────────────────────────────────────────
            FadeUpWidget(
              delay: const Duration(milliseconds: 130),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('今日概览', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppStyles.ink2, letterSpacing: 0.3)),
                    TapBounce(
                      onTap: () => onGoTo('stats'),
                      child: const Text('看趋势 ›', style: TextStyle(fontSize: 12.5, color: AppStyles.ink3)),
                    ),
                  ],
                ),
              ),
            ),

            // ── Stat grid ─────────────────────────────────────────────────────
            FadeUpWidget(
              delay: const Duration(milliseconds: 160),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: GridView.count(
                  crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10,
                  shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.4,
                  children: [
                    _StatCard(
                      icon: Icons.water_drop_outlined, color: AppStyles.cMilk, bg: AppStyles.cMilk2,
                      label: '母乳亲喂', value: '${milkRecords.length}',
                      unit: '次 · ${(milkSec / 60).round()}min',
                      hint: lastBreast != null ? '上次 ${relativeTime(lastBreast.time)}' : '尚未记录',
                      ring: milkSec / (8 * 3600),
                      onTap: () => onGoTo('history:breast'),
                    ),
                    _StatCard(
                      icon: Icons.local_drink_outlined, color: AppStyles.cMilk, bg: AppStyles.cMilk2,
                      label: '配方奶', value: '$bottleMl', unit: 'ml',
                      progress: bottleMl / 800,
                      onTap: () => onGoTo('history:bottle'),
                    ),
                    _StatCard(
                      icon: Icons.bedtime_outlined, color: AppStyles.cSleep, bg: AppStyles.cSleep2,
                      label: '睡眠', value: '${sleepSec ~/ 3600}',
                      unit: '小时 ${(sleepSec % 3600 / 60).round()} 分',
                      hint: '${sleepRecords.length} 段',
                      onTap: () => onGoTo('history:sleep'),
                    ),
                    _StatCard(
                      icon: Icons.child_care_outlined, color: AppStyles.cDiaper, bg: AppStyles.cDiaper2,
                      label: '尿布', value: '${diaperRecords.length}', unit: '次',
                      hint: diaperHint,
                      dots: diaperRecords.length,
                      onTap: () => onGoTo('history:diaper'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 36),

            // ── Today timeline ─────────────────────────────────────────────────
            FadeUpWidget(
              delay: const Duration(milliseconds: 200),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('最近的足迹', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppStyles.ink2, letterSpacing: 0.3)),
                    TapBounce(
                      onTap: () => onGoTo('history'),
                      child: const Text('全部 ›', style: TextStyle(fontSize: 12.5, color: AppStyles.ink3)),
                    ),
                  ],
                ),
              ),
            ),
            FadeUpWidget(
              delay: const Duration(milliseconds: 220),
              child: GlassCard(
                margin: const EdgeInsets.symmetric(horizontal: 18),
                radius: 22,
                child: Column(
                  children: [
                    ...recentTimeline.asMap().entries.map((e) {
                      final i = e.key;
                      final r = e.value;
                      final c = categories[r.type]!;
                      final isLast = i == recentTimeline.length - 1;
                      return Column(
                        children: [
                          TapBounce(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 44,
                                    child: Text(fmtTime(r.time),
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(fontSize: 13, color: AppStyles.ink3,
                                        fontFeatures: [FontFeature.tabularFigures()])),
                                  ),
                                  const SizedBox(width: 12),
                                  CategoryIconWidget(icon: c.icon, color: c.color, bg: c.bg),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(c.label, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500, color: AppStyles.ink)),
                                        Text(describeRecord(r.toJson()), style: const TextStyle(fontSize: 12.5, color: AppStyles.ink2)),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right_rounded, color: AppStyles.ink4, size: 18),
                                ],
                              ),
                            ),
                          ),
                          if (!isLast) Container(height: 1, margin: const EdgeInsets.only(left: 86), color: AppStyles.line.withOpacity(0.5)),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 36),

            // ── AI banner ──────────────────────────────────────────────────────
            FadeUpWidget(
              delay: const Duration(milliseconds: 250),
              child: TapBounce(
                onTap: onOpenAI,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(18, 0, 18, 0),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEFE5DD), Color(0xFFF6E8DA)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: AppStyles.shadowCard,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFC77B5E), Color(0xFFD88B5F)],
                            begin: Alignment.topLeft, end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Icon(Icons.auto_awesome, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('贝贝问问', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: AppStyles.ink)),
                            const SizedBox(height: 2),
                            Text('根据今日数据，${baby.name}接下来该怎么安排？',
                              style: const TextStyle(fontSize: 12.5, color: AppStyles.ink2)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppStyles.ink3),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ── Stat card ─────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color, bg;
  final String label, value, unit;
  final String? hint;
  final double? ring, progress;
  final int? dots;
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon, required this.color, required this.bg,
    required this.label, required this.value, required this.unit,
    this.hint, this.ring, this.progress, this.dots, this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TapBounce(
      onTap: onTap,
      child: GlassCard(
        radius: 26,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CategoryIconWidget(icon: icon, color: color, bg: bg, size: 30),
                const Spacer(),
                if (ring != null) MiniRing(pct: ring!, color: color)
                else if (dots != null) Row(children: List.generate(dots!, (_) =>
                  Container(width: 6, height: 6, margin: const EdgeInsets.only(left: 3),
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle)))),
              ],
            ),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(fontSize: 12.5, color: AppStyles.ink2, letterSpacing: 0.2)),
            const SizedBox(height: 2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(value, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w600, color: AppStyles.ink, height: 1, fontFamily: 'Quicksand')),
                const SizedBox(width: 4),
                Text(unit, style: const TextStyle(fontSize: 12, color: AppStyles.ink3)),
              ],
            ),
            if (progress != null) ...[
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: progress!.clamp(0.0, 1.0),
                  minHeight: 4,
                  backgroundColor: AppStyles.bgPill,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
            ],
            if (hint != null) Text(hint!, style: const TextStyle(fontSize: 11.5, color: AppStyles.ink3)),
          ],
        ),
      ),
    );
  }
}

// ── Quick item ────────────────────────────────────────────────────────────────
class _QuickItem extends StatelessWidget {
  final IconData icon;
  final Color color, bg;
  final String label;
  final VoidCallback? onTap;

  const _QuickItem({required this.icon, required this.color, required this.bg, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return TapBounce(
      onTap: onTap,
      child: GlassCard(
        margin: const EdgeInsets.only(right: 8),
        radius: 24,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CategoryIconWidget(icon: icon, color: color, bg: bg, size: 28),
            const SizedBox(width: 9),
            Text(label, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500, color: AppStyles.ink)),
          ],
        ),
      ),
    );
  }
}

// ── Reminder Settings Bottom Sheet ───────────────────────────────────────────
void _showReminderSheet(BuildContext context, AppState state, String type) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _ReminderSheet(state: state, type: type),
  );
}

class _ReminderSheet extends StatefulWidget {
  final AppState state;
  final String type;
  const _ReminderSheet({required this.state, required this.type});
  @override
  State<_ReminderSheet> createState() => _ReminderSheetState();
}

class _ReminderSheetState extends State<_ReminderSheet> {
  late double _interval;
  late bool _enabled;

  static const List<double> _presets = [1.5, 2.0, 2.5, 3.0, 3.5, 4.0];

  @override
  void initState() {
    super.initState();
    if (widget.type == 'feed') {
      _interval = widget.state.feedIntervalHours;
      _enabled = widget.state.feedReminderEnabled;
    } else {
      _interval = widget.state.diaperIntervalHours;
      _enabled = widget.state.diaperReminderEnabled;
    }
  }

  // Returns short Chinese label for dots
  String _dotLabel(double h) {
    if (h % 1 == 0) return '${h.toInt()}小时';
    return '$h小时';
  }

  // Returns the big display number string
  String _bigNum(double h) {
    if (h % 1 == 0) return '${h.toInt()}';
    return '$h';
  }

  @override
  Widget build(BuildContext context) {
    String title = '';
    Color themeColor = AppStyles.cMilk;
    int actualCount = 0;
    
    if (widget.type == 'feed') {
      title = '喂奶提醒设置';
      themeColor = AppStyles.cMilk;
      actualCount = widget.state.todayRecords.where((r) => r.type == 'breast' || r.type == 'bottle').length;
    } else {
      title = '换尿布提醒设置';
      themeColor = AppStyles.cDiaper;
      actualCount = widget.state.todayRecords.where((r) => r.type == 'diaper').length;
    }

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFCF5F5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: const Color(0xFFDDD8D0), borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Row(children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [themeColor.withOpacity(0.8), themeColor]),
              ),
              child: const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppStyles.ink)),
              const Text('根据宝宝作息灵活调整', style: TextStyle(fontSize: 12, color: AppStyles.ink3)),
            ]),
            const Spacer(),
            Switch(
              value: _enabled,
              activeColor: themeColor,
              onChanged: (v) => setState(() => _enabled = v),
            ),
          ]),
          const SizedBox(height: 24),

          // Today summary card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)],
            ),
            child: Row(children: [
              _SumCol(widget.type == 'feed' ? '今日已喂' : '今日已记录', '$actualCount 次', themeColor),
              Container(width: 1, height: 36, color: AppStyles.line.withOpacity(0.5)),
              _SumCol('当前提醒间隔', _dotLabel(_interval), themeColor),
            ]),
          ),
          const SizedBox(height: 24),

          // Interval selector - Big display + custom snap slider
          Center(
            child: Column(
              children: [
                // Big animated display: large number + 小时 unit below
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                  child: RichText(
                    key: ValueKey(_interval),
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: _bigNum(_interval),
                          style: const TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.w800,
                            color: AppStyles.brand,
                            letterSpacing: -2,
                          ),
                        ),
                        const TextSpan(
                          text: ' 小时',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: AppStyles.brand,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Text('每隔此时间喂一次奶', style: TextStyle(fontSize: 12, color: AppStyles.ink3)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Snap dots row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _presets.map((h) {
                final isActive = _interval == h;
                return TapBounce(
                  onTap: () => setState(() => _interval = h),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isActive ? 10 : 7,
                        height: isActive ? 10 : 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive ? AppStyles.brand : const Color(0xFFDDD8D0),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _dotLabel(h),
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                          color: isActive ? AppStyles.brand : AppStyles.ink3,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),

          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppStyles.brand,
              inactiveTrackColor: AppStyles.brand.withOpacity(0.15),
              thumbColor: Colors.white,
              overlayColor: AppStyles.brand.withOpacity(0.12),
              trackHeight: 5,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12, elevation: 4),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
            ),
            child: Slider(
              min: _presets.first,
              max: _presets.last,
              divisions: (_presets.length - 1) * 2,
              value: _interval,
              onChanged: (v) {
                // Snap to nearest preset
                final snapped = _presets.reduce((a, b) => (v - a).abs() < (v - b).abs() ? a : b);
                setState(() => _interval = snapped);
              },
            ),
          ),
          const SizedBox(height: 28),

          // Save button
          TapBounce(
            onTap: () {
              if (widget.type == 'feed') {
                widget.state.setFeedInterval(_interval);
                widget.state.toggleFeedReminder(_enabled);
              } else {
                widget.state.setDiaperInterval(_interval);
                widget.state.toggleDiaperReminder(_enabled);
              }
              Navigator.pop(context);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [themeColor.withOpacity(0.8), themeColor]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: themeColor.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))],
              ),
              child: const Center(
                child: Text('保存设置', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 0.5)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildReminderCard({
  required BuildContext context,
  required AppState state,
  required String type,
  required IconData icon,
  required String title,
  required Color color,
  required double interval,
  required VoidCallback onTapConfig,
  required List<Record> records,
}) {
  String nextLabel = '';
  String subLabel = '';

  if (records.isEmpty) {
    nextLabel = '随时可以';
    subLabel = '尚未记录过此项目';
  } else {
    final lastRecord = records.first;
    final nextTime = lastRecord.time.add(Duration(minutes: (interval * 60).round()));
    final diff = nextTime.difference(DateTime.now());
    if (diff.isNegative) {
      nextLabel = '❗ 已到时间';
    } else {
      final hrs = diff.inHours;
      final mins = diff.inMinutes % 60;
      if (hrs > 0) nextLabel = '约 $hrs 小时 $mins 分钟后';
      else nextLabel = '约 $mins 分钟后';
    }
    subLabel = '距上次 ${relativeTime(lastRecord.time)}';
  }

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.9),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
    ),
    child: Row(
      children: [
        CategoryIconWidget(icon: icon, color: color, bg: color.withOpacity(0.12), size: 40),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppStyles.ink)),
              const SizedBox(height: 4),
              Text(nextLabel, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
              const SizedBox(height: 2),
              Text(subLabel, style: const TextStyle(fontSize: 11.5, color: AppStyles.ink3)),
            ],
          ),
        ),
        TapBounce(
          onTap: onTapConfig,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.notifications_active_rounded, size: 14, color: color),
                const SizedBox(width: 5),
                Text('${interval % 1 == 0 ? interval.toInt() : interval}h',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: color),
                ),
              ],
            ),
          ),
        )
      ],
    ),
  );
}

class _SumCol extends StatelessWidget {
  final String label, val;
  final Color color;
  const _SumCol(this.label, this.val, this.color);
  @override
  Widget build(BuildContext context) => Expanded(child: Column(children: [
    Text(label, style: const TextStyle(fontSize: 11, color: AppStyles.ink3)),
    const SizedBox(height: 4),
    Text(val, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: color)),
  ]));
}
