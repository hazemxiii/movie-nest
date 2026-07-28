import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/core/models/watch_stream_data.dart';
import 'package:movie_nest/features/nest_list/data/models/nest_list.dart';
import 'package:movie_nest/features/nest_list/domain/usecases/watch_public_list.dart';

class PublicListViewmodel extends StreamNotifier<WatchStreamData<NestList>> {
  PublicListViewmodel(this.listId);
  final String listId;

  @override
  Stream<WatchStreamData<NestList>> build() async* {
    try {
      final watchPublicList = ref.read(watchPublicListProvider)(listId);
      yield* watchPublicList;
    } catch (e) {
      yield WatchStreamData<NestList>(
        data: null,
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

final publicListViewmodelProvider =
    StreamNotifierProvider.family<
      PublicListViewmodel,
      WatchStreamData<NestList>,
      String
    >((listId) {
      return PublicListViewmodel(listId);
    });
