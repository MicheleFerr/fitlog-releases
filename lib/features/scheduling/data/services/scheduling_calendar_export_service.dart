import 'dart:io';

import 'package:gymbro_flutter_new/features/scheduling/domain/entities/scheduled_workout.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

typedef TemporaryDirectoryProvider = Future<Directory> Function();
typedef CalendarShareHandler = Future<ShareResult> Function(ShareParams params);
typedef CurrentDateTimeProvider = DateTime Function();

/// Exports scheduled workouts as a shareable ICS calendar file.
class SchedulingCalendarExportService {
  SchedulingCalendarExportService({
    TemporaryDirectoryProvider? temporaryDirectoryProvider,
    CalendarShareHandler? shareHandler,
    CurrentDateTimeProvider? now,
  }) : _temporaryDirectoryProvider =
           temporaryDirectoryProvider ?? getTemporaryDirectory,
       _shareHandler =
           shareHandler ?? ((params) => SharePlus.instance.share(params)),
       _now = now ?? DateTime.now;

  static const Duration _defaultWorkoutDuration = Duration(hours: 1);
  static const Duration _defaultAlarmOffset = Duration(minutes: 15);

  final TemporaryDirectoryProvider _temporaryDirectoryProvider;
  final CalendarShareHandler _shareHandler;
  final CurrentDateTimeProvider _now;

  Future<File> createCalendarFile({
    required List<ScheduledWorkout> workouts,
    required String templateName,
  }) async {
    if (workouts.isEmpty) {
      throw StateError('No workouts to export');
    }

    final directory = await _temporaryDirectoryProvider();
    final timestamp = _now().millisecondsSinceEpoch;
    final sanitizedName = _sanitizeFileSegment(templateName);
    final file = File(
      '${directory.path}/fitlog_schedule_${sanitizedName}_$timestamp.ics',
    );

    await file.writeAsString(
      buildCalendarContent(workouts: workouts),
      flush: true,
    );

    return file;
  }

  Future<ShareResult> shareCalendarFile({
    required List<ScheduledWorkout> workouts,
    required String templateName,
  }) async {
    final file = await createCalendarFile(
      workouts: workouts,
      templateName: templateName,
    );

    return _shareHandler(
      ShareParams(files: [XFile(file.path)], subject: templateName),
    );
  }

  String buildCalendarContent({required List<ScheduledWorkout> workouts}) {
    final sortedWorkouts = List<ScheduledWorkout>.from(workouts)
      ..sort((a, b) => a.reminderDateTime.compareTo(b.reminderDateTime));
    final dtStamp = _formatUtc(_now().toUtc());
    final buffer = StringBuffer()
      ..writeln('BEGIN:VCALENDAR')
      ..writeln('VERSION:2.0')
      ..writeln('PRODID:-//FitLog Pro//Workout Schedule//EN')
      ..writeln('CALSCALE:GREGORIAN')
      ..writeln('METHOD:PUBLISH');

    for (final workout in sortedWorkouts) {
      final start = workout.reminderDateTime.toUtc();
      final end = start.add(_defaultWorkoutDuration);

      buffer
        ..writeln('BEGIN:VEVENT')
        ..writeln('UID:${workout.id}@fitlogpro.local')
        ..writeln('DTSTAMP:$dtStamp')
        ..writeln('DTSTART:${_formatUtc(start)}')
        ..writeln('DTEND:${_formatUtc(end)}')
        ..writeln('SUMMARY:${_escapeText(workout.templateName)}')
        ..writeln('DESCRIPTION:${_escapeText('Scheduled with FitLog Pro')}')
        ..writeln('BEGIN:VALARM')
        ..writeln('ACTION:DISPLAY')
        ..writeln('DESCRIPTION:${_escapeText('Workout reminder')}')
        ..writeln('TRIGGER:-PT${_defaultAlarmOffset.inMinutes}M')
        ..writeln('END:VALARM')
        ..writeln('END:VEVENT');
    }

    buffer.writeln('END:VCALENDAR');
    return buffer.toString();
  }

  String _formatUtc(DateTime dateTime) {
    final utc = dateTime.toUtc();
    final year = utc.year.toString().padLeft(4, '0');
    final month = utc.month.toString().padLeft(2, '0');
    final day = utc.day.toString().padLeft(2, '0');
    final hour = utc.hour.toString().padLeft(2, '0');
    final minute = utc.minute.toString().padLeft(2, '0');
    final second = utc.second.toString().padLeft(2, '0');
    return '$year$month$day'
        'T'
        '$hour$minute$second'
        'Z';
  }

  String _escapeText(String value) {
    return value
        .replaceAll(r'\', r'\\')
        .replaceAll(';', r'\;')
        .replaceAll(',', r'\,')
        .replaceAll('\n', r'\n');
  }

  String _sanitizeFileSegment(String value) {
    final sanitized = value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');

    return sanitized.isEmpty ? 'workout' : sanitized;
  }
}
