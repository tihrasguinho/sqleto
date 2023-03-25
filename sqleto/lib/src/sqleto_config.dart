import 'package:sqleto/sqleto.dart';

class SQLetoConfig {
  final String host;
  final int port;
  final String database;
  final String? username;
  final String? password;
  final bool useSSL;
  final List<SQLetoSchema Function()> schemas;

  SQLetoConfig({
    required this.host,
    required this.port,
    required this.database,
    this.username,
    this.password,
    this.useSSL = false,
    required this.schemas,
  });
}
