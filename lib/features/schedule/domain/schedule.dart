/// Display values only. Unverified weekday/lesson/week codes stay opaque.
class Schedule {
  Schedule({
    required this.currentTerm,
    required this.currentWeekdayCode,
    required List<ScheduleTerm> terms,
    required List<String> weekdayCodes,
    required List<ScheduleCourse> courses,
  }) : terms = List.unmodifiable(terms),
       weekdayCodes = List.unmodifiable(weekdayCodes),
       courses = List.unmodifiable(courses);

  final ScheduleTerm currentTerm;
  final String currentWeekdayCode;
  final List<ScheduleTerm> terms;
  final List<String> weekdayCodes;
  final List<ScheduleCourse> courses;
}

class ScheduleTerm {
  const ScheduleTerm({
    required this.id,
    required this.year,
    required this.term,
    required this.startDay,
    required this.weekCountCode,
    required this.week,
  });

  final String id;
  final String year;
  final String term;
  final String startDay;
  final String weekCountCode;
  final num week;
}

class ScheduleCourse {
  const ScheduleCourse({
    required this.id,
    required this.name,
    required this.location,
    required this.teacher,
    required this.weekdayCode,
    required this.lessonCode,
    required this.weekCode,
  });

  final String id;
  final String name;
  final String location;
  final String teacher;
  final String weekdayCode;
  final String lessonCode;
  final String weekCode;
}

enum ScheduleFailureKind { transport, business, invalidData, sourceUnavailable }

/// Never includes a response body, server message, credential or asset error.
class ScheduleFailure implements Exception {
  const ScheduleFailure(this.kind, {this.httpStatus, this.businessCode});

  final ScheduleFailureKind kind;
  final int? httpStatus;
  final num? businessCode;

  @override
  String toString() => 'ScheduleFailure(${kind.name})';
}
