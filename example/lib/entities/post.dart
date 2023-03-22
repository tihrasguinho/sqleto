import 'package:sqleto/sqleto.dart';

import 'user.dart';

part 'post.g.dart';

abstract class Post extends SQLetoSchema {
  @Field(type: SQLetoType.UUID, primaryKey: true, defaultValue: SQLetoDefaultValue.UUID_GENERATE_V4)
  final String uid;

  @Field(type: SQLetoType.TEXT)
  final String title;

  @Field(type: SQLetoType.TEXT)
  final String body;

  @Field(type: SQLetoType.UUID, references: User)
  final String ownerId;

  @Field(type: SQLetoType.TIMESTAMP, defaultValue: SQLetoDefaultValue.NOW)
  final DateTime createdAt;

  @Field(type: SQLetoType.BOOLEAN, defaultValue: SQLetoDefaultValue.NOW)
  final bool active;

  Post({
    required this.uid,
    required this.title,
    required this.body,
    required this.ownerId,
    required this.createdAt,
    required this.active,
  });
}
