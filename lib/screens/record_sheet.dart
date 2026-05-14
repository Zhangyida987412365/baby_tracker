import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/styles.dart';
import '../widgets/shared.dart';
import '../widgets/illustrations.dart';

class RecordSheet extends StatefulWidget {
  final bool open;
  final VoidCallback onClose;
  final String? initialType;
  final VoidCallback onOpenTimer;
  final Function(Map<String, dynamic>) onSave;

  const RecordSheet({
    super.key,
    required this.open,
    required this.onClose,
    this.initialType,
    required this.onOpenTimer,
    required this.onSave,
  });

  @override
  State<RecordSheet> createState() => _RecordSheetState();
}

class _RecordSheetState extends State<RecordSheet> {
  String? _active;
  late PageController _pageController;
  int _selectedIndex = 0;

  static const _quickItems = [
    {'key': 'breast',  'label': '母乳',    'icon': Icons.water_drop_outlined,  'color': AppStyles.cMilk,   'bg': AppStyles.cMilk2},
    {'key': 'bottle',  'label': '瓶喂',    'icon': Icons.local_drink_outlined,  'color': AppStyles.cMilk,   'bg': AppStyles.cMilk2},
    {'key': 'sleep',   'label': '睡眠',    'icon': Icons.bedtime_outlined,      'color': AppStyles.cSleep,  'bg': AppStyles.cSleep2},
    {'key': 'diaper',  'label': '尿布',    'icon': Icons.child_care_outlined,   'color': AppStyles.cDiaper, 'bg': AppStyles.cDiaper2},
    {'key': 'food',    'label': '辅食',    'icon': Icons.restaurant_outlined,   'color': AppStyles.cFood,   'bg': AppStyles.cMilk2},
    {'key': 'growth',  'label': '身高体重', 'icon': Icons.straighten_outlined,  'color': AppStyles.cGrowth, 'bg': AppStyles.cGrowth2},
    {'key': 'bath',    'label': '洗澡',    'icon': Icons.bathtub_outlined,      'color': AppStyles.cWater,  'bg': AppStyles.cSleep2},
    {'key': 'temp',    'label': '体温',    'icon': Icons.thermostat_outlined,   'color': AppStyles.cCare,   'bg': AppStyles.cCare2},
    {'key': 'med',     'label': '吃药',    'icon': Icons.medication_outlined,   'color': AppStyles.cCare,   'bg': AppStyles.cCare2},
    {'key': 'water',   'label': '喝水',    'icon': Icons.water_drop,            'color': AppStyles.cWater,  'bg': AppStyles.cSleep2},
  ];

