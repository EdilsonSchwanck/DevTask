import '../../core/errors/exceptions.dart';

abstract final class TaskValidator {
  static const int maxTitleLength = 80;
  static const int maxDescriptionLength = 500;

  static String validateTitle(String title) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) {
      throw const ValidationException(ValidationError.titleRequired);
    }
    if (trimmed.length > maxTitleLength) {
      throw const ValidationException(ValidationError.titleTooLong);
    }
    return trimmed;
  }

  static String validateDescription(String description) {
    final trimmed = description.trim();
    if (trimmed.length > maxDescriptionLength) {
      throw const ValidationException(ValidationError.descriptionTooLong);
    }
    return trimmed;
  }
}
