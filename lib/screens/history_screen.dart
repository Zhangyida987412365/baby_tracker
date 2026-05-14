import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../utils/styles.dart';
import '../utils/categories.dart';
import '../utils/formatters.dart';
import '../widgets/shared.dart';

class HistoryScreen extends StatefulWidget {
  final String initialFilter;
  const HistoryScreen({super.key, this.initialFilter = 'all'});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _filter = 'all';
  bool _isSearching = false;
  String _query = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
  }

  @override
  void didUpdateWidget(HistoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialFilter != oldWidget.initialFilter) {
      setState(() => _filter = widget.initialFilter);
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  final _types = [
    {'key': 'all', 'label': '全部'},
    {'key': 'breast', 'label': '母乳'},
    {'key': 'bottle', 'label': '瓶喂'},
    {'key': 'sleep', 'label': '睡眠'},
    {'key': 'diaper', 'label': '尿布'},
    {'key': 'food', 'label': '辅食'},
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (_, state, __) {
      var records = _filter == 'all'
          ? List<Record>.from(state.records)
          : state.records.where((r) => r.type == _filter).toList();
      
      // If searching, ignore the tab filter and search ALL records for the current baby
      if (_isSearching && _query.isNotEmpty) {
        records = state.records.where((r) {
          final cLabel = categories[r.type]?.label ?? '';
          final rDesc = describeRecord(r.toJson());
          // Deep search into the raw JSON strings as a fallback
          final rawJson = r.toJson().toString();
          return cLabel.contains(_query) || rDesc.contains(_query) || rawJson.contains(_query);
        }).toList();
      }
      
      records.sort((a, b) => b.time.compareTo(a.time));

      return SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _isSearching
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(22, 60, 22, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                          decoration: BoxDecoration(color: AppStyles.bgPill, borderRadius: BorderRadius.circular(24)),
                          child: TextField(
                            controller: _searchCtrl,
                            autofocus: true,
                            style: const TextStyle(fontSize: 15, color: AppStyles.ink),
                            decoration: const InputDecoration(
                              border: InputBorder.none, hintText: '搜索母乳、换尿布等...',
                              hintStyle: TextStyle(color: AppStyles.ink3),
                            ),
                            onChanged: (v) => setState(() => _query = v.trim()),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      TapBounce(
                        onTap: () {
                          _searchCtrl.clear();
                          setState(() { _isSearching = false; _query = ''; });
                        },
                        child: const Text('取消', style: TextStyle(fontSize: 15, color: AppStyles.ink2, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                )
              : PageHeaderWidget(
                  title: '记录',
                  subtitle: '共 ${state.records.length} 条',
                  right: TapBounce(
                    onTap: () => setState(() => _isSearching = true),
                    child: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(color: AppStyles.bgPill, borderRadius: BorderRadius.circular(20)),
                      child: const Icon(Icons.search_rounded, size: 18, color: AppStyles.ink),
                    ),
                  ),
                ),
            const SizedBox(height: 16),

            // Filter chips
            SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                itemCount: _types.length,
                itemBuilder: (_, i) {
                  final t = _types[i];
                  final isActive = _filter == t['key'];
                  return TapBounce(
                    onTap: () => setState(() => _filter = t['key']!),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isActive ? AppStyles.ink : AppStyles.bgCard,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: isActive ? AppStyles.ink : AppStyles.line),
                      ),
                      child: Text(t['label']!, style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500,
                        color: isActive ? Colors.white : AppStyles.ink2,
                      )),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Day separator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Row(
                children: [
                  Expanded(child: Container(height: 1, color: AppStyles.line.withOpacity(0.5))),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('今天', style: TextStyle(fontSize: 12.5, color: AppStyles.ink3, fontWeight: FontWeight.w500, letterSpacing: 0.4)),
                  ),
                  Expanded(child: Container(height: 1, color: AppStyles.line.withOpacity(0.5))),
                ],
              ),
            ),

            // Timeline or Search Results
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: records.isEmpty 
                ? Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: Center(child: Text(_isSearching ? '暂无搜索结果' : '暂无相关记录', style: const TextStyle(fontSize: 14, color: AppStyles.ink3))),
                  )
                : _buildTimeline(records),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTimeline(List<Record> records) {
    return Stack(
      children: [
        Positioned(
          left: 58, top: 24, bottom: 24,
          child: Container(width: 1.5, color: AppStyles.line.withOpacity(0.6)),
        ),
        Column(
          children: records.map((r) {
            final c = categories[r.type]!;
            return FadeUpWidget(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 46,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(fmtTime(r.time), textAlign: TextAlign.right,
                          style: const TextStyle(fontSize: 12, color: AppStyles.ink3,
                            fontFeatures: [FontFeature.tabularFigures()])),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: Container(
                        width: 16, height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: c.color, width: 3),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Dismissible(
                        key: ValueKey(r.dbId ?? r.time.toIso8601String()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          decoration: BoxDecoration(color: Colors.red.shade400, borderRadius: BorderRadius.circular(18)),
                          child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          if (r.dbId != null) {
                            Provider.of<AppState>(context, listen: false).deleteRecord(r.dbId!);
                          }
                        },
                        child: TapBounce(
                          child: GlassCard(
                            radius: 18,
                            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                            child: Row(
                              children: [
                                CategoryIconWidget(icon: c.icon, color: c.color, bg: c.bg),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(c.label, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: AppStyles.ink)),
                                      Text(describeRecord(r.toJson()), style: const TextStyle(fontSize: 12.5, color: AppStyles.ink2, height: 1.4)),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right_rounded, color: AppStyles.ink4, size: 18),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
