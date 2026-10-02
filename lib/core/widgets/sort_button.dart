import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/core/theme/theme_notifier.dart';

class SortButtonItem {
  const SortButtonItem({required this.text, required this.onSort});
  final String text;
  final VoidCallback onSort;
}

class SortButton extends ConsumerStatefulWidget {
  const SortButton({
    super.key,
    required this.items,
    required this.ascending,
    required this.onToggleDirection,
  });
  final List<SortButtonItem> items;
  final bool ascending;
  final VoidCallback onToggleDirection;

  @override
  ConsumerState<SortButton> createState() => _SortButtonState();
}

class _SortButtonState extends ConsumerState<SortButton> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider).value!;

    return Row(
      children: [
        IconButton(
          icon: Icon(
            widget.ascending ? Icons.arrow_upward : Icons.arrow_downward,
            color: theme.mainC,
            size: 20,
          ),
          onPressed: widget.onToggleDirection,
        ),
        PopupMenuButton<int>(
          icon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 4),
              Icon(Icons.sort, color: theme.mainC),
            ],
          ),
          color: theme.secBackC,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
            widget.items[index].onSort();
          },
          itemBuilder: (context) {
            return widget.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return PopupMenuItem<int>(
                value: index,
                child: Row(
                  children: [
                    if (_selectedIndex == index)
                      Icon(Icons.check, color: theme.mainC, size: 18)
                    else
                      const SizedBox(width: 18),
                    const SizedBox(width: 8),
                    Text(item.text, style: theme.secSmall),
                  ],
                ),
              );
            }).toList();
          },
        ),
      ],
    );
  }
}
