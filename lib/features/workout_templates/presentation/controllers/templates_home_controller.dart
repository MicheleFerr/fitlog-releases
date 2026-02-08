/// Controller for TemplatesHomeScreen state management
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'templates_home_controller.freezed.dart';
part 'templates_home_controller.g.dart';

@freezed
abstract class TemplatesHomeState with _$TemplatesHomeState {
  const factory TemplatesHomeState({
    @Default(true) bool isGridView,
    @Default(false) bool isMetricsMinimized,
    @Default(false) bool isSaving,
    @Default(false) bool isSupersetsExpanded,
    @Default(false) bool isDropsetsExpanded,
    @Default(false) bool isRestPauseExpanded,
    @Default(null) String? selectedCategory,
    @Default(0) int discoverSubTabIndex,
  }) = _TemplatesHomeState;
}

@riverpod
class TemplatesHomeController extends _$TemplatesHomeController {
  @override
  TemplatesHomeState build() => const TemplatesHomeState();

  void toggleGridView() {
    state = state.copyWith(isGridView: !state.isGridView);
  }

  void setMetricsMinimized(bool minimized) {
    state = state.copyWith(isMetricsMinimized: minimized);
  }

  void setSaving(bool saving) {
    state = state.copyWith(isSaving: saving);
  }

  void toggleSupersetsExpanded() {
    state = state.copyWith(isSupersetsExpanded: !state.isSupersetsExpanded);
  }

  void toggleDropsetsExpanded() {
    state = state.copyWith(isDropsetsExpanded: !state.isDropsetsExpanded);
  }

  void toggleRestPauseExpanded() {
    state = state.copyWith(isRestPauseExpanded: !state.isRestPauseExpanded);
  }

  void setSelectedCategory(String? category) {
    state = state.copyWith(selectedCategory: category);
  }

  void setDiscoverSubTabIndex(int index) {
    state = state.copyWith(discoverSubTabIndex: index);
  }
}
