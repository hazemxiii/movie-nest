import 'package:movie_nest/features/sync/data/models/sync_queue.dart';

abstract class SyncQueueDatasource {
  Future<void> addOperation(SyncOperation operation);
  Future<List<SyncOperation>> getOperations();
  Future<void> removeOperation(String id);
  Future<void> incrementTries(String id);
  Future<void> clearQueue();
  Future<bool> hasOperations();
}
