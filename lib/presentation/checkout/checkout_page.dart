import 'package:flutter/material.dart';
import 'package:kpostal/kpostal.dart';
import 'package:asian_mart_app/core/l10n/app_localizations.dart';
import 'package:asian_mart_app/core/state/app_controller.dart';
import 'package:asian_mart_app/core/theme/app_theme.dart';
import 'package:asian_mart_app/core/utils/formatters.dart';
import 'package:asian_mart_app/domain/entities/product.dart';
import 'package:asian_mart_app/presentation/checkout/payment_page.dart';

/// 결제(주문) 페이지.
///
/// 두 가지 모드를 지원한다.
/// - 장바구니 주문: [directProduct]가 null. 장바구니의 선택 항목 전체를 주문한다.
/// - 바로구매: [directProduct] 지정. 해당 상품 [directQuantity]개만 주문한다(장바구니 미사용).
class CheckoutPage extends StatefulWidget {
  const CheckoutPage({
    super.key,
    required this.controller,
    this.directProduct,
    this.directQuantity = 1,
  });

  final AppController controller;
  final Product? directProduct;
  final int directQuantity;

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _OrderLine {
  const _OrderLine({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.total,
  });

  final int productId;
  final String name;
  final int quantity;
  final double total;
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _noteController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _address2Controller = TextEditingController();

  // 직접 입력한 주소(주소검색 결과)
  String? _zipCode;
  String? _address1;

  // 저장된 배송지 대신 직접 입력 모드를 쓸지
  late bool _useManualAddress;

  bool _submitting = false;

  bool get _isDirect => widget.directProduct != null;

  @override
  void initState() {
    super.initState();
    final user = widget.controller.currentUser;
    _nameController.text = user?.name ?? '';
    _phoneController.text = user?.phone ?? '';
    // 저장된 배송지가 있으면 그걸 쓰고, 없으면 처음부터 직접 입력 모드.
    _useManualAddress = widget.controller.defaultAddress == null;
  }

  @override
  void dispose() {
    _noteController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _address2Controller.dispose();
    super.dispose();
  }

  // ── 주문 라인 / 합계 ────────────────────────────────────────────────────────
  List<_OrderLine> get _lines {
    final direct = widget.directProduct;
    if (direct != null) {
      return [
        _OrderLine(
          productId: direct.id,
          name: direct.name,
          quantity: widget.directQuantity,
          total: direct.sellingPrice * widget.directQuantity,
        ),
      ];
    }
    return widget.controller.selectedCartItems
        .map((item) => _OrderLine(
              productId: item.productId,
              name: item.productName,
              quantity: item.quantity,
              total: item.itemTotalPrice,
            ))
        .toList();
  }

  double get _total => _lines.fold(0, (sum, line) => sum + line.total);

  // ── 주소검색 ────────────────────────────────────────────────────────────────
  Future<void> _searchPostcode() async {
    final result = await Navigator.of(context).push<Kpostal>(
      MaterialPageRoute(
        builder: (_) => KpostalView(
          appBarColor: AppTheme.surface,
          titleColor: AppTheme.textPrimary,
          loadingColor: AppTheme.primary,
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _zipCode = result.postCode;
        _address1 =
            result.roadAddress.isNotEmpty ? result.roadAddress : result.address;
      });
    }
  }

  String? get _manualAddressText {
    if (_zipCode == null || _address1 == null) return null;
    final detail = _address2Controller.text.trim();
    return detail.isEmpty
        ? '[$_zipCode] $_address1'
        : '[$_zipCode] $_address1 $detail';
  }

  /// 현재 화면 상태로부터 주문에 사용할 배송지 문자열을 만든다. 없으면 null.
  String? _resolveRecipientAddress() {
    final saved = widget.controller.defaultAddress;
    if (!_useManualAddress && saved != null) {
      return saved.fullAddress;
    }
    return _manualAddressText;
  }

  // ── 입력한 주소를 배송지로 저장(팝업) ──────────────────────────────────────
  Future<void> _openSaveAddressDialog() async {
    if (_zipCode == null || _address1 == null) {
      _snack('먼저 주소를 검색해 주세요.');
      return;
    }
    final aliasController = TextEditingController();
    var setDefault = widget.controller.defaultAddress == null; // 첫 배송지면 기본값 on
    var saving = false;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setLocal) {
            Future<void> save() async {
              if (aliasController.text.trim().isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('배송지 이름을 입력해 주세요.')),
                );
                return;
              }
              setLocal(() => saving = true);
              final error = await widget.controller.addAddress(
                addressName: aliasController.text.trim(),
                zipCode: _zipCode!,
                address1: _address1!,
                address2: _address2Controller.text.trim(),
                isDefault: setDefault,
              );
              if (!dialogContext.mounted) return;
              if (error != null) {
                setLocal(() => saving = false);
                ScaffoldMessenger.of(dialogContext)
                    .showSnackBar(SnackBar(content: Text(error)));
                return;
              }
              Navigator.of(dialogContext).pop(true);
            }

