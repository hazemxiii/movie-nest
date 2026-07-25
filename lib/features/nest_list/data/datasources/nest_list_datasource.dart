import 'package:movie_nest/features/nest_list/data/models/nest_list.dart';

abstract class NestListDatasource {
  Future<void> create(NestList list);
  Future<NestList> getNestList(String listId);
  Future<NestList> getPublicNestList(String listId);
}
