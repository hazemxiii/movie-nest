import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/core/models/watch_stream_data.dart';
import 'package:movie_nest/features/nest_list/data/models/nest_list.dart';
import 'package:movie_nest/features/nest_list/data/models/nest_list_dto.dart';
import 'package:movie_nest/features/nest_list/domain/repositories/nest_list_repository.dart';

class PrivateNestListCollectionViewmodel
    extends StreamNotifier<WatchStreamData<List<NestList>>> {
  @override
  Stream<WatchStreamData<List<NestList>>> build() async* {
    try {
      final repository = ref.read(nestListRepositoryProvider);
      yield* repository.watchPrivateListCollectionSummary();
    } catch (e) {
      yield WatchStreamData(data: null, isLoading: false, error: e.toString());
    }
  }

  Future<void> addList(NestListDto dto) async {
    final oldLists = state.value?.data ?? [];
    state = AsyncValue.data(
      WatchStreamData(data: [...oldLists, dto.toModel()], isLoading: false),
    );
    final repository = ref.read(nestListRepositoryProvider);
    try {
      await repository.createList(dto);
    } catch (e) {
      state = AsyncValue.data(
        WatchStreamData(data: oldLists, isLoading: false),
      );
      rethrow;
    }
  }
}

final privateNestListCollectionViewmodelProvider =
    StreamNotifierProvider<
      PrivateNestListCollectionViewmodel,
      WatchStreamData<List<NestList>>
    >(PrivateNestListCollectionViewmodel.new);
