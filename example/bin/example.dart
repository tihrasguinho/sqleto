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
      schemas: [UserEntitySchema],
    );

    final sqleto = await SQLeto.initialize(config);

    UserEntitySchema user = UserEntitySchema.create(
      name: 'Tiago Alves',
      username: 'tihrasguinho',
      email: 'tiago@gmail.com',
      password: '123456',
      image: '',
    );

    // Insert
    user = await sqleto.insert(() => user);

    user = user.copyWith(name: 'Tiago Alves (editado)');

    // Update
    user = await sqleto.update<UserEntitySchema>(() => user);

    // Alternative update
    await user.save();

    // Find by primary key
    user = await sqleto.findByPK<UserEntitySchema>('90613630-a4f7-4294-9065-ad2742f51df1');

    // Delete
    await sqleto.delete<UserEntitySchema>(() => user);

    // Alternative delete
    await user.delete();
  } on SQLetoException catch (e) {
    print(e.error);
  } on Exception catch (e) {
    print(e);
  }
}
