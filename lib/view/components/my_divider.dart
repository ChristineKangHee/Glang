import 'package:flutter/material.dart';

/*
  아래와 같이 사용
  BigDivider()
  SmallDivider()
 */

class BigDivider extends StatelessWidget {
  final double thickness;
  final double height;

  const BigDivider({
    Key? key,
    this.thickness = 5.0,
    this.height = 5.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Divider(
      // color: Color(0xFFF8F9FE),
      color: Color(0xFFEAEBF3),
      // color: Theme.of(context).colorScheme.outline,
      thickness: thickness,
      height: height,
    );
  }
}

class SmallDivider extends StatelessWidget {
  final double thickness;
  final double height;

  const SmallDivider({
    Key? key,
    this.thickness = 1.0,
    this.height = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: Color(0xFFEAEBF3),
      // color: Theme.of(context).colorScheme.outline,
      thickness: thickness,
      height: height,
    );
  }
}

class LoginDivider extends StatelessWidget {
  final double thickness;
  final double height;

  const LoginDivider({
    Key? key,
    this.thickness = 1.0,
    this.height = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: Color(0xFFE1E1E1),
      // color: Theme.of(context).colorScheme.outline,
      thickness: thickness,
      height: height,
    );
  }
}