// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// SchemaGenerator
// **************************************************************************

class PostSchema extends Post {
  PostSchema({
    required super.uid,
    required super.title,
    required super.body,
    required super.ownerId,
    required super.createdAt,
    required super.active,
  });

  factory PostSchema.empty() {
    return PostSchema(
      uid: '',
      title: '',
      body: '',
      ownerId: '',
      createdAt: DateTime.now(),
      active: false,
    );
  }

  factory PostSchema.create({
    required String title,
    required String body,
    required String ownerId,
  }) {
    return PostSchema(
      uid: '', // WILL BE AUTOMATICALLY GENERATED
      title: title,
      body: body,
      ownerId: ownerId,
      createdAt: DateTime.now(), // WILL BE AUTOMATICALLY GENERATED
      active: false, // WILL BE AUTOMATICALLY GENERATED
    );
  }

  static PostSchema fromMap(Map<String, dynamic> map) {
    return PostSchema(
      uid: map['uid'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      ownerId: map['owner_id'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] ?? 0),
      active: map['active'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'title': title,
        'body': body,
        'owner_id': ownerId,
        'created_at': createdAt.millisecondsSinceEpoch,
        'active': active,
      };

  PostSchema copyWith({
    String? title,
    String? body,
    String? ownerId,
  }) {
    return PostSchema(
      uid: uid,
      title: title ?? this.title,
      body: body ?? this.body,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt,
      active: active,
    );
  }

  @override
  Future<void> save() => SQLeto.instance.update<PostSchema>(() => this);

  @override
  Future<void> delete() => SQLeto.instance.delete<PostSchema>(() => this);

  @override
  String get tableName => 'tb_post';
}
