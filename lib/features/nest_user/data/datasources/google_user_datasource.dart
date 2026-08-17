import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:movie_nest/core/exceptions/nest_exception.dart';
import 'package:movie_nest/core/services/api_service.dart';
import 'package:movie_nest/core/services/database_services/sqlite_service.dart';
import 'package:movie_nest/features/nest_user/data/datasources/user_data_source.dart';
import 'package:movie_nest/features/nest_user/data/entities/nest_user.dart';
import 'package:movie_nest/features/nest_user/data/models/google_user_model.dart';
import 'package:movie_nest/features/nest_user/data/models/server_user_model.dart';

class GoogleUserDatasource implements UserDataSource {
  GoogleUserDatasource({
    required this._apiService,
    required this._sqliteService,
  });

  final ApiService _apiService;
  final SqliteService _sqliteService;

  @override
  Future<NestUser> login() async {
    late final UserCredential userCredentials;
    late final GoogleUserModel googleUser;
    try {
      if (kIsWeb) {
        userCredentials = await _signInWithGoogleWeb();
      } else {
        userCredentials = await _signInWithGoogleMobile();
      }
      final userFromCredentials = userCredentials.user;
      if (userFromCredentials == null) {
        throw NestException('Failed to sign in');
      }
      googleUser = GoogleUserModel(
        id: userFromCredentials.uid,
        name: userFromCredentials.displayName!,
        email: userFromCredentials.email!,
        pictureUrl: userFromCredentials.photoURL,
      );
    } catch (e) {
      debugPrint('Google login error: $e');
      throw NestException('Failed to login with Google');
    }
    final emptyServerUser = ServerUserModel(
      id: googleUser.id,
      email: googleUser.email,
      name: googleUser.name,
      pictureUrl: googleUser.pictureUrl,
      googleUser: googleUser,
      listsCount: 0,
      mediaCount: 0,
    );
    try {
      final serverUserJson = await _apiService.fetch('users/me', ApiMethod.get);
      return ServerUserModel.fromJson(serverUserJson, googleUser).toEntity();
    } catch (e) {
      return emptyServerUser.toEntity();
    }
  }

  Future<UserCredential> _signInWithGoogleWeb() async {
    final provider = GoogleAuthProvider();

    return FirebaseAuth.instance.signInWithPopup(provider);
  }

  Future<UserCredential> _signInWithGoogleMobile() async {
    final googleSignIn = GoogleSignIn.instance;
    await googleSignIn.initialize(
      clientId:
          '700191840421-kj31d7fpg10smkpofbpqrpdpjrm3te9n.apps.googleusercontent.com',
      serverClientId:
          '700191840421-am164shmdt2iru41sps4m9jnijgfliad.apps.googleusercontent.com',
    );

    final result = await googleSignIn.authenticate();
    final credential = GoogleAuthProvider.credential(
      idToken: result.authentication.idToken,
    );
    return FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  Future<NestUser?> getUser() async {
    final signedInUser = FirebaseAuth.instance.currentUser;
    if (signedInUser == null) {
      return null;
    }
    final googleUser = GoogleUserModel(
      id: signedInUser.uid,
      name: signedInUser.displayName!,
      email: signedInUser.email!,
      pictureUrl: signedInUser.photoURL,
    );
    try {
      final serverUser = await _apiService.fetch('users/me', ApiMethod.get);
      return ServerUserModel.fromJson(serverUser, googleUser).toEntity();
    } catch (e) {
      return ServerUserModel(
        id: googleUser.id,
        email: googleUser.email,
        name: googleUser.name,
        pictureUrl: googleUser.pictureUrl,
        googleUser: googleUser,
        listsCount: 0,
        mediaCount: 0,
      ).toEntity();
    }
  }

  @override
  Future<void> signOut() async {
    await _sqliteService.clearTables();
    await FirebaseAuth.instance.signOut();
  }
}

final googleUserDS = Provider<GoogleUserDatasource>((ref) {
  return GoogleUserDatasource(
    apiService: ref.read(apiServiceProvider),
    sqliteService: ref.read(sqliteServiceProvider),
  );
});
