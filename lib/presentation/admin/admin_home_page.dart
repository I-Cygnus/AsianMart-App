import 'package:flutter/material.dart';
import 'package:asian_mart_app/core/state/app_controller.dart';
import 'package:asian_mart_app/core/theme/app_theme.dart';
import 'package:asian_mart_app/presentation/admin/admin_payment_page.dart';

/// 루트 관리자 전용 홈. 역할이 ADMIN인 계정일 때 스토어 대신 노출된다.
/// 절제된 모노톤 대시보드 — 관리 업무로 진입한다. (지금은 "입금 확인" 1개)
class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key, required this.controller});

  final AppController controller;

  // 잉크(거의 블랙) — 포멀한 강조에 빨강 대신 사용.
  static const Color _ink = Color(0xFF111111);

  Future<void> _confirmLogout(BuildContext context) async {
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

  void _openPayment(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AdminPaymentPage(controller: controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final pendingCount = controller.adminOrders.length;
        final name = controller.currentUser?.name;
        return Scaffold(
          backgroundColor: AppTheme.surface,
          appBar: AppBar(
            backgroundColor: AppTheme.surface,
            elevation: 0,
            scrolledUnderElevation: 0.5,
            titleSpacing: 20,
            title: Row(
              children: [
                const Text('관리자',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _ink,
                        letterSpacing: -0.4)),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: const Text('ADMIN',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textTertiary,
                          letterSpacing: 1.2)),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded,
                    size: 21, color: AppTheme.textSecondary),
                onPressed: controller.loadAdminOrders,
              ),
              IconButton(
                icon: const Icon(Icons.logout_rounded,
                    size: 20, color: AppTheme.textSecondary),
                onPressed: () => _confirmLogout(context),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: controller.loadAdminOrders,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
              children: [
                Text(
                  name == null ? '안녕하세요' : '$name님',
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: _ink,
                      letterSpacing: -0.6,
                      height: 1.2),
                ),
                const SizedBox(height: 4),
                const Text('오늘 처리할 업무를 확인하세요.',
                    style: TextStyle(
                        fontSize: 14, color: AppTheme.textTertiary)),
                const SizedBox(height: 28),
                _PendingStat(
                  count: pendingCount,
                  loading: controller.adminOrdersLoading,
                  onTap: () => _openPayment(context),
                ),
                const SizedBox(height: 32),
                const _SectionLabel('관리 메뉴'),
                const SizedBox(height: 12),
                _MenuTile(
                  icon: Icons.account_balance_outlined,
                  title: '주문 요청',
                  subtitle: '들어온 주문을 확인하고 처리합니다',
                  trailing: pendingCount > 0 ? '$pendingCount' : null,
                  onTap: () => _openPayment(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 입금 확인 대기 건수 — 큰 테뷸러 숫자 중심의 절제된 지표 카드.
class _PendingStat extends StatelessWidget {
  const _PendingStat({
    required this.count,
    required this.loading,
    required this.onTap,
  });

  final int count;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('주문 요청',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                          letterSpacing: 0.1)),
                  const SizedBox(width: 7),
                  if (count > 0 && !loading)
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              if (loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: AppTheme.textTertiary),
                  ),
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$count',
                      style: const TextStyle(
                        fontSize: 46,
                        fontWeight: FontWeight.w800,
                        color: AdminHomePage._ink,
                        letterSpacing: -1.5,
                        height: 1.0,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 6),
                      child: Text('건',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary)),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: AppTheme.divider),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    count > 0 ? '주문 요청 처리하기' : '주문 요청 보기',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AdminHomePage._ink),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_rounded,
                      size: 17, color: AdminHomePage._ink),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppTheme.textTertiary,
        letterSpacing: 0.3,
      ),
    );
  }
}

/// 관리 메뉴 행 — 컬러 아이콘 박스 없이 라인 아이콘 + 텍스트만.
class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              Icon(icon, size: 21, color: AdminHomePage._ink),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 12.5, color: AppTheme.textTertiary)),
                  ],
                ),
              ),
              if (trailing != null)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Text(trailing!,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AdminHomePage._ink,
                          fontFeatures: [FontFeature.tabularFigures()])),
                ),
              const Icon(Icons.chevron_right_rounded,
                  size: 20, color: AppTheme.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
