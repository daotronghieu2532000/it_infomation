import 'dart:ui';
import 'package:flutter/material.dart';

class GlassmorphicCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double borderWidth;
  final Color? backgroundColor;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final DecorationImage? backgroundImage;

  const GlassmorphicCard({
    super.key,
    required this.child,
    this.borderRadius = 0.0,
    this.borderWidth = 0.8,
    this.backgroundColor,
    this.borderColor,
    this.padding,
    this.onTap,
    this.backgroundImage,
  });

  @override
  Widget build(BuildContext context) {
    final defaultBg = Colors.white.withOpacity(0.04);
    final defaultBorder = Colors.white.withOpacity(0.08);

    Widget cardContent = Container(
      padding: padding ?? const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: backgroundColor ?? defaultBg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? defaultBorder,
          width: borderWidth,
        ),
        image: backgroundImage,
      ),
      child: child,
    );

    if (onTap != null) {
      cardContent = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: cardContent,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: cardContent,
      ),
    );
  }
}
