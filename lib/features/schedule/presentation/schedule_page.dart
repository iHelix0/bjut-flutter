import 'package:flutter/material.dart';

import '../data/schedule_repository.dart';
import '../domain/schedule.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key, this.repository});

  final ScheduleRepository? repository;

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  late ScheduleRepository _repository;
  late Future<Schedule> _schedule;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? ScheduleRepository();
    _schedule = _repository.getSchedule();
  }

  @override
  void didUpdateWidget(covariant SchedulePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository) {
      _repository = widget.repository ?? ScheduleRepository();
      _schedule = _repository.getSchedule();
    }
  }

  Future<void> _reload() async {
    final next = _repository.getSchedule();
    setState(() => _schedule = next);
    try {
      await next;
    } catch (_) {
      // FutureBuilder owns the failure state; do not leak an unhandled refresh
      // error or display underlying response/asset contents to the user.
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _reload,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          Text(
            '课表离线示例',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '完全虚构 · 未登录 · 未同步\n'
                '仅用于预览。星期、节次与周次展示原值，编码含义待核实。',
              ),
            ),
          ),
          const SizedBox(height: 12),
          FutureBuilder<Schedule>(
            future: _schedule,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('示例暂时无法加载'),
                    const Text('本地示例数据不可用，请重试。'),
                    const SizedBox(height: 8),
                    FilledButton.tonal(
                      onPressed: _reload,
                      child: const Text('重试示例'),
                    ),
                  ],
                );
              }
              final schedule = snapshot.data;
              if (schedule == null || schedule.courses.isEmpty) {
                return const Text('示例中暂无课程');
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '${schedule.currentTerm.year} / '
                    '${schedule.currentTerm.term}',
                  ),
                  const SizedBox(height: 12),
                  for (final course in schedule.courses)
                    _CourseCard(course: course),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _reload,
                    icon: const Icon(Icons.refresh),
                    label: const Text('重新加载本地示例'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course});

  final ScheduleCourse course;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              course.name.isEmpty ? '未提供课程名' : course.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('地点：${course.location}'),
            Text('教师：${course.teacher}'),
            Text('星期（原值）：${course.weekdayCode}'),
            Text('节次（原值）：${course.lessonCode}'),
            Text('周次（原值）：${course.weekCode}'),
          ],
        ),
      ),
    );
  }
}
