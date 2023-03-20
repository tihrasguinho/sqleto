// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_entity.dart';

// **************************************************************************
// SQLetoGenerator
// **************************************************************************

class PostEntitySchema extends Schema<PostEntity> {
  final String uid;
  final String title;
  final String body;
  final String ownerId;
  final DateTime createdAt;
  final bool active;

  PostEntitySchema._({
    required this.uid,
    required this.title,
    required this.body,
    required this.ownerId,
    required this.createdAt,
    required this.active,
  });

  factory PostEntitySchema.create({
    required String title,
    required String body,
    required String ownerId,
  }) {
    return PostEntitySchema._(
      uid: '',
      title: title,
      body: body,
      ownerId: ownerId,
      createdAt: DateTime.now(),
      active: false,
    );
  }

  static PostEntitySchema fromMap(Map<String, dynamic> map) {
    return PostEntitySchema._(
      uid: map['uid'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      ownerId: map['owner_id'] ?? '',
      createdAt: map['created_at'] ?? DateTime.now(),
      active: map['active'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'title': title,
        'body': body,
        'owner_id': ownerId,
        'created_at': createdAt,
        'active': active,
      };

  PostEntitySchema copyWith({
    String? title,
    String? body,
    String? ownerId,
  }) {
    return PostEntitySchema._(
      uid: uid,
      title: title ?? this.title,
      body: body ?? this.body,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt,
      active: active,
    );
  }

  @override
  String get tableName => 'tb_posts';

  @override
  Future<void> save() => SQLeto.instance.update<PostEntitySchema>(() => this);

  @override
  Future<void> delete() => SQLeto.instance.delete<PostEntitySchema>(() => this);
}
