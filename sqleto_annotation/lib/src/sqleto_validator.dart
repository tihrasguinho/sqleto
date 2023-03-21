// ignore_for_file: constant_identifier_names

enum SQLetoValidator {
  /// Check if the given value is a valid email!
  EMAIL,

  /// Check if the given value is a valid username! (letters, numbers and underscores with max 24 characteres)
  USERNAME,

  /// Check if the given value is not empty!
  EMPTY_TEXT,

  /// Check if the given value is not a negative number!
  NEGATIVE_NUMBER,

  /// Check it the given value is a valid UUID
  UUID
}
