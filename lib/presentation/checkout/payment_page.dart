import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:asian_mart_app/core/state/app_controller.dart';
import 'package:asian_mart_app/core/theme/app_theme.dart';
import 'package:asian_mart_app/core/utils/formatters.dart';

/// 무통장 입금 안내 페이지.
/// 주문 생성(PLACED) 직후 노출되고, "입금 완료"를 누르면 입금 통보(PAYMENT_PENDING)된다.
/// 실제 입금 확인과 주문 확정(CONFIRMED)은 루트 관리자가 처리한다.
class PaymentPage extends StatefulWidget {
  const PaymentPage({
    super.key,
    required this.controller,
    required this.orderId,
    required this.amount,
  });

  final AppController controller;
  final int orderId;
  final double amount;

  // 입금 받을 매장 고정 계좌
  static const String bankName = '국민은행';
  static const String accountNo = '123456-04-567890';
  static const String accountHolder = '(주)아시안마트';

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _submitting = false;

  Future<void> _complete() async {
    setState(() => _submitting = true);
    final error = await widget.controller.reportPayment(widget.orderId);
    if (!mounted) return;
    setState(() => _submitting = false);
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('입금 확인 요청이 접수되었어요'),
        content: const Text('입금 확인 후 주문이 확정됩니다.\n확인되면 바로 배송 준비할게요!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
    if (mounted) {
      // 결제 페이지 + 체크아웃 페이지를 모두 닫고 홈으로.
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('입금 안내'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded),
            tooltip: '나중에 입금',
            onPressed: _submitting
                ? null
                : () => Navigator.of(context).popUntil((r) => r.isFirst),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 입금 금액 강조 — 브랜드 그라데이션 히어로 카드
          _AmountHero(amount: widget.amount),
          const SizedBox(height: 16),
          // 계좌 정보
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
            child: Column(
              children: [
                _InfoLine(label: '은행', value: PaymentPage.bankName),
                const Divider(height: 24),
                _InfoLine(
                  label: '계좌번호',
                  value: PaymentPage.accountNo,
                  copyable: true,
                ),
                const Divider(height: 24),
                _InfoLine(label: '예금주', value: PaymentPage.accountHolder),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 18, color: AppTheme.textTertiary),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '입금자명과 주문자명이 다르면 확인이 늦어질 수 있어요. '
                    '입금을 완료한 뒤 아래 "입금 완료" 버튼을 눌러주세요.',
                    style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        height: 1.5),
                  ),
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
            onPressed: _submitting ? null : _complete,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
            ),
            child: _submitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white),
                  )
                : const Text('입금 완료',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ),
        ),
      ),
    );
  }
}

class _AmountHero extends StatelessWidget {
  const _AmountHero({required this.amount});

  final double amount;

  @override
  Widget build(BuildContext context) {
    // "5,500원" → 숫자("5,500")는 크게, "원"은 작게.
    final number = formatPrice(amount).replaceAll('원', '');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('입금하실 금액',
              style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                number,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.5,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 4),
              const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text('원',
                    style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 19,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.label,
    required this.value,
    this.copyable = false,
  });

  final String label;
  final String value;
  final bool copyable;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600)),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary)),
        ),
        if (copyable)
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('계좌번호를 복사했어요')),
              );
            },
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.copy_rounded,
                  size: 18, color: AppTheme.primary),
            ),
          ),
      ],
    );
  }
}