            return AlertDialog(
              title: const Text('배송지로 저장'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _manualAddressText ?? '',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: aliasController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: '배송지 이름',
                      hintText: '예) 집, 회사, 본가',
                      prefixIcon: Icon(Icons.bookmark_border_rounded, size: 20),
                    ),
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    value: setDefault,
                    onChanged: (v) => setLocal(() => setDefault = v ?? false),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: const Text('기본 배송지로 설정',
                        style: TextStyle(fontSize: 14)),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed:
                      saving ? null : () => Navigator.of(dialogContext).pop(false),
                  child: const Text('취소'),
                ),
                FilledButton(
                  onPressed: saving ? null : save,
                  child: saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text('저장'),
                ),
              ],
            );
          },
        );
      },
    );

    aliasController.dispose();
    if (saved == true && mounted) {
      // 저장 후엔 방금 등록한 배송지를 사용하도록 전환.
      setState(() => _useManualAddress = false);
      _snack('배송지로 저장되었습니다.');
    }
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // ── 주문 ────────────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    final recipientAddress = _resolveRecipientAddress();
    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty) {
      _snack('받는 분과 연락처를 입력해 주세요.');
      return;
    }
    if (recipientAddress == null || recipientAddress.isEmpty) {
      _snack('배송지를 입력하거나 선택해 주세요.');
      return;
    }

    setState(() => _submitting = true);
    // 바로구매는 단일 상품을 직접 주문하고, 장바구니 주문은 서버가 선택 항목을
    // 한 번에 처리(금액 계산 + 장바구니 정리)하는 체크아웃 API를 사용한다.
    final result = _isDirect
        ? await widget.controller.placeOrder(
            requestMessage: _noteController.text,
            recipientName: _nameController.text,
            recipientPhone: _phoneController.text,
            recipientAddress: recipientAddress,
            products: _lines
                .map((line) => {
                      'productId': line.productId,
                      'productQuantity': line.quantity,
                    })
                .toList(),
            totalAmount: _total,
          )
        : await widget.controller.checkoutCart(
            requestMessage: _noteController.text,
            recipientName: _nameController.text,
            recipientPhone: _phoneController.text,
            recipientAddress: recipientAddress,
          );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (result.error != null) {
      _snack(result.error!);
      return;
    }
    // 주문 생성(PLACED) 완료 → 무통장 입금 안내 페이지로.
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PaymentPage(
          controller: widget.controller,
          orderId: result.orderId!,
          amount: _total,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final l10n = AppLocalizations.of(context);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final lines = _lines;
        final total = _total;
        return Scaffold(
          appBar: AppBar(title: Text(l10n.checkoutTitle)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildShippingSection(controller),
              const SizedBox(height: 12),
              _Section(
                title: l10n.paymentMethod,
                child: Text(
                  l10n.bankTransfer,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _Section(
                title: l10n.orderNoteLabel,
                child: TextField(
                  controller: _noteController,
                  maxLines: 3,
                  decoration: InputDecoration(hintText: l10n.orderNoteHint),
                ),
              ),
              const SizedBox(height: 12),
              _Section(
                title: l10n.productCount(lines.length),
                child: Column(
                  children: [
                    for (final line in lines) ...[
                      Row(
                        children: [
                          Expanded(child: Text(line.name)),
                          const SizedBox(width: 12),
                          Text(
                            '${l10n.itemQty(line.quantity)}  ${formatPrice(line.total)}',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Section(
                title: l10n.paymentAmount,
                child: Column(
                  children: [
                    _PriceRow(
                        label: l10n.productAmount, value: formatPrice(total)),
                    const SizedBox(height: 8),
                    _PriceRow(label: l10n.shippingFee, value: l10n.free),
                    const Divider(height: 24),
                    _PriceRow(
                      label: l10n.finalAmount,
                      value: formatPrice(total),
                      bold: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: const BoxDecoration(
                color: AppTheme.surface,
                border: Border(top: BorderSide(color: AppTheme.divider)),
              ),
              child: FilledButton(
                onPressed: _submitting ? null : _submit,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: Text(
                  _submitting
                      ? '주문 처리 중...'
                      : '${l10n.payLabel}  ${formatPrice(total)}',
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── 배송 정보 섹션 ─────────────────────────────────────────────────────────
  Widget _buildShippingSection(AppController controller) {
    final saved = controller.defaultAddress;
    final usingSaved = !_useManualAddress && saved != null;

    return _Section(
      title: '배송 정보',
      trailing: usingSaved
          ? TextButton(
              onPressed: () => setState(() => _useManualAddress = true),
              child: const Text('직접 입력'),
            )
          : (saved != null
              ? TextButton(
                  onPressed: () => setState(() => _useManualAddress = false),
                  child: const Text('저장된 배송지'),
                )
              : null),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 받는 분 / 연락처는 항상 입력 가능(프로필 값 prefill)
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: '받는 분',
              prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: '연락처',
              hintText: '예) 010-1234-5678',
              prefixIcon: Icon(Icons.phone_outlined, size: 20),
            ),
          ),
          const SizedBox(height: 16),
          if (usingSaved)
            _SavedAddressCard(
              addressName: saved.addressName,
              fullAddress: saved.fullAddress,
            )
          else
            _buildManualAddress(controller),
        ],
      ),
    );
  }

  Widget _buildManualAddress(AppController controller) {
    final hasAddress = _zipCode != null && _address1 != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _searchPostcode,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(
                color: hasAddress ? AppTheme.primary : AppTheme.border,
                width: hasAddress ? 1.5 : 1.0,
              ),
            ),
            child: hasAddress
                ? Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          size: 20, color: AppTheme.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('[$_zipCode]',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textTertiary)),
                            const SizedBox(height: 2),
                            Text(_address1!,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      const Icon(Icons.edit_outlined,
                          size: 16, color: AppTheme.textTertiary),
                    ],
                  )
                : const Row(
                    children: [
                      Icon(Icons.search_rounded,
                          size: 20, color: AppTheme.textTertiary),
                      SizedBox(width: 10),
                      Text('우편번호로 주소 검색',
                          style: TextStyle(
                              fontSize: 14, color: AppTheme.textTertiary)),
                    ],
                  ),
          ),
        ),
        if (hasAddress) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _address2Controller,
            decoration: const InputDecoration(
              labelText: '상세주소',
              hintText: '동·호수, 층, 상세 위치',
              prefixIcon: Icon(Icons.door_front_door_outlined, size: 20),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _openSaveAddressDialog,
            icon: const Icon(Icons.add_location_alt_outlined, size: 18),
            label: const Text('이 주소를 배송지로 저장'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(46),
            ),
          ),
        ],
      ],
    );
  }
}

class _SavedAddressCard extends StatelessWidget {
  const _SavedAddressCard({
    required this.addressName,
    required this.fullAddress,
  });

  final String addressName;
  final String fullAddress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_rounded,
                  size: 18, color: AppTheme.primary),
              const SizedBox(width: 6),
              Text(
                addressName,
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            fullAddress,
            style: const TextStyle(
                color: AppTheme.textSecondary, height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: bold ? AppTheme.textPrimary : AppTheme.textSecondary,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w400,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: bold ? 18 : 14,
            fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
