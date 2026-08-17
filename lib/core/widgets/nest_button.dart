import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/core/theme/theme_notifier.dart';

class NestButton extends ConsumerStatefulWidget {
  const NestButton({
    super.key,
    this.text,
    this.icon,
    required this.onTap,
    this.backC,
    this.textC,
    this.borderC,
    this.radius = 999,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.fontSize = 14,
    this.isLoading = false,
  });
  final String? text;
  final IconData? icon;
  final Color? backC;
  final Color? textC;
  final Color? borderC;
  final double radius;
  final VoidCallback onTap;
  final EdgeInsets padding;
  final double fontSize;
  final bool isLoading;

  @override
  ConsumerState<NestButton> createState() => _NestButtonState();
}

class _NestButtonState extends ConsumerState<NestButton> {
  @override
  Widget build(BuildContext context) {
    final icon = _getIcon();
    final text = _getText();
    final theme = ref.watch(themeProvider).value!;
    return InkWell(
      onTap: () {
        if (!widget.isLoading) {
          widget.onTap();
        }
      },
      borderRadius: BorderRadius.circular(widget.radius),
      child: Container(
        padding: widget.padding,
        decoration: BoxDecoration(
          color: widget.backC ?? theme.textC,
          borderRadius: BorderRadius.circular(widget.radius),
          border: Border.all(color: widget.borderC ?? Colors.transparent),
        ),
        child: Row(
          spacing: 8,
          mainAxisSize: MainAxisSize.min,
          children: [?icon, ?text],
        ),
      ),
    );
  }

  Widget? _getIcon() {
    final theme = ref.watch(themeProvider).value!;
    if (widget.icon == null) {
      return null;
    }
    if (widget.isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: widget.textC ?? theme.backC,
        ),
      );
    }
    return Icon(widget.icon, color: widget.textC ?? theme.backC);
  }

  Widget? _getText() {
    final theme = ref.watch(themeProvider).value!;
    if (widget.text == null) {
      return null;
    }
    if (widget.isLoading && widget.icon == null) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: widget.textC ?? theme.backC,
        ),
      );
    }
    return Text(
      widget.text!,
      style: TextStyle(
        color: widget.textC ?? theme.backC,
        fontWeight: FontWeight.bold,
        fontSize: widget.fontSize,
      ),
    );
  }
}
