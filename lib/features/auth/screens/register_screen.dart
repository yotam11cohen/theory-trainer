import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth_error.dart';
import '../widgets/auth_form.dart';
import '../../../providers/supabase_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(supabaseClientProvider).auth.signUp(
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text,
          );
    } on AuthException catch (e) {
      setState(() => _error = friendlyAuthError(e.message));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(supabaseClientProvider).auth.signInWithOAuth(
            OAuthProvider.google,
            redirectTo: 'com.cleared.driving://login-callback',
          );
    } on AuthException catch (e) {
      setState(() => _error = friendlyAuthError(e.message));
    } catch (e) {
      setState(() => _error = 'Sign-in failed. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: AuthForm(
          formKey: _formKey,
          emailController: _emailCtrl,
          passwordController: _passCtrl,
          loading: _loading,
          error: _error,
          submitLabel: 'Sign Up',
          onSubmit: _register,
          onGoogle: _signInWithGoogle,
          footer: TextButton(
            onPressed: () => context.pop(),
            child: const Text('Already have an account? Sign In'),
          ),
        ),
      ),
    );
  }
}
