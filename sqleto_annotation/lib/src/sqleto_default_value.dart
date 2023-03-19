// ignore_for_file: constant_identifier_names

enum SQLetoDefaultValue {
  BOOLEAN_FALSE('FALSE'),
  BOOLEAN_TRUE('TRUE'),
  TEXT_EMPTY(''),
  TIMESTAMP_NOW('NOW()'),
  UUID_GENERATE_V4('UUID_GENERATE_V4()');

  final String command;

  const SQLetoDefaultValue(this.command);
}
