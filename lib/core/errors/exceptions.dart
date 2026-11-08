import 'package:equatable/equatable.dart';

sealed class AppException extends Equatable implements Exception {
  const AppException();

  String get message;

  @override
  String toString() => '$runtimeType: $message';
}

enum ValidationError {
  titleRequired,
  titleTooLong,
  descriptionTooLong,
  taskNotSaved,
}

final class ValidationException extends AppException {
  const ValidationException(this.error);

  final ValidationError error;

  @override
  String get message => switch (error) {
    ValidationError.titleRequired => 'Title is required.',
    ValidationError.titleTooLong => 'Title is too long.',
    ValidationError.descriptionTooLong => 'Description is too long.',
    ValidationError.taskNotSaved => 'Task has not been saved yet.',
  };

  @override
  List<Object?> get props => [error];
}

final class TaskNotFoundException extends AppException {
  const TaskNotFoundException(this.id);

  final int id;

  @override
  String get message => 'Task #$id was not found.';

  @override
  List<Object?> get props => [id];
}

final class StorageException extends AppException {
  const StorageException([this.cause]);

  final Object? cause;

  @override
  String get message => 'Could not access local storage ($cause).';

  @override
  List<Object?> get props => [cause];
}
