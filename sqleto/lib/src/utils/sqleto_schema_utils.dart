import 'dart:mirrors';

import 'package:sqleto/sqleto.dart';

class SQLetoSchemaUtils {
  SQLetoSchemaUtils._();

  static bool isValidSchema(Type T) {
    final cm = reflectClass(T);
    return cm.isSubtypeOf(reflectClass(SQLetoSchema));
  }

  static String tableName(Type T) {
    return invokeFromMap(T, {}).tableName;
  }

  static String buildSELECT(Type T, [String? whereScript]) {
    if (!isValidSchema(T)) throw InvalidSchemaException('Its given class does not extends from Schema!');

    return 'SELECT * FROM ${tableName(T)}${whereScript ?? ''}';
  }

  static String getPKName(Type T) {
    if (!isValidSchema(T)) throw InvalidSchemaException('Its given class does not extends from Schema!');

    final cm = reflectClass(T);

    final base = cm.superclass!.typeArguments.first as ClassMirror;

    final vms = base.declarations.values.whereType<VariableMirror>().toList();

    if (vms.any((e) => _instanceMirrorWithFieldAnnotation(e).getField(#primaryKey).reflectee == true)) {
      return vms.firstWhere((e) => _instanceMirrorWithFieldAnnotation(e).getField(#primaryKey).reflectee == true).simpleName.name;
    } else {
      throw InvalidSchemaException('T schema $T does not have a primary key!');
    }
  }

  static String buildDELETE(Type T) {
    if (!isValidSchema(T)) throw InvalidSchemaException('Its given class does not extends from Schema!');

    return 'DELETE FROM ${tableName(T).toUpperCase()} WHERE ${getPKName(T).toUpperCase()} = @${getPKName(T)} RETURNING *';
  }

  static String buildUPDATE(Type T) {
    if (!isValidSchema(T)) throw InvalidSchemaException('Its given class does not extends from Schema!');

    final cm = reflectClass(T);

    final base = cm.superclass!.typeArguments.first as ClassMirror;

    final vms = base.declarations.values.whereType<VariableMirror>();

    final builder = <String>[];

    final setters = <String>[];

    builder.add('UPDATE ${tableName(T).toUpperCase()} SET');

    for (var vm in vms) {
      final im = _instanceMirrorWithFieldAnnotation(vm);

      if (im.getField(#defaultValue).reflectee == null) {
        setters.add('${vm.simpleName.name} = @${vm.simpleName.name}');
      }
    }

    builder.add(setters.join(', '));

    final pkName = getPKName(T);

    builder.add('WHERE $pkName = @$pkName RETURNING *');

    return builder.join(' ');
  }

  static String buildINSERT(SQLetoSchema Function() schema) {
    final type = schema().runtimeType;

    if (!isValidSchema(type)) throw InvalidSchemaException('Its given class does not extends from Schema!');

    final builder = <String>[];

    builder.add('INSERT INTO');

    builder.add(tableName(type).toUpperCase());

    final im = reflect(schema());

    final cm = im.type;

    final base = cm.superclass as ClassMirror;

    final vms = base.declarations.values.whereType<VariableMirror>().toList();

    final requiredVms = vms.where((e) => _instanceMirrorWithFieldAnnotation(e).getField(#defaultValue).reflectee == null);

    if (requiredVms.any((e) => _instanceMirrorWithFieldAnnotation(e).getField(#validator).reflectee != null)) {
      final withValidator = vms.where((e) => _instanceMirrorWithFieldAnnotation(e).getField(#validator).reflectee != null).toList();

      for (final vm in withValidator) {
        final validator = _instanceMirrorWithFieldAnnotation(vm).getField(#validator).reflectee as SQLetoValidator;

        switch (validator) {
          case SQLetoValidator.EMAIL:
            {
              final value = im.getField(vm.simpleName).reflectee;

              if (value is! String) throw InvalidSchemaException('$type field >>${vm.simpleName.name.toUpperCase()}<< is marked as email but is not a String/TEXT!');

              final regex = RegExp(r"^[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$");

              if (!regex.hasMatch(value)) {
                throw InvalidSchemaException('$type field >>${vm.simpleName.name.toUpperCase()}<< is marked as email but the value given is not an email!');
              }

              break;
            }
          case SQLetoValidator.USERNAME:
            {
              final value = im.getField(vm.simpleName).reflectee;

              if (value is! String) throw InvalidSchemaException('$type field >>${vm.simpleName.name.toUpperCase()}<< is marked as username but is not a String/TEXT!');

              final regex = RegExp(r"^[a-zA-Z0-9_]{5,24}$");

              if (!regex.hasMatch(value)) {
                throw InvalidSchemaException('$type field >>${vm.simpleName.name.toUpperCase()}<< is marked as username, only letters, numbers and _ are allowed, max 24 characters!');
              }
              break;
            }
          case SQLetoValidator.EMPTY_TEXT:
            {
              final value = im.getField(vm.simpleName).reflectee;

              if (value is! String) throw InvalidSchemaException('$type field >>${vm.simpleName.name.toUpperCase()}<< is not a String/TEXT!');

              if (value.isEmpty) {
                throw InvalidSchemaException('$type field >>${vm.simpleName.name.toUpperCase()}<< cannot be empty!');
              }
              break;
            }
          case SQLetoValidator.NEGATIVE_NUMBER:
            {
              final value = im.getField(vm.simpleName).reflectee;

              if (value is! num) throw InvalidSchemaException('$type field >>${vm.simpleName.name.toUpperCase()}<< is marked as not negative number but is not a number!');

              if (value.isNegative) {
                throw InvalidSchemaException('$type field >>${vm.simpleName.name.toUpperCase()}<< cannot be negative!');
              }
              break;
            }
          case SQLetoValidator.UUID:
            {
              final value = im.getField(vm.simpleName).reflectee;

              if (value is! String) throw InvalidSchemaException('$type field >>${vm.simpleName.name.toUpperCase()}<< is not a String/UUID!');

              final regex = RegExp(r"^[0-9A-Za-z]{8}-[0-9A-Za-z]{4}-4[0-9A-Za-z]{3}-[89ABab][0-9A-Za-z]{3}-[0-9A-Za-z]{12}$");

              if (!regex.hasMatch(value)) {
                throw InvalidSchemaException('$type field >>${vm.simpleName.name.toUpperCase()}<< is not a valid UUID!');
              }

              break;
            }
        }
      }
    }

    builder.add('(${requiredVms.map((e) => _snakeCaseNORMALIZER(e.simpleName.name).toUpperCase()).join(', ')})');

    builder.add(' VALUES ');

    builder.add('(${requiredVms.map((e) => _buildReferenceFieldName(e)).join(', ')}) RETURNING *');

    return builder.join(' ');
  }

  static String _buildReferenceFieldName(VariableMirror vm) {
    if (_instanceMirrorWithFieldAnnotation(vm).getField(#password).reflectee == true) {
      return "crypt(@${_snakeCaseNORMALIZER(vm.simpleName.name)}, gen_salt('bf', 4))";
    } else {
      return '@${_snakeCaseNORMALIZER(vm.simpleName.name)}';
    }
  }

  static String buildClassSCHEMA(Type T) {
    if (!isValidSchema(T)) throw InvalidSchemaException('Its given class does not extends from Schema!');

    final cm = reflectClass(T);

    final base = cm.superclass as ClassMirror;

    final vms = base.declarations.values.whereType<VariableMirror>().toList();

    final buffer = StringBuffer();

    buffer.writeln('CREATE TABLE IF NOT EXISTS ${tableName(T).toUpperCase()} (');

    for (var i = 0; i < vms.length; i++) {
      final vm = vms[i];
      final comma = i + 1 == vms.length ? '' : ',';

      if (_containsFieldAnnotation(vm)) {
        buffer.writeln('  ${_fieldBuild(vm)}$comma');
      }
    }

    buffer.writeln(');');

    return buffer.toString();
  }

  static bool _containsFieldAnnotation(VariableMirror vm) {
    return vm.metadata.any((e) => e.type.simpleName == Symbol('Field'));
  }

  static InstanceMirror _instanceMirrorWithFieldAnnotation(VariableMirror vm) {
    return vm.metadata.firstWhere((e) => e.type.simpleName == Symbol('Field'));
  }

  static String _fieldBuild(VariableMirror vm) {
    final instance = _instanceMirrorWithFieldAnnotation(vm);

    final builder = <String>[];

    final name = _snakeCaseNORMALIZER(vm.simpleName.name).toUpperCase();

    builder.add(name);

    final type = (instance.getField(#type).reflectee as SQLetoType).name;

    builder.add(type);

    final primaryKey = instance.getField(#primaryKey).reflectee as bool;

    if (primaryKey) builder.add('PRIMARY KEY');

    final nullable = instance.getField(#nullable).reflectee as bool;

    if (nullable && primaryKey) throw InvalidSchemaException('This schema has a nullable primary key!');

    if (!nullable && !primaryKey) builder.add('NOT NULL');

    final unique = instance.getField(#unique).reflectee as bool;

    if (unique) builder.add('UNIQUE');

    final defaultValue = instance.getField(#defaultValue).reflectee as SQLetoDefaultValue?;

    if (defaultValue != null) builder.add('DEFAULT ${_enumToString(defaultValue)}');

    final references = instance.getField(#references).reflectee as Type?;

    if (references != null) {
      final cm = reflectClass(references);

      final referenceTableName = 'tb_${_snakeCaseNORMALIZER(cm.simpleName.name)}'.toUpperCase();

      final vms = cm.declarations.values.whereType<VariableMirror>().toList();

      if (vms.any((e) => e.metadata.any((e) => e.getField(#primaryKey).reflectee))) {
        final referencePkVm = vms.firstWhere((e) => e.metadata.any((e) => e.getField(#primaryKey).reflectee));

        final referencePkType = (referencePkVm.metadata.first.getField(#type).reflectee as SQLetoType).name;

        if (referencePkType != type) throw Exception('O PRIMARY KEY DA CLASSE REFERENCIADA NÃO É DO MESMO TIPO DA CAMPO DA CLASSE CRIADA');

        if (referencePkType != type) throw InvalidReferencedSchemaException('The referenced schema primary key type is not the same to the given Schema!');

        builder.add('REFERENCES $referenceTableName (${referencePkVm.simpleName.name.toUpperCase()})');
      } else {
        throw InvalidReferencedSchemaException('The referenced schema does not have a primary key!');
      }
    }

    return builder.join(' ');
  }

  static String _enumToString(SQLetoDefaultValue def) {
    switch (def) {
      case SQLetoDefaultValue.FALSE:
        return 'FALSE';
      case SQLetoDefaultValue.TRUE:
        return 'TRUE';
      case SQLetoDefaultValue.EMPTY:
        return "''";
      case SQLetoDefaultValue.ZERO:
        return '0';
      case SQLetoDefaultValue.NOW:
        return 'NOW()';
      case SQLetoDefaultValue.UUID_GENERATE_V4:
        return 'UUID_GENERATE_V4()';
    }
  }

  static dynamic invokeFromMap(Type T, Map<String, dynamic> map) {
    final cm = reflectClass(T);

    if (cm.declarations.containsKey(#fromMap)) {
      return cm.invoke(#fromMap, [map]).reflectee;
    } else {
      throw InvalidSchemaException('Its schema does not have a "fromMap" method!');
    }
  }

  static dynamic invokeFromPostgreSQLMap(Type T, Map<String, dynamic> map) {
    final cm = reflectClass(T);

    if (cm.declarations.containsKey(#fromPostgreSQLMap)) {
      return cm.invoke(#fromPostgreSQLMap, [map]).reflectee;
    } else {
      throw InvalidSchemaException('Its schema does not have a "fromPostgreSQLMap" method!');
    }
  }

  static Map<String, dynamic> invokeToMap(SQLetoSchema Function() schema) {
    final im = reflect(schema());

    final cm = im.type;

    if (cm.declarations.containsKey(#toMap)) {
      return im.invoke(#toMap, []).reflectee;
    } else {
      throw InvalidSchemaException('Its schema does not have a "toMap" method!');
    }
  }

  static String _snakeCaseNORMALIZER(String origin) {
    RegExp exp = RegExp(r'(?<=[a-z])[A-Z]');
    return origin.replaceAllMapped(exp, (Match m) => ('_${m.group(0)}')).toLowerCase();
  }
}

extension _SymbomStringExt on Symbol {
  String get name => MirrorSystem.getName(this);
}
