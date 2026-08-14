import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/core/exceptions/nest_exception.dart';
import 'package:movie_nest/features/nest_user/data/datasources/user_data_source.dart';
import 'package:movie_nest/features/nest_user/data/entities/nest_user.dart';
import 'package:movie_nest/features/nest_user/data/models/google_user_model.dart';
import 'package:movie_nest/features/nest_user/data/models/server_user_model.dart';

class GoogleUserDatasource implements UserDataSource {
  @override
  Future<NestUser> login() async {
    try {
      if (kIsWeb) {
        final userCredentials = await _signInWithGoogleWeb();
        final userFromCredentials = userCredentials.user;
        if (userFromCredentials == null) {
          throw NestException('Failed to sign in');
        }
        final googleUser = GoogleUserModel(
          id: userFromCredentials.uid,
          name: userFromCredentials.displayName!,
          email: userFromCredentials.email!,
          pictureUrl: userFromCredentials.photoURL,
        );
        final serverUser = ServerUserModel(
          id: googleUser.id,
          email: googleUser.email,
          name: null,
          pictureUrl: null,
          googleUser: googleUser,
        );

        return serverUser.toEntity();
      }
      // TODO: Implement mobile sign-in
      throw Exception();
    } catch (e) {
      throw NestException('Failed to login with Google');
    }
  }

  Future<UserCredential> _signInWithGoogleWeb() async {
    final provider = GoogleAuthProvider();

    return FirebaseAuth.instance.signInWithPopup(provider);
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
    final serverUser = ServerUserModel(
      id: googleUser.id,
      email: googleUser.email,
      name: null,
      pictureUrl: null,
      googleUser: googleUser,
    );
    return serverUser.toEntity();
  }
}

final googleUserDS = Provider<GoogleUserDatasource>((ref) {
  return GoogleUserDatasource();
});
