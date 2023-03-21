import 'package:sqleto/sqleto.dart';

part 'user_entity.g.dart';

@Table(name: 'tb_users')
abstract class UserEntity {
  @Column(type: SQLetoType.UUID, defaultValue: SQLetoDefaultValue.UUID_GENERATE_V4, primaryKey: true)
  final String uid;

  @Column(type: SQLetoType.TEXT)
  final String name;

  @Column(type: SQLetoType.TEXT, validator: SQLetoValidator.usernameValidator, unique: true)
  final String username;

  @Column(type: SQLetoType.TEXT, validator: SQLetoValidator.emailValidator, unique: true)
  final String email;

  @Column(type: SQLetoType.TEXT, validator: SQLetoValidator.emptyValidator, password: true)
  final String password;

  @Column(type: SQLetoType.TEXT, nullable: true)
  final String image;

  @Column(type: SQLetoType.TIMESTAMPTZ, defaultValue: SQLetoDefaultValue.TIMESTAMP_NOW)
  final DateTime createdAt;

  @Column(type: SQLetoType.TIMESTAMPTZ, defaultValue: SQLetoDefaultValue.TIMESTAMP_NOW)
  final DateTime updatedAt;

  UserEntity({
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