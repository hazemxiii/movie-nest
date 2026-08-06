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
  });
  final String? text;
  final IconData? icon;
  final Color? backC;
  final Color? textC;
  final Color? borderC;
  final double radius;
  final VoidCallback onTap;
  final EdgeInsets padding;

  @override
  ConsumerState<NestButton> createState() => _NestButtonState();
}

class _NestButtonState extends ConsumerState<NestButton> {
  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider).value!;
    return InkWell(
      onTap: widget.onTap,
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
          children: [
            if (widget.icon != null)
              Icon(widget.icon, color: widget.textC ?? theme.backC),
            if (widget.text != null)
              Text(
                widget.text!,
                style: TextStyle(
                  color: widget.textC ?? theme.backC,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
