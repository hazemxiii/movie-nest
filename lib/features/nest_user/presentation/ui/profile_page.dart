import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_nest/core/services/toast_service.dart';
import 'package:movie_nest/core/theme/nest_theme.dart';
import 'package:movie_nest/core/theme/theme_notifier.dart';
import 'package:movie_nest/core/widgets/nest_button.dart';
import 'package:movie_nest/core/widgets/nest_error_widget.dart';
import 'package:movie_nest/core/widgets/nest_image.dart';
import 'package:movie_nest/features/nest_user/presentation/ui/profile_page_shimmer.dart';
import 'package:movie_nest/features/nest_user/presentation/viewmodels/user_viewmodel.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSmall = MediaQuery.of(context).size.width < 700;
    final theme = ref.watch(themeProvider).value!;
    final userController = ref.read(userVMPrv.notifier);
    final userState = ref.watch(userVMPrv);
    return userState.when(
      data: (user) {
        if (user == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/');
          });
          return const SizedBox.shrink();
        }
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(26),
                decoration: BoxDecoration(
                  color: theme.secBackC,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.borderC, width: 1),
                ),
                child: Flex(
                  spacing: 16,
                  mainAxisAlignment: isSmall
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.start,
                  direction: isSmall ? Axis.vertical : Axis.horizontal,
                  children: [
                    _image(user.pictureUrl, theme, user.name),
                    Column(
                      crossAxisAlignment: isSmall
                          ? CrossAxisAlignment.center
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          textAlign: TextAlign.center,
                          style: theme.largeBold,
                        ),
                        Text(user.email, style: theme.sec),
                      ],
                    ),
                    if (!isSmall) const Spacer(),
                    NestButton(
                      backC: Colors.transparent,
                      borderC: theme.errorC,
                      textC: theme.errorC,
                      onTap: () async {
                        try {
                          await userController.signOut();
                        } catch (e) {
                          if (!context.mounted) return;
                          ToastService.error(
                            context,
                            theme,
                            message: e.toString(),
                            title: 'Error',
                          );
                        }
                      },
                      text: 'Sign Out',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Wrap(
                spacing: 20,
                runSpacing: 20,
                children: [
                  _tag(theme, 'Lists', user.listsCount),
                  _tag(theme, 'Media', user.mediaCount),
                ],
              ),
            ],
          ),
        );
      },
      error: (error, stack) {
        return NestErrorWidget(
          message: error.toString(),
          onTap: () {
            ref.invalidate(userVMPrv);
          },
        );
      },
      loading: () {
        return ProfileShimmer(isSmall: isSmall);
      },
    );
  }

  Widget _tag(NestTheme theme, String title, int number) {
    return Container(
      padding: const EdgeInsets.all(15),
      constraints: const BoxConstraints(minWidth: 120),
      decoration: BoxDecoration(
        color: theme.secBackC,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.borderC, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.secBold),
          Text(number.toString(), style: theme.bigBold),
        ],
      ),
    );
  }

  Widget _image(String? url, NestTheme theme, String name) {
    const imgSize = 100.0;
    if (url == null) {
      return _fallBack(theme, name);
    } else {
      return NestImage(
        url: url,
        height: imgSize,
        width: imgSize,
        borderRadius: 25,
        fallback: _fallBack(theme, name),
      );
    }
  }

  Widget _fallBack(NestTheme theme, String userName) {
    return Container(
      alignment: Alignment.center,
      height: 100,
      width: 100,
      decoration: BoxDecoration(
        color: theme.mainC.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: theme.borderC, width: 1),
      ),
      child: Text(
        _getInitials(userName),
        style: theme.bigMainBold.copyWith(fontSize: 50),
      ),
    );
  }

  String _getInitials(String name) {
    final names = name.split(' ');
    if (names.length == 1) {
      return names[0][0].toUpperCase();
    }
    return '${names[0][0].toUpperCase()}${names[1][0].toUpperCase()}';
  }
}
