import 'package:flutter/material.dart';
import 'package:asian_mart_app/core/l10n/app_localizations.dart';
import 'package:asian_mart_app/core/state/app_controller.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key, required this.controller});

  final AppController controller;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _signupEmailController = TextEditingController();
  final _signupPasswordController = TextEditingController();
  final _signupNameController = TextEditingController();
  final _signupPhoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    _signupNameController.dispose();
    _signupPhoneController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final controller = widget.controller;
    final error = await controller.login(
      email: _loginEmailController.text.trim(),
      password: _loginPasswordController.text,
    );
    if (!mounted) {
      return;
    }
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    Navigator.of(context).pop();
  }

  Future<void> _signup() async {
    final controller = widget.controller;
    final error = await controller.signup(
      email: _signupEmailController.text.trim(),
      password: _signupPasswordController.text,
      name: _signupNameController.text.trim(),
      phone: _signupPhoneController.text.trim(),
    );
    if (!mounted) {
      return;
    }
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = widget.controller;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.signIn),
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: l10n.signIn),
                Tab(text: l10n.signUp),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _AuthForm(
                title: l10n.signIn,
                subtitle: l10n.loginSubtitle,
                fields: [
                  _FieldConfig(
                    controller: _loginEmailController,
                    label: l10n.emailLabel,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  _FieldConfig(
                    controller: _loginPasswordController,
                    label: l10n.passwordLabel,
                    obscureText: true,
                  ),
                ],
                loading: controller.authLoading,
                actionLabel: l10n.signIn,
                onSubmit: _login,
              ),
              _AuthForm(
                title: l10n.signUp,
                subtitle: l10n.signupSubtitle,
                fields: [
                  _FieldConfig(
                    controller: _signupEmailController,
                    label: l10n.emailLabel,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  _FieldConfig(
                    controller: _signupPasswordController,
                    label: l10n.passwordLabel,
                    obscureText: true,
                  ),
                  _FieldConfig(
                    controller: _signupNameController,
                    label: l10n.nameLabel,
                  ),
                  _FieldConfig(
                    controller: _signupPhoneController,
                    label: l10n.phoneLabel,
                    keyboardType: TextInputType.phone,
                  ),
                ],
                loading: controller.authLoading,
                actionLabel: l10n.signUp,
                onSubmit: _signup,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AuthForm extends StatelessWidget {
  const _AuthForm({
    required this.title,
    required this.subtitle,
    required this.fields,
    required this.loading,
    required this.actionLabel,
    required this.onSubmit,
  });

  final String title;
  final String subtitle;
  final List<_FieldConfig> fields;
  final bool loading;
  final String actionLabel;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(subtitle),
        const SizedBox(height: 20),
        for (final field in fields) ...[
          TextField(
            controller: field.controller,
            keyboardType: field.keyboardType,
            obscureText: field.obscureText,
            decoration: InputDecoration(
              labelText: field.label,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 12),
        FilledButton(
          onPressed: loading ? null : onSubmit,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
          ),
          child: Text(loading ? '처리 중...' : actionLabel),
        ),
      ],
    );
  }
}

class _FieldConfig {
  const _FieldConfig({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final bool obscureText;
}
