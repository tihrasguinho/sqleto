import 'package:sqleto_annotation/src/sqleto_validator.dart';

import 'sqleto_default_value.dart';
import 'sqleto_type.dart';

/// Define it's variable as SQL field
class Field {
  /// Define the SQL type of field
  final SQLetoType type;

  /// Define default value of field
  final SQLetoDefaultValue? defaultValue;

  /// Define a validator for this field
  final SQLetoValidator? validator;

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

  const Field({
    required this.type,
    this.defaultValue,
    this.references,
    this.primaryKey = false,
    this.nullable = false,
    this.unique = false,
    this.password = false,
    this.validator,
  });
}
