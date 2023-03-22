import 'enums/operator.dart';

class Where {
  final List<String> _params = [];

  final String field;
  final Operator operator;
  final dynamic value;

  Where(this.field, this.operator, this.value);

  /// Merge another [Where] with AND [Operator]
  void and(Where where) {
    _params.add("AND ${where.field} ${where.operator.operator} '${where.value}'");
  }

  /// Merge another [Where] with OR [Operator]
  void or(Where where) {
    _params.add("OR ${where.field} ${where.operator.operator} '${where.value}'");
  }

  String whereScript() {
    _params.insert(0, "$field ${operator.operator} '$value'");

    return ' WHERE ${_params.join(' ')}';
  }
}
