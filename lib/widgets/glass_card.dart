import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Glass morphism card widget
class GlassCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry? padding;

  const GlassCard({
    super.key,
    required this.child,
    this.color,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: AppTheme.glassCard(context, color: color),
      child: child,
    );
  }
}

