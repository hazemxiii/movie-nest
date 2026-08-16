import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/features/nest_user/data/datasources/firebase_token_datasource.dart';
import 'package:movie_nest/features/nest_user/data/repositories/token_repository_impl.dart';

abstract class TokenRepository {
  Future<String?> getToken();
}

final tokenRepoPrv = Provider<TokenRepository>((ref) {
  return TokenRepositoryImpl(ref.read(firebaseTokenDePrv));
});
