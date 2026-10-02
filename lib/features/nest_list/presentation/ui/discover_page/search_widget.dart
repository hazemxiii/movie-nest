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
  final _controller = TextEditingController();
  Timer? _debounce;
  bool isNotEmpty = false;
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
      controller: _controller,
      onChanged: (value) {
        _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 1000), () {
          widget.queryListener.value = value;
        });
        if (value.isNotEmpty != isNotEmpty) {
          setState(() {
            isNotEmpty = value.isNotEmpty;
          });
        }
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
        suffixIcon: isNotEmpty
            ? Container(
                margin: const EdgeInsets.only(left: 12, right: 12),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    widget.queryListener.value = '';
                    _debounce?.cancel();
                    setState(() {
                      isNotEmpty = false;
                    });
                  },
                ),
              )
            : null,
        hintText: 'Search movies, series, or anime...',
        border: border,
        enabledBorder: border,
        focusedBorder: borderF,
      ),
    );
  }
}
