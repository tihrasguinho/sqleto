abstract class SQLetoSchema<T extends Object> {
  /// Table name on database
  String get tableName;

  /// Update a $T on database
  Future<void> save();

  /// Delete a $T from database
  Future<void> delete();
}
