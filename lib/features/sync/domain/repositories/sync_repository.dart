import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/core/services/api_service.dart';
import 'package:movie_nest/features/sync/data/datasources/local_sync_queue_datasource.dart';
import 'package:movie_nest/features/sync/data/repositories/sync_repository_impl.dart';

abstract class SyncRepository {
  Future<void> sync();
}

final syncRepositoryProvider = Provider<SyncRepository>((ref) {
  return SyncRepositoryImpl(
    ref.read(localSyncQueueDatasourceProvider),
    ref.read(apiServiceProvider),
  );
});
