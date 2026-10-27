import 'dart:async';

import 'package:bjut_campus/features/home/presentation/home_shell_page.dart';
import 'package:bjut_campus/features/schedule/data/schedule_repository.dart';
import 'package:bjut_campus/features/schedule/data/schedule_response_decoder.dart';
import 'package:bjut_campus/features/schedule/domain/schedule.dart';
import 'package:bjut_campus/features/schedule/presentation/schedule_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'schedule_test_support.dart';

Widget page(ScheduleRepository repository) => MaterialApp(
  home: Scaffold(body: SchedulePage(repository: repository)),
);

/// Switches the body like HomeShellPage, so leaving the tab disposes the page.
Widget navigationPage(ScheduleRepository repository) {
  var selectedIndex = 0;
  return MaterialApp(
    home: StatefulBuilder(
      builder: (context, setState) => Scaffold(
        body: selectedIndex == 0
            ? SchedulePage(repository: repository)
            : const Center(child: Text('已离开课表')),
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) =>
              setState(() => selectedIndex = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              label: '课表',
            ),
            NavigationDestination(
              key: Key('test-nav-away'),
              icon: Icon(Icons.home_outlined),
              label: '其他',
            ),
          ],
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('loading and success retain the fictional-data notice', (
    tester,
  ) async {
    final pending = Completer<SchedulePayload>();
    final source = CallbackScheduleDataSource(() => pending.future);
    await tester.pumpWidget(page(ScheduleRepository(dataSource: source)));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.textContaining('完全虚构 · 未登录 · 未同步'), findsOneWidget);
    pending.complete(examplePayload());
    await tester.pumpAndSettle();
    expect(find.text('课表离线示例'), findsOneWidget);
    expect(find.text('示例课程 A（虚构）'), findsOneWidget);
    expect(find.text('星期（原值）：fictional-day-a'), findsOneWidget);
    expect(find.text('节次（原值）：fictional-slots-a'), findsOneWidget);
    expect(find.text('周次（原值）：fictional-weeks-a'), findsOneWidget);
    expect(find.textContaining('完全虚构 · 未登录 · 未同步'), findsOneWidget);
    expect(source.calls, 1);
  });

  testWidgets('empty is distinct from failure and keeps the example label', (
    tester,
  ) async {
    final source = CallbackScheduleDataSource(
      () async => examplePayload(data: scheduleFixture('empty_data')),
    );
    await tester.pumpWidget(page(ScheduleRepository(dataSource: source)));
    await tester.pumpAndSettle();
    expect(find.text('示例中暂无课程'), findsOneWidget);
    expect(find.text('重试示例'), findsNothing);
    expect(find.textContaining('完全虚构 · 未登录 · 未同步'), findsOneWidget);
  });

  testWidgets(
    'failure, failed retry and recovery do not expose error contents',
    (tester) async {
      var shouldFail = true;
      final source = CallbackScheduleDataSource(() async {
        if (shouldFail) {
          throw StateError('fictional-private-marker');
        }
        return examplePayload();
      });
      await tester.pumpWidget(page(ScheduleRepository(dataSource: source)));
      await tester.pumpAndSettle();
      expect(find.text('示例暂时无法加载'), findsOneWidget);
      expect(find.textContaining('fictional-private-marker'), findsNothing);
      await tester.tap(find.text('重试示例'));
      await tester.pumpAndSettle();
      expect(find.text('示例暂时无法加载'), findsOneWidget);
      expect(tester.takeException(), isNull);
      shouldFail = false;
      await tester.tap(find.text('重试示例'));
      await tester.pumpAndSettle();
      expect(find.text('示例课程 A（虚构）'), findsOneWidget);
      expect(source.calls, 3);
    },
  );

  testWidgets('pull refresh failure is handled without an unhandled future', (
    tester,
  ) async {
    var shouldFail = false;
    final source = CallbackScheduleDataSource(() async {
      if (shouldFail) {
        throw const ScheduleFailure(ScheduleFailureKind.sourceUnavailable);
      }
      return examplePayload();
    });
    await tester.pumpWidget(page(ScheduleRepository(dataSource: source)));
    await tester.pumpAndSettle();
    shouldFail = true;
    await tester.drag(find.byType(ListView), const Offset(0, 400));
    await tester.pumpAndSettle();
    expect(source.calls, 2);
    expect(find.text('示例暂时无法加载'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('an obsolete load cannot overwrite a replacement repository', (
    tester,
  ) async {
    final oldLoad = Completer<SchedulePayload>();
    final oldRepository = ScheduleRepository(
      dataSource: CallbackScheduleDataSource(() => oldLoad.future),
    );
    final newRepository = ScheduleRepository(
      dataSource: CallbackScheduleDataSource(
        () async => examplePayload(data: scheduleFixture('empty_data')),
      ),
    );
    await tester.pumpWidget(page(oldRepository));
    await tester.pumpWidget(page(newRepository));
    await tester.pumpAndSettle();
    oldLoad.complete(examplePayload());
    await tester.pumpAndSettle();
    expect(find.text('示例中暂无课程'), findsOneWidget);
    expect(find.text('示例课程 A（虚构）'), findsNothing);
  });

  for (final refreshing in [false, true]) {
    for (final fails in [false, true]) {
      testWidgets(
        'navigation disposes a pending ${refreshing ? 'refresh' : 'load'}; '
        'late ${fails ? 'failure' : 'success'} is harmless',
        (tester) async {
          final pending = Completer<SchedulePayload>();
          final responses = <Future<SchedulePayload>>[
            if (refreshing) Future.value(examplePayload()),
            pending.future,
          ];
          final source = CallbackScheduleDataSource(
            () => responses.removeAt(0),
          );
          final repository = ScheduleRepository(dataSource: source);
          await tester.pumpWidget(navigationPage(repository));
          Future<void>? refreshDone;
          if (refreshing) {
            await tester.pumpAndSettle();
            refreshDone = tester
                .widget<RefreshIndicator>(find.byType(RefreshIndicator))
                .onRefresh();
            await tester.pump();
          } else {
            await tester.pump();
          }
          expect(find.byType(CircularProgressIndicator), findsOneWidget);

          await tester.tap(find.byKey(const Key('test-nav-away')));
          await tester.pumpAndSettle();
          expect(find.byType(SchedulePage), findsNothing);
          expect(find.text('已离开课表'), findsOneWidget);

          if (fails) {
            pending.completeError(StateError('fictional-late-error'));
          } else {
            pending.complete(examplePayload());
          }
          if (refreshDone != null) {
            await refreshDone;
          }
          await tester.pumpAndSettle();
          expect(find.byType(SchedulePage), findsNothing);
          expect(find.text('已离开课表'), findsOneWidget);
          expect(source.calls, refreshing ? 2 : 1);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  for (final olderFails in [false, true]) {
    for (final newerFails in [false, true]) {
      testWidgets(
        'same repository keeps newest ${newerFails ? 'failure' : 'success'} '
        'after an older ${olderFails ? 'failure' : 'success'} completes last',
        (tester) async {
          final older = Completer<SchedulePayload>();
          final newer = Completer<SchedulePayload>();
          final responses = <Future<SchedulePayload>>[
            Future.value(examplePayload()),
            older.future,
            newer.future,
          ];
          final source = CallbackScheduleDataSource(
            () => responses.removeAt(0),
          );
          final repository = ScheduleRepository(dataSource: source);
          await tester.pumpWidget(page(repository));
          await tester.pumpAndSettle();

          // Call the public refresh callback to overlap requests. A drag-driven
          // RefreshIndicator normally serializes gestures; this isolates the
          // page's handling of concurrent reloads without replacing its State.
          final reload = tester
              .widget<RefreshIndicator>(find.byType(RefreshIndicator))
              .onRefresh;
          final olderDone = reload();
          await tester.pump();
          final newerDone = reload();
          await tester.pump();
          expect(source.calls, 3);

          if (newerFails) {
            newer.completeError(StateError('fictional-newer-error'));
          } else {
            newer.complete(examplePayload(data: scheduleFixture('empty_data')));
          }
          await newerDone;
          await tester.pumpAndSettle();
          final newestText = newerFails ? '示例暂时无法加载' : '示例中暂无课程';
          expect(find.text(newestText), findsOneWidget);

          if (olderFails) {
            older.completeError(StateError('fictional-older-error'));
          } else {
            older.complete(examplePayload());
          }
          await olderDone;
          await tester.pumpAndSettle();
          expect(find.text(newestText), findsOneWidget);
          expect(find.text('示例课程 A（虚构）'), findsNothing);
          expect(find.textContaining('fictional-older-error'), findsNothing);
          expect(find.textContaining('fictional-newer-error'), findsNothing);
          expect(find.textContaining('完全虚构 · 未登录 · 未同步'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('narrow screen and large text remain scrollable', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final source = CallbackScheduleDataSource(() async => examplePayload());
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: Scaffold(
          body: SchedulePage(
            repository: ScheduleRepository(dataSource: source),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('重新加载本地示例'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('重新加载本地示例').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('重新加载本地示例'));
    await tester.pumpAndSettle();
    expect(source.calls, 2);
  });

  testWidgets('bottom navigation opens the repository example', (tester) async {
    final source = CallbackScheduleDataSource(() async => examplePayload());
    await tester.pumpWidget(
      MaterialApp(
        home: HomeShellPage(
          scheduleRepository: ScheduleRepository(dataSource: source),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('nav-schedule')));
    await tester.pumpAndSettle();
    expect(find.text('课表离线示例'), findsOneWidget);
    expect(find.text('示例课程 A（虚构）'), findsOneWidget);
    expect(find.textContaining('完全虚构 · 未登录 · 未同步'), findsOneWidget);
    expect(source.calls, 1);
    expect(tester.takeException(), isNull);
  });
}