  @override
  void initState() {
    super.initState();
    _active = widget.initialType;
    _pageController = PageController(viewportFraction: 0.35, initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(RecordSheet old) {
    super.didUpdateWidget(old);
    if (widget.open && !old.open) {
      setState(() {
        _active = widget.initialType;
        if (_active == null) {
          _selectedIndex = 0;
          if (_pageController.hasClients) {
            _pageController.jumpToPage(0);
          }
        }
      });
    }
  }

  void _handleSave(Map<String, dynamic> rec) {
    widget.onSave(rec);
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    return AppSheet(
      open: widget.open,
      onClose: widget.onClose,
      child: _active == null ? _buildGrid() : _buildForm(),
    );
  }

  Widget _buildGrid() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 24),
            child: Text('选择记录类型', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppStyles.ink2, letterSpacing: 1.2)),
          ),
          SizedBox(
            height: 100,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (idx) {
                HapticFeedback.selectionClick();
                setState(() => _selectedIndex = idx);
              },
              itemCount: _quickItems.length,
              itemBuilder: (context, index) {
                final it = _quickItems[index];
                final isSelected = index == _selectedIndex;
                
                return TapBounce(
                  onTap: () {
                    if (isSelected) {
                      _selectItem(it['key'] as String);
                    } else {
                      _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                    }
                  },
                  child: Center(
                    child: AnimatedScale(
                      scale: isSelected ? 1.05 : 0.7,
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutBack,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.white.withOpacity(0.35),
                          shape: BoxShape.circle,
                          boxShadow: isSelected 
                              ? [BoxShadow(color: (it['color'] as Color).withOpacity(0.4), blurRadius: 24, offset: const Offset(0, 10))] 
                              : [BoxShadow(color: Colors.transparent, blurRadius: 24, offset: const Offset(0, 10))],
                        ),
                        child: Icon(
                          it['icon'] as IconData, 
                          color: isSelected ? (it['color'] as Color) : AppStyles.ink2.withOpacity(0.8), 
                          size: 38
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(animation),
                child: child,
              ),
            ),
            child: Text(
              _quickItems[_selectedIndex]['label'] as String,
              key: ValueKey(_selectedIndex),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppStyles.ink),
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: TapBounce(
              onTap: () => _selectItem(_quickItems[_selectedIndex]['key'] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 56,
                decoration: BoxDecoration(
                  color: _quickItems[_selectedIndex]['color'] as Color,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [BoxShadow(color: (_quickItems[_selectedIndex]['color'] as Color).withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 8))],
                ),
                child: const Center(
                  child: Text('进入记录', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: 1.0)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectItem(String key) {
    if (key == 'breast') {
      widget.onClose();
      Future.delayed(const Duration(milliseconds: 200), widget.onOpenTimer);
    } else {
      setState(() => _active = key);
    }
  }

  Widget _buildForm() {
    final item = _quickItems.firstWhere((it) => it['key'] == _active);
    Widget form;
    switch (_active) {
      case 'bottle': form = _BottleForm(onSave: _handleSave); break;
      case 'diaper': form = _DiaperForm(onSave: _handleSave); break;
      case 'sleep':  form = _SleepForm(onSave: _handleSave); break;
      case 'food':   form = _FoodForm(onSave: _handleSave); break;
      case 'growth': form = _GrowthForm(onSave: _handleSave); break;
      case 'bath':   form = _BathForm(onSave: _handleSave); break;
      case 'temp':   form = _TempForm(onSave: _handleSave); break;
      case 'med':    form = _MedForm(onSave: _handleSave); break;
      case 'water':  form = _WaterForm(onSave: _handleSave); break;
      default:       form = _BottleForm(onSave: _handleSave);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // back header
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 8),
          child: Row(
            children: [
              TapBounce(
                onTap: () => setState(() => _active = null),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [Icon(Icons.chevron_left_rounded, size: 20, color: AppStyles.ink2)],
                ),
              ),
              Expanded(
                child: Text(item['label'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppStyles.ink)),
              ),
              const SizedBox(width: 24),
            ],
          ),
        ),
        form,
      ],
    );
  }
}

// ─── Shared form widgets ────────────────────────────────────────────────────
class _PrimaryButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _PrimaryButton({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
    child: TapBounce(
      onTap: onTap,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 24, offset: const Offset(0, 8))],
        ),
        child: Center(child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600))),
      ),
    ),
  );
}

class _FormCard extends StatelessWidget {
  final Widget child;
  const _FormCard({required this.child});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 22),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.65),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: Colors.white.withOpacity(0.8)),
      boxShadow: AppStyles.shadowCard,
    ),
    child: child,
  );
}

class _IllustrationBox extends StatelessWidget {
  final Widget child;
  const _IllustrationBox({required this.child});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(22, 4, 22, 12),
    height: 160,
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.4),
      borderRadius: BorderRadius.circular(22),
    ),
    child: child,
  );
}

class _AmountChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;
  const _AmountChip({required this.label, required this.isActive, required this.activeColor, required this.onTap});

  @override
  Widget build(BuildContext context) => TapBounce(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
      decoration: BoxDecoration(
        color: isActive ? activeColor : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isActive ? activeColor : AppStyles.line),
      ),
      child: Text(label, textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
          color: isActive ? Colors.white : AppStyles.ink2)),
    ),
  );
}

