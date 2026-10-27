import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bjut_campus/app/app.dart';
import 'package:bjut_campus/features/information/data/information_repository.dart';
import 'package:bjut_campus/features/information/domain/information_item.dart';
import 'package:bjut_campus/features/information/presentation/information_page.dart';

class _FixtureInformationRepository extends InformationRepository {
  int calls = 0;

  @override
  Future<List<InformationItem>> getItems() async {
    calls++;
    return [
      InformationItem(
        id: 'fictional-item',
        title: '示例信息',
        category: '示例',
        body: '完全虚构',
        updatedAt: DateTime(2026),
        sourceUrl: 'https://example.invalid',
      ),
    ];
  }
}

void main() {
  testWidgets('基础壳显示核心入口', (tester) async {
    await tester.pumpWidget(const BjutCampusApp());

    expect(find.text('日新工大'), findsOneWidget);
    expect(find.text('快捷入口'), findsOneWidget);
    expect(find.text('欢迎回来'), findsOneWidget);
    expect(find.text('课表'), findsOneWidget);
    expect(find.text('通知'), findsOneWidget);
    expect(find.text('校园卡'), findsOneWidget);
    expect(find.text('信息'), findsOneWidget);
  });

  testWidgets('信息页读取静态内容包', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: InformationPage()));
    for (var index = 0; index < 10; index++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.text('校内信息'), findsOneWidget);
    expect(find.text('校园服务'), findsOneWidget);
    expect(find.text('图书馆信息'), findsOneWidget);
  });

  testWidgets('信息页刷新不把 Future 返回给 setState', (tester) async {
    final repository = _FixtureInformationRepository();
    await tester.pumpWidget(
      MaterialApp(home: InformationPage(repository: repository)),
    );
    await tester.pumpAndSettle();
    final refresh = tester
        .widget<RefreshIndicator>(find.byType(RefreshIndicator))
        .onRefresh;
    final done = refresh();
    await tester.pumpAndSettle();
    await done;
    expect(find.text('校内信息'), findsOneWidget);
    expect(find.text('示例信息'), findsOneWidget);
    expect(repository.calls, 2);
    expect(tester.takeException(), isNull);
  });
}
