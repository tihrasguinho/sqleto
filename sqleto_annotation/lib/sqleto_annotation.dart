// ignore_for_file: constant_identifier_names

library sqleto_annotation;

/// Define it's Class as SQL Table
class Table {
  final String name;

  const Table({required this.name});
}

/// Define it's variable as SQL field
class Column {
  /// Define the SQL type of field
  final SQLetoType type;

  /// Define default value of field
  final SQLetoDefaultValue? defaultValue;

  /// Define wich table references to. (Must to be the private class, not the generated class)
  final Type? references;

  /// Define if field is Primary Key
  final bool primaryKey;

  /// Define if field is Nullable
  final bool nullable;

  /// Define if field is Unique
  final bool unique;

  /// Define if field is Password for hash
  final bool password;

  const Column({
    required this.type,
    this.defaultValue,
    this.references,
    this.primaryKey = false,
    this.nullable = false,
    this.unique = false,
    this.password = false,
  });
}

/// SQL Types
enum SQLetoType { UUID, TEXT, INTEGER, FLOAT, BOOLEAN, TIMESTAMP, TIMESTAMPTZ }

/// SQL Defaults
enum SQLetoDefaultValue {
  BOOLEAN_FALSE('FALSE'),
  BOOLEAN_TRUE('TRUE'),
  TEXT_EMPTY(''),
  TIMESTAMP_NOW('NOW()'),
  UUID_GENERATE_V4('UUID_GENERATE_V4()');

  final String command;

  const SQLetoDefaultValue(this.command);
}
