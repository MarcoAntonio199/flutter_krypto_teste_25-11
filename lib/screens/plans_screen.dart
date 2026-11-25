import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/models.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/kv_widgets.dart';

/// "Continuidade digital" (PreventPlans.jsx).
class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _contact = TextEditingController();
  final _days = TextEditingController(text: '30');
  final _instructions = TextEditingController();
  String _status = 'rascunho';

  List<ContinuityPlan> _plans = [];
  List<ChecklistItem> _checks = [];
  String _error = '';
  String _message = '';
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _title.dispose();
    _contact.dispose();
    _days.dispose();
    _instructions.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait<Object>([
        Api.instance.plans(),
        Api.instance.checklist(),
      ]);
      if (!mounted) return;
      setState(() {
        _plans = results[0] as List<ContinuityPlan>;
        _checks = results[1] as List<ChecklistItem>;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _error = '';
      _message = '';
      _busy = true;
    });
    try {
      final message = await Api.instance.addPlan({
        'title': _title.text,
        'instructions': _instructions.text,
        'contactName': _contact.text,
        'waitingDays': int.parse(_days.text.trim()),
        'status': _status,
      });
      if (!mounted) return;
      _formKey.currentState?.reset();
      setState(() {
        _message = message;
        _title.clear();
        _contact.clear();
        _instructions.clear();
        _days.text = '30';
        _status = 'rascunho';
      });
      await _load();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PageHeading(
          eyebrow: 'DIFERENCIAL DO PROJETO',
          title: 'Continuidade digital',
          subtitle: 'Organize instruções para situações imprevistas sem '
              'entregar automaticamente o acesso ao cofre.',
        ),
        const NoticeBox(
          'Os planos são documentos pessoais. Nesta versão, não há envio a '
          'contatos, verificação de incapacidade nem liberação automática '
          'de dados.',
          top: 0,
        ),
        KvPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PanelTitle('Novo plano'),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FormGrid(
                      cells: [
                        FormCell(
                          KvField(
                            label: 'Título',
                            controller: _title,
                            maxLength: 120,
                            required: true,
                            hint: 'Ex.: Instruções para contas digitais',
                          ),
                        ),
                        FormCell(
                          KvField(
                            label: 'Contato de confiança (opcional)',
                            controller: _contact,
                            maxLength: 120,
                            hint: 'Nome, sem dados de contato sensíveis',
                          ),
                        ),
                        FormCell(
                          KvField(
                            label: 'Período de espera (dias)',
                            controller: _days,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            required: true,
                            validator: (v) {
                              final n = int.tryParse(v.trim());
                              if (n == null || n < 1 || n > 3650) {
                                return 'Informe de 1 a 3650 dias.';
                              }
                              return null;
                            },
                          ),
                        ),
                        FormCell(
                          KvSelect(
                            label: 'Estado',
                            value: _status,
                            options: const [
                              KvOption('rascunho', 'Rascunho'),
                              KvOption('revisar', 'Precisa revisar'),
                              KvOption('arquivado', 'Arquivado'),
                            ],
                            onChanged: (v) => setState(() => _status = v),
                          ),
                        ),
                        FormCell(
                          KvField(
                            label: 'Instruções',
                            controller: _instructions,
                            maxLength: 5000,
                            rows: 4,
                            required: true,
                            hint: 'Descreva orientações gerais. Não inclua '
                                'senhas ou chaves de recuperação.',
                          ),
                          wide: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 17),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: KvButton(
                        label: _busy ? 'Salvando...' : 'Salvar plano',
                        onPressed: _busy ? null : _submit,
                      ),
                    ),
                  ],
                ),
              ),
              if (_error.isNotEmpty) ErrorText(_error),
              if (_message.isNotEmpty) SuccessText(_message),
            ],
          ),
        ),
        KvPanel(
          margin: const EdgeInsets.only(bottom: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PanelTitle('Checklist preventivo'),
              const SizedBox(height: 20),
              for (final check in _checks)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        margin: const EdgeInsets.only(top: 1),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF555555)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          check.label,
                          style: KV.body(
                            size: 13,
                            color: const Color(0xFFCCCCCC),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Text(
                'Checklist de orientação nesta versão; as marcações ainda não '
                'são persistidas.',
                style: KV.body(color: KV.muted, height: 1.7),
              ),
            ],
          ),
        ),
        KvPanel(
          margin: const EdgeInsets.only(bottom: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PanelTitle('Planos cadastrados'),
              const SizedBox(height: 20),
              if (_plans.isEmpty)
                Text(
                  'Nenhum plano criado.',
                  style: KV.body(color: KV.muted, height: 1.7),
                )
              else
                for (final plan in _plans) _PlanRow(plan: plan),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlanRow extends StatelessWidget {
  const _PlanRow({required this.plan});

  final ContinuityPlan plan;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF303030))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(plan.title, style: KV.body(weight: FontWeight.w700)),
          const SizedBox(height: 8),
          SelectableText(
            plan.instructions,
            style: KV.body(size: 13, color: const Color(0xFFAAAAAA), height: 1.6),
          ),
          const SizedBox(height: 10),
          Text(
            'Espera: ${plan.waitingDays} dias · Estado: ${plan.status}',
            style: KV.body(size: 13, color: const Color(0xFF888888)),
          ),
        ],
      ),
    );
  }
}
