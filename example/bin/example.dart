import 'package:example/entities/post_entity.dart';
import 'package:example/entities/user_entity.dart';

import 'package:sqleto/sqleto.dart';

void main() async {
  try {
    final config = SQLetoConfig(
      host: 'host.docker.internal',
      port: 5432,
      database: 'postgres',
      username: 'postgres',
      password: 'postgres',
      schemas: [UserEntitySchema, PostEntitySchema],
    );

    await SQLeto.initialize(config);

    final user = await createUser(
      () => UserEntitySchema.create(
        name: 'John Doe',
        username: 'johndoe',
        email: 'johndoe@gmail.com',
        password: '123456',
        image: '',
      ),
    );

    final post = await createPost(
      () => PostEntitySchema.create(
        title: 'My first post',
        body: 'LOL',
        ownerId: user.uid,
      ),
    );

    print(post.toMap());
  } on SQLetoException catch (e) {
    print(e.error);
  } on Exception catch (e) {
    print(e);
  }
}

Future<PostEntitySchema> createPost(PostEntitySchema Function() post) async {
  return await SQLeto.instance.insert<PostEntitySchema>(post);
}

Future<UserEntitySchema> createUser(UserEntitySchema Function() user) async {
  return await SQLeto.instance.insert<UserEntitySchema>(user);
}

Future<UserEntitySchema> updateUser(UserEntitySchema Function() user) async {
  return await SQLeto.instance.update<UserEntitySchema>(user);
}

Future<UserEntitySchema> deleteUser(UserEntitySchema Function() user) async {
  return await SQLeto.instance.delete<UserEntitySchema>(user);
}
