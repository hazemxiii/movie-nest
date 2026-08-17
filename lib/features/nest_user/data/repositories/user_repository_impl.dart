import 'package:movie_nest/features/nest_user/data/datasources/user_data_source.dart';
import 'package:movie_nest/features/nest_user/data/entities/nest_user.dart';
import 'package:movie_nest/features/nest_user/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._dataSource);
  final UserDataSource _dataSource;

  @override
  Future<NestUser> login() async {
    return await _dataSource.login();
  }

  @override
  Future<NestUser?> getUser() async {
    return await _dataSource.getUser();
  }

  @override
  Future<void> signOut() async {
    return await _dataSource.signOut();
  }
}
