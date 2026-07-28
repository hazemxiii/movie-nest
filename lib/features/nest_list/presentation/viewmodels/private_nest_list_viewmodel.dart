import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/core/models/watch_stream_data.dart';
import 'package:movie_nest/features/media/data/models/dtos/media_dto.dart';
import 'package:movie_nest/features/media/data/models/media.dart';
import 'package:movie_nest/features/media/domain/repositories/media_repository.dart';
import 'package:movie_nest/features/nest_list/data/models/nest_list.dart';
import 'package:movie_nest/features/nest_list/data/models/nest_list_dto.dart';
import 'package:movie_nest/features/nest_list/domain/repositories/nest_list_repository.dart';

class PrivateNestListViewmodel
    extends StreamNotifier<WatchStreamData<NestList>> {
  PrivateNestListViewmodel(this.listId);
  final String listId;

  @override
  Stream<WatchStreamData<NestList>> build() async* {
    try {
      yield* ref.read(nestListRepositoryProvider).watchPrivateList(listId);
    } catch (e) {
      yield WatchStreamData(data: null, isLoading: false, error: e.toString());
    }
  }

  Future<void> updateList(NestListDto list) async {
    final oldList = state.value?.data;
    final oldMedia = state.value?.data?.media;
    try {
      state = AsyncValue.data(
        WatchStreamData(data: oldList?.updateWith(list), isLoading: false),
      );
      final updatedList = await ref
          .read(nestListRepositoryProvider)
          .updateList(listId, list);
      state = AsyncValue.data(
        WatchStreamData(
          data: updatedList.copyWith(media: oldMedia),
          isLoading: false,
        ),
      );
    } catch (e) {
      state = AsyncValue.data(WatchStreamData(data: oldList, isLoading: false));
      rethrow;
    }
  }

  Future<void> addMedia(MediaDto media) async {
    final oldList = state.value?.data;
    final oldMedia = state.value?.data?.media;
    try {
      state = AsyncValue.data(
        WatchStreamData(
          data: oldList?.copyWith(
            media: [
              ...?oldMedia,
              Media(
                id: '',
                list: '',
                tmdbId: '',
                title: '',
                description: '',
                posterUrl: '',
                type: '',
                date: DateTime.now(),
                runTime: 0,
                status: '',
                tag: '',
                seasons: [],
              ).copyWithDto(media).copyWith(list: oldList.id),
            ],
          ),
          isLoading: false,
        ),
      );
      await ref.read(mediaRepositoryProvider).createMedia(listId, media);
    } catch (e) {
      state = AsyncValue.data(WatchStreamData(data: oldList, isLoading: false));
      rethrow;
    }
  }
}

final privateNestListViewmodelProvider =
    StreamNotifierProvider.family<
      PrivateNestListViewmodel,
      WatchStreamData<NestList>,
      String
    >((listId) {
      return PrivateNestListViewmodel(listId);
    });
