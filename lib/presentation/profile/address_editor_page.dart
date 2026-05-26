import 'package:flutter/material.dart';
import 'package:asian_mart_app/core/l10n/app_localizations.dart';

class AddressEditorPage extends StatefulWidget {
  const AddressEditorPage({
    super.key,
    required this.onSubmit,
  });

  final Future<String?> Function({
    required String addressName,
    required String zipCode,
    required String address1,
    required String address2,
    required bool isDefault,
  }) onSubmit;

  @override
  State<AddressEditorPage> createState() => _AddressEditorPageState();
}

class _AddressEditorPageState extends State<AddressEditorPage> {
  final _formKey = GlobalKey<FormState>();
  final _addressNameController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _address1Controller = TextEditingController();
  final _address2Controller = TextEditingController();
  bool _isDefault = false;
  bool _saving = false;

  @override
  void dispose() {
    _addressNameController.dispose();
    _zipCodeController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _saving = true);
    final error = await widget.onSubmit(
      addressName: _addressNameController.text.trim(),
      zipCode: _zipCodeController.text.trim(),
      address1: _address1Controller.text.trim(),
      address2: _address2Controller.text.trim(),
      isDefault: _isDefault,
    );
    if (!mounted) {
      return;
    }
    setState(() => _saving = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.addAddress)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _addressNameController,
              decoration: InputDecoration(labelText: l10n.addressNameLabel),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? '필수 입력입니다.' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _zipCodeController,
              decoration: InputDecoration(labelText: l10n.zipCodeLabel),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? '필수 입력입니다.' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _address1Controller,
              decoration: InputDecoration(labelText: l10n.address1Label),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? '필수 입력입니다.' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _address2Controller,
              decoration: InputDecoration(labelText: l10n.address2Label),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              value: _isDefault,
              onChanged: (value) => setState(() => _isDefault = value ?? false),
              title: Text(l10n.defaultAddress),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _saving ? null : _submit,
              child: Text(_saving ? '저장 중...' : l10n.saveAddress),
            ),
          ],
        ),
      ),
    );
  }
}
