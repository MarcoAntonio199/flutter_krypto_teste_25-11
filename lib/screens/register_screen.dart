import 'dart:convert';

import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/auth_state.dart';
import '../theme/app_theme.dart';
import '../widgets/kv_widgets.dart';
import 'auth_card.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  String _error = '';
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  /// O backend (bcrypt) limita a senha a 72 bytes; o formulário web usa
  /// maxLength=72 e o servidor valida de novo em bytes.
  String? _validatePassword(String value) {
    if (value.length < 10) return 'Use pelo menos 10 caracteres.';
    if (utf8.encode(value).length > 72) {
      return 'A senha deve ter no máximo 72 bytes.';
    }
    return null;
  }

  Future<void> _submit() async {
    setState(() => _error = '');
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_password.text != _confirm.text) {
      setState(() => _error = 'As senhas não coincidem.');
      return;
    }
    setState(() => _busy = true);
    try {
      final user =
          await Api.instance.register(_email.text.trim(), _password.text);
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
          const Eyebrow('COMECE COM SEGURANÇA'),
          const AuthTitle('Crie sua conta'),
          Text(
            'Use uma senha única e difícil de adivinhar.',
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
                    label: 'Senha (10 a 72 caracteres)',
                    controller: _password,
                    obscure: true,
                    maxLength: 72,
                    autofillHints: const [AutofillHints.newPassword],
                    textInputAction: TextInputAction.next,
                    required: true,
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 17),
                  KvField(
                    label: 'Confirme a senha',
                    controller: _confirm,
                    obscure: true,
                    maxLength: 72,
                    autofillHints: const [AutofillHints.newPassword],
                    textInputAction: TextInputAction.done,
                    required: true,
                    validator: _validatePassword,
                  ),
                  if (_error.isNotEmpty) ErrorText(_error),
                  const SizedBox(height: 17),
                  KvButton(
                    label: _busy ? 'Criando…' : 'Criar conta',
                    full: true,
                    onPressed: _busy ? null : _submit,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Já tem conta? ',
                style: KV.body(size: 12, color: const Color(0xFF8F8F8F)),
              ),
              KvLink(
                text: 'Entrar',
                color: const Color(0xFFEEEEEE),
                underline: true,
                onTap: () => Navigator.of(context).pushNamed('/login'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
