import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/core/models/watch_stream_data.dart';
import 'package:movie_nest/features/nest_list/data/models/nest_list.dart';
import 'package:movie_nest/features/nest_list/domain/repositories/nest_list_repository.dart';

class WatchPublicList {
  WatchPublicList(this._nestListRepository);
  final NestListRepository _nestListRepository;

  Stream<WatchStreamData<NestList>> call(String listId) {
    return _nestListRepository.watchPublicList(listId);
  }
}

final watchPublicListProvider = Provider<WatchPublicList>((ref) {
  return WatchPublicList(ref.read(nestListRepositoryProvider));
});
