class SQLUtils {
  SQLUtils._();

  static String createPGCryptoExtension() => 'CREATE EXTENSION IF NOT EXISTS pgcrypto';

  static String createUuidExtension() => 'CREATE EXTENSION IF NOT EXISTS "uuid-ossp"';

  static String createAutoUpdateAt([String defaultUpdatedAt = 'UPDATED_AT']) => '''
CREATE OR REPLACE FUNCTION AT_UPDATE_ROW()   
RETURNS TRIGGER AS \$\$
BEGIN
    NEW.$defaultUpdatedAt = NOW();
    RETURN NEW;   
END;
\$\$ language 'plpgsql';
''';

  static String createTrigger(String tableName) => '''
CREATE TRIGGER ON_UPDATE_${tableName.toUpperCase()} BEFORE UPDATE ON ${tableName.toUpperCase()} FOR EACH ROW EXECUTE PROCEDURE AT_UPDATE_ROW();
''';
}
