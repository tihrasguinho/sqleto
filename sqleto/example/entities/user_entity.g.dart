// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_entity.dart';

// **************************************************************************
// SQLetoGenerator
// **************************************************************************

class UserEntitySchema extends Schema<UserEntity> {
  final String uid;
  final String name;
  final String username;
  final String email;
  final String password;
  final String image;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserEntitySchema._({
    required this.uid,
    required this.name,
    required this.username,
    required this.email,
    required this.password,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserEntitySchema.create({
    required String name,
    required String username,
    required String email,
    required String password,
    required String image,
  }) {
    return UserEntitySchema._(
      uid: '',
      name: name,
      username: username,
      email: email,
      password: password,
      image: image,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  static UserEntitySchema fromMap(Map<String, dynamic> map) {
    return UserEntitySchema._(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      image: map['image'] ?? '',
      createdAt: map['created_at'] ?? DateTime.now(),
      updatedAt: map['updated_at'] ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'username': username,
        'email': email,
        'password': password,
        'image': image,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  UserEntitySchema copyWith({
    String? name,
    String? username,
    String? email,
    String? password,
    String? image,
  }) {
    return UserEntitySchema._(
      uid: uid,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      image: image ?? this.image,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  String get tableName => 'tb_users';

  @override
  Future<void> save() => SQLeto.instance.update<UserEntitySchema>(() => this);

  @override
  Future<void> delete() => SQLeto.instance.delete<UserEntitySchema>(() => this);
}
