
import 'package:freezed_annotation/freezed_annotation.dart';

part 'routine.freezed.dart';
part 'routine.g.dart';

@freezed
class Routine with _$Routine {
  const factory Routine({
    /// The key is the day of the week (1 = Monday, 7 = Sunday).
    /// The value is the ID of the workout template.
    required Map<int, String> schedule,
  }) = _Routine;

  factory Routine.fromJson(Map<String, dynamic> json) => _$RoutineFromJson(json);
}
