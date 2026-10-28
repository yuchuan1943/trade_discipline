import 'dart:convert';

/// 每日问答记录
class DailyRecord {
  /// 日期，格式 yyyy-MM-dd
  final String date;
  /// 当日盈亏金额（正 = 盈利，负 = 亏损，0 = 持平）
  final double pnl;
  /// 违规（未遵守）的守则 / 检查项 id 列表
  final List<String> violatedRuleIds;
  /// 备注
  final String note;
  /// 提交时间戳（毫秒）
  final int timestamp;

  const DailyRecord({
    required this.date,
    required this.pnl,
    required this.violatedRuleIds,
    this.note = '',
    required this.timestamp,
  });

  /// 是否盈利
  bool get isProfit => pnl > 0;
  bool get isLoss => pnl < 0;
  bool get isFlat => pnl == 0;

  /// 是否全部守则都遵守了
  bool get allComplied => violatedRuleIds.isEmpty;

  Map<String, dynamic> toJson() => {
        'date': date,
        'pnl': pnl,
        'violatedRuleIds': violatedRuleIds,
        'note': note,
        'timestamp': timestamp,
      };

  factory DailyRecord.fromJson(Map<String, dynamic> json) => DailyRecord(
        date: json['date'] as String,
        pnl: (json['pnl'] as num).toDouble(),
        violatedRuleIds:
            (json['violatedRuleIds'] as List<dynamic>).cast<String>(),
        note: (json['note'] as String?) ?? '',
        timestamp: json['timestamp'] as int,
      );

  String toJsonString() => jsonEncode(toJson());

  factory DailyRecord.fromJsonString(String s) =>
      DailyRecord.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
