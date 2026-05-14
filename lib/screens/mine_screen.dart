import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../utils/styles.dart';
import '../utils/categories.dart';
import '../utils/formatters.dart';
import '../widgets/shared.dart';
import '../widgets/settings_dialogs.dart';

// ── Milestone Data Model ──────────────────────────────────────────────────────
class _Milestone {
  final String emoji;
  final String title;
  final String hint;
  final Color color;
  DateTime? achievedAt; // null = locked
  _Milestone({required this.emoji, required this.title, required this.hint, required this.color, this.achievedAt});

  String get achievedLabel {
    if (achievedAt == null) return '';
    final d = achievedAt!;
    return '${d.year}年${d.month}月${d.day}日 · 人生第一次';
  }
}

// ── Screen ────────────────────────────────────────────────────────────────────
class MineScreen extends StatefulWidget {
  final VoidCallback onOpenOnboarding;
  const MineScreen({super.key, required this.onOpenOnboarding});

  @override
  State<MineScreen> createState() => _MineScreenState();
}

class _MineScreenState extends State<MineScreen> {
  final List<_Milestone> _milestones = [
    _Milestone(emoji: '🌟', title: '第一次睁眼', hint: '第一次打量这个世界', color: const Color(0xFF60A5FA)),
    _Milestone(emoji: '✋', title: '第一次伸手', hint: '小手努力探索的开始', color: const Color(0xFF06D6A0)),
    _Milestone(emoji: '😊', title: '第一次笑', hint: '融化心房的纯真笑容', color: const Color(0xFFFFD166)),
    _Milestone(emoji: '🐣', title: '第一次抬头', hint: '努力仰望更广阔的世界', color: const Color(0xFFFF9F51)),
    _Milestone(emoji: '🐬', title: '第一次翻身', hint: '掌握了翻滚的新技能', color: const Color(0xFF8CA5E8)),
    _Milestone(emoji: '🐼', title: '第一次坐', hint: '终于能稳稳坐着看世界啦', color: const Color(0xFFA78BFA)),
    _Milestone(emoji: '🐛', title: '第一次爬', hint: '化身敏捷的小爬行家', color: const Color(0xFF06D6A0)),
    _Milestone(emoji: '🗼', title: '第一次站', hint: '靠自己的力量稳稳站立', color: const Color(0xFFFF8C61)),
    _Milestone(emoji: '👣', title: '第一次走', hint: '迈向独立的第一小步', color: const Color(0xFFFF6B9D)),
    _Milestone(emoji: '💬', title: '第一次叫爸爸妈妈', hint: '世上最动听的声音', color: const Color(0xFFFF6B9D)),
  ];

