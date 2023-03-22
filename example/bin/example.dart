import 'package:example/entities/post.dart';
import 'package:example/entities/user.dart';

import 'package:sqleto/sqleto.dart';

void main() async {
  try {
    final config = SQLetoConfig(
      host: 'host.docker.internal',
      port: 5432,
      database: 'postgres',
      username: 'postgres',
      password: 'postgres',
      schemas: [UserSchema, PostSchema],
    );

    await SQLeto.initialize(config);

    // SELECT EXAMPLES --------------------------------------------

    List<PostSchema> posts = [];

    // Get all [PostSchema] from database!
    posts = await SQLeto.instance.select<PostSchema>();

    // Or with where to apply filters
    final where = Where('owner_id', Operator.EQUALS, '82184366-ea63-441a-9cf6-a3646299f16c');

    // Select posts by owner_id
    posts = await SQLeto.instance.select<PostSchema>(where);

    final whereByDate = Where('created_at', Operator.LESS_OR_EQUAL, DateTime.parse('2023-03-22 20:00:52.166887'));

    // Select posts merging two or more [Where]'s (active = true and created_at <= Date)
    posts = await SQLeto.instance.select<PostSchema>(Where('active', Operator.EQUALS, true)..and(whereByDate));

    print(posts);

    // INSERT EXAMPLES --------------------------------------------

    final user = await SQLeto.instance.insert<UserSchema>(
      () => UserSchema.create(
        name: 'John Doe',
        username: 'johndoe',
        email: 'john@gmail.com',
        password: '123456',
        image: '',
      ),
    );

    print(user.toMap());

    // Insert PostSchema with UserSchema reference
    final post = await SQLeto.instance.insert<PostSchema>(
      () => PostSchema.create(
        title: 'My first post',
        body: 'LOL',
        ownerId: user.uid,
      ),
    );

    print(post.toMap());

    // UPDATE EXAMPLES --------------------------------------------

    final updated1 = await SQLeto.instance.update<UserSchema>(() => user.copyWith(name: 'John Doe Edited'));

    print(updated1.toMap());

    // Or

    final updated2 = user.copyWith(name: 'John Doe Edited');

    await updated2.save();

    print(updated2.toMap());

    // DELETE EXAMPLES --------------------------------------------

    await SQLeto.instance.delete<UserSchema>(() => user);

    // Or

    await user.delete();
  } on SQLetoException catch (e) {
    print(e.error);
  } on Exception catch (e) {
    print(e);
  }
}
