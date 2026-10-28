import 'package:flutter/material.dart';

import '../data/rules_data.dart';
import '../models/daily_record.dart';
import '../services/storage_service.dart';
import '../utils/fmt.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('统计'), centerTitle: true),
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
                : ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    children: [
                      _overview(),
                      const SizedBox(height: 16),
                      _pnlSummary(),
                      const SizedBox(height: 16),
                      _violationRank(),
                    ],
                  ),
      ),
    );
  }

  Widget _empty() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 120),
      children: [
        Icon(Icons.bar_chart, size: 64, color: Colors.grey.shade300),
        const SizedBox(height: 12),
        Text(
          '暂无统计数据',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
        ),
        const SizedBox(height: 4),
        Text(
          '完成每日问答后即可查看违规统计\n下拉可刷新',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 13, height: 1.6),
        ),
      ],
    );
  }

  double get _totalPnl =>
      _records.fold(0.0, (sum, r) => sum + r.pnl);
  int get _profitDays => _records.where((r) => r.isProfit).length;
  int get _lossDays => _records.where((r) => r.isLoss).length;
  int get _flatDays => _records.where((r) => r.isFlat).length;
  int get _fullCompliedDays => _records.where((r) => r.allComplied).length;
  int get _totalViolations =>
      _records.fold(0, (sum, r) => sum + r.violatedRuleIds.length);
  double get _complyRate =>
      _records.isEmpty ? 0 : _fullCompliedDays / _records.length;

  Widget _overview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD9404A), Color(0xFFB32F39)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '累计盈亏',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            pnlText(_totalPnl),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _statItem('答题天数', '${_records.length}'),
              _statItem('违规次数', '$_totalViolations'),
              _statItem('遵守率', '${(_complyRate * 100).toStringAsFixed(0)}%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _pnlSummary() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('盈亏分布',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 12),
            Row(
              children: [
                _pnlCell('盈利天数', _profitDays, const Color(0xFFD9404A)),
                _pnlCell('亏损天数', _lossDays, const Color(0xFF238A5C)),
                _pnlCell('持平天数', _flatDays, const Color(0xFF6B7280)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _pnlCell(String label, int value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5)),
        ],
      ),
    );
  }

  Widget _violationRank() {
    // 统计每条守则违规次数
    final Map<String, int> count = {};
    for (final r in _records) {
      for (final id in r.violatedRuleIds) {
        count[id] = (count[id] ?? 0) + 1;
      }
    }
    final entries = count.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final maxCount = entries.isEmpty ? 1 : entries.first.value;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('违规守则排行',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 4),
            Text(
              '按违规次数降序，提醒你最常违背的守则',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12.5),
            ),
            const SizedBox(height: 12),
            if (entries.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    '👍 暂无违规记录，继续保持！',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              )
            else
              ...entries.map((e) {
                final rule = ruleById(e.key);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: rule.group.bg,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Text(
                              '#${rule.no}',
                              style: TextStyle(
                                color: rule.group.color,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              rule.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13.5),
                            ),
                          ),
                          Text(
                            '${e.value} 次',
                            style: TextStyle(
                              color: rule.group.color,
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: e.value / maxCount,
                          minHeight: 6,
                          backgroundColor: Colors.grey.shade100,
                          valueColor:
                              AlwaysStoppedAnimation(rule.group.color),
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
