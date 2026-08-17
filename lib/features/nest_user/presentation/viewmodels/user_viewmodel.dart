import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/features/nest_user/data/entities/nest_user.dart';
import 'package:movie_nest/features/nest_user/domain/repositories/user_repository.dart';

class UserViewModel extends AsyncNotifier<NestUser?> {
  @override
  FutureOr<NestUser?> build() async {
    return await ref.read(userRepoPrv).getUser();
  }

  Future<void> login() async {
    final user = await ref.read(userRepoPrv).login();
    state = AsyncValue.data(user);
  }

  Future<void> signOut() async {
    await ref.read(userRepoPrv).signOut();
    state = const AsyncValue.data(null);
  }
}

final userVMPrv = AsyncNotifierProvider<UserViewModel, NestUser?>(
  UserViewModel.new,
);
