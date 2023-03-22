// ignore_for_file: constant_identifier_names

enum Operator {
  EQUALS('='),
  NOT_EQUAL('!='),
  MORE_THAN('>'),
  MORE_OR_EQUAL('>='),
  LESS_THAN('<'),
  LESS_OR_EQUAL('<='),
  LIKE('LIKE'),
  I_LIKE('ILIKE'),
  AND('AND'),
  OR('OR');

  final String operator;

  const Operator(this.operator);
}
