import 'dart:io';

import 'package:bjut_campus/features/schedule/data/local_schedule_data_source.dart';
import 'package:bjut_campus/features/schedule/data/schedule_response_decoder.dart';

String scheduleFixture(String name) =>
    File('test/fixtures/schedule/$name.json').readAsStringSync();

String exampleData() => File(
  LocalScheduleDataSource.dataAsset,
).readAsStringSync();

String exampleIndex() => File(
  LocalScheduleDataSource.indexAsset,
).readAsStringSync();

SchedulePayload examplePayload({String? data}) {
  const decoder = ScheduleResponseDecoder();
  return SchedulePayload(
    index: decoder.decodeIndex(exampleIndex(), httpStatus: 200),
    data: decoder.decodeData(data ?? exampleData(), httpStatus: 200),
  );
}

class CallbackScheduleDataSource implements ScheduleDataSource {
  CallbackScheduleDataSource(this.callback);

  final Future<SchedulePayload> Function() callback;
  int calls = 0;

  @override
  Future<SchedulePayload> load() {
    calls++;
    return callback();
  }
}
