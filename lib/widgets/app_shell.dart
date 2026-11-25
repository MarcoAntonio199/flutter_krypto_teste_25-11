import 'package:flutter/material.dart';

import '../services/auth_state.dart';
import '../theme/app_theme.dart';
import 'kv_widgets.dart';

/// Fundo quadriculado do `body` (linhas brancas a 2,5% a cada 32px).
class _GridPainter extends CustomPainter {
  const _GridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x06FFFFFF)
      ..strokeWidth = 1;
    for (double x = 0; x <= size.width; x += 32) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += 32) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Equivalente ao `.app-shell` do App.jsx: topbar + conteúdo + rodapé.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.route, required this.child});

  /// Rota atual (usada para marcar o item ativo do menu).
  final String route;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final narrow = isNarrow(context);

    return Scaffold(
      backgroundColor: KV.black,
      body: Stack(
        children: [
          const Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(painter: _GridPainter()),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, box) {
                // Estimativas das alturas da topbar e do rodapé, só para o
                // rodapé ficar no fim da tela quando o conteúdo é curto.
                final reserved = narrow ? 190.0 : 150.0;
                final minContent =
                    (box.maxHeight - reserved).clamp(0.0, double.infinity);

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _TopBar(route: route),
                      ConstrainedBox(
                        constraints: BoxConstraints(minHeight: minContent),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints:
                                const BoxConstraints(maxWidth: 1100),
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                20,
                                narrow ? 34 : 52,
                                20,
                                80,
                              ),
                              child: child,
                            ),
                          ),
                        ),
                      ),
                      const _Footer(),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.route});

  final String route;

  @override
  Widget build(BuildContext context) {
    final narrow = isNarrow(context);
    final width = MediaQuery.sizeOf(context).width;
    // padding: 0 clamp(20px, 5vw, 76px)
    final horizontal = (width * 0.05).clamp(20.0, 76.0);
    final user = AuthState.instance.user;

    final brand = _Brand(
      onTap: () => _go(context, route, user != null ? '/dashboard' : '/login'),
    );

    final nav = user == null
        ? null
        : Wrap(
            spacing: narrow ? 16 : 22,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _NavLink('Visão geral', '/dashboard', route),
              _NavLink('Meu cofre', '/vault', route),
              _NavLink('Continuidade', '/plans', route),
              _NavLink('Atividade', '/history', route),
              KvLink(
                text: 'Sair',
                size: 13,
                color: KV.muted,
                hoverColor: Colors.white,
                onTap: () => AuthState.instance.logout(),
              ),
            ],
          );

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 78),
      padding: EdgeInsets.symmetric(
        horizontal: horizontal,
        vertical: narrow ? 18 : 0,
      ),
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(bottom: BorderSide(color: Colors.white)),
      ),
      child: narrow
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                brand,
                if (nav != null) ...[const SizedBox(height: 14), nav],
              ],
            )
          : Row(
              children: [
                brand,
                const SizedBox(width: 24),
                if (nav != null)
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: nav,
                    ),
                  ),
              ],
            ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(4),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: Image.asset(
                  'assets/images/kryptovault-eye.png',
                  fit: BoxFit.contain,
                  semanticLabel: 'KryptoVault Logo',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'KryptoVault',
                  style: KV.grotesk(size: 18, weight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  'COFRE DIGITAL',
                  style: KV.mono(size: 9, color: KV.gray, letterSpacing: 2),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink(this.label, this.target, this.current);

  final String label;
  final String target;
  final String current;

  @override
  Widget build(BuildContext context) {
    final active = current == target;
    return KvLink(
      text: label,
      size: 13,
      color: active ? Colors.white : KV.muted,
      hoverColor: Colors.white,
      underline: active,
      thickness: 2,
      onTap: () => _go(context, current, target),
    );
  }
}

void _go(BuildContext context, String current, String target) {
  if (current == target) return;
  Navigator.of(context).pushReplacementNamed(target);
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: Color(0xFF292929))),
      ),
      child: Text(
        'KryptoVault · Projeto acadêmico de segurança da informação',
        textAlign: TextAlign.center,
        style: KV.body(size: 12, color: KV.dim),
      ),
    );
  }
}
