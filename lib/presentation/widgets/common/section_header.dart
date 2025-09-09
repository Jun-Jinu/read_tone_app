import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? action;
  final Color? titleColor;
  final double? fontSize;
  final FontWeight? fontWeight;

  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.titleColor,
    this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: fontWeight ?? FontWeight.bold,
                color: titleColor,
                fontSize: fontSize,
              ),
        ),
        if (action != null) action!,
      ],
    );
  }
}
