import 'package:movie_nest/features/nest_user/data/datasources/token_datasource.dart';
import 'package:movie_nest/features/nest_user/domain/repositories/token_repository.dart';

class TokenRepositoryImpl implements TokenRepository {
  TokenRepositoryImpl(this._dataSource);
  final TokenDatasource _dataSource;

  @override
  Future<String?> getToken() async {
    return await _dataSource.getToken();
  }
}
