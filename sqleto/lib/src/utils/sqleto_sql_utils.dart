class SQLetoSQLUtils {
  SQLetoSQLUtils._();

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
CREATE TRIGGER ON_UPDATE_${tableName.toUpperCase()}
  BEFORE UPDATE ON ${tableName.toUpperCase()}
  FOR EACH ROW
  EXECUTE PROCEDURE AT_UPDATE_ROW();
''';

  static String createListenOnChanged() => 'LISTEN on_changed;';

  static String createFunctionOnChanged() => r'''
CREATE OR REPLACE FUNCTION FUNCTION_ON_CHANGED()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM PG_NOTIFY('on_changed', '{"table_name":"'||TG_TABLE_NAME||'","operation":"'||TG_OP||'","current_time":"'||to_char(now(),'HH24:MI:SS')||'"}');
  RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';
''';

  static String createTriggerOnChangedOnTable(String tableName) => '''
CREATE OR REPLACE TRIGGER TRIGGER_ON_CHANGED
  AFTER INSERT OR UPDATE ON ${tableName.toUpperCase()}
  FOR EACH ROW
  EXECUTE PROCEDURE FUNCTION_ON_CHANGED();
''';

  static String dropOnChangedTriggerFromTable(String tableName) => 'DROP TRIGGER IF EXISTS TRIGGER_ON_CHANGED ON ${tableName.toUpperCase()}';
}
