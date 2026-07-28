import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/core/widgets/nest_error_widget.dart';
import 'package:movie_nest/features/nest_list/presentation/ui/discover_page/list_carousel_widget.dart';
import 'package:movie_nest/features/nest_list/presentation/viewmodels/public_list_viewmodel.dart';

class PublicNestListLoader extends ConsumerWidget {
  const PublicNestListLoader({super.key, required this.id, this.description});
  final String id;
  final String? description;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listState = ref.watch(publicListViewmodelProvider(id));
    return listState.when(
      skipLoadingOnRefresh: false,
      data: (data) {
        if (data.data == null || data.error != null) {
          return NestErrorWidget(
            title: 'Error',
            message: data.error ?? 'Unknown error',
            onTap: () {
              ref.invalidate(publicListViewmodelProvider(id));
            },
          );
        }
        return ListCarouselWidget(list: data.data!, description: description);
      },
      loading: ListCarouselWidget.shimmer,
      error: (error, stackTrace) {
        return NestErrorWidget(
          title: 'Error',
          message: error.toString(),
          onTap: () {
            ref.invalidate(publicListViewmodelProvider(id));
          },
        );
      },
    );
  }
}
