import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/styles.dart';
import 'shared.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onPlus;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Glass bar
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xD9FFFFFF), // 85% white for extreme clean Apple glass look
                  border: Border(top: BorderSide(color: Color(0x40FFFFFF), width: 0.5)),
                ),
                padding: EdgeInsets.fromLTRB(0, 10, 0, 28 + bottomPad),
                child: Row(
                  children: [
                    Expanded(child: _buildTab(0, '首页', Icons.home_outlined, Icons.home_rounded)),
                    Expanded(child: _buildTab(1, '记录', Icons.list_rounded, Icons.list_rounded)),
                    const SizedBox(width: 72),
                    Expanded(child: _buildTab(2, '统计', Icons.bar_chart_rounded, Icons.bar_chart_rounded)),
                    Expanded(child: _buildTab(3, '我的', Icons.person_outline_rounded, Icons.person_rounded)),
                  ],
                ),
              ),
            ),
          ),
          // FAB
          Positioned(
            top: -28,
            child: TapBounce(
              onTap: onPlus,
              child: Container(
                width: 68, height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF8BA3), Color(0xFFFF5A79)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: Colors.white, width: 4.5),
                  boxShadow: [
                    BoxShadow(color: const Color(0x66FF5A79), blurRadius: 24, spreadRadius: 2, offset: const Offset(0, 8)),
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String label, IconData icon, IconData activeIcon) {
    final isActive = currentIndex == index;
    return TapBounce(
      onTap: () => onTap(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isActive ? activeIcon : icon,
                key: ValueKey(isActive),
                size: 24,
                color: isActive ? AppStyles.ink : AppStyles.ink3,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? AppStyles.ink : AppStyles.ink3,
                letterSpacing: 0.2,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
