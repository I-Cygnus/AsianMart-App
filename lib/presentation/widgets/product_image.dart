import 'package:flutter/material.dart';
import 'package:asian_mart_app/core/theme/app_theme.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.imageUrl,
    required this.label,
    this.unavailable = false,
    this.borderRadius = 14,
    this.fontSize = 52,
  });

  final String? imageUrl;
  final String label;
  final bool unavailable;
  final double borderRadius;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        color: unavailable ? const Color(0xFFEEEEEE) : AppTheme.imagePlaceholder,
        child: hasImage
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (_, __, ___) => _Placeholder(
                  label: label,
                  unavailable: unavailable,
                  fontSize: fontSize,
                ),
              )
            : _Placeholder(
                label: label,
                unavailable: unavailable,
                fontSize: fontSize,
              ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({
    required this.label,
    required this.unavailable,
    required this.fontSize,
  });

  final String label;
  final bool unavailable;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Opacity(
        opacity: unavailable ? 0.3 : 1.0,
        child: Text(
          label.isEmpty ? '?' : label.substring(0, 1),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            color: AppTheme.textTertiary,
          ),
        ),
      ),
    );
  }
}
