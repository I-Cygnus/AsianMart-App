import 'package:flutter/material.dart';
import 'package:asian_mart_app/core/l10n/app_localizations.dart';
import 'package:asian_mart_app/core/theme/app_theme.dart';
import 'package:asian_mart_app/core/utils/formatters.dart';
import 'package:asian_mart_app/domain/entities/product.dart';
import 'package:asian_mart_app/presentation/widgets/product_image.dart';
import 'package:asian_mart_app/presentation/widgets/quantity_stepper.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({
    super.key,
    required this.initialProduct,
    required this.onLoadDetail,
    required this.onAddToCart,
    required this.onBuyNow,
    required this.onToggleWishlist,
    required this.isWishlisted,
    required this.onRequireLogin,
    required this.isAuthenticated,
  });

  final Product initialProduct;
  final Future<Product> Function() onLoadDetail;
  final void Function(Product product, int quantity) onAddToCart;
  final Future<void> Function(Product product, int quantity) onBuyNow;
  final Future<void> Function() onToggleWishlist;
  final bool isWishlisted;
  final Future<void> Function() onRequireLogin;
  final bool isAuthenticated;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _quantity = 1;
  late Product _product;
  bool _detailLoading = false;

  @override
  void initState() {
    super.initState();
    _product = widget.initialProduct;
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() => _detailLoading = true);
    try {
      final detail = await widget.onLoadDetail();
      if (!mounted) {
        return;
      }
      setState(() {
        _product = detail;
        _detailLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _detailLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('상품 정보를 불러오지 못했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = _product;
    final l10n = AppLocalizations.of(context);
    final total = product.sellingPrice * _quantity;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          product.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            onPressed: () async {
              if (!widget.isAuthenticated) {
                await widget.onRequireLogin();
                return;
              }
              await widget.onToggleWishlist();
            },
            icon: Icon(
              widget.isWishlisted
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: widget.isWishlisted ? AppTheme.primary : null,
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          // ── Image area ──────────────────────────────────────────────
          Stack(
            children: [
              SizedBox(
                height: 320,
                width: double.infinity,
                child: product.thumbnailUrl != null
                    ? ProductImage(
                        imageUrl: product.thumbnailUrl,
                        label: product.name,
                        borderRadius: 0,
                        fontSize: 110,
                      )
                    : ColoredBox(
                        color: AppTheme.imagePlaceholder,
                        child: _detailLoading
                            ? const Center(child: CircularProgressIndicator())
                            : const SizedBox.expand(),
                      ),
              ),
              // Bottom gradient fade
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 80,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppTheme.background.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                ),
              ),
              if (product.discountPercent > 0)
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: Text(
                      '${product.discountPercent}% 할인',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // ── Product info card ────────────────────────────────────────
          Container(
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 8),
            color: AppTheme.surface,
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _StatusBadge(
                      label: product.statusLabel,
                      isOrderable: product.isOrderable,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textPrimary,
                    height: 1.3,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 14),
                // Price section
                if (product.discountPercent > 0) ...[
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                        ),
                        child: Text(
                          '${product.discountPercent}%',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formatPrice(product.listPrice),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textTertiary,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  formatPrice(product.sellingPrice),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),

          // ── Description card ─────────────────────────────────────────
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            color: AppTheme.surface,
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.productDesc,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  product.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.65,
                  ),
                ),
                // description Text 아래
                if (product.imageUrls != null && product.imageUrls!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  ...product.imageUrls!.map((url) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      child: Image.network(
                        url,
                        width: double.infinity,
                        fit: BoxFit.fitWidth, // 가로 맞춤, 세로는 원본 비율
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const SizedBox(
                            height: 160,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        },
                        errorBuilder: (_, __, ___) => Container(
                          height: 120,
                          color: AppTheme.imagePlaceholder,
                          alignment: Alignment.center,
                          child: Text(
                            product.name.substring(0, 1),
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textTertiary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )),
                ],
              ],
            ),
          ),

          // ── Quantity + subtotal card ──────────────────────────────────
          Container(
            color: AppTheme.surface,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      l10n.quantity,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    QuantityStepper(
                      quantity: _quantity,
                      onChanged: (value) {
                        if (value > 0) setState(() => _quantity = value);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text(
                      l10n.subtotal,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      formatPrice(total),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            border: Border(top: BorderSide(color: AppTheme.divider)),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: product.isOrderable
                      ? () {
                          widget.onAddToCart(product, _quantity);
                          Navigator.of(context).pop();
                        }
                      : null,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: Text(l10n.addToCart),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: product.isOrderable
                      ? () => widget.onBuyNow(product, _quantity)
                      : null,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: Text(l10n.buyNow),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.isOrderable});

  final String label;
  final bool isOrderable;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isOrderable
            ? AppTheme.primary.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isOrderable ? AppTheme.primary : AppTheme.textTertiary,
        ),
      ),
    );
  }
}
