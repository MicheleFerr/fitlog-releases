/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation/providers
/// 🎯 Feature: home
/// 🔧 Type: provider
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// Provider for HomeViewModel using HomeViewModelImpl.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/home/domain/viewmodels/home_viewmodel.dart';
import 'package:gymbro_flutter_new/features/home/data/viewmodels/home_viewmodel_impl.dart';

final homeViewModelProvider = Provider<HomeViewModel>((ref) {
  return HomeViewModelImpl(ref);
});
