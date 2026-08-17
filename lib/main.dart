import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_nest/core/services/database_services/sqlite_service.dart';
import 'package:movie_nest/core/services/nest_platform.dart';
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
import 'package:movie_nest/features/nest_user/presentation/ui/profile_page.dart';
import 'package:movie_nest/features/nest_user/presentation/ui/user_button.dart';
import 'package:movie_nest/features/nest_user/presentation/viewmodels/user_viewmodel.dart';
import 'package:movie_nest/features/sync/presentation/ui/sync_indicator_button.dart';
import 'package:movie_nest/firebase_options.dart';

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
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await ref.watch(themeProvider.future);
    await ref.watch(userVMPrv.future);
    await ref.read(sqliteServiceProvider).init();
    final theme = ref.watch(themeProvider).value!;
    router = GoRouter(
      routes: [
        ShellRoute(
          builder: (context, state, child) {
            int index = 0;
            if (state.matchedLocation == '/') {
              index = 0;
            } else if (state.matchedLocation == '/lists') {
              index = 1;
            } else if (state.matchedLocation == '/profile') {
              index = 2;
            }
            return Scaffold(
              backgroundColor: theme.backC,
              bottomNavigationBar: NestPlatform.isMobile
                  ? BottomNavigationBar(
                      backgroundColor: theme.backC,
                      selectedItemColor: theme.mainC,
                      unselectedItemColor: theme.textC,
                      currentIndex: index,
                      onTap: (index) {
                        if (index == 0) {
                          router.go('/');
                        } else if (index == 1) {
                          router.go('/lists');
                        } else if (index == 2) {
                          router.go('/profile');
                        }
                      },
                      items: const [
                        BottomNavigationBarItem(
                          activeIcon: Icon(Icons.home),
                          icon: Icon(Icons.home_outlined),
                          label: 'Home',
                        ),
                        BottomNavigationBarItem(
                          activeIcon: Icon(Icons.list),
                          icon: Icon(Icons.list_outlined),
                          label: 'Lists',
                        ),
                        BottomNavigationBarItem(
                          activeIcon: Icon(Icons.person),
                          icon: Icon(Icons.person_outlined),
                          label: 'Profile',
                        ),
                      ],
                    )
                  : null,
              appBar: AppBar(
                backgroundColor: theme.backC,
                actions: [
                  const SyncIndicatorButton(),
                  const SizedBox(width: 5),
                  const UserButton(),
                  if (!NestPlatform.isMobile) ...[
                    const SizedBox(width: 5),
                    if (state.fullPath == '/')
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: theme.mainC,
                        ),
                        onPressed: () {
                          context.push('/lists');
                        },
                        child: const Text('Lists'),
                      )
                    else
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: theme.mainC,
                        ),
                        onPressed: () {
                          context.push('/');
                        },
                        child: const Text('Home'),
                      ),
                    const SizedBox(width: 5),
                  ],
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
              path: '/profile',
              name: 'profile',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: ProfilePage()),
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
