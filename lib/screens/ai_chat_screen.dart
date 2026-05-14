import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../utils/styles.dart';
import '../utils/formatters.dart';
import '../widgets/shared.dart';

class AiChatScreen extends StatefulWidget {
  final VoidCallback onClose;
  const AiChatScreen({super.key, required this.onClose});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _ctrl = TextEditingController();
  final List<Map<String, String>> _msgs = [];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _send(String text) {
    final txt = text.trim();
    if (txt.isEmpty) return;
    setState(() {
      _msgs.add({'role': 'user', 'text': txt});
      _msgs.add({'role': 'ai', 'text': '这个问题问得好！不过我还在学习中，稍后我会连接大模型为你提供最专业的育儿建议。'});
    });
    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (_, state, __) {
      final baby = state.baby;
      final age = ageLabel(baby.birthday);
      
      final todayRecs = state.todayRecords;
      final milkCount = todayRecs.where((r) => r.type == 'breast' || r.type == 'bottle').length;
      final sleepSec = todayRecs.where((r) => r.type == 'sleep').fold(0, (s, r) => s + (r.value ?? 0));
      final sleepH = sleepSec ~/ 3600;
      final sleepM = (sleepSec % 3600) ~/ 60;
      final diaperCount = todayRecs.where((r) => r.type == 'diaper').length;

      final sleepStr = sleepH > 0 ? '${sleepH}h ${sleepM}m' : '${sleepM}m';
      final sleepTxt = sleepH > 0 ? '$sleepH 小时 $sleepM 分' : '$sleepM 分';

      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFCF5F5), // Light warm background
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Minimal header for closing
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TapBounce(
                      onTap: widget.onClose,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.6), shape: BoxShape.circle),
                        child: const Icon(Icons.keyboard_arrow_down_rounded, color: AppStyles.ink2),
                      ),
                    ),
                  ),
                ),
                
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      // Hero Header
                      Center(
                        child: Container(
                          width: 72, height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE89668), Color(0xFFE07A5F)],
                              begin: Alignment.topLeft, end: Alignment.bottomRight,
                            ),
                            boxShadow: [BoxShadow(color: const Color(0xFFE07A5F).withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))],
                          ),
                          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 32),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Center(
                        child: Text('贝贝问问', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: AppStyles.ink, letterSpacing: 0.5)),
                      ),
                      const SizedBox(height: 6),
                      Center(
                        child: Text('结合${baby.name}的日常数据 · 为你解答', style: const TextStyle(fontSize: 13, color: AppStyles.ink3)),
                      ),
                      const SizedBox(height: 32),

                      // Initial AI Summary Bubble
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [BoxShadow(color: const Color(0x1A000000), blurRadius: 20, offset: const Offset(0, 8))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '你好呀～我是贝贝。今天${baby.name} $age大了，喂奶 $milkCount 次，睡了 $sleepTxt。有什么我能帮你的吗？',
                              style: const TextStyle(fontSize: 15, height: 1.6, color: AppStyles.ink),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF0F3),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _StatCol('母乳', '$milkCount 次'),
                                  _StatCol('睡眠', sleepStr),
                                  _StatCol('尿布', '$diaperCount 次'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Quick Action Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            _QuickChip('今天数据正常吗?', () => _send('今天数据正常吗?')),
                            const SizedBox(width: 12),
                            _QuickChip('辅食应该怎么加?', () => _send('辅食应该怎么加?')),
                            const SizedBox(width: 12),
                            _QuickChip('睡眠时间够吗?', () => _send('睡眠时间够吗?')),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Chat messages
                      ..._msgs.map((m) {
                        final isAi = m['role'] == 'ai';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Row(
                            mainAxisAlignment: isAi ? MainAxisAlignment.start : MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (isAi)
                                Container(
                                  width: 36, height: 36, margin: const EdgeInsets.only(right: 12),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(colors: [Color(0xFFE89668), Color(0xFFE07A5F)]),
                                  ),
                                  child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                                ),
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: isAi ? Colors.white.withOpacity(0.9) : AppStyles.brand,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(20),
                                      topRight: const Radius.circular(20),
                                      bottomLeft: Radius.circular(isAi ? 4 : 20),
                                      bottomRight: Radius.circular(isAi ? 20 : 4),
                                    ),
                                    boxShadow: isAi ? AppStyles.shadowCard : AppStyles.shadowPop,
                                  ),
                                  child: Text(m['text']!, style: TextStyle(
                                    fontSize: 15, height: 1.5,
                                    color: isAi ? AppStyles.ink : Colors.white,
                                  )),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
                
                // Input
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    border: Border(top: BorderSide(color: AppStyles.line.withOpacity(0.5))),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                          ),
                          child: TextField(
                            controller: _ctrl,
                            style: const TextStyle(fontSize: 15, color: AppStyles.ink),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '问问关于${baby.name}的任何事...',
                              hintStyle: const TextStyle(color: AppStyles.ink3, fontSize: 14),
                              icon: const Icon(Icons.mic_none_rounded, color: AppStyles.ink3, size: 20),
                            ),
                            onSubmitted: (_) => _send(_ctrl.text),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      TapBounce(
                        onTap: () => _send(_ctrl.text),
                        child: Container(
                          width: 44, height: 44,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: AppStyles.brand),
                          child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _StatCol extends StatelessWidget {
  final String label, val;
  const _StatCol(this.label, this.val);
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(label, style: const TextStyle(fontSize: 11, color: AppStyles.ink3, fontWeight: FontWeight.w500)),
      const SizedBox(height: 4),
      Text(val, style: const TextStyle(fontSize: 15, color: AppStyles.cMilk, fontWeight: FontWeight.w600)),
    ],
  );
}

class _QuickChip extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _QuickChip(this.text, this.onTap);
  @override
  Widget build(BuildContext context) => TapBounce(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Text(text, style: const TextStyle(fontSize: 13.5, color: AppStyles.ink2, fontWeight: FontWeight.w500)),
    ),
  );
}