// ─── Bottle form ─────────────────────────────────────────────────────────────
class _BottleForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  const _BottleForm({required this.onSave});
  @override State<_BottleForm> createState() => _BottleFormState();
}
class _BottleFormState extends State<_BottleForm> {
  int _ml = 120;
  final _presets = [60, 90, 120, 150, 180, 210];

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 36),
    child: Column(
      children: [
        // Bottle illustration
        _IllustrationBox(child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: _ml / 240),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          builder: (_, v, __) => BottleIllustration(ml: (v * 240).round()),
        )),
        _FormCard(child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic,
            children: [
              Text('$_ml', style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w500, color: AppStyles.ink, height: 1, fontFamily: 'Quicksand')),
              const SizedBox(width: 6),
              const Text('ml', style: TextStyle(fontSize: 17, color: AppStyles.ink3)),
            ]),
          const SizedBox(height: 14),
          GridView.count(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8,
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), childAspectRatio: 2.4,
            children: _presets.map((p) => _AmountChip(
              label: '$p ml', isActive: _ml == p, activeColor: AppStyles.cMilk,
              onTap: () => setState(() => _ml = p),
            )).toList()),
          const SizedBox(height: 10),
          const Text('上次 11:35 喂了 120 ml · 4 小时前', style: TextStyle(fontSize: 11.5, color: AppStyles.ink3), textAlign: TextAlign.center),
        ])),
        _PrimaryButton(label: '保存', color: AppStyles.cMilk,
          onTap: () => widget.onSave({'type': 'bottle', 'value': _ml, 'extra': {}})),
      ],
    ),
  );
}

// ─── Diaper form ─────────────────────────────────────────────────────────────
class _DiaperForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  const _DiaperForm({required this.onSave});
  @override State<_DiaperForm> createState() => _DiaperFormState();
}
class _DiaperFormState extends State<_DiaperForm> {
  String _status = 'pee';

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 36),
    child: Column(children: [
      _IllustrationBox(child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: DiaperIllustration(key: ValueKey(_status), status: _status),
      )),
      _FormCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('状态', style: TextStyle(fontSize: 13.5, color: AppStyles.ink2)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: AppStyles.bgPill, borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            {'k': 'pee', 'l': '小便'}, {'k': 'poo', 'l': '大便'}, {'k': 'mixed', 'l': '混合'},
          ].map((o) {
            final isActive = _status == o['k'];
            return Expanded(child: TapBounce(
              onTap: () => setState(() => _status = o['k']!),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isActive ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4)] : null,
                ),
                child: Text(o['l']!, textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive ? AppStyles.ink : AppStyles.ink2)),
              ),
            ));
          }).toList()),
        ),
        const SizedBox(height: 10),
        const Text('今日已记录 3 次 · 上次 15:40', style: TextStyle(fontSize: 11.5, color: AppStyles.ink3), textAlign: TextAlign.center),
      ])),
      _PrimaryButton(label: '保存', color: AppStyles.cDiaper,
        onTap: () => widget.onSave({'type': 'diaper', 'value': null, 'extra': {'status': _status}})),
    ]),
  );
}

// ─── Sleep form ───────────────────────────────────────────────────────────────
class _SleepForm extends StatelessWidget {
  final Function(Map<String, dynamic>) onSave;
  const _SleepForm({required this.onSave});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 36),
    child: Column(children: [
      const _IllustrationBox(child: SleepIllustration()),
      _FormCard(child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('开始', style: TextStyle(fontSize: 14, color: AppStyles.ink2)),
          const Text('现在', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ]),
        const Divider(height: 20, color: AppStyles.line),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('结束', style: TextStyle(fontSize: 14, color: AppStyles.ink2)),
          Text('等待醒来 · 点保存后启动', style: TextStyle(fontSize: 14, color: AppStyles.cSleep, fontWeight: FontWeight.w500)),
        ]),
        const SizedBox(height: 10),
        const Text('今日已小睡 2h 50m · 推荐 13–15 小时/日', style: TextStyle(fontSize: 11.5, color: AppStyles.ink3), textAlign: TextAlign.center),
      ])),
      _PrimaryButton(label: '标记入睡', color: AppStyles.cSleep,
        onTap: () => onSave({'type': 'sleep', 'value': 0, 'extra': {'start': DateTime.now().toIso8601String()}})),
    ]),
  );
}

