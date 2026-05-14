import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'models/app_state.dart';
import 'utils/styles.dart';
import 'widgets/bottom_nav.dart';
import 'screens/home_screen.dart';
import 'screens/history_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/mine_screen.dart';
import 'screens/breast_timer_screen.dart';
import 'screens/record_sheet.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/ai_chat_screen.dart';
import 'screens/sleep_timer_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const BabyTrackerApp(),
    ),
  );
}

class BabyTrackerApp extends StatelessWidget {
  const BabyTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '宝宝记',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Quicksand',
        colorScheme: ColorScheme.fromSeed(seedColor: AppStyles.brand),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with TickerProviderStateMixin {
  int _tabIndex = 0;
  bool _showSheet = false;
  bool _showTimer = false;
  bool _showSleepTimer = false;
  bool _showOnboarding = false;
  bool _showAi = false;
  String _historyFilter = 'all';

  String? _sheetInitialType;

  // Animated page switching
  late AnimationController _pageCtrl;
  late Animation<double> _pageFade;

  @override
  void initState() {
    super.initState();
    _pageCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 280));
    _pageFade = CurvedAnimation(parent: _pageCtrl, curve: Curves.easeOut);
    _pageCtrl.value = 1.0;
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _switchTab(int i) {
    if (i == _tabIndex) return;
    _pageCtrl.forward(from: 0);
    setState(() => _tabIndex = i);
  }

  void _addRecord(Map<String, dynamic> rec) {
    final state = Provider.of<AppState>(context, listen: false);
    state.addRecord(Record(
      babyId: state.baby.dbId ?? 1,
      time: DateTime.now(),
      type: rec['type'],
      value: rec['value'] is int ? rec['value'] : (rec['value'] is double ? (rec['value'] as double).round() : null),
      extra: Map<String, dynamic>.from(rec['extra'] ?? {}),
    ));

    if (rec['type'] == 'growth') {
      final extra = rec['extra'] as Map<String, dynamic>? ?? {};
      final w = extra['weight'] as double?;
      final h = extra['height'] as double?;
      final head = extra['head'] as double?;
      if (w != null && h != null) {
        final b = state.baby;
        state.updateBaby(Baby(
          dbId: b.dbId, name: b.name, gender: b.gender, birthday: b.birthday,
          weightKg: w, heightCm: h, headCm: head ?? b.headCm,
        ));
      }
    }
  }

  Widget _buildCurrentPage() {
    switch (_tabIndex) {
      case 0: return HomeScreen(
        onOpenTimer: () => setState(() => _showTimer = true),
        onOpenSleepTimer: () => setState(() => _showSleepTimer = true),
        onOpenSheet: (type) => setState(() {
          _sheetInitialType = type;
          _showSheet = true;
        }),
        onOpenAI: () => setState(() => _showAi = true),
        onGoTo: (key) {
          if (key.startsWith('history:')) {
            setState(() {
              _historyFilter = key.split(':')[1];
            });
            _switchTab(1);
          } else {
            const map = {'home': 0, 'history': 1, 'stats': 2, 'mine': 3};
            if (map.containsKey(key)) {
              if (key == 'history') setState(() => _historyFilter = 'all');
              _switchTab(map[key]!);
            }
          }
        },
      );
      case 1: return HistoryScreen(initialFilter: _historyFilter);
      case 2: return const StatsScreen();
      case 3: return MineScreen(onOpenOnboarding: () => setState(() => _showOnboarding = true));
      default: return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.bgApp,
      body: Stack(
        children: [
          // ── Aurora background ───────────────────────────────────────────────
          Positioned.fill(
            child: CustomPaint(painter: _AuroraPainter()),
          ),

          // ── Main page ────────────────────────────────────────────────────────
          Positioned.fill(
            child: FadeTransition(
              opacity: _pageFade,
              child: _buildCurrentPage(),
            ),
          ),

          // ── Bottom nav ───────────────────────────────────────────────────────
          if (!_showTimer && !_showSleepTimer)
            BottomNavBar(
              currentIndex: _tabIndex,
              onTap: _switchTab,
              onPlus: () => setState(() => _showSheet = true),
            ),

          // ── Record sheet overlay ─────────────────────────────────────────────
          if (_showSheet)
            Positioned.fill(
              child: RecordSheet(
                open: _showSheet,
                initialType: _sheetInitialType,
                onClose: () => setState(() { _showSheet = false; _sheetInitialType = null; }),
                onOpenTimer: () => setState(() {
                  _showSheet = false;
                  _showTimer = true;
                }),
                onSave: (rec) {
                  _addRecord(rec);
                  setState(() => _showSheet = false);
                },
              ),
            ),

          // ── Breast timer overlay ─────────────────────────────────────────────
          if (_showTimer)
            Positioned.fill(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOut,
                builder: (_, v, c) => Opacity(opacity: v, child: c),
                child: BreastTimerScreen(
                  onClose: () => setState(() => _showTimer = false),
                ),
              ),
            ),

          // ── Sleep timer overlay ──────────────────────────────────────────────
          if (_showSleepTimer)
            Positioned.fill(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOut,
                builder: (_, v, c) => Opacity(opacity: v, child: c),
                child: SleepTimerScreen(
                  onClose: () => setState(() => _showSleepTimer = false),
                ),
              ),
            ),

          // ── Onboarding overlay ───────────────────────────────────────────────
          if (_showOnboarding)
            Positioned.fill(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOut,
                builder: (_, v, c) => Opacity(opacity: v, child: c),
                child: OnboardingScreen(
                  onClose: () => setState(() => _showOnboarding = false),
                ),
              ),
            ),

          // ── AI Chat overlay ───────────────────────────────────────────────
          if (_showAi)
            Positioned.fill(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 350),
                curve: Curves.fastOutSlowIn,
                builder: (_, v, c) => Transform.translate(
                  offset: Offset(0, (1 - v) * MediaQuery.of(context).size.height),
                  child: c,
                ),
                child: AiChatScreen(
                  onClose: () => setState(() => _showAi = false),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Aurora gradient background ────────────────────────────────────────────────
class _AuroraPainter extends CustomPainter {
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

    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = AppStyles.bgApp);
    radial(Offset(0, 0),                w * 0.9, const Color(0x99FFB4C8));
    radial(Offset(w, 0),                w * 0.9, const Color(0x99FFD2AA));
    radial(Offset(w, h),                w * 0.9, const Color(0x80DCB4FF));
    radial(Offset(0, h),                w * 0.9, const Color(0x99FFA0BE));
  }

  @override
  bool shouldRepaint(_AuroraPainter old) => false;
}
