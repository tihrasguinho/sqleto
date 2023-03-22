import 'package:sqleto/sqleto.dart';

part 'user.g.dart';

abstract class User extends SQLetoSchema {
  @Field(type: SQLetoType.UUID, defaultValue: SQLetoDefaultValue.UUID_GENERATE_V4, primaryKey: true)
  final String uid;

  @Field(type: SQLetoType.TEXT)
  final String name;

  @Field(type: SQLetoType.TEXT, validator: SQLetoValidator.USERNAME, unique: true)
  final String username;

  @Field(type: SQLetoType.TEXT, validator: SQLetoValidator.EMAIL, unique: true)
  final String email;

  @Field(type: SQLetoType.TEXT, validator: SQLetoValidator.EMPTY_TEXT, password: true)
  final String password;

  @Field(type: SQLetoType.TEXT, nullable: true)
  final String image;

  @Field(type: SQLetoType.TIMESTAMPTZ, defaultValue: SQLetoDefaultValue.NOW)
  final DateTime createdAt;

  @Field(type: SQLetoType.TIMESTAMPTZ, defaultValue: SQLetoDefaultValue.NOW)
  final DateTime updatedAt;

  User({
    required this.uid,
    required this.name,
    required this.username,
    required this.email,
    required this.password,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
  });
}
