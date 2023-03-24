import 'dart:async';

import 'package:sqleto/sqleto.dart';

import 'entities/post.dart';
import 'entities/user.dart';

void main() async {
  try {
    final config = SQLetoConfig(
      host: 'host.docker.internal',
      port: 5432,
      database: 'sqleto_first',
      username: 'postgres',
      password: 'postgres',
      schemas: [
        UserSchema,
        PostSchema,
      ],
    );

    await SQLeto.initialize(config).then((value) => print('CONNECTADO'));

    // On changed stream (Under development)

    final usersStream = SQLeto.instance.onChanged<UserSchema>();

    usersStream.listen((event) => print(event.length));

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
        name: 'Tiago Alves',
        username: 'tihrasguinho',
        email: 'tiago@gmail.com',
        password: '123456',
        image: '',
      ),
    );

    // Insert PostSchema with UserSchema reference
    final post = await SQLeto.instance.insert<PostSchema>(
      () => PostSchema.create(
        title: 'My second post',
        body: 'LOL OMEGALUL',
        ownerId: '6839c947-b6e8-4be4-8464-063460459e37',
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

Stream<List<T>> on<T extends SQLetoSchema>([Where? where]) async* {
  while (true) {
    final internalWhere = where;

    yield await SQLeto.instance.select<T>(internalWhere);

    await Future.delayed(Duration(seconds: 1));
  }
}
