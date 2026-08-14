import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/core/services/toast_service.dart';
import 'package:movie_nest/core/theme/theme_notifier.dart';
import 'package:movie_nest/core/widgets/nest_button.dart';
import 'package:movie_nest/core/widgets/nest_image.dart';
import 'package:movie_nest/features/nest_user/presentation/viewmodels/user_viewmodel.dart';

class UserButton extends ConsumerWidget {
  const UserButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider).value!;
    final userState = ref.watch(userVMPrv);
    final userController = ref.read(userVMPrv.notifier);
    return userState.when(
      data: (user) {
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
        if (user.pictureUrl == null) {
          return CircleAvatar(
            backgroundColor: theme.secBackC,
            radius: 20,
            child: Text(user.name[0].toUpperCase(), style: theme.mainBold),
          );
        }
        return NestImage(
          url: user.pictureUrl!,
          height: 40,
          width: 40,
          borderRadius: 999,
        );
      },
      loading: () => CircularProgressIndicator(color: theme.mainC),
      error: (error, stackTrace) => Container(),
    );
  }
}
