// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// SchemaGenerator
// **************************************************************************

class UserSchema extends User {
  UserSchema({
    required super.uid,
    required super.name,
    required super.username,
    required super.email,
    required super.password,
    required super.image,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserSchema.empty() {
    return UserSchema(
      uid: '',
      name: '',
      username: '',
      email: '',
      password: '',
      image: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  factory UserSchema.create({
    required String name,
    required String username,
    required String email,
    required String password,
    required String image,
  }) {
    return UserSchema(
      uid: '', // WILL BE AUTOMATICALLY GENERATED
      name: name,
      username: username,
      email: email,
      password: password,
      image: image,
      createdAt: DateTime.now(), // WILL BE AUTOMATICALLY GENERATED
      updatedAt: DateTime.now(), // WILL BE AUTOMATICALLY GENERATED
    );
  }

  static UserSchema fromMap(Map<String, dynamic> map) {
    return UserSchema(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      image: map['image'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'username': username,
        'email': email,
        'password': password,
        'image': image,
        'created_at': createdAt.millisecondsSinceEpoch,
        'updated_at': updatedAt.millisecondsSinceEpoch,
      };

  UserSchema copyWith({
    String? name,
    String? username,
    String? email,
    String? password,
    String? image,
  }) {
    return UserSchema(
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
  Future<void> save() => SQLeto.instance.update<UserSchema>(() => this);

  @override
  Future<void> delete() => SQLeto.instance.delete<UserSchema>(() => this);

  @override
  String get tableName => 'tb_user';
}
