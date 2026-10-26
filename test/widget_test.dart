import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bjut_campus/app/app.dart';
import 'package:bjut_campus/features/information/presentation/information_page.dart';

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
}
