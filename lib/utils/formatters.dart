String pad2(int n) => n.toString().padLeft(2, '0');

String fmtTime(DateTime d) => '${pad2(d.hour)}:${pad2(d.minute)}';

String fmtDuration(int sec) {
  final h = sec ~/ 3600;
  final m = (sec % 3600) ~/ 60;
  final s = sec % 60;
  if (h > 0) return '$h:${pad2(m)}:${pad2(s)}';
  return '${pad2(m)}:${pad2(s)}';
}

String fmtMinutes(int sec) {
  final h = sec ~/ 3600;
  final m = ((sec % 3600) / 60).round();
  if (h > 0 && m > 0) return '$h 小时 $m 分';
  if (h > 0) return '$h 小时';
  return '$m 分';
}

String relativeTime(DateTime? date) {
  if (date == null) return '未知';
  final diff = DateTime.now().difference(date).inSeconds;
  if (diff < 0) return '尚未发生';
  if (diff < 60) return '刚刚';
  if (diff < 3600) return '${diff ~/ 60} 分钟前';
  if (diff < 86400) return '${diff ~/ 3600} 小时前';
  return '${diff ~/ 86400} 天前';
}

String todayLabel() {
  final d = DateTime.now();
  const weekdays = ['日', '一', '二', '三', '四', '五', '六'];
  return '${d.month} 月 ${d.day} 日 · 周${weekdays[d.weekday % 7]}';
}

String ageLabel(DateTime birthday) {
  final now = DateTime.now();
  int months = (now.year - birthday.year) * 12 + now.month - birthday.month;
  int days = now.day - birthday.day;
  if (days < 0) {
    months--;
    days += 30;
  }
  return '$months 个月 $days 天';
}
