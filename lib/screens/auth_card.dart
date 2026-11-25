import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// `.auth-card`: cartão central de 450px usado em login, cadastro e recuperação.
class AuthCard extends StatelessWidget {
  const AuthCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    // padding: clamp(24px, 5vw, 42px)
    final padding = (width * 0.05).clamp(24.0, 42.0);

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 450),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 25, bottom: 25),
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: KV.panel,
            border: Border.all(color: KV.border),
            borderRadius: BorderRadius.circular(4),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// `h1` do cartão de autenticação.
class AuthTitle extends StatelessWidget {
  const AuthTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Text(
          text,
          style: KV.grotesk(size: 34, height: 1.12, letterSpacing: -1),
        ),
      );
}
