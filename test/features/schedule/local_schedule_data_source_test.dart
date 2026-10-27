import 'dart:convert';

import 'package:bjut_campus/features/schedule/data/local_schedule_data_source.dart';
import 'package:bjut_campus/features/schedule/domain/schedule.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'schedule_test_support.dart';

class _MemoryBundle extends CachingAssetBundle {
  _MemoryBundle(this.files);

  final Map<String, String> files;

  @override
  Future<ByteData> load(String key) async {
    final value = files[key];
    if (value == null) {
      throw FlutterError('fictional asset failure marker');
    }
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(value)));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'actual packaged schedule assets are registered and decode',
    () async {
      // Run real platform I/O outside testWidgets' virtual clock, with a fresh
      // bundle so no Future cached in another test zone is reused.
      final payload = await LocalScheduleDataSource(
        bundle: PlatformAssetBundle(),
      ).load();
      expect(payload.data.classes, hasLength(2));
      expect(payload.index.params.id, 'fictional-term-a');
    },
    timeout: const Timeout(Duration(seconds: 30)),
  );

  test(
    'source loads both bundled synthetic responses through the decoder',
    () async {
      final bundle = _MemoryBundle({
        LocalScheduleDataSource.indexAsset: exampleIndex(),
        LocalScheduleDataSource.dataAsset: exampleData(),
      });
      final payload = await LocalScheduleDataSource(bundle: bundle).load();
      expect(payload.index.params.id, 'fictional-term-a');
      expect(payload.data.classes.first.courseId, 'fictional-course-a');
    },
  );

  test('missing assets become a safe source failure', () async {
    await expectLater(
      LocalScheduleDataSource(bundle: _MemoryBundle({})).load(),
      throwsA(
        isA<ScheduleFailure>().having(
          (error) => error.kind,
          'kind',
          ScheduleFailureKind.sourceUnavailable,
        ),
      ),
    );
  });

  test(
    'broken asset JSON does not become a successful empty schedule',
    () async {
      final bundle = _MemoryBundle({
        LocalScheduleDataSource.indexAsset: exampleIndex(),
        LocalScheduleDataSource.dataAsset: scheduleFixture('malformed'),
      });
      await expectLater(
        LocalScheduleDataSource(bundle: bundle).load(),
        throwsA(
          isA<ScheduleFailure>().having(
            (error) => error.kind,
            'kind',
            ScheduleFailureKind.invalidData,
          ),
        ),
      );
    },
  );
}
