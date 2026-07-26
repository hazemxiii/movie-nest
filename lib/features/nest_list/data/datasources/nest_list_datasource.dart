import 'package:movie_nest/features/nest_list/data/models/nest_list.dart';
import 'package:movie_nest/features/nest_list/data/models/nest_list_dto.dart';

abstract class NestListDatasource {
  Future<void> create(NestListDto list);
  Future<NestList> update(String listId, NestListDto list);
  Future<void> delete(String listId);
  Future<NestList> getPublicNestList(String listId);
  Future<List<NestList>> getPrivateListCollectionSummary();
}