// ─── Food form ────────────────────────────────────────────────────────────────
class _FoodForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  const _FoodForm({required this.onSave});
  @override State<_FoodForm> createState() => _FoodFormState();
}
class _FoodFormState extends State<_FoodForm> {
  String _food = '米糊';
  String _amount = '30g';
  final _foods = ['米糊', '香蕉', '苹果泥', '南瓜泥', '蛋黄', '胡萝卜'];
  final _amounts = ['10g', '30g', '50g', '80g'];

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 36),
    child: Column(children: [
      _IllustrationBox(child: FoodIllustration(food: _food, amount: _amount)),
      _FormCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('食物', style: TextStyle(fontSize: 13.5, color: AppStyles.ink2)),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: _foods.map((f) => _AmountChip(
          label: f, isActive: _food == f, activeColor: AppStyles.cFood,
          onTap: () => setState(() => _food = f),
        )).toList()),
        const SizedBox(height: 16),
        const Text('分量', style: TextStyle(fontSize: 13.5, color: AppStyles.ink2)),
        const SizedBox(height: 10),
        Row(children: _amounts.map((a) => Expanded(child: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _AmountChip(label: a, isActive: _amount == a, activeColor: AppStyles.cFood,
            onTap: () => setState(() => _amount = a)),
        ))).toList()),
      ])),
      _PrimaryButton(label: '保存', color: AppStyles.cFood,
        onTap: () => widget.onSave({'type': 'food', 'value': null, 'extra': {'food': _food, 'amount': _amount}})),
    ]),
  );
}

// ─── Bath form ────────────────────────────────────────────────────────────────
class _BathForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  const _BathForm({required this.onSave});
  @override State<_BathForm> createState() => _BathFormState();
}
class _BathFormState extends State<_BathForm> {
  List<String> _acts = ['bath'];
  final _opts = [{'k': 'bath', 'l': '洗澡'}, {'k': 'touch', 'l': '抚触'}, {'k': 'hair', 'l': '洗头'}];

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 36),
    child: Column(children: [
      _IllustrationBox(child: BathIllustration(activities: _acts)),
      _FormCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('项目（可多选）', style: TextStyle(fontSize: 13.5, color: AppStyles.ink2)),
        const SizedBox(height: 10),
        Wrap(spacing: 8, children: _opts.map((o) => _AmountChip(
          label: o['l']!, isActive: _acts.contains(o['k']), activeColor: AppStyles.cWater,
          onTap: () => setState(() => _acts.contains(o['k']) ? _acts.remove(o['k']) : _acts.add(o['k']!)),
        )).toList()),
        const SizedBox(height: 10),
        const Text('水温建议 38–40°C · 时长 ≤ 10 分钟', style: TextStyle(fontSize: 11.5, color: AppStyles.ink3), textAlign: TextAlign.center),
      ])),
      _PrimaryButton(label: '保存', color: AppStyles.cWater,
        onTap: () => widget.onSave({'type': 'bath', 'value': null, 'extra': {'activities': _acts}})),
    ]),
  );
}

// ─── Temp form ────────────────────────────────────────────────────────────────
class _TempForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  const _TempForm({required this.onSave});
  @override State<_TempForm> createState() => _TempFormState();
}
class _TempFormState extends State<_TempForm> {
  double _temp = 36.8;
  final _presets = [36.5, 36.8, 37.2, 37.5, 38.0, 38.5];

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 36),
    child: Column(children: [
      _IllustrationBox(child: TempIllustration(temp: _temp)),
      _FormCard(child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic,
          children: [
            Text(_temp.toStringAsFixed(1), style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w500, color: AppStyles.ink, height: 1, fontFamily: 'Quicksand')),
            const SizedBox(width: 6),
            const Text('℃', style: TextStyle(fontSize: 17, color: AppStyles.ink3)),
          ]),
        const SizedBox(height: 14),
        GridView.count(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8,
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), childAspectRatio: 2.4,
          children: _presets.map((p) => _AmountChip(
            label: p.toStringAsFixed(1), isActive: _temp == p, activeColor: AppStyles.cCare,
            onTap: () => setState(() => _temp = p),
          )).toList()),
        const SizedBox(height: 10),
        Text(_temp >= 37.5 ? '⚠ 已超过正常范围，注意观察' : '正常范围 36.0–37.3 ℃',
          style: TextStyle(fontSize: 11.5, color: _temp >= 37.5 ? Colors.red : AppStyles.ink3), textAlign: TextAlign.center),
      ])),
      _PrimaryButton(label: '保存', color: AppStyles.cCare,
        onTap: () => widget.onSave({'type': 'temp', 'value': null, 'extra': {'temp': _temp}})),
    ]),
  );
}

