import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/core/theme/theme_notifier.dart';
import 'package:movie_nest/core/widgets/nest_button.dart';

class SignInPage extends ConsumerWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider).value!;
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
                NestButton(
                  onTap: () {},
                  text: 'Sign In',
                  backC: theme.secC,
                  textC: theme.backC,
                ),
                NestButton(
                  onTap: () {},
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
