import 'dart:convert';

import 'package:crypto/crypto.dart';

class SQLetoUtils {
  const SQLetoUtils._();

  static bool passwordMatches(String password, String hash) => sha256.convert(utf8.encode(password)).toString() == hash;
}
