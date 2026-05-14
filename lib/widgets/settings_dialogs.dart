import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../utils/styles.dart';
import 'shared.dart';

// 1. Reminders & Notifications
void showNotificationSettings(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const _NotificationSheet(),
  );
}

class _NotificationSheet extends StatefulWidget {
  const _NotificationSheet();
  @override
  State<_NotificationSheet> createState() => _NotificationSheetState();
}

class _NotificationSheetState extends State<_NotificationSheet> {

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
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
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: const Color(0xFFDDD8D0), borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 24),
          const Text('提醒与通知', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppStyles.ink)),
          const SizedBox(height: 24),
          _buildSwitch('喂奶提醒', '基于间隔时间预测下次喂奶', state.feedReminderEnabled, (v) => state.toggleFeedReminder(v)),
          const SizedBox(height: 16),
          _buildSwitch('换尿布提醒', '定时提醒更换，远离红屁屁', state.diaperReminderEnabled, (v) => state.toggleDiaperReminder(v)),
        ],
      ),
    );
  }

  Widget _buildSwitch(String title, String subtitle, bool val, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppStyles.ink)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: AppStyles.ink3)),
          ])),
          Switch(value: val, activeColor: AppStyles.brand, onChanged: onChanged),
        ],
      ),
    );
  }
}

// 2. Data Export
void showExportSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const _ExportSheet(),
  );
}

class _ExportSheet extends StatefulWidget {
  const _ExportSheet();
  @override
  State<_ExportSheet> createState() => _ExportSheetState();
}

class _ExportSheetState extends State<_ExportSheet> {
  bool _exporting = true;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _startExport();
  }

  void _startExport() async {
    for (int i = 0; i <= 100; i += 5) {
      await Future.delayed(const Duration(milliseconds: 60));
      if (mounted) setState(() => _progress = i / 100.0);
    }
    if (mounted) setState(() => _exporting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFCF5F5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 50),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(color: const Color(0xFFDDD8D0), borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 32),
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _exporting ? const Color(0xFF6E7DA0).withOpacity(0.1) : const Color(0xFF06D6A0).withOpacity(0.15),
            ),
            child: _exporting 
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 80, height: 80,
                      child: CircularProgressIndicator(value: _progress, color: const Color(0xFF6E7DA0), strokeWidth: 4),
                    ),
                    const Icon(Icons.cloud_download_rounded, color: Color(0xFF6E7DA0), size: 32),
                  ],
                )
              : const Icon(Icons.check_rounded, color: Color(0xFF06D6A0), size: 40),
          ),
          const SizedBox(height: 24),
          Text(_exporting ? '正在生成数据报表...' : '生成成功！', 
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppStyles.ink)),
          const SizedBox(height: 8),
          Text(_exporting ? '预计包含 ${Provider.of<AppState>(context, listen: false).records.length} 条成长记录' : '数据已打包为 CSV 格式',
            style: const TextStyle(fontSize: 14, color: AppStyles.ink3)),
          const SizedBox(height: 32),
          if (!_exporting)
            Row(
              children: [
                Expanded(child: _ExportBtn(icon: Icons.share_rounded, text: '分享文件', color: const Color(0xFF6E7DA0), onTap: () => Navigator.pop(context))),
                const SizedBox(width: 16),
                Expanded(child: _ExportBtn(icon: Icons.folder_rounded, text: '保存到本地', color: AppStyles.brand, onTap: () => Navigator.pop(context))),
              ],
            )
        ],
      ),
    );
  }
}

class _ExportBtn extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final VoidCallback onTap;
  const _ExportBtn({required this.icon, required this.text, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => TapBounce(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w600)),
        ],
      ),
    ),
  );
}

// 3. Cloud Sync
void showSyncDialog(BuildContext context) {
  showDialog(context: context, barrierDismissible: false, builder: (_) => const _SyncDialog());
}

class _SyncDialog extends StatefulWidget {
  const _SyncDialog();
  @override
  State<_SyncDialog> createState() => _SyncDialogState();
}

class _SyncDialogState extends State<_SyncDialog> {
  bool _done = false;
  
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _done = true);
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (mounted) Navigator.pop(context);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
              child: _done
                ? Container(
                    key: const ValueKey('done'),
                    width: 60, height: 60,
                    decoration: BoxDecoration(color: const Color(0xFF06D6A0).withOpacity(0.15), shape: BoxShape.circle),
                    child: const Icon(Icons.cloud_done_rounded, color: Color(0xFF06D6A0), size: 32),
                  )
                : Container(
                    key: const ValueKey('syncing'),
                    width: 60, height: 60,
                    decoration: BoxDecoration(color: const Color(0xFF8FA48E).withOpacity(0.15), shape: BoxShape.circle),
                    child: const Center(
                      child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Color(0xFF8FA48E), strokeWidth: 3)),
                    ),
                  ),
            ),
            const SizedBox(height: 20),
            Text(_done ? '同步成功' : '正在同步至云端...', 
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppStyles.ink)),
            const SizedBox(height: 6),
            Text(_done ? '所有设备数据已更新' : '请勿关闭应用或断开网络', 
              style: const TextStyle(fontSize: 13, color: AppStyles.ink3)),
          ],
        ),
      ),
    );
  }
}

// 4. About
void showCustomAboutDialog(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (ctx, _, __) => Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 40)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF8BA3), Color(0xFFFF5A79)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  boxShadow: [BoxShadow(color: const Color(0xFFFF5A79).withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 8))],
                ),
                child: const Icon(Icons.child_care_rounded, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 20),
              const Text('宝宝记', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppStyles.ink, letterSpacing: -0.5)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppStyles.brand.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: const Text('Version 1.0.0 Pro', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppStyles.brand)),
              ),
              const SizedBox(height: 24),
              const Text('由晋商行科技有限公司构建\n为您提供最专业的育儿记录体验',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppStyles.ink2, height: 1.6)),
              const SizedBox(height: 32),
              TapBounce(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(color: AppStyles.bgPill, borderRadius: BorderRadius.circular(16)),
                  child: const Center(child: Text('关闭', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppStyles.ink))),
                ),
              )
            ],
          ),
        ),
      ),
    ),
  );
}