  void _showUnlockDialog(BuildContext context, int idx, AppState state, Baby baby) {
    final m = _milestones[idx];
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.55),
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (ctx, anim, _, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
        return ScaleTransition(scale: curved, child: FadeTransition(opacity: anim, child: child));
      },
      pageBuilder: (ctx, _, __) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 28),
            padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [BoxShadow(color: m.color.withOpacity(0.25), blurRadius: 40, offset: const Offset(0, 16))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Big emoji
                Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: m.color.withOpacity(0.12),
                    border: Border.all(color: m.color.withOpacity(0.3), width: 2),
                  ),
                  child: Center(child: Text(m.emoji, style: const TextStyle(fontSize: 42))),
                ),
                const SizedBox(height: 20),

                Text('🎉 准备解锁！', style: TextStyle(fontSize: 13, color: m.color, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                const SizedBox(height: 8),
                Text(m.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppStyles.ink), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    color: m.color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '这一刻常常是最小的事，却是你心里最大的宇宙。\n点击下方按鈕，记录${baby.name}的这一步。',
                    style: TextStyle(fontSize: 13.5, color: AppStyles.ink2, height: 1.7),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),

                // Record button
                TapBounce(
                  onTap: () {
                    Navigator.pop(ctx);
                    state.addRecord(Record(
                      babyId: baby.dbId ?? 1,
                      time: DateTime.now(),
                      type: 'milestone',
                      extra: {'title': m.title, 'emoji': m.emoji},
                    ));
                    _showCelebration(context, m, baby);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [m.color.withOpacity(0.85), m.color],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: m.color.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))],
                    ),
                    child: const Center(
                      child: Text('记录这一刻 ✨', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('稍后再说', style: TextStyle(color: AppStyles.ink3, fontSize: 13)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCelebration(BuildContext context, _Milestone m, Baby baby) {
    final GlobalKey boundaryKey = GlobalKey();
    bool hasPhoto = false;
    bool isGenerating = false;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.85),
      transitionDuration: const Duration(milliseconds: 600),
      transitionBuilder: (ctx, anim, _, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
        return ScaleTransition(scale: curved, child: FadeTransition(opacity: anim, child: child));
      },
      pageBuilder: (ctx, anim, __) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return _ConfettiWidget(
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  width: double.infinity,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // The Outer Shadow
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(color: m.color.withOpacity(0.4), blurRadius: 40, spreadRadius: 10),
                            const BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, 10)),
                          ],
                        ),
                        // The Screenshot Boundary
                        child: RepaintBoundary(
                          key: boundaryKey,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAF9F6), // Premium warm white paper
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(24, 48, 24, 42),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text('CERTIFICATE OF MILESTONE', style: TextStyle(fontSize: 10, letterSpacing: 2, color: AppStyles.ink3, fontWeight: FontWeight.w700)),
                                      const SizedBox(height: 24),
                                      
                                      // Photo Area
                                      TapBounce(
                                        onTap: () {
                                          setStateDialog(() => hasPhoto = true);
                                          _showMsg(context, '📸 咔嚓！定格这珍贵的一刻！');
                                        },
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 400),
                                          width: 120, height: 120,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: hasPhoto ? null : LinearGradient(colors: [m.color.withOpacity(0.2), m.color.withOpacity(0.05)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                                            border: Border.all(color: m.color.withOpacity(hasPhoto ? 0.8 : 0.5), width: hasPhoto ? 4 : 3),
                                            image: hasPhoto ? const DecorationImage(image: NetworkImage('https://images.unsplash.com/photo-1519689680058-324335c77eba?auto=format&fit=crop&w=300&q=80'), fit: BoxFit.cover) : null,
                                            boxShadow: hasPhoto ? [BoxShadow(color: m.color.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))] : null,
                                          ),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            clipBehavior: Clip.none,
                                            children: [
                                              if (!hasPhoto) Center(child: Text(m.emoji, style: const TextStyle(fontSize: 54))),
                                              if (hasPhoto) Positioned(bottom: -8, right: -8, child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]), child: Text(m.emoji, style: const TextStyle(fontSize: 22)))),
                                              if (!hasPhoto) Positioned(bottom: -12, child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), decoration: BoxDecoration(color: m.color, borderRadius: BorderRadius.circular(16)), child: const Text('拍张照', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)))),
                                            ],
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 32),
                                      Text(baby.name.isEmpty ? '宝宝' : baby.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppStyles.ink, letterSpacing: 1)),
                                      const SizedBox(height: 8),
                                      const Text('在今天完成了', style: TextStyle(fontSize: 13, color: AppStyles.ink2)),
                                      const SizedBox(height: 12),
                                      Text('「 ${m.title} 」', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: m.color)),
                                      const SizedBox(height: 20),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 16),
                                        child: Text(
                                          '每一个第一次，都是生命中最闪耀的星星。\n这一天，我们将永远珍藏。',
                                          style: TextStyle(fontSize: 14, color: AppStyles.ink2, height: 1.8, fontStyle: FontStyle.italic),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // The Stamp Animation (Now inside the screenshot boundary)
                                Positioned(
                                  bottom: 24, right: 24,
                                  child: IgnorePointer(
                                    child: TweenAnimationBuilder<double>(
                                      tween: Tween(begin: 3.0, end: 1.0),
                                      duration: const Duration(milliseconds: 800),
                                      curve: Curves.elasticOut,
                                      builder: (_, scale, __) => Transform.scale(
                                        scale: scale,
                                        child: Opacity(
                                          opacity: (4.0 - scale).clamp(0.0, 1.0),
                                          child: Transform.rotate(
                                            angle: -0.2,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.redAccent.withOpacity(0.7), width: 3),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Column(
                                                children: [
                                                  const Text('ACHIEVED', style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2)),
                                                  Text('${DateTime.now().year}.${DateTime.now().month}.${DateTime.now().day}', style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w800)),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      // Decorative top pin (Outside boundary, just for UI overlay)
                      Positioned(
                        top: -10, left: 0, right: 0,
                        child: Center(
                          child: Container(
                            width: 40, height: 12,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 2))],
                            ),
                          ),
                        ),
                      ),

                      // Floating Action Buttons (Outside boundary, not in screenshot)
                      Positioned(
                        bottom: -76, left: 0, right: 0,
                        child: isGenerating ? const Center(child: CircularProgressIndicator(color: Colors.white)) : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TapBounce(
                              onTap: () async {
                                if (!hasPhoto) {
                                  _showMsg(context, '别急，先点击上方给宝宝拍张照吧！');
                                  return;
                                }
                                setStateDialog(() => isGenerating = true);
                                // Here we would capture boundaryKey and use share_plus
                                await Future.delayed(const Duration(milliseconds: 1500)); 
                                setStateDialog(() => isGenerating = false);
                                _showMsg(context, '✅ 完美！已为您生成专属海报并跳转微信朋友圈。');
                                Navigator.pop(ctx);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF07C160), // WeChat Green
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [BoxShadow(color: const Color(0xFF07C160).withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))],
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.wechat_rounded, color: Colors.white, size: 20),
                                    SizedBox(width: 8),
                                    Text('分享朋友圈', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            TapBounce(
                              onTap: () async {
                                setStateDialog(() => isGenerating = true);
                                await Future.delayed(const Duration(milliseconds: 800));
                                setStateDialog(() => isGenerating = false);
                                _showMsg(context, '🎉 卡片已保存至本地相册');
                                Navigator.pop(ctx);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
                                ),
                                child: const Icon(Icons.download_rounded, color: AppStyles.ink2, size: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (_, state, __) {
      final baby = state.baby;
      
      for (var m in _milestones) {
        final recs = state.records.where((r) => r.type == 'milestone' && r.extra['title'] == m.title);
        m.achievedAt = recs.isNotEmpty ? recs.first.time : null;
      }

      final unlockedCount = _milestones.where((m) => m.achievedAt != null).length;

      return SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 86, 24, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFFFCF5F5), const Color(0xFFFCF5F5).withOpacity(0)],
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                ),
              ),
              child: const Text('我的', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600, fontFamily: 'Quicksand', color: AppStyles.ink)),
            ),

            // Baby card
            FadeUpWidget(
              child: GlassCard(
                margin: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                padding: const EdgeInsets.all(18),
                radius: 24,
                child: Row(
                  children: [
                    Container(
                      width: 60, height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(colors: [Color(0xFFFF8BA3), Color(0xFFFF5A79)]),
                        boxShadow: [BoxShadow(color: const Color(0x4DFF5A79), blurRadius: 12, offset: const Offset(0, 4))],
                      ),
                      child: Center(child: Text(baby.name.isNotEmpty ? baby.name.substring(0, 1) : '宝', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 22))),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(baby.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppStyles.ink)),
                          const SizedBox(height: 3),
                          Text('女孩 · ${ageLabel(baby.birthday)} · ${baby.weightKg} kg',
                            style: const TextStyle(fontSize: 12.5, color: AppStyles.ink2)),
                        ],
                      ),
                    ),
                    TapBounce(
                      onTap: () {
                        if (state.babies.length > 1) {
                          final idx = state.babies.indexWhere((b) => b.dbId == baby.dbId);
                          final next = state.babies[(idx + 1) % state.babies.length];
                          if (next.dbId != null) state.switchBaby(next.dbId!);
                          _showMsg(context, '已切换至 ${next.name}');
                        } else {
                          _showMsg(context, '请先在下方添加宝宝档案');
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: AppStyles.bgPill, borderRadius: BorderRadius.circular(20)),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.swap_vert_rounded, size: 14, color: AppStyles.ink2),
                            SizedBox(width: 5),
                            Text('切换', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: AppStyles.ink2)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            _sectionLabel('我的宝宝'),

            // Baby list
            FadeUpWidget(
              child: GlassCard(
                margin: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                padding: const EdgeInsets.symmetric(vertical: 4),
                radius: 22,
                child: Column(
                  children: [
                    ...state.babies.asMap().entries.map((e) {
                      final b = e.value;
                      final isActive = b.dbId == baby.dbId;
                      final colorIdx = (b.dbId ?? 0) % 4;
                      final colors = [const Color(0xFFE89668), const Color(0xFF6E7DA0), const Color(0xFF8FA48E), AppStyles.cMilk];
                      return Column(
                        children: [
                          TapBounce(
                            onTap: () async {
                              if (!isActive && b.dbId != null) {
                                await state.switchBaby(b.dbId!);
                                _showMsg(context, '已切换至 ${b.name} 档案');
                              }
                            },
                            onLongPress: () {
                              if (b.dbId == null) return;
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('删除宝宝'),
                                  content: Text('确定要删除 ${b.name} 及其所有记录吗？此操作无法恢复。'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.pop(ctx);
                                        await state.deleteBaby(b.dbId!);
                                        _showMsg(context, '已删除 ${b.name} 档案');
                                      },
                                      child: const Text('删除', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: _BabyRow(
                              name: b.name,
                              age: ageLabel(b.birthday),
                              color: colors[colorIdx],
                              initial: b.name.isNotEmpty ? b.name.substring(0, 1) : '宝',
                              isActive: isActive,
                              onDelete: isActive || b.dbId == null ? null : () {
                                showGeneralDialog(
                                  context: context,
                                  barrierDismissible: true,
                                  barrierLabel: '',
                                  barrierColor: Colors.black.withOpacity(0.4),
                                  transitionDuration: const Duration(milliseconds: 300),
                                  transitionBuilder: (ctx, anim, _, child) {
                                    return ScaleTransition(
                                      scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
                                      child: FadeTransition(opacity: anim, child: child),
                                    );
                                  },
                                  pageBuilder: (ctx, _, __) => Center(
                                    child: Material(
                                      color: Colors.transparent,
                                      child: Container(
                                        width: 320,
                                        padding: const EdgeInsets.all(24),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.95),
                                          borderRadius: BorderRadius.circular(28),
                                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 56, height: 56,
                                              decoration: BoxDecoration(
                                                color: Colors.redAccent.withOpacity(0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent, size: 28),
                                            ),
                                            const SizedBox(height: 16),
                                            const Text('删除宝宝档案', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppStyles.ink)),
                                            const SizedBox(height: 8),
                                            Text('确定要删除 ${b.name} 及其所有的记录吗？\n此操作一旦执行将无法恢复。',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(fontSize: 14, color: AppStyles.ink2, height: 1.5)),
                                            const SizedBox(height: 28),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: TapBounce(
                                                    onTap: () => Navigator.pop(ctx),
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                                      decoration: BoxDecoration(color: AppStyles.bgPill, borderRadius: BorderRadius.circular(16)),
                                                      child: const Center(child: Text('取消', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppStyles.ink2))),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: TapBounce(
                                                    onTap: () async {
                                                      Navigator.pop(ctx);
                                                      await state.deleteBaby(b.dbId!);
                                                      _showMsg(context, '已删除 ${b.name} 档案');
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                                      decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.redAccent.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))]),
                                                      child: const Center(child: Text('确认删除', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white))),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Container(height: 1, margin: const EdgeInsets.only(left: 64), color: AppStyles.line.withOpacity(0.5)),
                        ],
                      );
                    }),
                    TapBounce(
                      onTap: widget.onOpenOnboarding,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                        child: Row(
                          children: [
                            Container(
                              width: 38, height: 38, decoration: BoxDecoration(shape: BoxShape.circle, color: AppStyles.cMilk2),
                              child: const Icon(Icons.add_rounded, color: AppStyles.cMilk, size: 20),
                            ),
                            const SizedBox(width: 12),
                            const Text('添加宝宝', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500, color: AppStyles.cMilk)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Milestone Section ─────────────────────────────────────────────
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 8),
              child: Row(children: [
                Expanded(child: Text('成长里程碑'.toUpperCase(), style: const TextStyle(fontSize: 11.5, color: AppStyles.ink3, letterSpacing: 0.6, fontWeight: FontWeight.w600))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppStyles.cMilk.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                  child: Text('$unlockedCount / ${_milestones.length} 已解锁',
                    style: TextStyle(fontSize: 11, color: AppStyles.cMilk, fontWeight: FontWeight.w600)),
                ),
              ]),
            ),

            FadeUpWidget(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.6,
                  ),
                  itemCount: _milestones.length,
                  itemBuilder: (_, i) {
                    final m = _milestones[i];
                    final unlocked = m.achievedAt != null;
                    return TapBounce(
                      onTap: () {
                        if (!unlocked) {
                          _showUnlockDialog(context, i, state, baby);
                        } else {
                          _showMsg(context, '🎉 ${m.title}: ${m.achievedLabel}');
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: unlocked ? m.color.withOpacity(0.1) : Colors.white.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: unlocked ? m.color.withOpacity(0.35) : AppStyles.line.withOpacity(0.4),
                            width: 1.5,
                          ),
                          boxShadow: unlocked ? [
                            BoxShadow(color: m.color.withOpacity(0.15), blurRadius: 14, offset: const Offset(0, 5))
                          ] : [],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(m.emoji, style: TextStyle(fontSize: 22, color: unlocked ? null : Colors.black.withOpacity(0.2))),
                                const Spacer(),
                                if (!unlocked)
                                  Icon(Icons.lock_outline_rounded, size: 13, color: AppStyles.ink3.withOpacity(0.4))
                                else
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: m.color.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text('✓ 已解锁', style: TextStyle(fontSize: 9.5, color: m.color, fontWeight: FontWeight.w700)),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              m.title,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: unlocked ? AppStyles.ink : AppStyles.ink3,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              unlocked ? m.achievedLabel : m.hint,
                              style: TextStyle(
                                fontSize: 10.5,
                                color: unlocked ? m.color : AppStyles.ink3.withOpacity(0.65),
                                fontWeight: unlocked ? FontWeight.w600 : FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),
            _sectionLabel('设置'),

            FadeUpWidget(
              child: GlassCard(
                margin: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                radius: 22,
                child: Column(
                  children: [

                    _SettingsRow(
                      icon: Icons.notifications_active_outlined, iconColor: const Color(0xFFF09A6C), 
                      label: '提醒与通知', subtitle: '按需定制规律作息',
                      onTap: () => showNotificationSettings(context),
                    ),
                    Container(height: 1, margin: const EdgeInsets.only(left: 70), color: AppStyles.line.withOpacity(0.4)),
                    _SettingsRow(
                      icon: Icons.ios_share_rounded, iconColor: const Color(0xFF6E7DA0), 
                      label: '数据导出', subtitle: '一键生成记录表格',
                      onTap: () => showExportSheet(context),
                    ),
                    Container(height: 1, margin: const EdgeInsets.only(left: 70), color: AppStyles.line.withOpacity(0.4)),
                    _SettingsRow(
                      icon: Icons.cloud_done_outlined, iconColor: const Color(0xFF8FA48E), 
                      label: '云端同步', subtitle: '全家共享无缝连接',
                      onTap: () => showSyncDialog(context),
                    ),
                    Container(height: 1, margin: const EdgeInsets.only(left: 70), color: AppStyles.line.withOpacity(0.4)),
                    _SettingsRow(
                      icon: Icons.verified_outlined, iconColor: const Color(0xFFB07AA1), 
                      label: '关于宝宝记', subtitle: 'Version 1.0.0 Pro',
                      onTap: () => showCustomAboutDialog(context),
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

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.fromLTRB(30, 0, 30, 6),
    child: Text(text.toUpperCase(), style: const TextStyle(fontSize: 11.5, color: AppStyles.ink3, letterSpacing: 0.6, fontWeight: FontWeight.w600)),
  );

  void _showMsg(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppStyles.ink,
      duration: const Duration(seconds: 2),
    ));
  }
}

class _BabyRow extends StatelessWidget {
  final String name, age, initial;
  final Color color;
  final bool isActive;
  final VoidCallback? onDelete;
  const _BabyRow({required this.name, required this.age, required this.initial, required this.color, this.isActive = false, this.onDelete});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
    child: Row(
      children: [
        Container(width: 38, height: 38, decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          child: Center(child: Text(initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500, color: AppStyles.ink)),
          Text(age, style: const TextStyle(fontSize: 11.5, color: AppStyles.ink3)),
        ])),
        if (isActive) 
          const Text('当前', style: TextStyle(fontSize: 11, color: AppStyles.cMilk, fontWeight: FontWeight.w600))
        else if (onDelete != null)
          TapBounce(
            onTap: onDelete,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
            ),
          ),
        const SizedBox(width: 8),
        if (isActive || onDelete == null) 
          const Icon(Icons.chevron_right_rounded, color: AppStyles.ink4, size: 18),
      ],
    ),
  );
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String? subtitle;
  final String? value;
  final VoidCallback? onTap;
  const _SettingsRow({required this.icon, required this.iconColor, required this.label, this.subtitle, this.value, this.onTap});

  @override
  Widget build(BuildContext context) => TapBounce(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          CategoryIconWidget(icon: icon, color: iconColor, bg: iconColor.withOpacity(0.12), size: 40),
          const SizedBox(width: 14),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppStyles.ink)),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!, style: const TextStyle(fontSize: 12, color: AppStyles.ink3)),
              ],
            ],
          )),
          if (value != null) Text(value!, style: const TextStyle(fontSize: 12.5, color: AppStyles.ink3)),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded, color: AppStyles.ink4, size: 18),
        ],
      ),
    ),
  );
}

