import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_nest/core/services/sqlite_service.dart';
import 'package:movie_nest/core/theme/theme_notifier.dart';
import 'package:movie_nest/features/media/presentation/ui/media_page.dart';
import 'package:movie_nest/features/nest_list/presentation/ui/discover_page.dart';

void main() {
  runApp(const ProviderScope(child: Bootstrap()));
}

class Bootstrap extends ConsumerStatefulWidget {
  const Bootstrap({super.key});

  @override
  ConsumerState<Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends ConsumerState<Bootstrap> {
  bool _isLoaded = false;
  Future<void> _loadApp() async {
    await ref.watch(themeProvider.future);
    await ref.read(sqliteServiceProvider).init();
    router = GoRouter(
      routes: [
        ShellRoute(
          builder: (context, state, child) {
            return Scaffold(
              backgroundColor: ref.watch(themeProvider).value!.backC,
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(
                    right: 16.0,
                    left: 16.0,
                    top: 8,
                  ),
                  child: Center(
                    child: Container(
                      alignment: Alignment.topCenter,
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: child,
                    ),
                  ),
                ),
              ),
            );
          },
          routes: [
            GoRoute(
              path: '/',
              name: 'home',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: DiscoverPage()),
            ),
            GoRoute(
              path: '/media/public/:mediaId',
              name: 'media',
              pageBuilder: (context, state) {
                final mediaId = state.pathParameters['mediaId']!;
                final isTv = state.extra as bool? ?? false;
                return NoTransitionPage(
                  child: MediaPage(
                    mediaId: mediaId,
                    isPublic: true,
                    isTv: isTv,
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
    setState(() {
      _isLoaded = true;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadApp();
    });
    super.initState();
  }

  late final GoRouter router;

  @override
  Widget build(BuildContext context) {
    if (_isLoaded) {
      return MaterialApp.router(routerConfig: router);
    }
    return const MaterialApp(
      home: Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}
