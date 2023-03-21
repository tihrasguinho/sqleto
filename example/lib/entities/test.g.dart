// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test.dart';

// **************************************************************************
// SQLetoGenerator
// **************************************************************************

class TestSchema extends Schema<Test> {
  final int age;
  final double weight;

  TestSchema._({
    required this.age,
    required this.weight,
  });

  factory TestSchema.create({
    required int age,
    required double weight,
  }) {
    return TestSchema._(
      age: age,
      weight: weight,
    );
  }

  static TestSchema fromMap(Map<String, dynamic> map) {
    return TestSchema._(
      age: map['age'] ?? 0,
      weight: map['weight'] ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() => {
        'age': age,
        'weight': weight,
      };

  TestSchema copyWith({
    int? age,
    double? weight,
  }) {
    return TestSchema._(
      age: age ?? this.age,
      weight: weight ?? this.weight,
    );
  }

  @override
  String get tableName => 'test';

  @override
  Future<void> save() => SQLeto.instance.update<TestSchema>(() => this);

  @override
  Future<void> delete() => SQLeto.instance.delete<TestSchema>(() => this);
}
