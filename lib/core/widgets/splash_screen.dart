import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..addListener(() {
            setState(() {});
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _animationController.reverse();
            } else if (status == AnimationStatus.dismissed) {
              _animationController.forward();
            }
          });

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0E),
      body: Stack(
        children: [
          ...List<Widget>.generate(4, (index) {
            final totalWidth = MediaQuery.of(context).size.width;
            double width = totalWidth / 4;
            width = max(width, 200);
            return FloatingImage(
              top: (index % 2 == 0 ? 50 : 200),
              left: index == 0 ? 10 : width * index - 100 * (index - 1) - 10,
              animationValue: _animation.value,
              imagePath: 'assets/images/splash_screen/${index + 1}.jpg',
            );
          }),
          Center(
            child: Column(
              children: [
                const Spacer(),
                const Text(
                  'Movie Nest',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: const Text(
                    'Track movies, series, and anime. Build lists, follow airing seasons, and never lose your place.',
                    style: TextStyle(color: Color(0xFFa4a4ab), fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                const CircularProgressIndicator(color: Color(0xFFFF007F)),
                const Spacer(),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FloatingImage extends StatelessWidget {
  const FloatingImage({
    super.key,
    required this.top,
    required this.left,
    required this.animationValue,
    required this.imagePath,
  });
  final double top;
  final double left;
  final double animationValue;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width / 4;
    width = max(width, 200);
    return Positioned(
      left: left,
      top: top + animationValue * 20,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withValues(alpha: 0.05),
        ),
        width: width,
        height: width * 1.333,
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Image.asset(imagePath, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
