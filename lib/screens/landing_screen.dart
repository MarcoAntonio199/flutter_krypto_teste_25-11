import 'package:flutter/material.dart';

import '../services/auth_state.dart';
import '../theme/app_theme.dart';
import '../widgets/kv_widgets.dart';

/// Página inicial (`Landing` do App.jsx).
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthState.instance.user;
    final narrow = isNarrow(context);
    final width = MediaQuery.sizeOf(context).width;
    // padding: clamp(64px, 10vw, 112px) 0
    final vertical = (width * 0.10).clamp(64.0, 112.0);
    final titleSize = narrow ? 43.0 : (width * 0.05).clamp(34.0, 58.0);

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: vertical),
          child: SizedBox(
            width: double.infinity,
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Eyebrow('PRIVACIDADE POR DESIGN'),
              Text.rich(
                TextSpan(
                  style: KV.grotesk(
                    size: titleSize,
                    height: 1.12,
                    letterSpacing: -1.8,
                  ),
                  children: const [
                    TextSpan(text: 'Suas informações.\n'),
                    TextSpan(
                      text: 'Sob seu controle.',
                      style: TextStyle(color: KV.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 590),
                child: Text(
                  'Um espaço organizado para proteger informações importantes '
                  'e preparar um plano de continuidade digital.',
                  style: KV.body(size: 16, color: KV.muted, height: 1.85),
                ),
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  KvButton(
                    label: user != null ? 'Abrir meu cofre' : 'Criar meu cofre',
                    onPressed: () => Navigator.of(context)
                        .pushNamed(user != null ? '/dashboard' : '/register'),
                  ),
                  KvButton(
                    label: 'Entrar na conta',
                    kind: KvButtonKind.secondary,
                    onPressed: () => Navigator.of(context)
                        .pushNamed(user != null ? '/vault' : '/login'),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 7),
                    child: Dot(),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Criptografia de dados · Sessões protegidas · '
                      'Histórico de segurança',
                      style: KV.mono(size: 11, color: KV.gray, height: 1.8),
                    ),
                  ),
                ],
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}
