import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/core/theme/theme_notifier.dart';

class SearchWidget extends ConsumerStatefulWidget {
  const SearchWidget({super.key, required this.queryListener});

  final ValueNotifier<String> queryListener;

  @override
  ConsumerState<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends ConsumerState<SearchWidget> {
  Timer? _debounce;
  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider).value!;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(999),
      borderSide: BorderSide(color: theme.borderC),
    );
    final borderF = OutlineInputBorder(
      borderRadius: BorderRadius.circular(999),
      borderSide: BorderSide(color: theme.mainC),
    );
    return TextField(
      onChanged: (value) {
        _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 1000), () {
          widget.queryListener.value = value;
        });
      },
      cursorColor: theme.textC,
      style: theme.normal,
      decoration: InputDecoration(
        prefixIcon: Container(
          margin: const EdgeInsets.only(left: 12, right: 12),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: theme.secTextC, width: 2),
          ),
        ),
        hintText: 'Search movies, series, or anime...',
        border: border,
        enabledBorder: border,
        focusedBorder: borderF,
      ),
    );
  }
}
