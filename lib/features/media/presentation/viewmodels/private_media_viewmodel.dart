import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/core/models/watch_stream_data.dart';
import 'package:movie_nest/features/media/data/models/dtos/media_dto.dart';
import 'package:movie_nest/features/media/data/models/media.dart';
import 'package:movie_nest/features/media/domain/repositories/media_repository.dart';
import 'package:movie_nest/features/nest_list/presentation/viewmodels/private_nest_list_viewmodel.dart';

class PrivateMediaViewmodel extends StreamNotifier<WatchStreamData<Media>> {
  PrivateMediaViewmodel(this.id);
  final String id;
  @override
  Stream<WatchStreamData<Media>> build() async* {
    try {
      yield* ref.read(mediaRepositoryProvider).watchPrivateMedia(id);
    } catch (e) {
      yield WatchStreamData(data: null, isLoading: false);
    }
  }

  Future<void> toggleEpisodeWatched(
    int seasonNumber,
    List<int> added,
    List<int> removed,
  ) async {
    final oldSeasons = state.value?.data?.seasons ?? [];
    try {
      final newSeason = await ref
          .read(mediaRepositoryProvider)
          .toggleEpisode(id, seasonNumber, added, removed);
      final newSeasons = oldSeasons.map((season) {
        if (season.number == seasonNumber) {
          return newSeason;
        }
        return season;
      }).toList();
      state = AsyncValue.data(
        WatchStreamData(
          data: state.value?.data?.copyWith(seasons: newSeasons),
          isLoading: false,
        ),
      );
    } catch (e) {
      state = AsyncValue.data(
        WatchStreamData(
          data: state.value?.data?.copyWith(seasons: oldSeasons),
          isLoading: false,
        ),
      );
      rethrow;
    }
  }

  Future<void> updateMedia(MediaDto dto) async {
    final oldMedia = state.value?.data;
    state = AsyncValue.data(
      WatchStreamData(data: oldMedia?.copyWithDto(dto), isLoading: false),
    );
    try {
      final newMedia = await ref.read(mediaRepositoryProvider).updateMedia(dto);
      state = AsyncValue.data(
        WatchStreamData(data: newMedia, isLoading: false),
      );
    } catch (e) {
      state = AsyncValue.data(
        WatchStreamData(data: oldMedia, isLoading: false),
      );
      rethrow;
    }
  }

  Future<void> deleteMedia() async {
    state = AsyncValue.data(WatchStreamData(data: null, isLoading: false));
    ref.invalidate(
      privateNestListViewmodelProvider(state.value?.data?.list ?? ''),
    );
    await ref.read(mediaRepositoryProvider).deleteMedia(id);
  }
}

final privateMediaViewmodelProvider =
    StreamNotifierProvider.family<
      PrivateMediaViewmodel,
      WatchStreamData<Media>,
      String
    >((id) {
      return PrivateMediaViewmodel(id);
    });
