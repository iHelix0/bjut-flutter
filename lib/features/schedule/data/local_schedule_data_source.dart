import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../domain/schedule.dart';
import 'schedule_response_decoder.dart';

abstract class ScheduleDataSource {
  Future<SchedulePayload> load();
}

/// Bundled, entirely fictional examples. No HTTP, account or persistent cache.
class LocalScheduleDataSource implements ScheduleDataSource {
  LocalScheduleDataSource({AssetBundle? bundle})
    : _bundle = bundle ?? rootBundle;

  static const indexAsset = 'assets/content/schedule/example_index.json';
  static const dataAsset = 'assets/content/schedule/example_data.json';
  final AssetBundle _bundle;

  @override
  Future<SchedulePayload> load() async {
    final List<String> raw;
    try {
      raw = await Future.wait([
        _bundle.loadString(indexAsset),
        _bundle.loadString(dataAsset),
      ]);
    } on FlutterError {
      throw const ScheduleFailure(ScheduleFailureKind.sourceUnavailable);
    } on FormatException {
      throw const ScheduleFailure(ScheduleFailureKind.invalidData);
    }
    const decoder = ScheduleResponseDecoder();
    // 200 describes only this synthetic response fixture, never a real request.
    return SchedulePayload(
      index: decoder.decodeIndex(raw[0], httpStatus: 200),
      data: decoder.decodeData(raw[1], httpStatus: 200),
    );
  }
}
