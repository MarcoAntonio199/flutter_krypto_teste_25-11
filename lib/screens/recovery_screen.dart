import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/kv_widgets.dart';
import 'auth_card.dart';

class RecoveryScreen extends StatelessWidget {
  const RecoveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Eyebrow('RECUPERAÇÃO DE ACESSO'),
          const AuthTitle('Recuperação segura'),
          Text(
            'O fluxo de recuperação por token ainda não está implementado '
            'nesta versão. Não seria seguro simular uma recuperação sem '
            'verificar a identidade e sem definir como a chave de '
            'criptografia do cofre seria recuperada.',
            style: KV.body(height: 1.6),
          ),
          const NoticeBox(
            'A recuperação da conta e a recuperação dos dados criptografados '
            'são problemas diferentes. Uma redefinição de senha não deve '
            'apagar nem expor silenciosamente o conteúdo do cofre.',
          ),
          const SizedBox(height: 22),
          KvLink(
            text: 'Voltar ao login',
            size: 15,
            underline: true,
            onTap: () {
              final navigator = Navigator.of(context);
              if (navigator.canPop()) {
                navigator.pop();
              } else {
                navigator.pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
    );
  }
}
