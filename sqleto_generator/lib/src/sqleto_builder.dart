import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'sqleto_generator.dart';

Builder sqletoGenerator(BuilderOptions options) {
  return SharedPartBuilder([SQLetoGenerator()], 'sqleto_gen');
}
