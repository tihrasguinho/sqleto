import 'dart:async';

import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'package:sqleto_annotation/sqleto_annotation.dart';

final _typeChecker = TypeChecker.fromRuntime(SQLetoSchema);
final _fieldChecker = TypeChecker.fromRuntime(Field);

class SchemaGenerator extends Generator {
  final BuilderOptions options;

  SchemaGenerator([this.options = BuilderOptions.empty]);

  @override
  FutureOr<String?> generate(LibraryReader library, BuildStep buildStep) {
    if (library.classes.isEmpty) return null;

    final classElement = library.classes.first;

    if (classElement.supertype == null) return null;

    if (!_typeChecker.isExactly(classElement.supertype!.element)) return null;

    if (!classElement.isAbstract) return null;

    final className = classElement.displayName;

    final schemaName = '${className}Schema';

    final fields = classElement.fields;

    final buffer = StringBuffer();

    buffer.writeln('class $schemaName extends $className {');

    // WRITE CONSTRUCTOR
    buffer.writeln('$schemaName({');

    for (var field in fields) {
      buffer.writeln('required super.${field.displayName},');
    }

    buffer.writeln('});');

    buffer.writeln('');

    buffer.writeln('factory $schemaName.create({');

    for (var field in fields) {
      if (_fieldChecker.hasAnnotationOf(field)) {
        final defaultValue = _fieldChecker.firstAnnotationOfExact(field)!.getField('defaultValue')?.getField('_name')?.toStringValue();

        if (defaultValue == null) buffer.writeln('required ${field.type} ${field.displayName},');
      }
    }

    buffer.writeln('}) {');

    buffer.writeln('return $schemaName(');

    for (var field in fields) {
      if (_fieldChecker.hasAnnotationOf(field)) {
        final defaultValue = _fieldChecker.firstAnnotationOfExact(field)!.getField('defaultValue')?.getField('_name')?.toStringValue();

        if (defaultValue == null) {
          buffer.writeln('${field.displayName}: ${field.displayName},');
        } else {
          buffer.writeln('${field.displayName}: ${_defaultValue(field.type)}, // WILL BE AUTOMATICALLY GENERATED');
        }
      }
    }

    buffer.writeln(');');

    buffer.writeln('}');

    buffer.writeln('');

    buffer.writeln('static $schemaName fromMap(Map<String, dynamic> map) {');

    buffer.writeln('return $schemaName(');

    for (var field in fields) {
      if (field.type.toString() == 'DateTime') {
        buffer.writeln("${field.displayName}: DateTime.fromMillisecondsSinceEpoch(map['${_snakeCaseNORMALIZER(field.displayName)}'] as int),");
      } else {
        buffer.writeln("${field.displayName}: map['${_snakeCaseNORMALIZER(field.displayName)}'] ?? ${_defaultValue(field.type)},");
      }
    }

    buffer.writeln(');');

    buffer.writeln('}');

    buffer.writeln('');

    buffer.writeln('Map<String, dynamic> toMap() => {');

    for (var field in fields) {
      buffer.writeln("'${_snakeCaseNORMALIZER(field.displayName)}': ${field.displayName},");
    }

    buffer.writeln('};');

    buffer.writeln('');

    buffer.writeln('$schemaName copyWith({');

    for (var field in fields) {
      if (_fieldChecker.hasAnnotationOf(field)) {
        final defaultValue = _fieldChecker.firstAnnotationOfExact(field)!.getField('defaultValue')?.getField('_name')?.toStringValue();

        if (defaultValue == null) buffer.writeln('${field.type}? ${field.displayName},');
      }
    }

    buffer.writeln('}) {');

    buffer.writeln('return $schemaName(');

    for (var field in fields) {
      if (_fieldChecker.hasAnnotationOf(field)) {
        final defaultValue = _fieldChecker.firstAnnotationOfExact(field)!.getField('defaultValue')?.getField('_name')?.toStringValue();

        if (defaultValue == null) {
          buffer.writeln('${field.displayName}: ${field.displayName} ?? this.${field.displayName},');
        } else {
          buffer.writeln('${field.displayName}: ${field.displayName},');
        }
      }
    }

    buffer.writeln(');');

    buffer.writeln('}');

    buffer.writeln('');

    buffer.writeln('@override');

    buffer.writeln('Future<void> save() => SQLeto.instance.update<$schemaName>(() => this);');

    buffer.writeln('');

    buffer.writeln('@override');

    buffer.writeln('Future<void> delete() => SQLeto.instance.delete<$schemaName>(() => this);');

    buffer.writeln('');

    buffer.writeln('@override');

    buffer.writeln("String get tableName => 'tb_${className.toLowerCase()}';");

    buffer.writeln('');

    buffer.writeln('}');

    return buffer.toString();
  }

  String _snakeCaseNORMALIZER(String origin) {
    RegExp exp = RegExp(r'(?<=[a-z])[A-Z]');
    return origin.replaceAllMapped(exp, (Match m) => ('_${m.group(0)}')).toLowerCase();
  }

  String _defaultValue(DartType type) {
    switch (type.toString()) {
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
        return "''";
    }
  }
}
