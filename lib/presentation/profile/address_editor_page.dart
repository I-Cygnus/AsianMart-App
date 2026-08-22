import 'package:flutter/material.dart';
import 'package:asian_mart_app/core/l10n/app_localizations.dart';
import 'package:asian_mart_app/core/theme/app_theme.dart';
import 'package:kpostal/kpostal.dart';

class AddressEditorPage extends StatefulWidget {
  const AddressEditorPage({
    super.key,
    required this.onSubmit,
    this.showDefaultToggle = true,
  });

  final Future<String?> Function({
    required String addressName,
    required String zipCode,
    required String address1,
    required String address2,
    required bool isDefault,
  }) onSubmit;
  final bool showDefaultToggle;

  @override
  State<AddressEditorPage> createState() => _AddressEditorPageState();
}

class _AddressEditorPageState extends State<AddressEditorPage> {
  final _formKey = GlobalKey<FormState>();
  final _addressNameController = TextEditingController();
  final _address2Controller = TextEditingController();
  final _address2FocusNode = FocusNode();

  String? _zipCode;
  String? _address1;
  bool _isDefault = false;
  bool _saving = false;

  @override
  void dispose() {
    _addressNameController.dispose();
    _address2Controller.dispose();
    _address2FocusNode.dispose();
    super.dispose();
  }

  Future<void> _openPostcodeSearch() async {
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
        _address1 = result.roadAddress.isNotEmpty
            ? result.roadAddress
            : result.address;
      });
      _address2FocusNode.requestFocus();
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_zipCode == null || _address1 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('주소를 검색해 주세요.')),
      );
      return;
    }
    setState(() => _saving = true);
    final error = await widget.onSubmit(
      addressName: _addressNameController.text.trim(),
      zipCode: _zipCode!,
      address1: _address1!,
      address2: _address2Controller.text.trim(),
      isDefault: widget.showDefaultToggle ? _isDefault : true,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasAddress = _zipCode != null && _address1 != null;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addAddress)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
          children: [
            // ── 배송지 이름 ──────────────────────────────────────
            TextFormField(
              controller: _addressNameController,
              decoration: InputDecoration(
                labelText: l10n.addressNameLabel,
                hintText: '예) 집, 회사, 본가',
                prefixIcon: const Icon(Icons.bookmark_border_rounded, size: 20),
              ),
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? '필수 입력입니다.' : null,
            ),
            const SizedBox(height: 16),

            // ── 주소 검색 ────────────────────────────────────────
            _AddressSearchField(
              zipCode: _zipCode,
              address1: _address1,
              onTap: _openPostcodeSearch,
            ),
            const SizedBox(height: 16),

            // ── 상세주소 ─────────────────────────────────────────
            TextFormField(
              controller: _address2Controller,
              focusNode: _address2FocusNode,
              enabled: hasAddress,
              decoration: InputDecoration(
                labelText: l10n.address2Label,
                hintText: '동·호수, 층, 상세 위치',
                prefixIcon: const Icon(Icons.door_front_door_outlined, size: 20),
              ),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 24),

            if (widget.showDefaultToggle) ...[
              _DefaultAddressTile(
                value: _isDefault,
                onChanged: (v) => setState(() => _isDefault = v),
              ),
              const SizedBox(height: 28),
            ],

            // ── 저장 버튼 ────────────────────────────────────────
            FilledButton(
              onPressed: _saving ? null : _submit,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(l10n.saveAddress),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressSearchField extends StatelessWidget {
  const _AddressSearchField({
    required this.zipCode,
    required this.address1,
    required this.onTap,
  });

  final String? zipCode;
  final String? address1;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasAddress = zipCode != null && address1 != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 테마 스타일과 동일한 label 영역
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 6),
          child: Text(
            '주소',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: hasAddress ? AppTheme.primary : AppTheme.textSecondary,
            ),
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 20,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '[$zipCode]',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textTertiary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              address1!,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: AppTheme.textTertiary,
                      ),
                    ],
                  )
                : Row(
                    children: [
                      const Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: AppTheme.textTertiary,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        '우편번호로 주소 검색',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textTertiary,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class _DefaultAddressTile extends StatelessWidget {
  const _DefaultAddressTile({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: value
              ? AppTheme.primary.withValues(alpha: 0.05)
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: value
                ? AppTheme.primary.withValues(alpha: 0.3)
                : AppTheme.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              value
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              size: 22,
              color: value ? AppTheme.primary : AppTheme.textTertiary,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '기본 배송지로 설정',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '주문 시 이 주소가 자동으로 선택됩니다',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
