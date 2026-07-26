import 'package:movie_nest/core/exceptions/nest_internet_exception.dart';
import 'package:movie_nest/core/services/api_service.dart';
import 'package:movie_nest/core/services/nest_logger.dart';
import 'package:movie_nest/features/sync/data/datasources/sync_queue_datasource.dart';
import 'package:movie_nest/features/sync/domain/repositories/sync_repository.dart';

class SyncRepositoryImpl implements SyncRepository {
  SyncRepositoryImpl(this._syncQueueDatasource, this._apiService);
  final SyncQueueDatasource _syncQueueDatasource;
  final ApiService _apiService;

  final Map<String, ApiMethod> _methodMap = {
    'GET': ApiMethod.get,
    'POST': ApiMethod.post,
    'PATCH': ApiMethod.patch,
    'DELETE': ApiMethod.delete,
  };

  @override
  Future<void> sync() async {
    final operations = await _syncQueueDatasource.getOperations();
    for (final operation in operations) {
      try {
        await _apiService.fetch(
          operation.url,
          _methodMap[operation.method.toUpperCase()]!,
          requestBody: operation.body,
          logResponse: true,
          // encodeBody: false,
        );
        await _syncQueueDatasource.removeOperation(operation.id);
      } on NestInternetException {
        await _syncQueueDatasource.incrementTries(operation.id);
      } catch (e) {
        NestLogger.logError(e, code: 'SNC');
        // await _syncQueueDatasource.removeOperation(operation.id);
      }
    }
  }
}
