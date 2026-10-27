import 'dart:convert';

import '../domain/schedule.dart';

/// Candidate wire contract from historical evidence, not a live API client.
class ScheduleResponseDecoder {
  const ScheduleResponseDecoder();

  ScheduleDataDto decodeData(String body, {required int httpStatus}) {
    final data = _envelope(body, httpStatus);
    return ScheduleDataDto(
      classes: _list(data['classes']).map((value) {
        final row = _object(value);
        return ScheduleCourseDto(
          courseId: _string(row['course_id']),
          courseName: _string(row['course_name']),
          location: _string(row['location']),
          weekday: _string(row['weekday']),
          lessons: _string(row['lessons']),
          teacher: _string(row['teacher']),
          week: _string(row['week']),
        );
      }).toList(growable: false),
      weekdays: _list(data['weekdays']).map(_string).toList(growable: false),
    );
  }

  ScheduleIndexDto decodeIndex(String body, {required int httpStatus}) {
    final data = _envelope(body, httpStatus);
    return ScheduleIndexDto(
      params: _term(data['params']),
      termInfo: _list(data['termInfo']).map(_term).toList(growable: false),
      weekday: _string(data['weekday']),
    );
  }

  Map<String, dynamic> _envelope(String body, int httpStatus) {
    // HTTP success and business success are independent. Never parse a failed
    // transport's HTML/error body as a successful timetable response.
    if (httpStatus < 200 || httpStatus >= 300) {
      throw ScheduleFailure(
        ScheduleFailureKind.transport,
        httpStatus: httpStatus,
      );
    }
    final Object? decoded;
    try {
      decoded = jsonDecode(body);
    } on FormatException {
      throw const ScheduleFailure(ScheduleFailureKind.invalidData);
    }
    final envelope = _object(decoded);
    final code = _number(envelope['e']);
    _string(envelope['m']);
    if (code != 0) {
      // Error envelopes need not contain a successful d object. No unverified
      // business code is interpreted as session expiry or a login instruction.
      throw ScheduleFailure(ScheduleFailureKind.business, businessCode: code);
    }
    return _object(envelope['d']);
  }

  ScheduleTermDto _term(Object? value) {
    final row = _object(value);
    return ScheduleTermDto(
      id: _string(row['id']),
      year: _string(row['year']),
      term: _string(row['term']),
      startday: _string(row['startday']),
      countweek: _string(row['countweek']),
      week: _number(row['week']),
    );
  }

  static Map<String, dynamic> _object(Object? value) {
    if (value is! Map<String, dynamic>) {
      throw const ScheduleFailure(ScheduleFailureKind.invalidData);
    }
    return value;
  }

  static List<dynamic> _list(Object? value) {
    if (value is! List) {
      throw const ScheduleFailure(ScheduleFailureKind.invalidData);
    }
    return value;
  }

  static String _string(Object? value) {
    if (value is! String) {
      throw const ScheduleFailure(ScheduleFailureKind.invalidData);
    }
    // Do not trim, split, coerce or guess the meaning of protocol strings.
    return value;
  }

  static num _number(Object? value) {
    if (value is! num || !value.isFinite) {
      throw const ScheduleFailure(ScheduleFailureKind.invalidData);
    }
    return value;
  }
}

class SchedulePayload {
  const SchedulePayload({required this.index, required this.data});

  final ScheduleIndexDto index;
  final ScheduleDataDto data;
}

class ScheduleDataDto {
  const ScheduleDataDto({required this.classes, required this.weekdays});

  final List<ScheduleCourseDto> classes;
  final List<String> weekdays;
}

class ScheduleIndexDto {
  const ScheduleIndexDto({
    required this.params,
    required this.termInfo,
    required this.weekday,
  });

  final ScheduleTermDto params;
  final List<ScheduleTermDto> termInfo;
  final String weekday;
}

class ScheduleTermDto {
  const ScheduleTermDto({
    required this.id,
    required this.year,
    required this.term,
    required this.startday,
    required this.countweek,
    required this.week,
  });

  final String id;
  final String year;
  final String term;
  final String startday;
  final String countweek;
  final num week;
}

class ScheduleCourseDto {
  const ScheduleCourseDto({
    required this.courseId,
    required this.courseName,
    required this.location,
    required this.weekday,
    required this.lessons,
    required this.teacher,
    required this.week,
  });

  final String courseId;
  final String courseName;
  final String location;
  final String weekday;
  final String lessons;
  final String teacher;
  final String week;
}
