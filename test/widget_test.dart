// 交易守则打卡 App 基础冒烟测试

import 'package:flutter_test/flutter_test.dart';

import 'package:trade_discipline/main.dart';

void main() {
  testWidgets('App 启动并显示底部导航', (WidgetTester tester) async {
    await tester.pumpWidget(const TradeDisciplineApp());
    await tester.pumpAndSettle();

    expect(find.text('今日'), findsOneWidget);
    expect(find.text('记录'), findsOneWidget);
    expect(find.text('统计'), findsOneWidget);
    expect(find.text('设置'), findsOneWidget);
  });
}
