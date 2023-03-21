import 'package:sqleto/sqleto.dart';

import 'user_entity.dart';

part 'post_entity.g.dart';

@Table(name: 'tb_posts')
abstract class PostEntity {
  @Column(type: SQLetoType.UUID, primaryKey: true, defaultValue: SQLetoDefaultValue.UUID_GENERATE_V4)
  final String uid;

  @Column(type: SQLetoType.TEXT)
  final String title;

  @Column(type: SQLetoType.TEXT)
  final String body;

  @Column(type: SQLetoType.UUID, references: UserEntity)
  final String ownerId;

  @Column(type: SQLetoType.TIMESTAMP, defaultValue: SQLetoDefaultValue.NOW)
  final DateTime createdAt;

  @Column(type: SQLetoType.BOOLEAN, defaultValue: SQLetoDefaultValue.TRUE)
  final bool active;

  PostEntity({
    required this.uid,
    required this.title,
    required this.body,
    required this.ownerId,
    required this.createdAt,
    required this.active,
  });
}
