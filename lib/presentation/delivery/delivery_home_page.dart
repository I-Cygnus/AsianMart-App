import 'package:flutter/material.dart';
import 'package:asian_mart_app/core/state/app_controller.dart';
import 'package:asian_mart_app/core/theme/app_theme.dart';
import 'package:asian_mart_app/core/utils/formatters.dart';
import 'package:asian_mart_app/domain/entities/delivery.dart';
import 'package:asian_mart_app/domain/enums/delivery_status.dart';
import 'package:asian_mart_app/presentation/widgets/empty_state.dart';

// 절제된 모노톤 팔레트 + 레드 1포인트.
const _ink = AppTheme.textPrimary; // #1A1A1A
const _sub = AppTheme.textSecondary; // #767676
const _faint = AppTheme.textTertiary; // #AAAAAA
const _line = AppTheme.border; // #EBEBEB
const _accent = AppTheme.primary; // brand red (포인트)

/// 배송 기사 전용 홈. 역할이 DELIEVER인 계정일 때 노출.
class DeliveryHomePage extends StatefulWidget {
  const DeliveryHomePage({super.key, required this.controller});

  final AppController controller;

  @override
  State<DeliveryHomePage> createState() => _DeliveryHomePageState();
}

/// 4개 탭. 접수 대기(pending)는 "배송접수" 탭에 함께 묶는다.
class _Tab {
  const _Tab(this.label, this.matches);
  final String label;
  final bool Function(DeliveryStage) matches;
}

final _kTabs = <_Tab>[
  _Tab('배송접수',
      (s) => s == DeliveryStage.pending || s == DeliveryStage.accepted),
  _Tab('배송준비', (s) => s == DeliveryStage.preparing),
  _Tab('배송중', (s) => s == DeliveryStage.inTransit),
  _Tab('배송완료', (s) => s == DeliveryStage.delivered),
];

class _DeliveryHomePageState extends State<DeliveryHomePage> {
  int _tab = 0;

  AppController get controller => widget.controller;

  List<Delivery> _forTab(int i) {
    final m = _kTabs[i].matches;
    return controller.deliveries
        .where((d) => m(DeliveryStage.of(d.deliveryStatus)))
        .toList();
  }

  Future<void> _openDetail(Delivery delivery) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
      ),
      builder: (_) =>
          _DeliveryDetailSheet(delivery: delivery, controller: controller),
    );
  }

  Future<void> _confirmLogout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('로그아웃 하시겠어요?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('취소')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('로그아웃')),
        ],
      ),
    );
    if (ok == true) await controller.logout();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final shown = _forTab(_tab);
        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            backgroundColor: AppTheme.surface,
            elevation: 0,
            scrolledUnderElevation: 0,
            titleSpacing: 20,
            title: Row(
              children: [
                const Text('배송',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: _ink,
                        letterSpacing: -0.6)),
                if (controller.currentUser != null) ...[
                  const SizedBox(width: 8),
                  Text(controller.currentUser!.name,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _faint)),
                ],
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: _sub, size: 22),
                onPressed: controller.loadDeliveries,
              ),
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: _sub, size: 21),
                onPressed: _confirmLogout,
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            children: [
              _UnderlineTabs(
                selected: _tab,
                labels: [for (final t in _kTabs) t.label],
                counts: [for (var i = 0; i < _kTabs.length; i++) _forTab(i).length],
                onSelect: (i) => setState(() => _tab = i),
              ),
              Expanded(child: _buildBody(shown)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(List<Delivery> shown) {
    if (controller.deliveriesLoading && controller.deliveries.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.deliveriesError != null && controller.deliveries.isEmpty) {
      return _ErrorPanel(
        message: controller.deliveriesError!,
        onRetry: controller.loadDeliveries,
      );
    }
    return RefreshIndicator(
      onRefresh: controller.loadDeliveries,
      child: shown.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 130),
                EmptyState(
                  icon: Icons.inbox_outlined,
                  title: '해당하는 배송이 없어요',
                  description: '결제 완료된 주문이 들어오면 표시됩니다',
                ),
              ],
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              itemCount: shown.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _DeliveryCard(
                delivery: shown[i],
                onTap: () => _openDetail(shown[i]),
              ),
            ),
    );
  }
}

// ── 언더라인 탭 ───────────────────────────────────────────────────────────────
class _UnderlineTabs extends StatelessWidget {
  const _UnderlineTabs({
    required this.selected,
    required this.labels,
    required this.counts,
    required this.onSelect,
  });

  final int selected;
  final List<String> labels;
  final List<int> counts;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(bottom: BorderSide(color: _line)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onSelect(i),
                behavior: HitTestBehavior.opaque,
                child: _TabItem(
                  label: labels[i],
                  count: counts[i],
                  active: selected == i,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem(
      {required this.label, required this.count, required this.active});

  final String label;
  final int count;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                    color: active ? _ink : _faint,
                    letterSpacing: -0.3,
                  ),
                ),
                if (count > 0)
                  TextSpan(
                    text: '  $count',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: active ? _accent : _faint,
                    ),
                  ),
              ],
            ),
          ),
        ),
        // 활성 인디케이터 (레드 포인트)
        Container(
          height: 2,
          width: 28,
          color: active ? _accent : Colors.transparent,
        ),
      ],
    );
  }
}

// ── 배송 카드 (플랫 + 헤어라인) ───────────────────────────────────────────────
class _DeliveryCard extends StatelessWidget {
  const _DeliveryCard({required this.delivery, required this.onTap});

