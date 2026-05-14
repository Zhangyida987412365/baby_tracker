class Record {
  final String id;
  final DateTime time;
  final String type;
  final int? value; // could be seconds (sleep, breast) or ml (bottle)
  final Map<String, dynamic> extra;

  Record({
    required this.id,
    required this.time,
    required this.type,
    this.value,
    this.extra = const {},
  });

  factory Record.fromJson(Map<String, dynamic> json) {
    return Record(
      id: json['id'],
      time: DateTime.parse(json['time']),
      type: json['type'],
      value: json['value'],
      extra: json['extra'] ?? {},
    );
  }
}
