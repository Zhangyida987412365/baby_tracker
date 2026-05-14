import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../utils/styles.dart';
import '../widgets/shared.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onClose;
  const OnboardingScreen({super.key, required this.onClose});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  String _gender = 'girl';
  DateTime _birthday = DateTime.now();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_nameCtrl.text.isEmpty || _weightCtrl.text.isEmpty || _heightCtrl.text.isEmpty) return;
    final w = double.tryParse(_weightCtrl.text);
    final h = double.tryParse(_heightCtrl.text);
    if (w == null || h == null) return;

    final b = Baby(
      name: _nameCtrl.text.trim(),
      gender: _gender,
      birthday: _birthday,
      weightKg: w,
      heightCm: h,
      headCm: 40.0,
    );

    Provider.of<AppState>(context, listen: false).addBaby(b);
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppStyles.bgApp,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Row(
                children: [
                  TapBounce(
                    onTap: widget.onClose,
                    child: const Icon(Icons.close_rounded, color: AppStyles.ink2, size: 28),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text('添加宝宝', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600, color: AppStyles.ink)),
            ),
            const SizedBox(height: 36),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildInput('宝宝小名', '例如：小米团', _nameCtrl, TextInputType.text),
                    const SizedBox(height: 24),
                    _buildGenderPicker(),
                    const SizedBox(height: 24),
                    _buildDatePicker(context),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(child: _buildInput('体重 (kg)', '例如：7.2', _weightCtrl, const TextInputType.numberWithOptions(decimal: true))),
                        const SizedBox(width: 16),
                        Expanded(child: _buildInput('身高 (cm)', '例如：65.0', _heightCtrl, const TextInputType.numberWithOptions(decimal: true))),
                      ],
                    ),
                    const SizedBox(height: 60),
                    TapBounce(
                      onTap: _save,
                      child: Container(
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppStyles.brand,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: AppStyles.shadowPop,
                        ),
                        child: const Center(child: Text('保存', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600))),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String label, String hint, TextEditingController ctrl, TextInputType type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: AppStyles.ink2, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: TextField(
            controller: ctrl, keyboardType: type,
            style: const TextStyle(fontSize: 16, color: AppStyles.ink, fontWeight: FontWeight.w500),
            decoration: InputDecoration(border: InputBorder.none, hintText: hint, hintStyle: const TextStyle(color: AppStyles.ink3)),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('性别', style: TextStyle(fontSize: 14, color: AppStyles.ink2, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _genderBtn('girl', '女宝宝', AppStyles.brand)),
            const SizedBox(width: 16),
            Expanded(child: _genderBtn('boy', '男宝宝', AppStyles.cSleep)),
          ],
        ),
      ],
    );
  }

  Widget _genderBtn(String g, String label, Color c) {
    final isActive = _gender == g;
    return TapBounce(
      onTap: () => setState(() => _gender = g),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isActive ? c : Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isActive ? c : Colors.white),
          boxShadow: isActive ? [BoxShadow(color: c.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))] : [],
        ),
        child: Center(child: Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isActive ? Colors.white : AppStyles.ink2))),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('出生日期', style: TextStyle(fontSize: 14, color: AppStyles.ink2, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TapBounce(
          onTap: () async {
            final d = await showDatePicker(
              context: context,
              initialDate: _birthday, firstDate: DateTime(2020), lastDate: DateTime.now(),
              builder: (ctx, child) => Theme(
                data: ThemeData.light().copyWith(colorScheme: const ColorScheme.light(primary: AppStyles.brand)),
                child: child!,
              ),
            );
            if (d != null) setState(() => _birthday = d);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${_birthday.year} 年 ${_birthday.month} 月 ${_birthday.day} 日',
                  style: const TextStyle(fontSize: 16, color: AppStyles.ink, fontWeight: FontWeight.w500)),
                const Icon(Icons.calendar_today_rounded, color: AppStyles.ink3, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
