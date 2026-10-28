import 'package:flutter/material.dart';

/// 守则分组
enum RuleGroup { bottomLine, standard, extra, preCheck }

extension RuleGroupInfo on RuleGroup {
  String get label {
    switch (this) {
      case RuleGroup.bottomLine:
        return '底线铁律';
      case RuleGroup.standard:
        return '标准操作规则';
      case RuleGroup.extra:
        return '补充注意事项';
      case RuleGroup.preCheck:
        return '开仓前四查';
    }
  }

  Color get color {
    switch (this) {
      case RuleGroup.bottomLine:
        return const Color(0xFFD9404A);
      case RuleGroup.standard:
        return const Color(0xFFB45309);
      case RuleGroup.extra:
        return const Color(0xFF238A5C);
      case RuleGroup.preCheck:
        return const Color(0xFF3B5BDB);
    }
  }

  Color get bg {
    switch (this) {
      case RuleGroup.bottomLine:
        return const Color(0xFFFBEaEB);
      case RuleGroup.standard:
        return const Color(0xFFFCF0DC);
      case RuleGroup.extra:
        return const Color(0xFFE6F4EC);
      case RuleGroup.preCheck:
        return const Color(0xFFE9EDFC);
    }
  }

  String get emoji {
    switch (this) {
      case RuleGroup.bottomLine:
        return '🔴';
      case RuleGroup.standard:
        return '🟡';
      case RuleGroup.extra:
        return '🟢';
      case RuleGroup.preCheck:
        return '🔵';
    }
  }
}

/// 单条守则 / 检查项
class TradeRule {
  /// 唯一标识：1..13 为守则，c1..c4 为四查
  final String id;
  final int no;
  final String title;
  final String content;
  final List<String> subItems;
  final RuleGroup group;

  const TradeRule({
    required this.id,
    required this.no,
    required this.title,
    required this.content,
    this.subItems = const [],
    required this.group,
  });
}

/// 13 条交易守则 + 开仓前四查
const List<TradeRule> allRules = [
  // ---------- 底线铁律 ----------
  TradeRule(
    id: '1',
    no: 1,
    title: '单笔亏损上限 2%',
    content: '单笔最大亏损 ≤ 总资金 2%；连亏 3 笔，当日停止新开仓',
    group: RuleGroup.bottomLine,
  ),
  TradeRule(
    id: '2',
    no: 2,
    title: '回撤 15% 降仓',
    content: '账户总回撤 ≥ 15%，仓位上限 50% → 25%，并降低交易频次',
    group: RuleGroup.bottomLine,
  ),
  TradeRule(
    id: '3',
    no: 3,
    title: '仓位占用 < 50%',
    content: '总开仓占用 ＜ 50%，禁止满仓；高波动 / 长假前 ≤ 30%；数据 / 交割周隔夜 ≤ 20%',
    group: RuleGroup.bottomLine,
  ),
  TradeRule(
    id: '4',
    no: 4,
    title: '末日期权 ≤ 10%',
    content: '末日期权投入 ≤ 总资金 10%',
    group: RuleGroup.bottomLine,
  ),
  TradeRule(
    id: '5',
    no: 5,
    title: '禁止摊薄补仓',
    content: '期货严禁浮亏摊薄补仓；期权仅趋势未破才可补仓，趋势证伪立刻离场',
    group: RuleGroup.bottomLine,
  ),
  // ---------- 标准操作规则 ----------
  TradeRule(
    id: '6',
    no: 6,
    title: '周 / 日线定趋势',
    content: '周 / 日线定大趋势，震荡无方向直接空仓',
    subItems: [
      '期货：顺势 + 定方向，不逆势抄底摸顶',
      '期权：过滤震荡，避开时间价值衰减',
      '口诀：周线 + 日线方向一致且明确才动手，不一致 → 空仓',
    ],
    group: RuleGroup.standard,
  ),
  TradeRule(
    id: '7',
    no: 7,
    title: '开仓即设止损',
    content: '开仓即设初始止损；止损只上移、绝不放大后移；期权补仓后重算整体止损',
    group: RuleGroup.standard,
  ),
  TradeRule(
    id: '8',
    no: 8,
    title: '期货减仓追踪',
    content: '期货减仓追踪：',
    subItems: [
      '1 倍盈亏比 → 减 50%，止损移到开仓价',
      '2 倍盈亏比 → 再减 30%',
      '剩余 20% → 按日线高点回撤 1.5ATR 追踪',
    ],
    group: RuleGroup.standard,
  ),
  TradeRule(
    id: '9',
    no: 9,
    title: '期权减仓追踪',
    content: '期权买方减仓追踪：',
    subItems: [
      '1 倍盈亏比 → 减 50%，止损移到成本线',
      '2 倍盈亏比 → 再减 30%',
      '剩余 20% → 非末日回撤 30% 追踪；末日期权不做移动止损、达标清仓',
    ],
    group: RuleGroup.standard,
  ),
  TradeRule(
    id: '10',
    no: 10,
    title: '浮盈 100% 抽本金',
    content: '期权浮盈 100%，抽出全部本金，利润继续博弈',
    group: RuleGroup.standard,
  ),
  TradeRule(
    id: '11',
    no: 11,
    title: '浮盈回撤 40% 减半',
    content: '已有浮盈回撤 40%，强制减半仓',
    group: RuleGroup.standard,
  ),
  // ---------- 补充注意事项 ----------
  TradeRule(
    id: '12',
    no: 12,
    title: 'ATR 取日线',
    content: 'ATR 取日线；期权补仓总额提前锁定，不无限追加',
    group: RuleGroup.extra,
  ),
  TradeRule(
    id: '13',
    no: 13,
    title: '破位直接离场',
    content: '趋势结构破位直接离场，不等反弹',
    group: RuleGroup.extra,
  ),
  // ---------- 开仓前四查 ----------
  TradeRule(
    id: 'c1',
    no: 1,
    title: '方向',
    content: '周线 + 日线方向一致且明确吗？不一致 / 震荡 → 空仓',
    group: RuleGroup.preCheck,
  ),
  TradeRule(
    id: 'c2',
    no: 2,
    title: '仓位',
    content: '占用 ＜ 50%；高波动 / 长假 ≤ 30%；交割周隔夜 ≤ 20%',
    group: RuleGroup.preCheck,
  ),
  TradeRule(
    id: 'c3',
    no: 3,
    title: '止损',
    content: '开仓前先定好初始止损位，只上移、不后移',
    group: RuleGroup.preCheck,
  ),
  TradeRule(
    id: 'c4',
    no: 4,
    title: '上限',
    content: '单笔 ≤ 2%；末日期权 ≤ 10%',
    group: RuleGroup.preCheck,
  ),
];

/// 按分组取守则
List<TradeRule> rulesByGroup(RuleGroup group) =>
    allRules.where((r) => r.group == group).toList();

/// 根据 id 取守则
TradeRule ruleById(String id) => allRules.firstWhere((r) => r.id == id);

/// 分组顺序
const List<RuleGroup> groupOrder = [
  RuleGroup.bottomLine,
  RuleGroup.standard,
  RuleGroup.extra,
  RuleGroup.preCheck,
];
