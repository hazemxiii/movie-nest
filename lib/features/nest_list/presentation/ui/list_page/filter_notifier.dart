import 'package:flutter_riverpod/flutter_riverpod.dart';

class FilterState {
  FilterState({
    this.typeFilter,
    // this.statusFilter,
    this.selectedTags = const {},
    this.episodeCountMin,
    this.episodeCountMax,
  });
  final String? typeFilter;
  // final String? statusFilter;
  final Set<String> selectedTags;
  final int? episodeCountMin;
  final int? episodeCountMax;

  FilterState copyWith({
    String? typeFilter,
    // String? statusFilter,
    Set<String>? selectedTags,
    int? episodeCountMin,
    int? episodeCountMax,
  }) {
    return FilterState(
      typeFilter: typeFilter ?? this.typeFilter,
      // statusFilter: statusFilter ?? this.statusFilter,
      selectedTags: selectedTags ?? this.selectedTags,
      episodeCountMin: episodeCountMin ?? this.episodeCountMin,
      episodeCountMax: episodeCountMax ?? this.episodeCountMax,
    );
  }

  bool get hasActiveFilters =>
      typeFilter != null ||
      // statusFilter != null ||
      selectedTags.isNotEmpty ||
      episodeCountMin != null ||
      episodeCountMax != null;
}

class FilterNotifier extends Notifier<FilterState> {
  @override
  FilterState build() {
    return FilterState();
  }

  void setTypeFilter(String? value) {
    state = state.copyWith(typeFilter: value);
  }

  // void setStatusFilter(String? value) {
  //   state = state.copyWith(statusFilter: value);
  // }

  void toggleTag(String tag) {
    final newTags = Set<String>.from(state.selectedTags);
    if (newTags.contains(tag)) {
      newTags.remove(tag);
    } else {
      newTags.add(tag);
    }
    state = state.copyWith(selectedTags: newTags);
  }

  void setEpisodeCountMin(int? value) {
    state = state.copyWith(episodeCountMin: value);
  }

  void setEpisodeCountMax(int? value) {
    state = state.copyWith(episodeCountMax: value);
  }

  void clearFilters() {
    state = FilterState();
  }
}

final filterNotifierProvider = NotifierProvider<FilterNotifier, FilterState>(
  FilterNotifier.new,
);
