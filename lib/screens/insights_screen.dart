import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';
import '../models/study_task.dart';

class InsightsScreen extends StatelessWidget {
  final List<StudyTask> tasks;

  const InsightsScreen({super.key, required this.tasks});

  DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime get _weekStart {
    final today = _dayOnly(DateTime.now());
    return DateTime(today.year, today.month, today.day - (today.weekday - 1));
  }

  List<int> get _dailyCounts {
    final start = _weekStart;
    return List.generate(7, (i) {
      final day = DateTime(start.year, start.month, start.day + i);
      return tasks
          .where(
            (t) => t.completedAt != null && _dayOnly(t.completedAt!) == day,
          )
          .length;
    });
  }

  int get _lastWeekCount {
    final start = _weekStart;
    final prevStart = DateTime(start.year, start.month, start.day - 7);
    return tasks.where((t) {
      if (t.completedAt == null) return false;
      final d = _dayOnly(t.completedAt!);
      return !d.isBefore(prevStart) && d.isBefore(start);
    }).length;
  }

  int get _streak {
    final days = tasks
        .where((t) => t.completedAt != null)
        .map((t) => _dayOnly(t.completedAt!))
        .toSet();

    var day = _dayOnly(DateTime.now());
    if (!days.contains(day)) {
      day = DateTime(day.year, day.month, day.day - 1);
    }

    int streak = 0;
    while (days.contains(day)) {
      streak++;
      day = DateTime(day.year, day.month, day.day - 1);
    }
    return streak;
  }

  Map<String, List<int>> get _bySubject {
    final map = <String, List<int>>{};
    for (final t in tasks) {
      map.putIfAbsent(t.subject, () => [0, 0]);
      map[t.subject]![1]++;
      if (t.isCompleted) map[t.subject]![0]++;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final daily = _dailyCounts;
    final weekTotal = daily.fold<int>(0, (sum, c) => sum + c);
    final diff = weekTotal - _lastWeekCount;
    final maxCount = daily.reduce((a, b) => a > b ? a : b);
    final todayIndex = DateTime.now().weekday - 1;
    const dayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final subjects = _bySubject;
    final streak = _streak;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Text('This week', style: AppTheme.serif(32)),
            const SizedBox(height: 10),

            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('$weekTotal', style: AppTheme.serif(46)),
                const SizedBox(width: 8),
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    'tasks completed',
                    style: TextStyle(color: AppColors.muted),
                  ),
                ),
                const Spacer(),
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: diff >= 0
                        ? const Color(0xFFDFE8DA)
                        : const Color(0xFFF3DDD5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    diff == 0
                        ? 'Same as last week'
                        : '${diff > 0 ? '+' : ''}$diff vs last week',
                    style: TextStyle(
                      fontSize: 12,
                      color: diff >= 0 ? AppColors.forest : AppColors.clay,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            Container(
              padding: const EdgeInsets.fromLTRB(14, 18, 14, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.hairline, width: 0.8),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 125,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(7, (i) {
                        final count = daily[i];
                        final height = maxCount == 0
                            ? 6.0
                            : 6.0 + (count / maxCount) * 90;
                        final isToday = i == todayIndex;
                        return Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (count > 0)
                                Text(
                                  '$count',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.muted,
                                  ),
                                ),
                              const SizedBox(height: 3),
                              Container(
                                height: height,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: count == 0
                                      ? AppColors.sand
                                      : isToday
                                      ? AppColors.clay
                                      : const Color(0xFFCDD8C7),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(7, (i) {
                      return Expanded(
                        child: Text(
                          dayLetters[i],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: i == todayIndex
                                ? FontWeight.w700
                                : FontWeight.normal,
                            color: i == todayIndex
                                ? AppColors.charcoal
                                : AppColors.muted,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'By subject',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (subjects.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Add some tasks to see your progress here.',
                  style: TextStyle(color: AppColors.muted),
                ),
              )
            else
              ...subjects.entries.map((entry) {
                final done = entry.value[0];
                final total = entry.value[1];
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppColors.hairline, width: 0.8),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(entry.key, style: const TextStyle(fontSize: 15)),
                          const Spacer(),
                          Text(
                            '$done / $total',
                            style: const TextStyle(color: AppColors.muted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: total == 0 ? 0 : done / total,
                        minHeight: 4,
                        backgroundColor: AppColors.sand,
                        color: AppColors.forest,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ],
                  ),
                );
              }),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.sand,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    size: 30,
                    color: AppColors.clay,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          streak == 0 ? 'No streak yet' : '$streak day streak',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          streak == 0
                              ? 'Complete a task today to start one'
                              : 'Keep it going, one task a day',
                          style: const TextStyle(color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
