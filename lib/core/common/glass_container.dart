import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:tapzy/core/constants/appColors.dart';

/// Frosted glass panel — brand-tinted, dark premium look.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final double opacity;
  final Color? tintColor;
  final Border? border;
  final double? width;
  final double? height;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;
  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.blur = 22,
    this.opacity = 0.08,
    this.tintColor,
    this.border,
    this.width,
    this.height,
    this.boxShadow,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final tint = tintColor ?? AppColors.colorPurple;

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: boxShadow ??
            [
              BoxShadow(
                color: tint.withOpacity(0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              gradient: gradient ??
                  LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: opacity + 0.04),
                      tint.withValues(alpha: opacity * 0.35),
                      Colors.white.withValues(alpha: opacity * 0.25),
                    ],
                  ),
              border: border ??
                  Border.all(
                    color: Colors.white.withOpacity(0.12),
                    width: 1,
                  ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Ambient purple orb for dashboard background depth.
class GlassAmbientOrb extends StatelessWidget {
  final double size;
  final Alignment alignment;
  final double opacity;

  const GlassAmbientOrb({
    super.key,
    required this.size,
    this.alignment = Alignment.topRight,
    this.opacity = 0.22,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppColors.colorPurple.withValues(alpha: opacity),
              AppColors.colorPurpleLight.withValues(alpha: opacity * 0.35),
              Colors.transparent,
            ],
            stops: const [0.0, 0.45, 1.0],
          ),
        ),
      ),
    );
  }
}
