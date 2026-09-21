import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/feature/auth/auth_provider.dart';
import 'package:frontend/feature/auth/auth_state.dart';
import 'package:frontend/utils/locale_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(authProvider.notifier)
        .login(_usernameController.text.trim(), _passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final currentLocale = ref.watch(localeProvider);
    final l10n = context.l10n;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEDF4FE), Color(0xFFC7DCF8)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 16,
              right: 16,
              child: PopupMenuButton<String>(
                position: PopupMenuPosition.under,
                offset: const Offset(0, 4),
                icon: const Icon(Icons.language, color: Color(0xFF2A3E5C), size: 28),
                tooltip: l10n.switchLanguage,
                color: const Color(0xFF1E2638),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.white24),
                ),
                onSelected: (code) {
                  ref.read(localeProvider.notifier).setLocale(Locale(code));
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'zh',
                    child: Row(
                      children: [
                        Text(
                          '🇹🇼 繁體中文',
                          style: TextStyle(
                            color: currentLocale.languageCode == 'zh'
                                ? const Color(0xFF79A9EA)
                                : Colors.white,
                            fontWeight: currentLocale.languageCode == 'zh'
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        if (currentLocale.languageCode == 'zh') ...[
                          const Spacer(),
                          const Icon(Icons.check, size: 16, color: Color(0xFF79A9EA)),
                        ],
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'en',
                    child: Row(
                      children: [
                        Text(
                          '🇺🇸 English',
                          style: TextStyle(
                            color: currentLocale.languageCode == 'en'
                                ? const Color(0xFF79A9EA)
                                : Colors.white,
                            fontWeight: currentLocale.languageCode == 'en'
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        if (currentLocale.languageCode == 'en') ...[
                          const Spacer(),
                          const Icon(Icons.check, size: 16, color: Color(0xFF79A9EA)),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Card(
                    elevation: 12,
                    shadowColor: Colors.black.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
                    color: Colors.white.withValues(alpha: 0.85),
                    margin: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 400),
                      padding: const EdgeInsets.all(32.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24.0),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header Icon & Title
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0x22508FE8),
                              ),
                              child: const Icon(
                                Icons.directions_run_rounded,
                                size: 48,
                                color: Color(0xFF508FE8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.appTitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2A3E5C),
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.login,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                          ),
                          const SizedBox(height: 32),

                          // Username field
                          TextFormField(
                            controller: _usernameController,
                            style: const TextStyle(color: Color(0xFF1F2937)),
                            decoration: InputDecoration(
                              labelText: l10n.username,
                              labelStyle: const TextStyle(color: Color(0xFF6B7280)),
                              prefixIcon: const Icon(
                                Icons.person_outline_rounded,
                                color: Color(0xFF508FE8),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                borderSide: const BorderSide(color: Color(0x55508FE8)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                borderSide: const BorderSide(color: Color(0xFF508FE8), width: 2),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                borderSide: const BorderSide(color: Colors.redAccent),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                borderSide: const BorderSide(color: Colors.redAccent, width: 2),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return l10n.usernameHint;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Password field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: const TextStyle(color: Color(0xFF1F2937)),
                            decoration: InputDecoration(
                              labelText: l10n.password,
                              labelStyle: const TextStyle(color: Color(0xFF6B7280)),
                              prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                                color: Color(0xFF508FE8),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: const Color(0xFF6B7280),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                borderSide: const BorderSide(color: Color(0x55508FE8)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                borderSide: const BorderSide(color: Color(0xFF508FE8), width: 2),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                borderSide: const BorderSide(color: Colors.redAccent),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                borderSide: const BorderSide(color: Colors.redAccent, width: 2),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n.passwordHint;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Error display
                          if (authState.status == AuthStatus.error &&
                              authState.errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Text(
                                authState.errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                          // Login Button
                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: authState.status == AuthStatus.loading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF508FE8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                elevation: 2,
                              ),
                              child: authState.status == AuthStatus.loading
                                  ? const SpinKitThreeBounce(color: Colors.white, size: 20)
                                  : Text(
                                      l10n.login,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Switch to Register Page
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                l10n.dontHaveAccount,
                                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.push('/register');
                                },
                                child: Text(
                                  l10n.register,
                                  style: const TextStyle(
                                    color: Color(0xFF508FE8),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
