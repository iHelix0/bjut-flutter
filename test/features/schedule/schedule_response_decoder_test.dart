import 'dart:convert';

import 'package:bjut_campus/features/schedule/data/schedule_response_decoder.dart';
import 'package:bjut_campus/features/schedule/domain/schedule.dart';
import 'package:flutter_test/flutter_test.dart';

import 'schedule_test_support.dart';

void main() {
  const decoder = ScheduleResponseDecoder();
  TypeMatcher<ScheduleFailure> failure(ScheduleFailureKind kind) =>
      isA<ScheduleFailure>().having((error) => error.kind, 'kind', kind);
  Map<String, dynamic> dataJson() =>
      jsonDecode(exampleData()) as Map<String, dynamic>;
  Map<String, dynamic> indexJson() =>
      jsonDecode(exampleIndex()) as Map<String, dynamic>;

  test('synthetic data and index preserve the observed field types', () {
    final data = decoder.decodeData(exampleData(), httpStatus: 200);
    final index = decoder.decodeIndex(exampleIndex(), httpStatus: 200);
    expect(data.classes, hasLength(2));
    expect(data.classes.first.courseId, 'fictional-course-a');
    expect(data.classes.first.courseName, '示例课程 A（虚构）');
    expect(data.classes.first.location, '虚构教学楼 A');
    expect(data.classes.first.teacher, '虚构教师甲');
    expect(data.weekdays, ['fictional-day-a', 'unknown-day-code']);
    expect(index.params.id, 'fictional-term-a');
    expect(index.params.year, '虚构示例学年');
    expect(index.params.term, '虚构示例学期');
    expect(index.params.startday, 'fictional-start-day');
    expect(index.params.countweek, 'fictional-week-count');
    expect(index.params.week, 1);
    expect(index.termInfo.single.id, index.params.id);
    expect(index.weekday, 'fictional-day-a');
  });

  test('unknown codes, empty strings and whitespace are never interpreted', () {
    final json = dataJson();
    final row = json['d']['classes'][0] as Map<String, dynamic>;
    row['weekday'] = '  opaque-日?  ';
    row['lessons'] = '01,?~x';
    row['week'] = 'odd?/未核实';
    row['location'] = '';
    json['d']['weekdays'] = ['  opaque-日?  ', '', 'not-in-classes'];
    final data = decoder.decodeData(jsonEncode(json), httpStatus: 200);
    expect(data.classes.first.weekday, '  opaque-日?  ');
    expect(data.classes.first.lessons, '01,?~x');
    expect(data.classes.first.week, 'odd?/未核实');
    expect(data.classes.first.location, '');
    expect(data.weekdays, ['  opaque-日?  ', '', 'not-in-classes']);
  });

  test(
    'empty lists are valid and no sample count becomes a protocol limit',
    () {
      final empty = decoder.decodeData(
        scheduleFixture('empty_data'),
        httpStatus: 200,
      );
      expect(empty.classes, isEmpty);
      expect(empty.weekdays, isEmpty);
      final json = dataJson();
      final row = json['d']['classes'][0];
      json['d']['classes'] = List.filled(80, row);
      json['d']['weekdays'] = List.generate(30, (index) => 'opaque-$index');
      final data = decoder.decodeData(jsonEncode(json), httpStatus: 200);
      expect(data.classes, hasLength(80));
      expect(data.weekdays, hasLength(30));
      // Repeated course IDs may represent multiple meetings; never deduplicate.
      expect(data.classes.last.courseId, data.classes.first.courseId);
    },
  );

  test('business success depends on numeric e, not localized m text', () {
    final json = dataJson();
    json['e'] = 0.0;
    json['m'] = 'fictional alternate success message';
    expect(
      decoder.decodeData(jsonEncode(json), httpStatus: 201).classes,
      hasLength(2),
    );
    expect(
      () => decoder.decodeData('', httpStatus: 204),
      throwsA(failure(ScheduleFailureKind.invalidData)),
    );
  });

  test('non-finite numeric values never become successful codes or weeks', () {
    expect(
      () => decoder.decodeData(
        '{"e":1e999,"m":"fictional","d":{}}',
        httpStatus: 200,
      ),
      throwsA(failure(ScheduleFailureKind.invalidData)),
    );
    final body = exampleIndex().replaceFirst('"week": 1', '"week": 1e999');
    expect(
      () => decoder.decodeIndex(body, httpStatus: 200),
      throwsA(failure(ScheduleFailureKind.invalidData)),
    );
  });

  for (final status in [199, 301, 401, 403, 429, 500]) {
    test('HTTP $status wins over a success body or malformed body', () {
      for (final body in [exampleData(), '<html>fictional error</html>']) {
        expect(
          () => decoder.decodeData(body, httpStatus: status),
          throwsA(
            failure(
              ScheduleFailureKind.transport,
            ).having((error) => error.httpStatus, 'httpStatus', status),
          ),
        );
        expect(
          () => decoder.decodeIndex(body, httpStatus: status),
          throwsA(failure(ScheduleFailureKind.transport)),
        );
      }
    });
  }

  test(
    'HTTP 200 does not imply business success; d may be absent on error',
    () {
      for (final body in [
        scheduleFixture('business_error'),
        jsonEncode({'e': 123, 'm': 'fictional error'}),
      ]) {
        for (final decode in [decoder.decodeData, decoder.decodeIndex]) {
          expect(
            () => decode(body, httpStatus: 200),
            throwsA(
              isA<ScheduleFailure>()
                  .having(
                    (error) => error.kind,
                    'kind',
                    ScheduleFailureKind.business,
                  )
                  .having((error) => error.businessCode, 'businessCode', 123),
            ),
          );
        }
      }
    },
  );

  for (final fixture in ['malformed', 'missing_fields', 'wrong_type']) {
    test('$fixture fixture produces a safe data failure', () {
      expect(
        () => decoder.decodeData(scheduleFixture(fixture), httpStatus: 200),
        throwsA(failure(ScheduleFailureKind.invalidData)),
      );
    });
  }

  test('invalid JSON roots and success envelope fields are rejected', () {
    for (final value in [
      null,
      [],
      'text',
      1,
      true,
      {},
      {'e': '0', 'm': 'ok', 'd': {}},
      {'e': false, 'm': 'ok', 'd': {}},
      {'e': null, 'm': 'ok', 'd': {}},
      {'e': 0, 'm': 1, 'd': {}},
      {'e': 0, 'd': {}},
      {'e': 0, 'm': 'ok'},
      {'e': 0, 'm': 'ok', 'd': []},
      {'e': 0, 'm': 'ok', 'd': null},
    ]) {
      for (final decode in [decoder.decodeData, decoder.decodeIndex]) {
        expect(
          () => decode(jsonEncode(value), httpStatus: 200),
          throwsA(failure(ScheduleFailureKind.invalidData)),
          reason: 'Invalid envelope must not become an empty success',
        );
      }
    }
  });

  test('missing or wrong list shapes never silently drop rows', () {
    for (final field in ['classes', 'weekdays']) {
      for (final value in [
        null,
        {},
        'text',
        1,
        [null],
        [false],
      ]) {
        final json = dataJson();
        json['d'][field] = value;
        expect(
          () => decoder.decodeData(jsonEncode(json), httpStatus: 200),
          throwsA(failure(ScheduleFailureKind.invalidData)),
        );
      }
      final json = dataJson();
      (json['d'] as Map<String, dynamic>).remove(field);
      expect(
        () => decoder.decodeData(jsonEncode(json), httpStatus: 200),
        throwsA(failure(ScheduleFailureKind.invalidData)),
      );
    }
  });

  for (final field in [
    'course_id',
    'course_name',
    'location',
    'weekday',
    'lessons',
    'teacher',
    'week',
  ]) {
    test('course $field must exist and remain a string', () {
      for (final value in [null, 1, true, [], {}]) {
        final json = dataJson();
        json['d']['classes'][0][field] = value;
        expect(
          () => decoder.decodeData(jsonEncode(json), httpStatus: 200),
          throwsA(failure(ScheduleFailureKind.invalidData)),
        );
      }
      final json = dataJson();
      (json['d']['classes'][0] as Map<String, dynamic>).remove(field);
      expect(
        () => decoder.decodeData(jsonEncode(json), httpStatus: 200),
        throwsA(failure(ScheduleFailureKind.invalidData)),
      );
    });
  }

  for (final field in ['id', 'year', 'term', 'startday', 'countweek', 'week']) {
    for (final container in ['params', 'termInfo']) {
      test('index $container.$field is required with its observed type', () {
        final badValues = field == 'week'
            ? <Object?>[null, '1', false, [], {}]
            : <Object?>[null, 1, false, [], {}];
        for (final value in badValues) {
          final json = indexJson();
          final row = container == 'params'
              ? json['d']['params']
              : json['d']['termInfo'][0];
          row[field] = value;
          expect(
            () => decoder.decodeIndex(jsonEncode(json), httpStatus: 200),
            throwsA(failure(ScheduleFailureKind.invalidData)),
          );
        }
        final json = indexJson();
        final row = container == 'params'
            ? json['d']['params']
            : json['d']['termInfo'][0];
        (row as Map<String, dynamic>).remove(field);
        expect(
          () => decoder.decodeIndex(jsonEncode(json), httpStatus: 200),
          throwsA(failure(ScheduleFailureKind.invalidData)),
        );
      });
    }
  }

  test('index container and weekday shapes are checked', () {
    for (final field in ['params', 'termInfo', 'weekday']) {
      final json = indexJson();
      (json['d'] as Map<String, dynamic>).remove(field);
      expect(
        () => decoder.decodeIndex(jsonEncode(json), httpStatus: 200),
        throwsA(failure(ScheduleFailureKind.invalidData)),
      );
    }
    for (final entry in [
      MapEntry('params', []),
      MapEntry('params', 'text'),
      MapEntry('termInfo', {}),
      MapEntry('termInfo', [1]),
      MapEntry('weekday', 1),
    ]) {
      final json = indexJson();
      json['d'][entry.key] = entry.value;
      expect(
        () => decoder.decodeIndex(jsonEncode(json), httpStatus: 200),
        throwsA(failure(ScheduleFailureKind.invalidData)),
      );
    }
  });

  test('unknown fields, numeric week and empty termInfo remain compatible', () {
    final json = indexJson();
    json['extra'] = 'ignored';
    json['d']['extra'] = {'future': true};
    json['d']['params']['week'] = 1.5;
    json['d']['termInfo'] = [];
    json['d']['weekday'] = '  opaque  ';
    final index = decoder.decodeIndex(jsonEncode(json), httpStatus: 200);
    expect(index.params.week, 1.5);
    expect(index.termInfo, isEmpty);
    expect(index.weekday, '  opaque  ');
    final data = dataJson();
    data['d']['classes'][0]['future'] = {'not': 'a course field'};
    expect(
      decoder.decodeData(jsonEncode(data), httpStatus: 200).classes,
      hasLength(2),
    );
  });

  test('malformed payload contents never appear in error text', () {
    const marker = 'fictional-private-marker';
    for (final body in ['{"$marker":', '{"e":1,"m":"$marker"}']) {
      try {
        decoder.decodeData(body, httpStatus: 200);
        fail('Expected a failure');
      } on ScheduleFailure catch (error) {
        expect(error.toString(), isNot(contains(marker)));
      }
    }
  });
}
