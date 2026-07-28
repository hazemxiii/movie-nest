import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/core/theme/theme_notifier.dart';

class NestRefreshButton extends ConsumerStatefulWidget {
  const NestRefreshButton({
    super.key,
    this.onRefresh,
    required this.isRefreshing,
  });

  final VoidCallback? onRefresh;
  final bool isRefreshing;

  @override
  ConsumerState<NestRefreshButton> createState() => _NestRefreshButtonState();
}

class _NestRefreshButtonState extends ConsumerState<NestRefreshButton>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _animationController.addListener(() {
      setState(() {});
    });
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isRefreshing) {
      _animationController.stop();
      _animationController.value = 0;
    } else {
      _animationController.repeat();
    }
    final theme = ref.watch(themeProvider).value!;
    return IconButton(
      icon: Transform.rotate(
        angle: _rotationAnimation.value * 2 * 3.14159,
        child: const Icon(Icons.refresh),
      ),
      color: theme.textC,
      onPressed: widget.isRefreshing ? () {} : widget.onRefresh ?? () {},
    );
  }
}
