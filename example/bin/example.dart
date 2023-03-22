import 'dart:mirrors';

import 'package:example/entities/post.dart';
import 'package:example/entities/user.dart';

import 'package:sqleto/sqleto.dart';

void main() async {
  try {
    print(reflectClass(UserSchema).isSubclassOf(reflectClass(SQLetoSchema)));

    // final config = SQLetoConfig(
    //   host: 'host.docker.internal',
    //   port: 5432,
    //   database: 'postgres',
    //   username: 'postgres',
    //   password: 'postgres',
    //   schemas: [UserSchema, PostSchema],
    // );

    // await SQLeto.initialize(config);

    // final user = await createUser(
    //   () => UserSchema.create(
    //     name: 'John Doe',
    //     username: 'johndoe',
    //     email: 'johndoe@gmail.com',
    //     password: '123456',
    //     image: '',
    //   ),
    // );

    // final post = await createPost(
    //   () => PostSchema.create(
    //     title: 'My first post',
    //     body: 'LOL',
    //     ownerId: user.uid,
    //   ),
    // );

    // print(post.toMap());
  } on SQLetoException catch (e) {
    print(e.error);
  } on Exception catch (e) {
    print(e);
  }
}

Future<PostSchema> createPost(PostSchema Function() post) async {
  return await SQLeto.instance.insert<PostSchema>(post);
}

Future<UserSchema> createUser(UserSchema Function() user) async {
  return await SQLeto.instance.insert<UserSchema>(user);
}

Future<UserSchema> updateUser(UserSchema Function() user) async {
  return await SQLeto.instance.update<UserSchema>(user);
}

Future<UserSchema> deleteUser(UserSchema Function() user) async {
  return await SQLeto.instance.delete<UserSchema>(user);
}
