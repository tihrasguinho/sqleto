import 'package:sqleto/sqleto.dart';

import 'entities/post.dart';
import 'entities/user.dart';

void mainInsert() async {
  try {
    final config = SQLetoConfig(
      host: 'host.docker.internal',
      port: 5432,
      database: 'postgres',
      username: 'postgres',
      password: 'postgres',
      schemas: [
        () => UserSchema.empty(),
        () => PostSchema.empty(),
      ],
    );

    await SQLeto.initialize(config);

    // Insert a single record
    final user = await SQLeto.instance.insert<UserSchema>(
      () => UserSchema.create(
        name: 'John Doe',
        username: 'johndoe',
        email: 'johndoe@gmail.com',
        password: '123456',
        image: '',
      ),
    );

    print(user.toMap());

    // Insert with foreignKey reference
    final post = await SQLeto.instance.insert<PostSchema>(
      () => PostSchema.create(
        title: 'My second post',
        body: 'LOL OMEGALUL',
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

void mainSelect() async {
  try {
    final config = SQLetoConfig(
      host: 'host.docker.internal',
      port: 5432,
      database: 'postgres',
      username: 'postgres',
      password: 'postgres',
      schemas: [
        () => UserSchema.empty(),
        () => PostSchema.empty(),
      ],
    );

    await SQLeto.initialize(config);

    List<UserSchema> users = [];

    // All
    users = await SQLeto.instance.select<UserSchema>();

    // With [Where] filters
    users = await SQLeto.instance.select<UserSchema>(Where('username', Operator.I_LIKE, 'john%'));

    print(users.map((e) => e.toMap()).toList());

    // By primary key
    final user = await SQLeto.instance.findByPK<UserSchema>('a6e29ec6-fb82-4945-9b65-de9ef03f0e35');

    print(user.toMap());

    // You can also listen when table changes in real time and with [Where] filters
    final stream = SQLeto.instance.onChanged<UserSchema>();

    stream.listen((event) => print(event.map((e) => e.toMap()).toList()));
  } on SQLetoException catch (e) {
    print(e.error);
  } on Exception catch (e) {
    print(e);
  }
}

void mainUpdate() async {
  try {
    final config = SQLetoConfig(
      host: 'host.docker.internal',
      port: 5432,
      database: 'postgres',
      username: 'postgres',
      password: 'postgres',
      schemas: [
        () => UserSchema.empty(),
        () => PostSchema.empty(),
      ],
    );

    await SQLeto.initialize(config);

    UserSchema user = await SQLeto.instance.findByPK<UserSchema>('843092cf-8981-4388-b739-fe3d2a3a04b0');

    user = user.copyWith(name: 'John Doe Edited');

    await SQLeto.instance.update<UserSchema>(() => user);

    // Or

    await user.save();

    print(user.toMap());
  } on SQLetoException catch (e) {
    print(e.error);
  } on Exception catch (e) {
    print(e);
  }
}

void mainDelete() async {
  try {
    final config = SQLetoConfig(
      host: 'host.docker.internal',
      port: 5432,
      database: 'postgres',
      username: 'postgres',
      password: 'postgres',
      schemas: [
        () => UserSchema.empty(),
        () => PostSchema.empty(),
      ],
    );

    await SQLeto.initialize(config);

    UserSchema user = await SQLeto.instance.findByPK<UserSchema>('843092cf-8981-4388-b739-fe3d2a3a04b0');

    await SQLeto.instance.delete<UserSchema>(() => user);

    // Or

    await user.delete();
  } on SQLetoException catch (e) {
    print(e.error);
  } on Exception catch (e) {
    print(e);
  }
}
