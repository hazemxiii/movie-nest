import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
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
import 'package:url_launcher/url_launcher.dart';

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
      } else if (Platform.isWindows) {
        userCredentials = await _signInWithGoogleWindows();
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

  Future<UserCredential> _signInWithGoogleWindows() async {
    const windowsClientId =
        '700191840421-jkaj1365vi4cfo6edfce3gkea2garuks.apps.googleusercontent.com';
    final codeVerifier = _randomString(64);
    final codeChallenge = base64UrlEncode(
      sha256.convert(utf8.encode(codeVerifier)).bytes,
    ).replaceAll('=', '');
    final state = _randomString(32);

    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final redirectUri = 'http://127.0.0.1:${server.port}';

    try {
      final authUri = Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
        'client_id': windowsClientId,
        'redirect_uri': redirectUri,
        'response_type': 'code',
        'scope': 'openid email profile',
        'code_challenge': codeChallenge,
        'code_challenge_method': 'S256',
        'state': state,
      });

      final launched = await launchUrl(
        authUri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        throw NestException('Could not open the browser');
      }

      final code = await _waitForAuthCode(
        server,
        state,
      ).timeout(const Duration(minutes: 3));

      final tokens = await _apiService.fetch(
        'users/google/token',
        ApiMethod.post,
        requestBody: {
          'code': code,
          'code_verifier': codeVerifier,
          'redirect_uri': redirectUri,
        },
      );
      final credential = GoogleAuthProvider.credential(
        idToken: tokens['id_token'] as String?,
        accessToken: tokens['access_token'] as String?,
      );
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } finally {
      await server.close(force: true);
    }
  }

  Future<String> _waitForAuthCode(
    HttpServer server,
    String expectedState,
  ) async {
    await for (final request in server) {
      final params = request.uri.queryParameters;

      // Ignore unrelated requests (e.g. /favicon.ico)
      if (!params.containsKey('code') && !params.containsKey('error')) {
        request.response.statusCode = HttpStatus.notFound;
        await request.response.close();
        continue;
      }

      final success =
          params['code'] != null && params['state'] == expectedState;

      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.html
        ..write(
          '<html><body style="font-family:sans-serif;text-align:center;margin-top:20%">'
          '<h2>${success ? 'Signed in successfully' : 'Sign in failed'}</h2>'
          '<p>You can close this tab and return to the app.</p>'
          '</body></html>',
        );
      await request.response.close();

      if (params.containsKey('error')) {
        throw NestException('Google sign-in was cancelled or denied');
      }
      if (!success) {
        throw NestException('Invalid OAuth state');
      }
      return params['code']!;
    }
    throw NestException('Sign-in server closed unexpectedly');
  }

  String _randomString(int length) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
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
