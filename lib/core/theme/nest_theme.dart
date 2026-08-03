import 'package:flutter/material.dart';

abstract class NestTheme {
  const NestTheme({
    required this.backC,
    required this.textC,
    required this.mainC,
    required this.secBackC,
    required this.inputBackC,
    required this.secTextC,
    required this.borderC,
    required this.errorC,
    required this.innerBorderC,
    required this.secBackC2,
  });
  final Color mainC;
  final Color backC;
  final Color secBackC;
  final Color inputBackC;
  final Color textC;
  final Color secTextC;
  final Color borderC;
  final Color errorC;
  final Color innerBorderC;
  final Color secBackC2;

  TextStyle get bold => TextStyle(fontWeight: FontWeight.bold, color: textC);
  TextStyle get main => TextStyle(color: mainC);
  TextStyle get backBold =>
      TextStyle(fontWeight: FontWeight.bold, color: backC);
  TextStyle get bigBold =>
      TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textC);
  TextStyle get largeBold =>
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: textC);
  TextStyle get largeBoldMain =>
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: mainC);
  TextStyle get sec => TextStyle(color: secTextC);
  TextStyle get secBold =>
      TextStyle(color: secTextC, fontWeight: FontWeight.bold);
  TextStyle get secStrikeBold => TextStyle(
    color: secTextC,
    decoration: TextDecoration.lineThrough,
    decorationColor: mainC,
    decorationThickness: 3,
    fontWeight: FontWeight.bold,
  );
  TextStyle get mainBold =>
      TextStyle(color: mainC, fontWeight: FontWeight.bold);
  TextStyle get bigMainBold =>
      TextStyle(color: mainC, fontSize: 20, fontWeight: FontWeight.bold);
  TextStyle get bigErrorBold =>
      TextStyle(fontSize: 20, color: errorC, fontWeight: FontWeight.bold);
  TextStyle get normal => TextStyle(color: textC);
  TextStyle get error => TextStyle(color: errorC);
  TextStyle get secSmall => TextStyle(color: secTextC, fontSize: 12);
  TextStyle get secSmallBold =>
      TextStyle(color: secTextC, fontSize: 12, fontWeight: FontWeight.bold);
  TextStyle get mainSmallBold =>
      TextStyle(color: mainC, fontSize: 12, fontWeight: FontWeight.bold);
}
