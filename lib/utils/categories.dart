import 'package:flutter/material.dart';
import 'styles.dart';

enum RecordType { breast, bottle, sleep, diaper, food, growth, bath, temp, med, water, milestone }

class CategoryInfo {
  final String key;
  final String label;
  final Color color;
  final Color bg;
  final IconData icon;
  const CategoryInfo({
    required this.key,
    required this.label,
    required this.color,
    required this.bg,
    required this.icon,
  });
}

const categories = {
  'breast':  CategoryInfo(key:'breast',  label:'母乳',   color:AppStyles.cMilk,   bg:AppStyles.cMilk2,   icon:Icons.water_drop_outlined),
  'bottle':  CategoryInfo(key:'bottle',  label:'瓶喂',   color:AppStyles.cMilk,   bg:AppStyles.cMilk2,   icon:Icons.local_drink_outlined),
  'sleep':   CategoryInfo(key:'sleep',   label:'睡眠',   color:AppStyles.cSleep,  bg:AppStyles.cSleep2,  icon:Icons.bedtime_outlined),
  'diaper':  CategoryInfo(key:'diaper',  label:'尿布',   color:AppStyles.cDiaper, bg:AppStyles.cDiaper2, icon:Icons.child_care_outlined),
  'food':    CategoryInfo(key:'food',    label:'辅食',   color:AppStyles.cFood,   bg:AppStyles.cMilk2,   icon:Icons.restaurant_outlined),
  'growth':  CategoryInfo(key:'growth',  label:'身高体重', color:AppStyles.cGrowth, bg:AppStyles.cGrowth2, icon:Icons.straighten_outlined),
  'bath':    CategoryInfo(key:'bath',    label:'洗澡',   color:AppStyles.cWater,  bg:AppStyles.cSleep2,  icon:Icons.bathtub_outlined),
  'temp':    CategoryInfo(key:'temp',    label:'体温',   color:AppStyles.cCare,   bg:AppStyles.cCare2,   icon:Icons.thermostat_outlined),
  'med':     CategoryInfo(key:'med',     label:'吃药',   color:AppStyles.cCare,   bg:AppStyles.cCare2,   icon:Icons.medication_outlined),
  'water':   CategoryInfo(key:'water',   label:'喝水',   color:AppStyles.cWater,  bg:AppStyles.cSleep2,  icon:Icons.water_drop),
  'milestone':CategoryInfo(key:'milestone',label:'里程碑', color:Color(0xFFFF9F51), bg:Color(0xFFFFF0E0), icon:Icons.emoji_events_rounded),
};

String describeRecord(Map<String, dynamic> r) {
  final type = r['type'] as String;
  final extra = r['extra'] as Map<String, dynamic>? ?? {};
  switch (type) {
    case 'breast':
      final side = extra['side'] == 'left' ? '左侧' : extra['side'] == 'right' ? '右侧' : '双侧';
      final mins = ((r['value'] as int? ?? 0) / 60).round();
      return '$side · $mins 分钟';
    case 'bottle':
      return '配方奶 ${r['value']} ml';
    case 'sleep':
      final sec = r['value'] as int? ?? 0;
      final h = sec ~/ 3600;
      final m = (sec % 3600) ~/ 60;
      if (h > 0) return '睡了 $h 小时 $m 分';
      return '睡了 $m 分';
    case 'diaper':
      const s = {'pee': '小便', 'poo': '大便', 'mixed': '大便 + 小便'};
      return s[extra['status']] ?? '换尿布';
    case 'food':
      return '${extra['food']} · ${extra['amount']}';
    case 'bath':
      return '洗澡 + 抚触';
    case 'temp':
      return '${extra['temp']} ℃';
    case 'med':
      return extra['name'] ?? '吃药';
    case 'water':
      return '${r['value']} ml';
    case 'growth':
      return '${extra['weight'] ?? ''} kg · ${extra['height'] ?? ''} cm';
    case 'milestone':
      return '${extra['emoji'] ?? '🎉'} 解锁：${extra['title']}';
    default:
      return '';
  }
}
