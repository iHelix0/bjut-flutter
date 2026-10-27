import 'package:bjut_campus/features/schedule/data/schedule_repository.dart';
import 'package:bjut_campus/features/schedule/domain/schedule.dart';
import 'package:flutter_test/flutter_test.dart';

import 'schedule_test_support.dart';

void main() {
  test('repository maps DTOs without guessing, sorting or deduplicating codes', () async {
    final payload = examplePayload();
    final source = CallbackScheduleDataSource(() async => payload);
    final schedule = await ScheduleRepository(dataSource: source).getSchedule();
    expect(source.calls, 1);
    expect(schedule.currentTerm.id, payload.index.params.id);
    expect(schedule.currentTerm.year, payload.index.params.year);
    expect(schedule.currentTerm.term, payload.index.params.term);
    expect(schedule.currentTerm.startDay, payload.index.params.startday);
    expect(schedule.currentTerm.weekCountCode, payload.index.params.countweek);
    expect(schedule.currentTerm.week, payload.index.params.week);
    expect(schedule.currentWeekdayCode, payload.index.weekday);
    expect(schedule.terms.single.id, payload.index.termInfo.single.id);
    expect(schedule.weekdayCodes, payload.data.weekdays);
    for (var i = 0; i < schedule.courses.length; i++) {
      final course = schedule.courses[i];
      final row = payload.data.classes[i];
      expect(course.id, row.courseId);
      expect(course.name, row.courseName);
      expect(course.location, row.location);
      expect(course.teacher, row.teacher);
      expect(course.weekdayCode, row.weekday);
      expect(course.lessonCode, row.lessons);
      expect(course.weekCode, row.week);
    }
    expect(() => schedule.courses.clear(), throwsUnsupportedError);
    expect(() => schedule.terms.clear(), throwsUnsupportedError);
    expect(() => schedule.weekdayCodes.clear(), throwsUnsupportedError);
    payload.data.weekdays[0] = 'changed-after-mapping';
    expect(schedule.weekdayCodes, hasLength(2));
    expect(schedule.weekdayCodes.first, 'fictional-day-a');
  });

  test('empty data stays empty, with no invented courses', () async {
    final source = CallbackScheduleDataSource(
      () async => examplePayload(data: scheduleFixture('empty_data')),
    );
    final schedule = await ScheduleRepository(dataSource: source).getSchedule();
    expect(schedule.courses, isEmpty);
    expect(schedule.weekdayCodes, isEmpty);
  });

  test('source failures propagate; the repository never falls back to examples', () async {
    for (final kind in ScheduleFailureKind.values) {
      final error = ScheduleFailure(kind);
      final source = CallbackScheduleDataSource(() async => throw error);
      await expectLater(
        ScheduleRepository(dataSource: source).getSchedule(),
        throwsA(same(error)),
      );
    }
  });
}
