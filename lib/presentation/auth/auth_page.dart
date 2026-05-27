import 'package:flutter/material.dart';
import 'package:asian_mart_app/core/l10n/app_localizations.dart';
import 'package:asian_mart_app/core/state/app_controller.dart';
import 'package:asian_mart_app/core/theme/app_theme.dart';

const _kErrorColor = Color(0xFFE53935);

// ── Validators ────────────────────────────────────────────────────────────────

String? _checkEmail(String v) {
  if (v.isEmpty) return '이메일을 입력해 주세요.';
  if (!RegExp(r'^[\w.+\-]+@[\w\-]+\.[a-zA-Z]{2,}$').hasMatch(v)) {
    return '올바른 이메일 형식이 아닙니다.';
  }
  return null;
}

String? _checkPasswordLogin(String v) {
  if (v.isEmpty) return '비밀번호를 입력해 주세요.';
  return null;
}

String? _checkPasswordSignup(String v) {
  if (v.isEmpty) return '비밀번호를 입력해 주세요.';
  if (v.length < 8) return '비밀번호는 8자 이상이어야 합니다.';
  return null;
}

String? _checkName(String v) {
  if (v.trim().isEmpty) return '이름을 입력해 주세요.';
  return null;
}

String? _checkPhone(String v) {
  if (v.isEmpty) return null;
  final digits = v.replaceAll(RegExp(r'[\s\-]'), '');
  if (!RegExp(r'^01[016789]\d{7,8}$').hasMatch(digits)) {
    return '올바른 전화번호 형식이 아닙니다. (예: 010-0000-0000)';
  }
  return null;
}

// ── Page ──────────────────────────────────────────────────────────────────────

class AuthPage extends StatefulWidget {
  const AuthPage({super.key, required this.controller});
  final AppController controller;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<String?> _login(String email, String password) =>
      widget.controller.login(email: email, password: password);

  Future<String?> _signup(
          String email, String password, String name, String phone) =>
      widget.controller.signup(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final controller = widget.controller;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppTheme.background,
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: Column(
              children: [
                // ── 닫기 ─────────────────────────────────────────
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: AppTheme.textPrimary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),

                // ── 로고 ─────────────────────────────────────────
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: bottomInset > 0 ? 0 : null,
                  clipBehavior: Clip.hardEdge,
                  decoration: const BoxDecoration(),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          ),
                          child: const Icon(Icons.storefront_rounded,
                              color: Colors.white, size: 36),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Asian Mart',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '신선한 아시안 식품을 집에서',
                          style: TextStyle(
                              fontSize: 13, color: AppTheme.textTertiary),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── 탭 바 ─────────────────────────────────────────
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: AppTheme.imagePlaceholder,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: AppTheme.textPrimary,
                    unselectedLabelColor: AppTheme.textTertiary,
                    labelStyle: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14),
                    unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 14),
                    padding: const EdgeInsets.all(4),
                    tabs: [Tab(text: l10n.signIn), Tab(text: l10n.signUp)],
                  ),
                ),

                // ── 폼 ───────────────────────────────────────────
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _LoginForm(
                        loading: controller.authLoading,
                        onSubmit: _login,
                        l10n: l10n,
                        bottomInset: bottomInset,
                      ),
                      _SignupForm(
                        loading: controller.authLoading,
                        onSubmit: _signup,
                        l10n: l10n,
                        bottomInset: bottomInset,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Login Form ────────────────────────────────────────────────────────────────

class _LoginForm extends StatefulWidget {
  const _LoginForm({
    required this.loading,
    required this.onSubmit,
    required this.l10n,
    required this.bottomInset,
  });

  final bool loading;
  final Future<String?> Function(String email, String password) onSubmit;
  final AppLocalizations l10n;
  final double bottomInset;

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  Map<String, String?> _errors = {};
  bool _submitted = false;
  String? _apiError;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Map<String, String?> _validate() => {
        'email': _checkEmail(_emailCtrl.text.trim()),
        'password': _checkPasswordLogin(_passwordCtrl.text),
      };

  void _onChange() {
    if (!_submitted) return;
    setState(() {
      _errors = _validate();
      _apiError = null;
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _submitted = true;
      _apiError = null;
      _errors = _validate();
    });
    if (_errors.values.any((e) => e != null)) return;

    final error = await widget.onSubmit(
      _emailCtrl.text.trim(),
      _passwordCtrl.text,
    );
    if (!mounted) return;
    if (error != null) {
      setState(() => _apiError = error);
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + widget.bottomInset),
      children: [
        _AuthFormField(
          controller: _emailCtrl,
          label: widget.l10n.emailLabel,
          hint: 'example@email.com',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
          textInputAction: TextInputAction.next,
          errorText: _errors['email'],
          onChanged: (_) => _onChange(),
        ),
        const SizedBox(height: 16),
        _AuthFormField(
          controller: _passwordCtrl,
          label: widget.l10n.passwordLabel,
          hint: '비밀번호를 입력하세요',
          obscureText: true,
          prefixIcon: Icons.lock_outline_rounded,
          textInputAction: TextInputAction.done,
          errorText: _errors['password'],
          onChanged: (_) => _onChange(),
          onSubmitted: (_) => _submit(),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: _apiError != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: _ApiErrorBanner(message: _apiError!),
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: 28),
        _SubmitButton(
          label: widget.l10n.signIn,
          loading: widget.loading,
          onPressed: _submit,
        ),
      ],
    );
  }
}

