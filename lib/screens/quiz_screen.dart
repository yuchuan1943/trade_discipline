import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/rules_data.dart';
import '../models/daily_record.dart';
import '../services/storage_service.dart';
import '../utils/fmt.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  /// 每条守则 id -> 是否遵守（true = 遵守）
  final Map<String, bool> _complied = {
    for (final r in allRules) r.id: true,
  };
  final TextEditingController _pnlCtrl = TextEditingController();
  final TextEditingController _noteCtrl = TextEditingController();
  bool _submitting = false;

  int get _violatedCount => _complied.values.where((v) => !v).length;

  @override
  void dispose() {
    _pnlCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;

    // 解析盈亏
    double pnl = 0;
    final pnlText = _pnlCtrl.text.trim();
    if (pnlText.isNotEmpty) {
      final v = double.tryParse(pnlText);
      if (v == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('盈亏金额格式不正确，请输入数字（如 1200 或 -800）')),
        );
        return;
      }
      pnl = v;
    }

    final violated = _complied.entries
        .where((e) => !e.value)
        .map((e) => e.key)
        .toList();

    setState(() => _submitting = true);

    final record = DailyRecord(
      date: todayString(),
      pnl: pnl,
      violatedRuleIds: violated,
      note: _noteCtrl.text.trim(),
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    await StorageService.saveRecord(record);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('今日复盘已保存')),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(prettyDate(todayString())),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _progressBar(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: [
                for (final group in groupOrder) _groupSection(group),
                const SizedBox(height: 8),
                _pnlCard(),
                const SizedBox(height: 12),
                _noteCard(),
                const SizedBox(height: 8),
              ],
            ),
          ),
          _bottomBar(),
        ],
      ),
    );
  }

  Widget _progressBar() {
    final total = allRules.length;
    final done = total - _violatedCount;
    return Container(
      color: const Color(0xFFD9404A),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Text(
            '已遵守',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: total == 0 ? 0 : done / total,
                minHeight: 8,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation(Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$done/$total',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _groupSection(RuleGroup group) {
    final rules = rulesByGroup(group);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 10),
          child: Row(
            children: [
              Text(group.emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                group.label,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: group.color,
                ),
              ),
            ],
          ),
        ),
        ...rules.map((r) => _ruleTile(r)),
      ],
    );
  }

  Widget _ruleTile(TradeRule rule) {
    final ok = _complied[rule.id]!;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: ok ? Colors.white : rule.group.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ok ? Colors.grey.shade200 : rule.group.color,
          width: ok ? 1 : 1.4,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: rule.group.bg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${rule.no}',
                style: TextStyle(
                  color: rule.group.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rule.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14.5),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    rule.content,
                    style: TextStyle(
                        color: Colors.grey.shade700, fontSize: 13, height: 1.5),
                  ),
                  if (rule.subItems.isNotEmpty)
                    ...rule.subItems.map(
                      (s) => Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 6),
                              child: Text('·  ',
                                  style: TextStyle(color: Colors.grey)),
                            ),
                            Expanded(
                              child: Text(
                                s,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12.5,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Column(
              children: [
                Switch(
                  value: ok,
                  activeThumbColor: const Color(0xFF238A5C),
                  onChanged: (v) => setState(() => _complied[rule.id] = v),
                ),
                Text(
                  ok ? '遵守' : '违规',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: ok ? const Color(0xFF238A5C) : rule.group.color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _pnlCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '当日盈亏（元）',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              '正数为盈利，负数为亏损，留空表示持平',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _pnlCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(signed: true, decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*$')),
              ],
              decoration: InputDecoration(
                prefixText: '¥ ',
                hintText: '例如 1200 或 -800',
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _noteCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '备注（可选）',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _noteCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: '记录当日交易心得、情绪状态等',
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 8, 16, 8 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFD9404A),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: _submitting ? null : _submit,
          child: Text(
            _submitting
                ? '保存中...'
                : _violatedCount > 0
                    ? '提交复盘（违规 $_violatedCount 项）'
                    : '提交复盘（全部遵守）',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
