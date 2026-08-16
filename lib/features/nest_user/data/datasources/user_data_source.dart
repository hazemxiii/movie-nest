import 'package:movie_nest/features/nest_user/data/entities/nest_user.dart';

abstract class UserDataSource {
  Future<NestUser> login();
  Future<NestUser?> getUser();
  Future<void> signOut();
}
