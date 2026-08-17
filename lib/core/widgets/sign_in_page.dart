import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_nest/core/services/toast_service.dart';
import 'package:movie_nest/core/theme/theme_notifier.dart';
import 'package:movie_nest/core/widgets/nest_button.dart';
import 'package:movie_nest/features/nest_user/presentation/viewmodels/user_viewmodel.dart';

class SignInPage extends ConsumerWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userController = ref.read(userVMPrv.notifier);
    final theme = ref.watch(themeProvider).value!;
    final isLoading = ValueNotifier<bool>(false);
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.borderC, width: 1),
          gradient: LinearGradient(
            colors: [
              theme.mainC.withValues(alpha: 0.1),
              theme.secC.withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          spacing: 10,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.secC.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: theme.borderC, width: 1),
              ),
              child: Icon(Icons.lock_outline, color: theme.mainC, size: 40),
            ),
            Text(
              'MEMBERS ONLY',
              style: theme.secCBoldSmall,
              textAlign: TextAlign.center,
            ),
            Text(
              'Please Sign In First',
              style: theme.largeBold,
              textAlign: TextAlign.center,
            ),
            Text(
              'Your lists live with your account. Sign in to create collections, track episodes, and keep everything in sync.',
              style: theme.sec,
              textAlign: TextAlign.center,
            ),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                ValueListenableBuilder(
                  valueListenable: isLoading,
                  builder: (context, value, child) {
                    return NestButton(
                      onTap: () async {
                        isLoading.value = true;
                        try {
                          await userController.login();
                        } catch (e) {
                          if (!context.mounted) return;
                          ToastService.error(
                            context,
                            theme,
                            message: e.toString(),
                            title: 'Error',
                          );
                        } finally {
                          isLoading.value = false;
                        }
                      },
                      text: 'Sign In',
                      backC: theme.secC,
                      textC: theme.backC,
                      isLoading: value,
                    );
                  },
                ),
                NestButton(
                  onTap: () {
                    context.push('/');
                  },
                  text: 'Home',
                  borderC: theme.borderC,
                  backC: theme.secBackC,
                  textC: theme.textC,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
