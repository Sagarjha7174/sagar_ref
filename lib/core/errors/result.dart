import 'failures.dart';

sealed class Result<T> {
  const Result._();

  factory Result.success(T data) = Success<T>;
  factory Result.failure(AppFailure failure) = Failure<T>;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T get data => (this as Success<T>).value;
  AppFailure get error => (this as Failure<T>).failure;

  R when<R>({
    required R Function(T data) success,
    required R Function(AppFailure failure) failure,
  }) {
    return switch (this) {
      Success<T>(value: final v) => success(v),
      Failure<T>(failure: final f) => failure(f),
    };
  }

  Result<R> map<R>(R Function(T data) transform) {
    return switch (this) {
      Success<T>(value: final v) => Result.success(transform(v)),
      Failure<T>(failure: final f) => Result.failure(f),
    };
  }
}

class Success<T> extends Result<T> {
  const Success(this.value) : super._();
  final T value;
}

class Failure<T> extends Result<T> {
  const Failure(this.failure) : super._();
  final AppFailure failure;
}