  final Delivery delivery;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final stage = DeliveryStage.of(delivery.deliveryStatus);
    final action = stage.nextAction;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: _line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _StatusChip(stage: stage),
                const Spacer(),
                Text('No. ${delivery.orderId}',
                    style: const TextStyle(
                        fontSize: 12,
                        color: _faint,
                        fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(delivery.recipientName,
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: _ink,
                              letterSpacing: -0.3)),
                      const SizedBox(height: 3),
                      Text(delivery.recipientPhone,
                          style: const TextStyle(fontSize: 13, color: _faint)),
                    ],
                  ),
                ),
                Text(formatPrice(delivery.totalAmount.toDouble()),
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _ink)),
              ],
            ),
            const SizedBox(height: 12),
            Text(delivery.address,
                style: const TextStyle(
                    fontSize: 14, color: _sub, height: 1.45)),
            if (action != null) ...[
              const SizedBox(height: 16),
              const Divider(height: 1, color: _line),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Spacer(),
                  Text(action.label,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: _ink)),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_rounded, size: 16, color: _ink),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 모노톤 상태 칩. 진행 중(배송중)만 레드 포인트.
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.stage});

  final DeliveryStage stage;

  @override
  Widget build(BuildContext context) {
    final isActive = stage == DeliveryStage.inTransit;
    final isDone = stage == DeliveryStage.delivered;
    final dot = isActive ? _accent : (isDone ? _faint : _ink);
    final textColor = isDone ? _faint : _ink;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(stage.label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: textColor,
                letterSpacing: -0.2)),
      ],
    );
  }
}

// ── 상세 시트 ─────────────────────────────────────────────────────────────────
class _DeliveryDetailSheet extends StatefulWidget {
  const _DeliveryDetailSheet({required this.delivery, required this.controller});

  final Delivery delivery;
  final AppController controller;

  @override
  State<_DeliveryDetailSheet> createState() => _DeliveryDetailSheetState();
}

class _DeliveryDetailSheetState extends State<_DeliveryDetailSheet> {
  bool _busy = false;

  Future<void> _runAction(DeliveryAction action) async {
    setState(() => _busy = true);
    final d = widget.delivery;
    final String? error;
    if (action.isRegister) {
      error = await widget.controller.acceptDelivery(orderId: d.orderId);
    } else {
      error = await widget.controller
          .advanceDelivery(deliveryId: d.deliveryId!, action: action.endpoint);
    }
    if (!mounted) return;
    setState(() => _busy = false);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(error ?? '${action.next.label} 처리했습니다.'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.delivery;
    final stage = DeliveryStage.of(d.deliveryStatus);
    final action = stage.nextAction;
    final height = MediaQuery.of(context).size.height * 0.6;
    return SafeArea(
      top: false,
      child: SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 26),
                  decoration: BoxDecoration(
                    color: _line,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  _StatusChip(stage: stage),
                  const Spacer(),
                  Text('No. ${d.orderId}',
                      style: const TextStyle(
                          fontSize: 13,
                          color: _faint,
                          fontWeight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: 20),
              Text(d.recipientName,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: _ink,
                      letterSpacing: -0.6)),
              const SizedBox(height: 4),
              Text(d.recipientPhone,
                  style: const TextStyle(fontSize: 14, color: _sub)),
              const SizedBox(height: 24),
              _SheetRow(label: '배송지', value: d.address),
              const SizedBox(height: 14),
              _SheetRow(
                  label: '결제금액',
                  value: formatPrice(d.totalAmount.toDouble())),
              const SizedBox(height: 30),
              _MiniStepper(current: stage),
              const Spacer(),
              if (action != null)
                FilledButton(
                  onPressed: _busy ? null : () => _runAction(action),
                  style: FilledButton.styleFrom(
                    backgroundColor: _ink,
                    minimumSize: const Size.fromHeight(58),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                  ),
                  child: _busy
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white),
                        )
                      : Text(action.label,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2)),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: const Text('배송이 완료된 주문입니다',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _faint)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetRow extends StatelessWidget {
  const _SheetRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 64,
          child: Text(label,
              style: const TextStyle(fontSize: 14, color: _faint)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _ink,
                  height: 1.45)),
        ),
      ],
    );
  }
}

/// 미니멀 스텝퍼 — 작은 점 + 얇은 선. 현재 단계만 레드.
class _MiniStepper extends StatelessWidget {
  const _MiniStepper({required this.current});

  final DeliveryStage current;

  @override
  Widget build(BuildContext context) {
    final flow = DeliveryStage.flow;
    return Row(
      children: [
        for (var i = 0; i < flow.length; i++) ...[
          _StepDot(
            stage: flow[i],
            done: flow[i].flowIndex <= current.flowIndex,
            isCurrent: flow[i] == current,
          ),
          if (i < flow.length - 1)
            Expanded(
              child: Container(
                height: 1.5,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                color: flow[i + 1].flowIndex <= current.flowIndex
                    ? _ink
                    : _line,
              ),
            ),
        ],
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot(
      {required this.stage, required this.done, required this.isCurrent});

  final DeliveryStage stage;
  final bool done;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final Color fill;
    final Color border;
    if (isCurrent) {
      fill = _accent;
      border = _accent;
    } else if (done) {
      fill = _ink;
      border = _ink;
    } else {
      fill = AppTheme.surface;
      border = _line;
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isCurrent ? 16 : 12,
          height: isCurrent ? 16 : 12,
          decoration: BoxDecoration(
            color: fill,
            shape: BoxShape.circle,
            border: Border.all(color: border, width: 1.5),
          ),
        ),
        const SizedBox(height: 8),
        Text(stage.label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
                color: isCurrent ? _ink : _faint)),
      ],
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 44, color: _faint),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: _sub)),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                foregroundColor: _ink,
                side: const BorderSide(color: _line),
              ),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }
}
