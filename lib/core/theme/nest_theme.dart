import 'package:flutter/material.dart';

abstract class NestTheme {
  const NestTheme({
    required this.backC,
    required this.textC,
    required this.mainC,
    required this.secBackC,
    required this.secTextC,
    required this.borderC,
    required this.errorC,
    required this.innerBorderC,
  });
  final Color mainC;
  final Color backC;
  final Color secBackC;
  final Color textC;
  final Color secTextC;
  final Color borderC;
  final Color errorC;
  final Color innerBorderC;

  TextStyle get bold => TextStyle(fontWeight: FontWeight.bold, color: textC);
  TextStyle get main => TextStyle(color: mainC);
  TextStyle get backBold =>
      TextStyle(fontWeight: FontWeight.bold, color: backC);
  TextStyle get bigBold =>
      TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textC);
  TextStyle get largeBold =>
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: textC);
  TextStyle get sec => TextStyle(color: secTextC);
  TextStyle get secStrikeBold => TextStyle(
    color: secTextC,
    decoration: TextDecoration.lineThrough,
    decorationColor: mainC,
    decorationThickness: 3,
    fontWeight: FontWeight.bold,
  );
  TextStyle get mainBold =>
      TextStyle(color: mainC, fontWeight: FontWeight.bold);
  TextStyle get bigErrorBold =>
      TextStyle(fontSize: 20, color: errorC, fontWeight: FontWeight.bold);
  TextStyle get normal => TextStyle(color: textC);
}
