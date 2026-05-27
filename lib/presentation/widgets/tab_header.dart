import 'package:flutter/material.dart';
import 'package:asian_mart_app/core/theme/app_theme.dart';

class TabLayoutSpacing {
  const TabLayoutSpacing._();

  static const double horizontal = 16;
  static const double contentTop = 12;
  static const double contentBottom = 24;
  static const double headerTop = 16;
  static const double headerBottom = 14;
  static const double headerContentHeight = 32;
}

class TabHeader extends StatelessWidget {
  const TabHeader({
    super.key,
    this.title,
    this.badge,
    this.action,
    this.leading,
  }) : assert(title != null || leading != null, 'title or leading must be provided');

  final String? title;
  final String? badge;
  final Widget? action;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    return Container(
      padding: EdgeInsets.fromLTRB(
        TabLayoutSpacing.horizontal,
        TabLayoutSpacing.headerTop + topPadding,
        TabLayoutSpacing.horizontal,
        TabLayoutSpacing.headerBottom,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(bottom: BorderSide(color: AppTheme.divider)),
      ),
      child: SizedBox(
        height: TabLayoutSpacing.headerContentHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (leading != null)
              leading!
            else ...[
              Text(
                title!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 7),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ],
            ],
            const Spacer(),
            if (action != null) action!,
          ],
        ),
      ),
    );
  }
}
