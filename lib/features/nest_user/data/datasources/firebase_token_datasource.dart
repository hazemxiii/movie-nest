import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/features/nest_user/data/datasources/token_datasource.dart';

class FirebaseTokenDatasource implements TokenDatasource {
  @override
  Future<String?> getToken() async {
    try {
      return await FirebaseAuth.instance.currentUser!.getIdToken();
    } catch (e) {
      return null;
    }
  }
}

final firebaseTokenDePrv = Provider<FirebaseTokenDatasource>((ref) {
  return FirebaseTokenDatasource();
});
