import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/kv_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.user});

  final AppUser? user;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DashboardData? _data;
  String _error = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final result = await Api.instance.dashboard();
      if (!mounted) return;
      setState(() => _data = result);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().isEmpty
            ? 'Não foi possível carregar o painel.'
            : e.toString();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _count(int? value) =>
      (_loading && _data == null) || value == null ? '—' : value.toString();

  void _open(String route) => Navigator.of(context).pushReplacementNamed(route);

  @override
  Widget build(BuildContext context) {
    final narrow = isNarrow(context);
    final email = widget.user?.email;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeading(
          eyebrow: 'VISÃO GERAL',
          title: 'Seu espaço seguro',
          subtitle: 'Olá, ${(email == null || email.isEmpty) ? 'usuário' : email}. '
              'Acompanhe seus registros e seus planos de continuidade.',
          action: KvButton(
            label: _loading ? 'Atualizando...' : 'Atualizar painel',
            kind: KvButtonKind.secondary,
            onPressed: _loading ? null : _load,
          ),
        ),
        if (_error.isNotEmpty)
          KvPanel(
            margin: const EdgeInsets.only(bottom: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ErrorText(_error),
                const SizedBox(height: 16),
                KvButton(
                  label: 'Tentar novamente',
                  kind: KvButtonKind.secondary,
                  onPressed: _loading ? null : _load,
                ),
              ],
            ),
          ),
        ResponsiveGrid(
          columns: narrow ? 1 : 3,
          gap: 16,
          children: [
            _StatCard(
              label: 'Registros no cofre',
              value: _count(_data?.itemCount),
              footer: KvLink(
                text: 'Gerenciar registros →',
                onTap: () => _open('/vault'),
              ),
            ),
            _StatCard(
              label: 'Planos de continuidade',
              value: _count(_data?.planCount),
              footer: KvLink(
                text: 'Revisar planos →',
                onTap: () => _open('/plans'),
              ),
            ),
            _StatCard(
              label: 'Estado da sessão',
              value: widget.user != null ? 'Autenticada' : 'Verificando',
              valueSize: 20,
              footer: Text(
                'A sessão não representa uma auditoria completa de segurança.',
                style: KV.body(size: 12, color: KV.muted, height: 1.6),
              ),
            ),
          ],
        ),
        KvPanel(
          margin: const EdgeInsets.only(top: 24, bottom: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PanelHeading('Acesso rápido'),
              ResponsiveGrid(
                columns: narrow ? 1 : 3,
                gap: 12,
                children: [
                  _QuickLink(
                    title: '01 · Meu cofre',
                    text: 'Organize senhas, contas, anotações e referências '
                        'de documentos.',
                    onTap: () => _open('/vault'),
                  ),
                  _QuickLink(
                    title: '02 · Continuidade digital',
                    text: 'Registre instruções para situações excepcionais e '
                        'revise seus planos.',
                    onTap: () => _open('/plans'),
                  ),
                  _QuickLink(
                    title: '03 · Histórico de atividades',
                    text: 'Consulte os eventos registrados pelo sistema.',
                    onTap: () => _open('/history'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const KvPanel(
          margin: EdgeInsets.only(top: 0, bottom: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PanelHeading('Boas práticas de segurança'),
              _Bullet(
                'Utilize uma senha forte e exclusiva para acessar sua conta.',
              ),
              _Bullet(
                'Revise seus planos de continuidade e mantenha as instruções '
                'atualizadas.',
              ),
              _Bullet(
                'Faça cópias de segurança protegidas dos dados e planeje a '
                'preservação da chave de criptografia.',
              ),
            ],
          ),
        ),
        const NoticeBox(
          'Protótipo acadêmico: utilize dados fictícios durante o '
          'desenvolvimento. A criptografia implementada não substitui uma '
          'auditoria de segurança completa.',
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.footer,
    this.valueSize = 30,
  });

  final String label;
  final String value;
  final Widget footer;
  final double valueSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isNarrow(context) ? 20 : 24),
      decoration: BoxDecoration(
        color: KV.panel,
        border: Border.all(color: KV.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: KV.body(size: 13, color: KV.muted)),
          const SizedBox(height: 15),
          Text(
            value,
            style: KV.mono(size: valueSize, weight: FontWeight.w500),
          ),
          const SizedBox(height: 15),
          footer,
        ],
      ),
    );
  }
}

class _QuickLink extends StatefulWidget {
  const _QuickLink({
    required this.title,
    required this.text,
    required this.onTap,
  });

  final String title;
  final String text;
  final VoidCallback onTap;

  @override
  State<_QuickLink> createState() => _QuickLinkState();
}

class _QuickLinkState extends State<_QuickLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _hover ? const Color(0xFF111111) : Colors.black,
            border: Border.all(
              color: _hover ? Colors.white : KV.borderSoft,
            ),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: KV.body(size: 13, weight: FontWeight.w700).copyWith(
                      decoration: _hover
                          ? TextDecoration.underline
                          : TextDecoration.none,
                      decorationColor: Colors.white,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.text,
                style: KV.body(size: 12, color: KV.muted, height: 1.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Item de lista `ul` do painel.
class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 6, right: 12),
            child: Text(
              '•',
              style: KV.body(color: const Color(0xFFB5B5B5), height: 2),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: KV.body(color: const Color(0xFFB5B5B5), height: 2),
            ),
          ),
        ],
      ),
    );
  }
}
