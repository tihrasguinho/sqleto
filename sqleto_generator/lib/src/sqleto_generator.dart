import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'package:sqleto_annotation/sqleto_annotation.dart';

class SQLetoGenerator extends GeneratorForAnnotation<Table> {
  @override
  String generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    final buffer = StringBuffer();

    if (element is! ClassElement) throw Exception('Its not a valid class!');

    final name = element.displayName;

    if (!element.isAbstract) throw Exception('Its given class is not an abstract class!');

    final className = '${name}Schema';

    final tableName = element.metadata.first.computeConstantValue()?.getField('name')?.toStringValue();

    if (tableName == null) throw Exception('Missing table_name on @Table() annotation!');

    final fields = element.fields;

    buffer.writeln('class $className extends Schema<$name> {');

    buffer.writeln();

    for (var field in fields) {
      if (field.metadata.any((e) => e.element?.displayName == 'Column')) {
        buffer.writeln('final ${field.type.toString()} ${field.displayName};');
      }
    }

    buffer.writeln();

    buffer.writeln('$className._({${fields.map((e) => 'required this.${e.displayName}').join(', ')},});');

    buffer.writeln();

    buffer.writeln('factory $className.create({');

    for (var field in fields) {
      if (field.metadata.any((e) => e.element?.displayName == 'Column')) {
        final column = field.metadata.firstWhere((e) => e.element?.displayName == 'Column');

        final defaultValue = column.computeConstantValue()?.getField('defaultValue')?.getField('_name')?.toStringValue();

        if (defaultValue == null) {
          buffer.writeln('required ${field.type} ${field.displayName},');
        }
      }
    }

    buffer.writeln('}) {');

    buffer.writeln('return $className._(');

    for (var field in fields) {
      if (field.metadata.any((e) => e.element?.displayName == 'Column')) {
        final column = field.metadata.firstWhere((e) => e.element?.displayName == 'Column');

        final defaultValue = column.computeConstantValue()?.getField('defaultValue')?.getField('_name')?.toStringValue();

        if (defaultValue != null) {
          buffer.writeln('${field.displayName}: ${_dartDefault(field.type.toString())},');
        } else {
          buffer.writeln('${field.displayName}: ${field.displayName},');
        }
      }
    }

    buffer.writeln(');');

    buffer.writeln('}');

    buffer.writeln();

    buffer.writeln('static $className fromMap(Map<String, dynamic> map) {');

    buffer.writeln('return $className._(${fields.map((e) => "${e.displayName}: map['${_camelCaseToSnakeCase(e.displayName)}'] ?? ${_dartDefault(e.type.toString())}").join(', ')},);');

    buffer.writeln('}');

    buffer.writeln();

    buffer.writeln('Map<String, dynamic> toMap() => {');

    for (var field in fields) {
      buffer.writeln("'${_camelCaseToSnakeCase(field.displayName)}': ${field.displayName},");
    }

    buffer.writeln('};');

    buffer.writeln();

    buffer.writeln('$className copyWith({');

    for (var field in fields) {
      if (field.metadata.any((e) => e.element?.displayName == 'Column')) {
        final column = field.metadata.firstWhere((e) => e.element?.displayName == 'Column');

        final defaultValue = column.computeConstantValue()?.getField('defaultValue')?.getField('_name')?.toStringValue();

        if (defaultValue == null) {
          buffer.writeln('${field.type}? ${field.displayName},');
        }
      }
    }

    buffer.writeln('}) {');

    buffer.writeln('return $className._(');

    for (var field in fields) {
      if (field.metadata.any((e) => e.element?.displayName == 'Column')) {
        final column = field.metadata.firstWhere((e) => e.element?.displayName == 'Column');

        final defaultValue = column.computeConstantValue()?.getField('defaultValue')?.getField('_name')?.toStringValue();

        if (defaultValue == null) {
          buffer.writeln('${field.displayName}: ${field.displayName} ?? this.${field.displayName},');
        } else {
          buffer.writeln('${field.displayName}: ${field.displayName},');
        }
      }
    }

    buffer.writeln(');');

    buffer.writeln('}');

    buffer.writeln();

    buffer.writeln('@override');

    buffer.writeln("String get tableName => '$tableName';");

    buffer.writeln();

    buffer.writeln('@override');

    buffer.writeln('Future<void> save() => SQLeto.instance.update<$className>(() => this);');

    buffer.writeln();

    buffer.writeln('@override');

    buffer.writeln('Future<void> delete() => SQLeto.instance.delete<$className>(() => this);');

    buffer.writeln();

    buffer.writeln('}');

    return buffer.toString();
  }

  String _camelCaseToSnakeCase(String origin) {
    RegExp exp = RegExp(r'(?<=[a-z])[A-Z]');
    return origin.replaceAllMapped(exp, (Match m) => ('_${m.group(0)}')).toLowerCase();
  }

  String _dartDefault(String dartType) {
    switch (dartType) {
      case 'String':
        return "''";
      case 'int':
        return '0';
      case 'double':
        return '0.0';
      case 'bool':
        return 'false';
      case 'DateTime':
        return 'DateTime.now()';
      default:
        throw Exception('The dart type $dartType is not supported yet!');
    }
  }
}