// ─── Med form ─────────────────────────────────────────────────────────────────
class _MedForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  const _MedForm({required this.onSave});
  @override State<_MedForm> createState() => _MedFormState();
}
class _MedFormState extends State<_MedForm> {
  String _name = '维生素 D';
  final _meds = ['维生素 D', '益生菌', '退烧药', '止咳水', '钙剂', '抗生素'];

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 36),
    child: Column(children: [
      _IllustrationBox(child: MedIllustration(name: _name)),
      _FormCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('药物', style: TextStyle(fontSize: 13.5, color: AppStyles.ink2)),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: _meds.map((m) => _AmountChip(
          label: m, isActive: _name == m, activeColor: AppStyles.cCare,
          onTap: () => setState(() => _name = m),
        )).toList()),
        const SizedBox(height: 10),
        const Text('下次提醒：明天 9:00', style: TextStyle(fontSize: 11.5, color: AppStyles.ink3), textAlign: TextAlign.center),
      ])),
      _PrimaryButton(label: '保存', color: AppStyles.cCare,
        onTap: () => widget.onSave({'type': 'med', 'value': null, 'extra': {'name': _name}})),
    ]),
  );
}

// ─── Water form ───────────────────────────────────────────────────────────────
class _WaterForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  const _WaterForm({required this.onSave});
  @override State<_WaterForm> createState() => _WaterFormState();
}
class _WaterFormState extends State<_WaterForm> {
  int _ml = 30;
  final _presets = [15, 30, 50, 80, 120, 180];

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 36),
    child: Column(children: [
      _IllustrationBox(child: WaterIllustration(ml: _ml)),
      _FormCard(child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic,
          children: [
            Text('$_ml', style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w500, color: AppStyles.ink, height: 1, fontFamily: 'Quicksand')),
            const SizedBox(width: 6),
            const Text('ml', style: TextStyle(fontSize: 17, color: AppStyles.ink3)),
          ]),
        const SizedBox(height: 14),
        GridView.count(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8,
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), childAspectRatio: 2.4,
          children: _presets.map((p) => _AmountChip(
            label: '$p ml', isActive: _ml == p, activeColor: AppStyles.cWater,
            onTap: () => setState(() => _ml = p),
          )).toList()),
        const SizedBox(height: 10),
        const Text('今日已喝 0 ml · 6 月后可适量饮水', style: TextStyle(fontSize: 11.5, color: AppStyles.ink3), textAlign: TextAlign.center),
      ])),
      _PrimaryButton(label: '保存', color: AppStyles.cWater,
        onTap: () => widget.onSave({'type': 'water', 'value': _ml, 'extra': {}})),
    ]),
  );
}

// ─── Growth form ──────────────────────────────────────────────────────────────
class _GrowthForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  const _GrowthForm({required this.onSave});
  @override State<_GrowthForm> createState() => _GrowthFormState();
}
class _GrowthFormState extends State<_GrowthForm> {
  double _weight = 7.2;
  double _height = 65.1;
  double _head = 41.8;
  final _wPresets = [6.0, 6.5, 7.0, 7.2, 7.5, 8.0];
  final _hPresets = [60.0, 62.0, 65.0, 67.0, 70.0, 72.0];

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 36),
    child: Column(children: [
      _IllustrationBox(child: GrowthIllustration(height: _height, weight: _weight)),
      _FormCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('体重 (kg)', style: TextStyle(fontSize: 13.5, color: AppStyles.ink2)),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: _wPresets.map((w) => _AmountChip(
          label: w.toStringAsFixed(1), isActive: _weight == w, activeColor: AppStyles.cGrowth,
          onTap: () => setState(() => _weight = w),
        )).toList()),
        const SizedBox(height: 16),
        const Text('身高 (cm)', style: TextStyle(fontSize: 13.5, color: AppStyles.ink2)),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: _hPresets.map((h) => _AmountChip(
          label: h.toStringAsFixed(1), isActive: _height == h, activeColor: AppStyles.cGrowth,
          onTap: () => setState(() => _height = h),
        )).toList()),
      ])),
      _PrimaryButton(label: '保存', color: AppStyles.cGrowth,
        onTap: () => widget.onSave({'type': 'growth', 'value': null, 'extra': {'weight': _weight, 'height': _height, 'head': _head}})),
    ]),
  );
}
