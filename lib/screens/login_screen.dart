import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/auth_state.dart';
import '../theme/app_theme.dart';
import '../widgets/kv_widgets.dart';
import 'auth_card.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String _error = '';
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _busy = true;
      _error = '';
    });
    try {
      final user = await Api.instance.login(_email.text.trim(), _password.text);
      if (!mounted) return;
      AuthState.instance.setUser(user);
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/dashboard', (route) => false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Eyebrow('ACESSO SEGURO'),
          const AuthTitle('Bem-vindo de volta'),
          Text(
            'Entre para acessar seu espaço protegido.',
            style: KV.body(color: KV.muted, height: 1.7),
          ),
          const SizedBox(height: 24),
          Form(
            key: _formKey,
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  KvField(
                    label: 'E-mail',
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    textInputAction: TextInputAction.next,
                    maxLength: 254,
                    required: true,
                    validator: (v) =>
                        v.contains('@') ? null : 'Informe um e-mail válido.',
                  ),
                  const SizedBox(height: 17),
                  KvField(
                    label: 'Senha',
                    controller: _password,
                    obscure: true,
                    autofillHints: const [AutofillHints.password],
                    textInputAction: TextInputAction.done,
                    required: true,
                  ),
                  if (_error.isNotEmpty) ErrorText(_error),
                  const SizedBox(height: 17),
                  KvButton(
                    label: _busy ? 'Entrando…' : 'Entrar',
                    full: true,
                    onPressed: _busy ? null : _submit,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          _FootLine(
            before: 'Ainda não tem conta? ',
            link: 'Criar conta',
            onTap: () => Navigator.of(context).pushNamed('/register'),
          ),
          const SizedBox(height: 6),
          KvLink(
            text: 'Sobre recuperação de acesso',
            color: const Color(0xFFEEEEEE),
            underline: true,
            onTap: () => Navigator.of(context).pushNamed('/recovery'),
          ),
        ],
      ),
    );
  }
}

/// `.form-foot`: "Texto cinza + link sublinhado".
class _FootLine extends StatelessWidget {
  const _FootLine({
    required this.before,
    required this.link,
    required this.onTap,
  });

  final String before;
  final String link;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(before, style: KV.body(size: 12, color: const Color(0xFF8F8F8F))),
        KvLink(
          text: link,
          color: const Color(0xFFEEEEEE),
          underline: true,
          onTap: onTap,
        ),
      ],
    );
  }
}
