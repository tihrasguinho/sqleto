import 'dart:async';
import 'dart:convert';

import 'package:postgres/postgres.dart';
import 'package:rxdart/rxdart.dart';

import 'package:sqleto_annotation/sqleto_annotation.dart';

import 'exceptions/sqleto_exception.dart';
import 'sqleto_config.dart';
import 'utils/sqleto_schema_utils.dart';
import 'utils/sqleto_sql_utils.dart';
import 'where.dart';

class SQLeto {
  static final _instance = SQLeto._();

  final BehaviorSubject<SQLetoSchema Function()> _onChangedController = BehaviorSubject<SQLetoSchema Function()>();

  PostgreSQLConnection? _connection;

  SQLetoConfig? _config;

  SQLetoConfig get config => _config!;

  SQLeto._();

  static SQLeto get instance => _instance;

  static Future<SQLeto> initialize(SQLetoConfig config) async {
    try {
      _instance._config = config;

      for (final schema in _instance._config!.schemas) {
        if (!SQLetoSchemaUtils.isValidSchema(schema)) throw InvalidSchemaException('Its schema $schema does not extends Schema!');
      }

      _instance._connection ??= PostgreSQLConnection(
        config.host,
        config.port,
        config.database,
        username: config.username,
        password: config.password,
        useSSL: config.useSSL,
      );

      await _instance._connection?.open();

      _instance._connection!.notifications.listen((event) {
        if (event.channel == 'on_changed') {
          final decoded = jsonDecode(event.payload);

          if (config.schemas.any((e) => SQLetoSchemaUtils.tableName(e) == decoded['table_name'])) {
            final schema = config.schemas.firstWhere((e) => SQLetoSchemaUtils.tableName(e) == decoded['table_name']);

            if (_instance._onChangedController.hasListener) _instance._onChangedController.sink.add(schema);
          }
        }
      });

      await _instance._connection?.transaction((connection) async {
        await connection.execute(SQLetoSQLUtils.createUuidExtension());

        await connection.execute(SQLetoSQLUtils.createPGCryptoExtension());

        await connection.execute(SQLetoSQLUtils.createAutoUpdateAt());

        await connection.execute(SQLetoSQLUtils.createFunctionOnChanged());

        await connection.execute(SQLetoSQLUtils.createListenOnChanged());

        for (final schema in config.schemas) {
          await connection.execute(SQLetoSchemaUtils.buildClassSCHEMA(schema));
          await connection.execute(SQLetoSQLUtils.createTriggerOnChangedOnTable(SQLetoSchemaUtils.tableName(schema)));
        }
      });

      return _instance;
    } on SQLetoException {
      rethrow;
    } on PostgreSQLException catch (e) {
      throw DatabaseException(e.message ?? 'Unhandled Postgres Exception!');
    } on Exception catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  /// Stream of [T] from database, its trigger is when insert or update!
  Stream<List<T>> onChanged<T extends SQLetoSchema>([Where? where]) {
    return _onChangedController.stream.switchMap((e) async* {
      if (SQLetoSchemaUtils.isValidSchema(e) && config.schemas.contains(e)) {
        final values = await select<T>(where);

        if (values.isNotEmpty) yield values;
      }
    }).distinct((prev, next) => _isListEquals(prev, next));
  }

  /// Insert a schema [T] on database
  ///
  /// E.g.:
  /// ```dart
  ///
  /// UserSchema user = UserSchema.create(name: 'John Doe', email: 'johndoe@gmail.com', password: '123456');
  ///
  /// user = await SQLeto.instence.insert<UserSchema>(user);
  /// ```
  Future<T> insert<T extends SQLetoSchema>(Object Function() object) async {
    try {
      if (!_containsSchema<T>()) throw GenericException('$T is not registered on SQLetoSchema list!');

      final query = SQLetoSchemaUtils.buildINSERT(object);

      final substitutionValues = SQLetoSchemaUtils.invokeToMap(object);

      final insert = await _connection?.mappedResultsQuery(query, substitutionValues: substitutionValues);

      if (insert == null) throw DatabaseException('Fail to get the returning of this operation!');

      final insertedSchema = SQLetoSchemaUtils.invokeFromMap(object, insert.first[SQLetoSchemaUtils.tableName(object)]!);

      return insertedSchema;
    } on SQLetoException {
      rethrow;
    } on PostgreSQLException catch (e) {
      if (e.code == '23505') throw DatabaseConflictException(e.message ?? 'Unhandled Postgres Exception!');

      if (e.code == '23503') throw DatabaseForeignKeyExcenption(e.message ?? 'Unhandled Postgres Exception!');

      throw DatabaseException(e.message ?? 'Unhandled Postgres Exception!');
    } on Exception catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  /// Select a list of [T] from database
  ///
  /// E.g.:
  /// ```dart
  /// List<UserSchema> users = await SQLeto.instance.select<UserSchema>();
  /// ```
  ///
  ///
  /// You can pass [Where] as parameter to apply filters
  ///
  /// E.g.:
  /// ```dart
  /// final where = Where('name', Operator.EQUALS, 'John Doe');
  /// ```
  /// If necessary you can merge multiple [Where]
  ///
  /// ```dart
  /// where.and(Where('created_at', Operator.LESS_THAN, DateTime.now()));
  ///
  /// where.or(Where('created_at', Operator.MORE_THAN, DateTime.now()));
  ///
  /// List<UserSchema> users = await SQLeto.instance.select<UserSchema>(where);
  /// ```
  Future<List<T>> select<T extends SQLetoSchema>([Where? where]) async {
    try {
      if (!_containsSchema<T>()) throw GenericException('$T is not registered on SQLetoSchema list!');

      final object = _getSchema<T>();

      final query = SQLetoSchemaUtils.buildSELECT(object, where?.whereScript());

      final select = await _connection?.mappedResultsQuery(query);

      if (select == null) throw DatabaseException('Fail to get the returning of this operation!');

      return select.map((e) => SQLetoSchemaUtils.invokeFromMap(object, e[SQLetoSchemaUtils.tableName(object)]!) as T).toList();
    } on SQLetoException {
      rethrow;
    } on PostgreSQLException catch (e) {
      print(e.detail);

      throw DatabaseException(e.message ?? 'Unhandled Postgres Exception!');
    } on Exception catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  /// Select a single [T] from database based on their [primaryKey]
  ///
  /// E.g.:
  /// ```dart
  /// UserSchema user = await SQLeto.instance.findByPK<UserSchema>('a_unique_primary_key');
  /// ```
  Future<T> findByPK<T extends SQLetoSchema>(dynamic primaryKey) async {
    try {
      if (!_containsSchema<T>()) throw GenericException('$T is not registered on SQLetoSchema list!');

      final object = _getSchema<T>();

      final query = SQLetoSchemaUtils.buildSELECT(object);

      final pkName = SQLetoSchemaUtils.getPKName(object);

      final select = await _connection?.mappedResultsQuery('$query WHERE $pkName = @$pkName', substitutionValues: {pkName: primaryKey});

      if (select == null) throw DatabaseException('Fail to get the returning of this operation!');

      if (select.isEmpty) throw NotFoundException('No founded ${object.runtimeType} wich this PK: $primaryKey');

      return SQLetoSchemaUtils.invokeFromMap(object, select.first[SQLetoSchemaUtils.tableName(object)]!);
    } on SQLetoException {
      rethrow;
    } on PostgreSQLException catch (e) {
      print(e.toString());

      throw DatabaseException(e.message ?? 'Unhandled Postgres Exception!');
    } on Exception catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  /// Update a [T] in database if exists
  ///
  /// The [update] method is based on [T] primaryKey
  ///
  /// E.g.:
  /// ```dart
  /// UserSchema user = await SQLeto.instance.findByPK<UserSchema>('a_unique_primary_key');
  ///
  /// user = await SQLeto.instance.update<UserSchema>(user.copyWith(name: 'John Doe Reformed'));
  /// ```
  ///
  /// You can also use [save] method inside [T]
  ///
  /// E.g.:
  /// ```dart
  /// user = user.copyWith(name: 'John Doe Reformed');
  ///
  /// await user.save();
  /// ```
  Future<T> update<T extends SQLetoSchema>(SQLetoSchema Function() object) async {
    try {
      if (!_containsSchema<T>()) throw GenericException('${object.runtimeType} is not registered on SQLetoSchema list!');

      final query = SQLetoSchemaUtils.buildUPDATE(object);

      final substitutionValues = SQLetoSchemaUtils.invokeToMap(object);

      final update = await _connection?.mappedResultsQuery(query, substitutionValues: substitutionValues);

      if (update == null) throw DatabaseException('Fail to get the returning of this operation!');

      if (update.isEmpty) throw NotFoundException('No ${object.runtimeType} found with PK: ${substitutionValues[SQLetoSchemaUtils.getPKName(object)]} to update!');

      return SQLetoSchemaUtils.invokeFromMap(object, update.first[SQLetoSchemaUtils.tableName(object)]!);
    } on SQLetoException {
      rethrow;
    } on PostgreSQLException catch (e) {
      throw DatabaseException(e.message ?? 'Unhandled Postgres Exception!');
    } on Exception catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  /// Delete a [T] from database if exists
  ///
  /// E.g.:
  /// ```dart
  /// UserSchema user = await SQLeto.instance.findByPK<UserSchema>('a_unique_primary_key');
  ///
  /// await SQLeto.instance.delete<UserSchema>();
  /// ```
  ///
  /// You can also use [delete] method inside [T]
  ///
  /// E.g.:
  /// ```dart
  /// await user.delete();
  /// ```
  Future<T> delete<T extends SQLetoSchema>(Object Function() object) async {
    try {
      if (!_containsSchema<T>()) throw GenericException('$T is not registered on SQLetoSchema list!');

      final query = SQLetoSchemaUtils.buildDELETE(object);

      final substitutionValues = SQLetoSchemaUtils.invokeToMap(object);

      final delete = await _connection?.mappedResultsQuery(query, substitutionValues: substitutionValues);

      if (delete == null) throw DatabaseException('Fail to get the returning of this operation!');

      if (delete.isEmpty) throw NotFoundException('No ${object.runtimeType} found with PK: ${substitutionValues[SQLetoSchemaUtils.getPKName(object)]} to delete!');

      return SQLetoSchemaUtils.invokeFromMap(object, delete.first[SQLetoSchemaUtils.tableName(object)]!);
    } on SQLetoException {
      rethrow;
    } on PostgreSQLException catch (e) {
      throw DatabaseException(e.message ?? 'Unhandled Postgres Exception!');
    } on Exception catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  static bool _containsSchema<T extends Object>() => _instance._config!.schemas.any((e) => e().runtimeType == T);

  static Object Function() _getSchema<T extends Object>() => _instance._config!.schemas.firstWhere((e) => e().runtimeType == T);

  static bool _isListEquals<T extends SQLetoSchema>(List<T> first, List<T> second) {
    if (first.length != second.length) return false;

    for (var i = 0; i < first.length; i++) {
      if (first[i] != second[i]) return false;
    }

    return true;
  }

  void dispose() async {
    _onChangedController.close();
    await _connection?.close();
  }
}
