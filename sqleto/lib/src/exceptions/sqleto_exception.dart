abstract class SQLetoException implements Exception {
  final String error;
  final StackTrace? stackTrace;

  SQLetoException(this.error, [this.stackTrace]);
}

class GenericException extends SQLetoException {
  GenericException(super.error, [super.stackTrace]);
}

class NotFoundException extends SQLetoException {
  NotFoundException(super.error, [super.stackTrace]);
}

class DatabaseException extends SQLetoException {
  DatabaseException(super.error, [super.stackTrace]);
}

class DatabaseConflictException extends SQLetoException {
  DatabaseConflictException(super.error, [super.stackTrace]);
}

class DatabaseForeignKeyExcenption extends SQLetoException {
  DatabaseForeignKeyExcenption(super.error, [super.stackTrace]);
}

class InvalidSchemaException extends SQLetoException {
  InvalidSchemaException(super.error, [super.stackTrace]);
}

class InvalidReferencedSchemaException extends SQLetoException {
  InvalidReferencedSchemaException(super.error, [super.stackTrace]);
}
