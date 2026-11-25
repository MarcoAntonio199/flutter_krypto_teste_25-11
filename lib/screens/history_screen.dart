import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/kv_widgets.dart';

const Map<String, String> _eventLabels = {
  'cadastro_sucesso': 'Conta criada',
  'login_sucesso': 'Login realizado',
  'login_falhou': 'Tentativa de login falhou',
  'logout': 'Sessão encerrada',
  'item_criado': 'Registro criado',
  'item_atualizado': 'Registro atualizado',
  'item_excluido': 'Registro excluído',
};

/// "Histórico de atividade" (ActivityHistory.jsx).
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<ActivityEvent>? _events;
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
      setState(() => _events = result.events);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().isEmpty
            ? 'Não foi possível carregar o histórico.'
            : e.toString();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final events = _events;

    Widget list;
    if (_loading && events == null) {
      list = Text('Carregando histórico...', style: KV.body(color: KV.muted));
    } else if (events == null) {
      list = Text(
        'O histórico não está disponível no momento.',
        style: KV.body(color: KV.muted),
      );
    } else if (events.isEmpty) {
      list = Text('Nenhum evento disponível.', style: KV.body(color: KV.muted));
    } else {
      list = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < events.length; i++)
            _EventRow(event: events[i], last: i == events.length - 1),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeading(
          eyebrow: 'TRANSPARÊNCIA',
          title: 'Histórico de atividade',
          subtitle: 'Consulte os eventos registrados pelo sistema, '
              'sem exibir o conteúdo dos seus segredos.',
          action: KvButton(
            label: _loading ? 'Atualizando...' : 'Atualizar histórico',
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
        KvPanel(
          margin: const EdgeInsets.only(top: 0, bottom: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PanelHeading(
                'Eventos registrados',
                trailing: Text(
                  events != null ? '${events.length} evento(s)' : '',
                  style: KV.body(color: KV.muted),
                ),
              ),
              list,
            ],
          ),
        ),
        const NoticeBox(
          'O histórico mostra apenas os eventos disponibilizados pela API. '
          'Ele não comprova, por si só, que todas as ações possíveis estejam '
          'sendo registradas.',
        ),
      ],
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.event, required this.last});

  final ActivityEvent event;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(bottom: BorderSide(color: Color(0xFF292929))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 5),
            child: Dot(),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _eventLabels[event.event] ?? 'Atividade registrada',
                  style: KV.body(size: 13, weight: FontWeight.w500),
                ),
                const SizedBox(height: 7),
                Text(
                  formatDateTime(event.createdAt),
                  style: KV.body(size: 11, color: const Color(0xFF888888)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
