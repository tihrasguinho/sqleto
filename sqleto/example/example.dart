import 'package:sqleto/sqleto.dart';

import 'entities/post.dart';
import 'entities/user.dart';

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

    final user = await createUser(
      () => UserSchema.create(
        name: 'John Doe',
        username: 'johndoe',
        email: 'johndoe@gmail.com',
        password: '123456',
        image: '',
      ),
    );

    print(user.toMap());

    final post = await createPost(
      () => PostSchema.create(
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

// Insert post
Future<PostSchema> createPost(PostSchema Function() post) async {
  return await SQLeto.instance.insert<PostSchema>(post);
}

// Update post
Future<PostSchema> updatePost(PostSchema Function() post) async {
  return await SQLeto.instance.update<PostSchema>(post);
}

// Delete post
Future<PostSchema> deletePost(PostSchema Function() post) async {
  return await SQLeto.instance.delete<PostSchema>(post);
}

// Insert user
Future<UserSchema> createUser(UserSchema Function() user) async {
  return await SQLeto.instance.insert<UserSchema>(user);
}

// Update User
Future<UserSchema> updateUser(UserSchema Function() user) async {
  return await SQLeto.instance.update<UserSchema>(user);
}

// Delete User
Future<UserSchema> deleteUser(UserSchema Function() user) async {
  return await SQLeto.instance.delete<UserSchema>(user);
}
