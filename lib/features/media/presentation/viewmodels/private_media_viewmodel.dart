import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/core/models/watch_stream_data.dart';
import 'package:movie_nest/features/media/data/models/media.dart';
import 'package:movie_nest/features/media/domain/repositories/media_repository.dart';

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
}

final privateMediaViewmodelProvider =
    StreamNotifierProvider.family<
      PrivateMediaViewmodel,
      WatchStreamData<Media>,
      String
    >((id) {
      return PrivateMediaViewmodel(id);
    });
