import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/features/nest_list/presentation/ui/discover_page/public_nest_list_loader.dart';
import 'package:movie_nest/features/nest_list/presentation/ui/discover_page/search_widget.dart';

class DiscoverPage extends ConsumerWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queryListener = ValueNotifier<String>('');
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 26),
            child: SearchWidget(queryListener: queryListener),
          ),
          ValueListenableBuilder(
            valueListenable: queryListener,
            builder: (context, value, child) {
              if (value.isEmpty) {
                return const SizedBox.shrink();
              }
              return PublicNestListLoader(
                id: 'search?query=$value',
                description: 'Search results for "$value"',
              );
            },
          ),
          const SizedBox(height: 20),
          const PublicNestListLoader(
            id: 'trending',
            description: 'Movies/Shows that are trending Now',
          ),
        ],
      ),
    );
  }
}
