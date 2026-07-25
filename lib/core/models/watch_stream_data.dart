class WatchStreamData<T> {
  WatchStreamData({required this.data, required this.isLoading, this.error});
  final T? data;
  final bool isLoading;
  final String? error;
}
