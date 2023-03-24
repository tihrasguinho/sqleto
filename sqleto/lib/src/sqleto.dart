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

  Timer? _timeout;

  PostgreSQLConnection? _connection;

  final BehaviorSubject<Type> _onChangedController = BehaviorSubject<Type>();

  SQLeto._();

  static SQLeto get instance => _instance;

  static Future<SQLeto> initialize(SQLetoConfig config) async {
    try {
      for (final schema in config.schemas) {
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

      _instance._connection!.notifications.listen(
        (event) {
          if (event.channel == 'on_changed') {
            final decoded = jsonDecode(event.payload) as Map<String, dynamic>;

            if (config.schemas.any((e) => SQLetoSchemaUtils.tableName(e) == decoded['table_name'])) {
              final schema = config.schemas.firstWhere((e) => SQLetoSchemaUtils.tableName(e) == decoded['table_name']);

              if (_instance._onChangedController.hasListener) {
                if (_instance._timeout?.isActive ?? false) _instance._timeout?.cancel();
                _instance._timeout = Timer(Duration(seconds: 1), () => _instance._onChangedController.sink.add(schema));
              }
            }
          }
        },
        onError: (err) {
          print('### NOTIFICATIONS ERROR ###');
          print(err);
        },
        onDone: () {
          print('### NOTIFICATIONS DONE ###');
        },
      );

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
  Stream<List<T>> onChanged<T extends SQLetoSchema>([Where? where]) => _onChangedController.stream.switchMap((e) => _onChangedSwithMap(e, where));

  Stream<List<T>> _onChangedSwithMap<T extends SQLetoSchema>(Type schema, [Where? where]) async* {
    if (schema == T) {
      final values = await select<T>(where);

      if (values.isNotEmpty) yield values;
    }
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
  Future<T> insert<T extends SQLetoSchema>(SQLetoSchema Function() schema) async {
    try {
      final query = SQLetoSchemaUtils.buildINSERT(schema);

      final substitutionValues = SQLetoSchemaUtils.invokeToMap(schema);

      final insert = await _connection?.mappedResultsQuery(query, substitutionValues: substitutionValues);

      if (insert == null) throw DatabaseException('Fail to get the returning of this operation!');

      final insertedSchema = SQLetoSchemaUtils.invokeFromPostgreSQLMap(T, insert.first);

      return insertedSchema;
    } on SQLetoException {
      rethrow;
    } on PostgreSQLException catch (e) {
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
      final query = SQLetoSchemaUtils.buildSELECT(T, where?.whereScript());

      final select = await _connection?.mappedResultsQuery(query);

      if (select == null) throw DatabaseException('Fail to get the returning of this operation!');

      return select.map((e) => SQLetoSchemaUtils.invokeFromPostgreSQLMap(T, e) as T).toList();
    } on SQLetoException {
      rethrow;
    } on PostgreSQLException catch (e) {
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
      final query = SQLetoSchemaUtils.buildSELECT(T);

      final pkName = SQLetoSchemaUtils.getPKName(T);

      final select = await _connection?.mappedResultsQuery('$query WHERE $pkName = @$pkName', substitutionValues: {pkName: primaryKey});

      if (select == null) throw DatabaseException('Fail to get the returning of this operation!');

      if (select.isEmpty) throw NotFoundException('No founded $T wich this PK: $primaryKey');

      return SQLetoSchemaUtils.invokeFromPostgreSQLMap(T, select.first);
    } on SQLetoException {
      rethrow;
    } on PostgreSQLException catch (e) {
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
  Future<T> update<T extends SQLetoSchema>(SQLetoSchema Function() schema) async {
    try {
      final query = SQLetoSchemaUtils.buildUPDATE(T);

      final substitutionValues = SQLetoSchemaUtils.invokeToMap(schema);

      final update = await _connection?.mappedResultsQuery(query, substitutionValues: substitutionValues);

      if (update == null) throw DatabaseException('Fail to get the returning of this operation!');

      if (update.isEmpty) throw NotFoundException('No $T found with PK: ${substitutionValues[SQLetoSchemaUtils.getPKName(T)]} to update!');

      return SQLetoSchemaUtils.invokeFromPostgreSQLMap(T, update.first);
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
  Future<T> delete<T extends SQLetoSchema>(SQLetoSchema Function() schema) async {
    try {
      final query = SQLetoSchemaUtils.buildDELETE(T);

      final substitutionValues = SQLetoSchemaUtils.invokeToMap(schema);

      final delete = await _connection?.mappedResultsQuery(query, substitutionValues: substitutionValues);

      if (delete == null) throw DatabaseException('Fail to get the returning of this operation!');

      if (delete.isEmpty) throw NotFoundException('No $T found with PK: ${substitutionValues[SQLetoSchemaUtils.getPKName(T)]} to delete!');

      return SQLetoSchemaUtils.invokeFromPostgreSQLMap(T, delete.first);
    } on SQLetoException {
      rethrow;
    } on PostgreSQLException catch (e) {
      throw DatabaseException(e.message ?? 'Unhandled Postgres Exception!');
    } on Exception catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  void dispose() {}
}
