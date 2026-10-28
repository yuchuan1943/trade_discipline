import 'package:flutter/material.dart';

import '../data/rules_data.dart';
import '../models/daily_record.dart';
import '../services/storage_service.dart';
import '../utils/fmt.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<DailyRecord> _records = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await StorageService.getAllRecords();
    if (!mounted) return;
    setState(() {
      _records = list;
      _loading = false;
    });
  }

  Future<void> _delete(DailyRecord r) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除记录'),
        content: Text('确定删除 ${prettyDate(r.date)} 的记录吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('删除', style: TextStyle(color: Color(0xFFD9404A))),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await StorageService.deleteRecord(r.date);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('往日记录'), centerTitle: true),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 200),
                  Center(child: CircularProgressIndicator()),
                ],
              )
            : _records.isEmpty
                ? _empty()
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: _records.length,
                    itemBuilder: (ctx, i) => _recordCard(_records[i]),
                  ),
      ),
    );
  }

  Widget _empty() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 120),
      children: [
        Icon(Icons.history, size: 64, color: Colors.grey.shade300),
        const SizedBox(height: 12),
        Text(
          '还没有任何记录',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
        ),
        const SizedBox(height: 4),
        Text(
          '完成每日问答后，记录会出现在这里\n下拉可刷新',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 13, height: 1.6),
        ),
      ],
    );
  }

  Widget _recordCard(DailyRecord r) {
    return Dismissible(
      key: ValueKey(r.date),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _delete(r),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFD9404A),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    prettyDate(r.date),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text(
                    pnlText(r.pnl),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: pnlColor(r.pnl),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    r.allComplied ? Icons.check_circle : Icons.cancel,
                    size: 18,
                    color: r.allComplied
                        ? const Color(0xFF238A5C)
                        : const Color(0xFFD9404A),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    r.allComplied
                        ? '全部守则遵守'
                        : '违规 ${r.violatedRuleIds.length} 项',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: r.allComplied
                          ? const Color(0xFF238A5C)
                          : const Color(0xFFD9404A),
                    ),
                  ),
                  if (r.note.isNotEmpty) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        r.note,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            TextStyle(color: Colors.grey.shade500, fontSize: 12.5),
                      ),
                    ),
                  ],
                ],
              ),
              if (!r.allComplied) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: r.violatedRuleIds
                      .map((id) => _chip(ruleById(id)))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(TradeRule rule) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: rule.group.bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '#${rule.no} ${rule.title}',
        style: TextStyle(
          color: rule.group.color,
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
