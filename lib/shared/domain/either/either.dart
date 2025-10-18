/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: shared/domain
/// 🎯 Feature: functional_programming
/// 🔧 Type: either
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
/// 
/// Dependencies:
/// - None (pure domain)
library;

import 'package:equatable/equatable.dart';

/// Functional programming Either type for error handling
/// Left = Failure, Right = Success
abstract class Either<L, R> extends Equatable {
  const Either();
  
  /// Transform the right value
  Either<L, T> map<T>(T Function(R) mapper);
  
  /// Transform the left value  
  Either<T, R> mapLeft<T>(T Function(L) mapper);
  
  /// Chain operations that return Either
  Either<L, T> flatMap<T>(Either<L, T> Function(R) mapper);
  
  /// Fold both sides into a single value
  T fold<T>(T Function(L) onLeft, T Function(R) onRight);
  
  /// Get right value or throw
  R getOrThrow();
  
  /// Get right value or return default
  R getOrElse(R Function() defaultValue);
  
  /// Check if this is a success (Right)
  bool get isRight;
  
  /// Check if this is a failure (Left)  
  bool get isLeft;
  
  /// Get the right value if present
  R? get rightOrNull;
  
  /// Get the left value if present
  L? get leftOrNull;
}

class Left<L, R> extends Either<L, R> {
  
  const Left(this.value);
  final L value;
  
  @override
  Either<L, T> map<T>(T Function(R) mapper) => Left(value);
  
  @override
  Either<T, R> mapLeft<T>(T Function(L) mapper) => Left(mapper(value));
  
  @override
  Either<L, T> flatMap<T>(Either<L, T> Function(R) mapper) => Left(value);
  
  @override
  T fold<T>(T Function(L) onLeft, T Function(R) onRight) => onLeft(value);
  
  @override
  R getOrThrow() => throw Exception('Called getOrThrow on Left($value)');
  
  @override
  R getOrElse(R Function() defaultValue) => defaultValue();
  
  @override
  bool get isRight => false;
  
  @override
  bool get isLeft => true;
  
  @override
  R? get rightOrNull => null;
  
  @override
  L? get leftOrNull => value;
  
  @override
  List<Object?> get props => [value];
  
  @override
  String toString() => 'Left($value)';
}

class Right<L, R> extends Either<L, R> {
  
  const Right(this.value);
  final R value;
  
  @override
  Either<L, T> map<T>(T Function(R) mapper) => Right(mapper(value));
  
  @override
  Either<T, R> mapLeft<T>(T Function(L) mapper) => Right(value);
  
  @override
  Either<L, T> flatMap<T>(Either<L, T> Function(R) mapper) => mapper(value);
  
  @override
  T fold<T>(T Function(L) onLeft, T Function(R) onRight) => onRight(value);
  
  @override
  R getOrThrow() => value;
  
  @override
  R getOrElse(R Function() defaultValue) => value;
  
  @override
  bool get isRight => true;
  
  @override
  bool get isLeft => false;
  
  @override
  R? get rightOrNull => value;
  
  @override
  L? get leftOrNull => null;
  
  @override
  List<Object?> get props => [value];
  
  @override
  String toString() => 'Right($value)';
}

/// Helper functions for creating Either instances
Either<L, R> left<L, R>(L value) => Left<L, R>(value);
Either<L, R> right<L, R>(R value) => Right<L, R>(value);

/// Extension for easier async Either operations
extension EitherAsync<L, R> on Future<Either<L, R>> {
  Future<Either<L, T>> mapAsync<T>(Future<T> Function(R) mapper) async {
    final result = await this;
    if (result.isLeft) return Left(result.leftOrNull as L);
    return Right(await mapper(result.rightOrNull as R));
  }
  
  Future<Either<L, T>> flatMapAsync<T>(Future<Either<L, T>> Function(R) mapper) async {
    final result = await this;
    if (result.isLeft) return Left(result.leftOrNull as L);
    return await mapper(result.rightOrNull as R);
  }
}