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
        color:
            unavailable ? const Color(0xFFEEEEEE) : AppTheme.imagePlaceholder,
        child: hasImage
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (wasSynchronouslyLoaded || frame != null) {
                    return AnimatedOpacity(
                      opacity: 1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      child: child,
                    );
                  }
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      _ShimmerBox(unavailable: unavailable),
                      AnimatedOpacity(
                        opacity: frame == null ? 0 : 1,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        child: child,
                      ),
                    ],
                  );
                },
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

class _ShimmerBox extends StatefulWidget {
  const _ShimmerBox({required this.unavailable});
  final bool unavailable;

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        color: AppTheme.imagePlaceholder.withValues(alpha: _anim.value),
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
