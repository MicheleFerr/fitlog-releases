import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/home/presentation/providers/home_viewmodel_provider.dart';

void main() {
  test('HomeViewModelImpl loads data within 3 seconds', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final viewModel = container.read(homeViewModelProvider);

    final stopwatch = Stopwatch()..start();
    await viewModel.loadInitialData();
    stopwatch.stop();

    expect(stopwatch.elapsed.inSeconds, lessThan(3));
  });
}
