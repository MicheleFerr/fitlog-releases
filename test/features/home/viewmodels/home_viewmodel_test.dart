import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/home/domain/viewmodels/home_viewmodel.dart';

void main() {
  test('HomeViewModel provides all required data streams', () {
    final container = ProviderContainer();
    final viewModel = container.read(homeViewModelProvider);

    expect(viewModel.greeting, isNotNull);
    expect(viewModel.workoutBanner, isNotNull);
    expect(viewModel.aiCoachData, isNotNull);
    expect(viewModel.streakData, isNotNull);
  });
}
