import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/features/nest_user/data/datasources/google_user_datasource.dart';
import 'package:movie_nest/features/nest_user/data/entities/nest_user.dart';
import 'package:movie_nest/features/nest_user/data/repositories/user_repository_impl.dart';

abstract class UserRepository {
  Future<NestUser> login();
  Future<NestUser?> getUser();
  Future<void> signOut();
}

final userRepoPrv = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(ref.read(googleUserDS));
});
