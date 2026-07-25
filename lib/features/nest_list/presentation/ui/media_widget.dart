import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_nest/core/theme/theme_notifier.dart';
import 'package:movie_nest/core/widgets/nest_button.dart';
import 'package:movie_nest/core/widgets/nest_image.dart';
import 'package:movie_nest/features/media/data/models/media.dart';

class MediaWidget extends ConsumerStatefulWidget {
  const MediaWidget({super.key, required this.media, required this.isPublic});
  final Media media;
  final bool isPublic;

  @override
  ConsumerState<MediaWidget> createState() => _MediaWidgetState();
}

class _MediaWidgetState extends ConsumerState<MediaWidget>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider).value!;
    return InkWell(
      onTap: () {
        goToDetails(widget.media.tmdbId, widget.media.type == 'tv');
      },
      onHover: (hovered) {
        if (!kIsWeb) {
          if (!Platform.isAndroid && !Platform.isIOS) {
            if (hovered) {
              _animationController.forward();
            } else {
              _animationController.reverse();
            }
          }
        }
      },
      child: SizedBox(
        width: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, con) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        ImageFiltered(
                          imageFilter: ImageFilter.blur(
                            sigmaX: 2 * _animation.value,
                            sigmaY: 2 * _animation.value,
                          ),
                          child: Transform.scale(
                            scale: 1 + (_animation.value * 0.1),
                            child: NestImage(url: widget.media.posterUrl),
                          ),
                        ),
                        Positioned(
                          bottom:
                              -con.maxHeight +
                              (con.maxHeight * _animation.value),
                          left: 0,
                          right: 0,
                          child: SizedBox(
                            height: con.maxHeight,
                            child: Center(
                              child: NestButton(
                                text: 'View Details',
                                icon: Icons.arrow_forward,
                                onTap: () {
                                  goToDetails(
                                    widget.media.tmdbId,
                                    widget.media.type == 'tv',
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.media.title,
              style: TextStyle(
                color: Color.lerp(theme.textC, theme.mainC, _animation.value),
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.media.date.year.toString(), style: theme.sec),
                Row(
                  children: [
                    Text(
                      widget.media.rating.toString().substring(0, 3),
                      style: theme.sec,
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.star_outline,
                      size: 16,
                      color: Colors.amber,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void goToDetails(String id, bool isTv) {
    if (widget.isPublic) {
      context.push('/media/public/$id', extra: isTv);
    } else {
      // TODO: Navigate to private media details
    }
  }
}
