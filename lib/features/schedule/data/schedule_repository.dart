import '../domain/schedule.dart';
import 'local_schedule_data_source.dart';
import 'schedule_response_decoder.dart';

class ScheduleRepository {
  ScheduleRepository({ScheduleDataSource? dataSource})
    : _dataSource = dataSource ?? LocalScheduleDataSource();

  final ScheduleDataSource _dataSource;

  Future<Schedule> getSchedule() async {
    final payload = await _dataSource.load();
    return Schedule(
      currentTerm: _term(payload.index.params),
      currentWeekdayCode: payload.index.weekday,
      terms: payload.index.termInfo.map(_term).toList(growable: false),
      weekdayCodes: payload.data.weekdays,
      courses: payload.data.classes
          .map(
            (row) => ScheduleCourse(
              id: row.courseId,
              name: row.courseName,
              location: row.location,
              teacher: row.teacher,
              weekdayCode: row.weekday,
              lessonCode: row.lessons,
              weekCode: row.week,
            ),
          )
          .toList(growable: false),
    );
  }

  ScheduleTerm _term(ScheduleTermDto row) => ScheduleTerm(
    id: row.id,
    year: row.year,
    term: row.term,
    startDay: row.startday,
    weekCountCode: row.countweek,
    week: row.week,
  );
}
