import 'package:postgres/postgres.dart';

import 'package:sqleto/sqleto.dart';

import 'utils/sql_utils.dart';

class SQLeto {
  static final _instance = SQLeto._();

  PostgreSQLConnection? _connection;

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

      await _instance._connection?.transaction((connection) async {
        await connection.query(SQLUtils.createUuidExtension());

        await connection.query(SQLUtils.createPGCryptoExtension());

        await connection.query(SQLUtils.createAutoUpdateAt());

        for (final schema in config.schemas) {
          await connection.query(SQLetoSchemaUtils.buildClassSCHEMA(schema));
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

  /// Insert a schema [T] on database
  ///
  /// E.g.:
  /// ```dart
  ///
  /// UserSchema user = UserSchema.create(name: 'John Doe', email: 'johndoe@gmail.com', password: '123456');
  ///
  /// user = await SQLeto.instence.insert<UserSchema>(user);
  /// ```
  Future<T> insert<T extends Schema>(Schema Function() schema) async {
    try {
      final query = SQLetoSchemaUtils.buildINSERT(schema().runtimeType);

      final substitutionValues = SQLetoSchemaUtils.invokeToMap(schema);

      final insert = await _connection?.mappedResultsQuery(query, substitutionValues: substitutionValues);

      if (insert == null) throw DatabaseException('Fail to get the returning of this operation!');

      return SQLetoSchemaUtils.invokeFromMap(T, insert.first[SQLetoSchemaUtils.tableName(T)]!);
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
  /// final where = Where('name', Op.equals, 'John Doe');
  /// ```
  /// If necessary you can merge multiple [Where]
  ///
  /// ```dart
  /// where.and(Where('created_at', Op.lessThan, DateTime.now()));
  ///
  /// where.or(Where('created_at', Op.moreThan, DateTime.now()));
  ///
  /// List<UserSchema> users = await SQLeto.instance.select<UserSchema>(where);
  /// ```
  Future<List<T>> select<T extends Schema>([Where? where]) async {
    try {
      final query = SQLetoSchemaUtils.buildSELECT(T, where?.whereScript());

      final select = await _connection?.mappedResultsQuery(query, substitutionValues: where?.substitutionValues());

      if (select == null) throw DatabaseException('Fail to get the returning of this operation!');

      return select.map((e) => SQLetoSchemaUtils.invokeFromMap(T, e[SQLetoSchemaUtils.tableName(T)]!) as T).toList();
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
  Future<T> findByPK<T extends Schema>(dynamic primaryKey) async {
    try {
      final query = SQLetoSchemaUtils.buildSELECT(T);

      final pkName = SQLetoSchemaUtils.getPKName(T);

      final select = await _connection?.mappedResultsQuery('$query WHERE $pkName = @$pkName', substitutionValues: {pkName: primaryKey});

      if (select == null) throw DatabaseException('Fail to get the returning of this operation!');

      if (select.isEmpty) throw NotFoundException('No founded $T wich this PK: $primaryKey');

      return SQLetoSchemaUtils.invokeFromMap(T, select.first[SQLetoSchemaUtils.tableName(T)]!);
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
  Future<T> update<T extends Schema>(Schema Function() schema) async {
    try {
      final query = SQLetoSchemaUtils.buildUPDATE(T);

      final substitutionValues = SQLetoSchemaUtils.invokeToMap(schema);

      final update = await _connection?.mappedResultsQuery(query, substitutionValues: substitutionValues);

      if (update == null) throw DatabaseException('Fail to get the returning of this operation!');

      if (update.isEmpty) throw NotFoundException('No $T found with PK: ${substitutionValues[SQLetoSchemaUtils.getPKName(T)]} to update!');

      return SQLetoSchemaUtils.invokeFromMap(T, update.first[SQLetoSchemaUtils.tableName(T)]!);
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
  Future<T> delete<T extends Schema>(Schema Function() schema) async {
    try {
      final query = SQLetoSchemaUtils.buildDELETE(T);

      final substitutionValues = SQLetoSchemaUtils.invokeToMap(schema);

      final delete = await _connection?.mappedResultsQuery(query, substitutionValues: substitutionValues);

      if (delete == null) throw DatabaseException('Fail to get the returning of this operation!');

      if (delete.isEmpty) throw NotFoundException('No $T found with PK: ${substitutionValues[SQLetoSchemaUtils.getPKName(T)]} to delete!');

      return SQLetoSchemaUtils.invokeFromMap(T, delete.first[SQLetoSchemaUtils.tableName(T)]!);
    } on SQLetoException {
      rethrow;
    } on PostgreSQLException catch (e) {
      throw DatabaseException(e.message ?? 'Unhandled Postgres Exception!');
    } on Exception catch (e) {
      throw DatabaseException(e.toString());
    }
  }
}
