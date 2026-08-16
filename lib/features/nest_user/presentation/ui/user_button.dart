import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_nest/core/services/toast_service.dart';
import 'package:movie_nest/core/theme/nest_theme.dart';
import 'package:movie_nest/core/theme/theme_notifier.dart';
import 'package:movie_nest/core/widgets/nest_button.dart';
import 'package:movie_nest/core/widgets/nest_image.dart';
import 'package:movie_nest/features/nest_user/presentation/viewmodels/user_viewmodel.dart';

class UserButton extends ConsumerWidget {
  const UserButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider).value!;
    final user = ref.watch(userVMPrv).value;
    final userController = ref.read(userVMPrv.notifier);
    if (user == null) {
      return NestButton(
        onTap: () async {
          try {
            await userController.login();
          } catch (e) {
            if (!context.mounted) return;
            ToastService.error(
              context,
              theme,
              message: e.toString(),
              title: 'Sign In Error',
            );
          }
        },
        icon: Icons.person_outline,
        backC: theme.secBackC,
        textC: theme.mainC,
        text: 'Sign In',
      );
    }
    return InkWell(
      onTap: () {
        context.push('/profile');
      },
      child: user.pictureUrl == null
          ? _fallBack(theme, user.name)
          : NestImage(
              url: user.pictureUrl!,
              height: 40,
              width: 40,
              borderRadius: 999,
              fallback: _fallBack(theme, user.name),
            ),
    );
  }

  Widget _fallBack(NestTheme theme, String userName) {
    return CircleAvatar(
      backgroundColor: theme.secBackC,
      radius: 20,
      child: Text(userName[0].toUpperCase(), style: theme.mainBold),
    );
  }
}
