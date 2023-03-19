// ignore_for_file: constant_identifier_names

class Where {
  final List<String> _merged = [];
  final Map<String, dynamic> _substitutionValues = {};

  final String name;
  final Op op;
  final dynamic value;

  Where(this.name, this.op, this.value);

  void join(Op op, Where where) {
    _merged.add('${op.operation} ${where.name} ${where.op.operation} @${where.name}');
    _substitutionValues[where.name] = where.value;
  }

  void and(Where where) {
    _merged.add('${Op.and.operation} ${where.name} ${where.op.operation} @${where.name}');
    _substitutionValues[where.name] = where.value;
  }

  void or(Where where) {
    _merged.add('${Op.or.operation} ${where.name} ${where.op.operation} @${where.name}');
    _substitutionValues[where.name] = where.value;
  }

  String whereScript() {
    return ' WHERE $name ${op.operation} @$name ${_merged.join(' ')}';
  }

  Map<String, dynamic> substitutionValues() {
    _substitutionValues[name] = value;

    return _substitutionValues;
  }
}

enum Op {
  equals('='),
  notEquals('!='),
  moreThan('>'),
  moreOrEqual('>='),
  lessThan('<'),
  lessOrEqual('<='),
  like('LIKE'),
  ilike('ILIKE'),
  and('AND'),
  or('OR');

  final String operation;

  const Op(this.operation);
}
