import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/features/nest_list/presentation/ui/list_carousel_widget.dart';
import 'package:movie_nest/features/nest_list/presentation/ui/nest_list_error_widget.dart';
import 'package:movie_nest/features/nest_list/presentation/viewmodels/public_list_viewmodel.dart';

class PublicNestListLoader extends ConsumerWidget {
  const PublicNestListLoader({super.key, required this.id, this.description});
  final String id;
  final String? description;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listState = ref.watch(publicListViewmodelProvider(id));
    return listState.when(
      data: (data) {
        if (data.data == null) {
          return Center(
            child: NestListErrorWidget(message: data.error ?? 'Unknown error'),
          );
        }
        if (data.error != null) {
          return Center(child: NestListErrorWidget(message: data.error!));
        }
        return ListCarouselWidget(
          list: data.data!,
          description: description,
          isPublic: true,
        );
      },
      loading: ListCarouselWidget.shimmer,
      error: (error, stackTrace) {
        return Center(child: NestListErrorWidget(message: error.toString()));
      },
    );
  }
}