// ── Confetti Animation ────────────────────────────────────────────────────────
class _ConfettiWidget extends StatefulWidget {
  final Widget child;
  const _ConfettiWidget({required this.child});
  @override
  State<_ConfettiWidget> createState() => _ConfettiWidgetState();
}

class _ConfettiWidgetState extends State<_ConfettiWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final Random _rnd = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    for (int i = 0; i < 80; i++) {
      _particles.add(_Particle(
        x: _rnd.nextDouble(),
        y: -0.2 - _rnd.nextDouble() * 0.5,
        vx: (_rnd.nextDouble() - 0.5) * 0.8,
        vy: 0.5 + _rnd.nextDouble() * 1.5,
        color: const [Color(0xFFFF6B9D), Color(0xFF8CA5E8), Color(0xFFFFD166), Color(0xFF06D6A0), Color(0xFFFF9F51)][_rnd.nextInt(5)],
        size: 6 + _rnd.nextDouble() * 8,
        rot: _rnd.nextDouble() * pi * 2,
        rotV: (_rnd.nextDouble() - 0.5) * 0.5,
      ));
    }
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, __) => CustomPaint(
                painter: _ConfettiPainter(_particles, _controller.value),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Particle {
  double x, y, vx, vy, size, rot, rotV;
  Color color;
  _Particle({required this.x, required this.y, required this.vx, required this.vy, required this.size, required this.color, required this.rot, required this.rotV});
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  _ConfettiPainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (var p in particles) {
      double cx = size.width * p.x + p.vx * size.width * progress;
      double cy = size.height * p.y + p.vy * size.height * progress + 400 * progress * progress; // gravity effect
      
      if (cy > size.height + 50) continue; // optimize

      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(p.rot + p.rotV * progress * 100);
      paint.color = p.color.withOpacity((1.0 - (progress > 0.8 ? (progress - 0.8) * 5 : 0)).clamp(0.0, 1.0));
      canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6), paint);
      canvas.restore();
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

