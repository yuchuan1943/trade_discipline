import 'package:flutter/material.dart';

import '../data/rules_data.dart';
import '../models/daily_record.dart';
import '../services/storage_service.dart';
import '../utils/fmt.dart';
import 'quiz_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DailyRecord? _today;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final r = await StorageService.getRecord(todayString());
    if (!mounted) return;
    setState(() {
      _today = r;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('今日复盘'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  _headerCard(),
                  const SizedBox(height: 16),
                  if (_today == null) _notDoneCard() else _doneCard(_today!),
                ],
              ),
            ),
    );
  }

  Widget _headerCard() {
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
            '期货 & 期权买方交易卡',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            prettyDate(todayString()),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '纪律第一，严格照做 · 风控第一',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _notDoneCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.fact_check_outlined, size: 64, color: Color(0xFFD9404A)),
            const SizedBox(height: 16),
            const Text(
              '今日问答尚未完成',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '逐条核对 13 项交易守则与开仓前四查，\n记录当日盈亏，每天仅可提交一次。',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, height: 1.6),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFD9404A),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const QuizScreen()),
                  );
                  _load();
                },
                icon: const Icon(Icons.edit_note),
                label: const Text(
                  '开始今日问答',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _doneCard(DailyRecord r) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  r.allComplied
                      ? Icons.check_circle
                      : Icons.cancel,
                  color: r.allComplied
                      ? const Color(0xFF238A5C)
                      : const Color(0xFFD9404A),
                  size: 28,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    r.allComplied ? '全部守则均已遵守' : '存在未遵守的守则',
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _kv('当日盈亏', pnlText(r.pnl), pnlColor(r.pnl)),
            const SizedBox(height: 8),
            _kv(
              '违规项',
              r.allComplied ? '无' : '${r.violatedRuleIds.length} 项',
              r.allComplied ? const Color(0xFF238A5C) : const Color(0xFFD9404A),
            ),
            if (!r.allComplied) ...[
              const SizedBox(height: 12),
              ...r.violatedRuleIds.map((id) => _violatedChip(id)),
            ],
            if (r.note.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                '备注：${r.note}',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              ),
            ],
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock_outline, size: 16, color: Colors.grey),
                  SizedBox(width: 8),
                  Text(
                    '今日已完成，每天仅可问答一次',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kv(String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: TextStyle(color: Colors.grey.shade600)),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _violatedChip(String id) {
    final rule = ruleById(id);
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: rule.group.bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            rule.group.emoji,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '#${rule.no} ${rule.title}',
              style: TextStyle(
                color: rule.group.color,
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
