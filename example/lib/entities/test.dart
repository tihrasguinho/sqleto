import 'package:sqleto/sqleto.dart';

part 'test.g.dart';

@Table(name: 'test')
abstract class Test {
  @Column(type: SQLetoType.INTEGER, validator: SQLetoValidator.NEGATIVE_NUMBER)
  final int age;

  @Column(type: SQLetoType.FLOAT, validator: SQLetoValidator.NEGATIVE_NUMBER)
  final double weight;

  Test({
    required this.age,
    required this.weight,
  });
}
