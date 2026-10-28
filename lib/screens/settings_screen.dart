import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'
    show CupertinoPicker, FixedExtentScrollController;

import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../services/webview_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const String _tradeCardUrl =
      'https://workbuddy.link/p/VUzHo8Ht9CjAVeXi02xZHW?source=2';

  bool _enabled = false;
  int _hour = 9;
  int _minute = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _enabled = await StorageService.getReminderEnabled();
    _hour = await StorageService.getReminderHour();
    _minute = await StorageService.getReminderMinute();
    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _toggle(bool v) async {
    setState(() => _enabled = v);
    await StorageService.setReminderEnabled(v);
    if (v) {
      await NotificationService.requestPermissions();
      await NotificationService.scheduleDailyReminder(_hour, _minute);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已开启每日 $_hour:${_minute.toString().padLeft(2, '0')} 提醒')),
        );
      }
    } else {
      await NotificationService.cancelDailyReminder();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已关闭每日提醒')),
        );
      }
    }
  }

  Future<void> _selectTime(int hour, int minute) async {
    setState(() {
      _hour = hour;
      _minute = minute;
    });
    await StorageService.setReminderTime(_hour, _minute);
    if (_enabled) {
      await NotificationService.scheduleDailyReminder(_hour, _minute);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('提醒时间已设为 $hour:${minute.toString().padLeft(2, '0')}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置'), centerTitle: true),
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
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                _sectionTitle('每日提醒'),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        value: _enabled,
                        onChanged: _toggle,
                        title: const Text('每日问答提醒'),
                        subtitle: Text(
                          _enabled
                              ? '每天 $_hour:${_minute.toString().padLeft(2, '0')} 提醒你完成复盘'
                              : '关闭后不再提醒',
                        ),
                        activeThumbColor: const Color(0xFFD9404A),
                      ),
                      if (_enabled) _timeTile(),
                    ],
                  ),
                ),
                if (kIsWeb) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCF0DC),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            size: 18, color: Color(0xFFB45309)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '当前为 Web 调试环境，本地通知仅在 Android 真机端生效。',
                            style: TextStyle(
                                color: const Color(0xFFB45309), fontSize: 12.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                _sectionTitle('关于'),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('期货 & 期权买方交易守则打卡',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15)),
                            SizedBox(height: 6),
                            Text(
                              '13 条交易守则 · 开仓前四查\n单笔亏损 ≤ 2% · 仓位 < 50%\n纪律第一，严格照做 · 风控第一',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                  height: 1.6),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.menu_book_outlined),
                        title: const Text('查看交易守则原文'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () =>
                            openTradeCardPage(context, _tradeCardUrl),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      ),
    );
  }

  Widget _timeTile() {
    return ListTile(
      leading: const Icon(Icons.access_time),
      title: const Text('提醒时间'),
      trailing: Text(
        '$_hour:${_minute.toString().padLeft(2, '0')}',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      onTap: _showTimePicker,
    );
  }

  Future<void> _showTimePicker() async {
    int tmpHour = _hour;
    int tmpMinute = _minute >= 30 ? 30 : 0;

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('取消'),
                        ),
                        const Text('选择提醒时间',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('确定',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 200,
                    child: Row(
                      children: [
                        Expanded(
                          child: CupertinoPicker(
                            scrollController: FixedExtentScrollController(
                                initialItem: tmpHour),
                            itemExtent: 40,
                            onSelectedItemChanged: (i) => tmpHour = i,
                            children: List.generate(
                              24,
                              (i) => Center(
                                  child: Text(i.toString().padLeft(2, '0'),
                                      style: const TextStyle(fontSize: 20))),
                            ),
                          ),
                        ),
                        const Text(':',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                        Expanded(
                          child: CupertinoPicker(
                            scrollController: FixedExtentScrollController(
                                initialItem: tmpMinute == 30 ? 1 : 0),
                            itemExtent: 40,
                            onSelectedItemChanged: (i) =>
                                tmpMinute = i == 0 ? 0 : 30,
                            children: const [
                              Center(
                                  child: Text('00',
                                      style: TextStyle(fontSize: 20))),
                              Center(
                                  child: Text('30',
                                      style: TextStyle(fontSize: 20))),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );

    if (confirmed == true) {
      await _selectTime(tmpHour, tmpMinute);
    }
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10, top: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
