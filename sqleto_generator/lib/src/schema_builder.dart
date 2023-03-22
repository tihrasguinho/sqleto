import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'schema_generator.dart';

Builder schemaBuilder(BuilderOptions options) {
  return SharedPartBuilder([SchemaGenerator(options)], 'schema_gen');
}
