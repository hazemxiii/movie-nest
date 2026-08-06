import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_nest/core/services/database_services/sqlite_service.dart';
import 'package:movie_nest/core/services/toast_service.dart';
import 'package:movie_nest/core/theme/theme_notifier.dart';
import 'package:movie_nest/core/widgets/nest_button.dart';
import 'package:movie_nest/core/widgets/splash_screen.dart';
import 'package:movie_nest/features/media/presentation/ui/media_page.dart';
import 'package:movie_nest/features/nest_list/data/models/nest_list_dto.dart';
import 'package:movie_nest/features/nest_list/presentation/ui/add_nest_list_dialog.dart';
import 'package:movie_nest/features/nest_list/presentation/ui/discover_page/discover_page.dart';
import 'package:movie_nest/features/nest_list/presentation/ui/list_page/list_page.dart';
import 'package:movie_nest/features/nest_list/presentation/ui/private_list_collection_page/private_list_collection_page.dart';
import 'package:movie_nest/features/nest_list/presentation/viewmodels/private_nest_list_collection_viewmodel.dart';
import 'package:movie_nest/features/sync/presentation/ui/sync_indicator_button.dart';

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
    final theme = ref.watch(themeProvider).value!;
    router = GoRouter(
      // TODO remove this later
      initialLocation: 'media/b8c228c7-0e8b-4c55-8490-68e8ed91b883',
      routes: [
        ShellRoute(
          builder: (context, state, child) {
            return Scaffold(
              backgroundColor: theme.backC,
              appBar: AppBar(
                backgroundColor: theme.backC,
                actions: [
                  const SyncIndicatorButton(),
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: theme.mainC),
                    onPressed: () {
                      if (state.fullPath == '/lists') {
                        context.push('/');
                      } else {
                        context.push('/lists');
                      }
                    },
                    child: Text(state.fullPath == '/lists' ? 'Home' : 'Lists'),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    child: NestButton(
                      onTap: () async {
                        final result = await showDialog<NestListDto>(
                          context: context,
                          builder: (context) => const AddNestListDialog(),
                        );
                        if (result != null && mounted) {
                          try {
                            await ref
                                .read(
                                  privateNestListCollectionViewmodelProvider
                                      .notifier,
                                )
                                .addList(result);
                          } catch (e) {
                            if (!context.mounted) return;
                            ToastService.error(
                              context,
                              theme,
                              title: 'Error',
                              message: e.toString(),
                            );
                          }
                        }
                      },
                      text: 'New List',
                      backC: theme.mainC,
                      textC: theme.backC,
                    ),
                  ),
                ],
              ),
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
              path: '/lists',
              name: 'lists',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: PrivateListCollectionPage()),
            ),
            GoRoute(
              path: '/lists/:listId',
              name: 'list',
              pageBuilder: (context, state) {
                final listId = state.pathParameters['listId']!;
                return NoTransitionPage(child: ListPage(listId: listId));
              },
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
            GoRoute(
              path: '/media/:mediaId',
              name: 'private-media',
              pageBuilder: (context, state) {
                final mediaId = state.pathParameters['mediaId']!;
                final isTv = state.extra as bool? ?? false;
                return NoTransitionPage(
                  child: MediaPage(
                    mediaId: mediaId,
                    isPublic: false,
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
    return const MaterialApp(home: SplashScreen());
  }
}