// ── Signup Form ───────────────────────────────────────────────────────────────

class _SignupForm extends StatefulWidget {
  const _SignupForm({
    required this.loading,
    required this.onSubmit,
    required this.l10n,
    required this.bottomInset,
  });

  final bool loading;
  final Future<String?> Function(
      String email, String password, String name, String phone) onSubmit;
  final AppLocalizations l10n;
  final double bottomInset;

  @override
  State<_SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<_SignupForm> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  Map<String, String?> _errors = {};
  bool _submitted = false;
  String? _apiError;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Map<String, String?> _validate() => {
        'email': _checkEmail(_emailCtrl.text.trim()),
        'password': _checkPasswordSignup(_passwordCtrl.text),
        'name': _checkName(_nameCtrl.text),
        'phone': _checkPhone(_phoneCtrl.text.trim()),
      };

  void _onChange() {
    if (!_submitted) return;
    setState(() {
      _errors = _validate();
      _apiError = null;
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _submitted = true;
      _apiError = null;
      _errors = _validate();
    });
    if (_errors.values.any((e) => e != null)) return;

    final error = await widget.onSubmit(
      _emailCtrl.text.trim(),
      _passwordCtrl.text,
      _nameCtrl.text.trim(),
      _phoneCtrl.text.trim(),
    );
    if (!mounted) return;
    if (error != null) {
      setState(() => _apiError = error);
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + widget.bottomInset),
      children: [
        _AuthFormField(
          controller: _emailCtrl,
          label: widget.l10n.emailLabel,
          hint: 'example@email.com',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
          textInputAction: TextInputAction.next,
          errorText: _errors['email'],
          onChanged: (_) => _onChange(),
        ),
        const SizedBox(height: 16),
        _AuthFormField(
          controller: _passwordCtrl,
          label: widget.l10n.passwordLabel,
          hint: '8자 이상 입력하세요',
          obscureText: true,
          prefixIcon: Icons.lock_outline_rounded,
          textInputAction: TextInputAction.next,
          errorText: _errors['password'],
          onChanged: (_) => _onChange(),
        ),
        const SizedBox(height: 16),
        _AuthFormField(
          controller: _nameCtrl,
          label: widget.l10n.nameLabel,
          hint: '이름을 입력하세요',
          prefixIcon: Icons.person_outline_rounded,
          textInputAction: TextInputAction.next,
          errorText: _errors['name'],
          onChanged: (_) => _onChange(),
        ),
        const SizedBox(height: 16),
        _AuthFormField(
          controller: _phoneCtrl,
          label: widget.l10n.phoneLabel,
          hint: '010-0000-0000 (선택)',
          keyboardType: TextInputType.phone,
          prefixIcon: Icons.phone_outlined,
          textInputAction: TextInputAction.done,
          errorText: _errors['phone'],
          onChanged: (_) => _onChange(),
          onSubmitted: (_) => _submit(),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: _apiError != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: _ApiErrorBanner(message: _apiError!),
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: 28),
        _SubmitButton(
          label: widget.l10n.signUp,
          loading: widget.loading,
          onPressed: _submit,
        ),
      ],
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _AuthFormField extends StatefulWidget {
  const _AuthFormField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.errorText,
    this.keyboardType,
    this.obscureText = false,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final String? errorText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<_AuthFormField> createState() => _AuthFormFieldState();
}

class _AuthFormFieldState extends State<_AuthFormField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // label
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: hasError ? _kErrorColor : AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 6),

        // input container
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: hasError
                ? _kErrorColor.withValues(alpha: 0.03)
                : AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(
              color: hasError ? _kErrorColor : AppTheme.border,
              width: hasError ? 1.5 : 1.0,
            ),
          ),
          child: TextField(
            controller: widget.controller,
            keyboardType: widget.keyboardType,
            obscureText: _isObscured,
            textInputAction: widget.textInputAction,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            style: const TextStyle(fontSize: 15, color: AppTheme.textPrimary),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: const TextStyle(
                  color: AppTheme.textTertiary, fontSize: 14),
              prefixIcon: Icon(
                widget.prefixIcon,
                size: 20,
                color: hasError
                    ? _kErrorColor.withValues(alpha: 0.55)
                    : AppTheme.textTertiary,
              ),
              suffixIcon: widget.obscureText
                  ? GestureDetector(
                      onTap: () =>
                          setState(() => _isObscured = !_isObscured),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Icon(
                          _isObscured
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 20,
                          color: AppTheme.textTertiary,
                        ),
                      ),
                    )
                  : null,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              filled: false,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
            ),
          ),
        ),

        // error message (animates in/out)
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: hasError
              ? Padding(
                  padding: const EdgeInsets.only(top: 6, left: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 1),
                        child: Icon(
                          Icons.error_outline_rounded,
                          size: 13,
                          color: _kErrorColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.errorText!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: _kErrorColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _ApiErrorBanner extends StatelessWidget {
  const _ApiErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _kErrorColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: _kErrorColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(
              Icons.info_outline_rounded,
              size: 16,
              color: _kErrorColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                color: _kErrorColor,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final bool loading;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: loading ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppTheme.primary,
        minimumSize: const Size.fromHeight(52),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
      child: loading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                  strokeWidth: 2.5, color: Colors.white),
            )
          : Text(label),
    );
  }
}
