/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/widgets
/// 🎯 Feature: analytics
/// 🔧 Type: widget
///
/// Wrapper per caricare charts in modo lazy con skeleton loader
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/skeleton_loader.dart';

/// Wrapper per lazy loading di charts con skeleton
///
/// Usa `Future.delayed` per simulare il caricamento asincrono
/// e mostra uno skeleton loader durante l'attesa
class LazyChartWrapper extends StatefulWidget {

  const LazyChartWrapper({
    super.key,
    required this.child,
    this.skeletonHeight = 200,
    this.showLegend = false,
    this.delayMs = 300,
  });
  /// Widget chart da mostrare dopo il caricamento
  final Widget child;

  /// Altezza dello skeleton loader
  final double skeletonHeight;

  /// Se mostrare la legenda nello skeleton
  final bool showLegend;

  /// Delay artificiale per dare tempo al rendering (ms)
  final int delayMs;

  @override
  State<LazyChartWrapper> createState() => _LazyChartWrapperState();
}

class _LazyChartWrapperState extends State<LazyChartWrapper> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChart();
  }

  Future<void> _loadChart() async {
    // Delay per dare tempo al frame di renderizzare
    await Future.delayed(Duration(milliseconds: widget.delayMs));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return ChartSkeleton(
        height: widget.skeletonHeight,
        showLegend: widget.showLegend,
      );
    }

    return widget.child;
  }
}

/// Wrapper per lazy loading di liste con skeleton
class LazyListWrapper extends StatefulWidget {

  const LazyListWrapper({
    super.key,
    required this.child,
    this.skeletonItemCount = 3,
    this.delayMs = 200,
  });
  /// Widget lista da mostrare dopo il caricamento
  final Widget child;

  /// Numero di item skeleton da mostrare
  final int skeletonItemCount;

  /// Delay artificiale per dare tempo al rendering (ms)
  final int delayMs;

  @override
  State<LazyListWrapper> createState() => _LazyListWrapperState();
}

class _LazyListWrapperState extends State<LazyListWrapper> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadList();
  }

  Future<void> _loadList() async {
    await Future.delayed(Duration(milliseconds: widget.delayMs));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return WorkoutListSkeleton(
        itemCount: widget.skeletonItemCount,
      );
    }

    return widget.child;
  }
}

/// Wrapper per lazy loading di muscle balance chart
class LazyMuscleChartWrapper extends StatefulWidget {

  const LazyMuscleChartWrapper({
    super.key,
    required this.child,
    this.delayMs = 400,
  });
  /// Widget chart da mostrare dopo il caricamento
  final Widget child;

  /// Delay artificiale per dare tempo al rendering (ms)
  final int delayMs;

  @override
  State<LazyMuscleChartWrapper> createState() => _LazyMuscleChartWrapperState();
}

class _LazyMuscleChartWrapperState extends State<LazyMuscleChartWrapper> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChart();
  }

  Future<void> _loadChart() async {
    await Future.delayed(Duration(milliseconds: widget.delayMs));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MuscleBalanceSkeleton();
    }

    return widget.child;
  }
}
