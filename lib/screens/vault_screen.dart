import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/kv_widgets.dart';

/// Tela "Meu cofre" (Vault.jsx): formulário + lista de registros.
///
/// O conteúdo dos itens "senha" e "conta" é enviado como JSON estruturado
/// (`__kryptovault_format: 1`), exatamente como no front React, e o backend
/// cifra tudo com AES-256-GCM antes de gravar.
class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  static const _categories = [
    KvOption('anotacao', 'Anotação'),
    KvOption('senha', 'Senha'),
    KvOption('conta', 'Conta'),
    KvOption('documento', 'Documento (referência)'),
    KvOption('outro', 'Outro'),
  ];

  final _formKey = GlobalKey<FormState>();
  final _panelKey = GlobalKey();

  final _title = TextEditingController();
  final _website = TextEditingController();
  final _service = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _notes = TextEditingController();
  final _content = TextEditingController();

  List<VaultItem> _items = [];
  String _category = 'anotacao';
  int? _editing;
  String _error = '';
  bool _busy = false;
  final Map<int, bool> _revealed = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in [
      _title,
      _website,
      _service,
      _username,
      _password,
      _notes,
      _content,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final items = await Api.instance.items();
      if (!mounted) return;
      setState(() => _items = items);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    for (final c in [
      _title,
      _website,
      _service,
      _username,
      _password,
      _notes,
      _content,
    ]) {
      c.clear();
    }
    _category = 'anotacao';
  }

  void _cancelEdit() {
    setState(() {
      _editing = null;
      _error = '';
      _clearForm();
    });
  }

  /// `prepareContent` do Vault.jsx.
  String _prepareContent() {
    if (_category == 'senha') {
      return jsonEncode({
        '__kryptovault_format': 1,
        'website': _website.text,
        'username': _username.text,
        'password': _password.text,
        'notes': _notes.text,
      });
    }
    if (_category == 'conta') {
      return jsonEncode({
        '__kryptovault_format': 1,
        'service': _service.text,
        'username': _username.text,
        'notes': _notes.text,
      });
    }
    return _content.text;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _busy = true;
      _error = '';
    });

    try {
      final item = {
        'title': _title.text.trim(),
        'category': _category,
        'content': _prepareContent(),
      };
      final editing = _editing;
      if (editing != null) {
        await Api.instance.updateItem(editing, item);
      } else {
        await Api.instance.addItem(item);
      }
      if (!mounted) return;
      _cancelEdit();
      await _load();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _edit(VaultItem item) {
    final content = VaultContent.parse(item.rawContent);

    setState(() {
      _editing = item.id;
      _error = '';
      _clearForm();
      _title.text = item.title;
      _category = item.category;

      if (item.category == 'senha') {
        _website.text = content.field('website') ?? '';
        _username.text = content.field('username') ?? '';
        _password.text = content.field('password') ?? '';
        _notes.text = content.field('notes') ?? content.legacy ?? '';
      } else if (item.category == 'conta') {
        _service.text = content.field('service') ?? '';
        _username.text = content.field('username') ?? '';
        _notes.text = content.field('notes') ?? content.legacy ?? '';
      } else {
        _content.text = content.legacy ?? item.rawContent;
      }
    });

    // No celular o formulário fica acima da lista: leva a tela até ele.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final panelContext = _panelKey.currentContext;
      if (panelContext != null) {
        Scrollable.ensureVisible(
          panelContext,
          duration: const Duration(milliseconds: 250),
        );
      }
    });
  }

  Future<void> _remove(VaultItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: KV.panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: KV.border),
        ),
        title: Text('Excluir registro', style: KV.grotesk(size: 18)),
        content: Text(
          'Excluir este registro permanentemente?',
          style: KV.body(color: KV.muted),
        ),
        actions: [
          KvButton(
            label: 'Cancelar',
            kind: KvButtonKind.secondary,
            small: true,
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
          KvButton(
            label: 'Excluir',
            kind: KvButtonKind.danger,
            small: true,
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _error = '');
    try {
      await Api.instance.deleteItem(item.id);
      if (!mounted) return;
      if (_editing == item.id) _cancelEdit();
      await _load();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  // ---- Formulário ---------------------------------------------------------

  Widget _buildForm() {
    final editing = _editing != null;

    final cells = <FormCell>[
      FormCell(
        KvField(
          label: 'Título',
          controller: _title,
          maxLength: 120,
          required: true,
        ),
      ),
      FormCell(
        KvSelect(
          label: 'Categoria',
          value: _category,
          options: _categories,
          onChanged: editing ? null : (v) => setState(() => _category = v),
        ),
      ),
    ];

    if (_category == 'senha') {
      cells.addAll([
        FormCell(
          KvField(
            label: 'Site ou endereço',
            controller: _website,
            maxLength: 2048,
            keyboardType: TextInputType.url,
            hint: 'https://exemplo.com',
          ),
        ),
        FormCell(
          KvField(
            label: 'Usuário ou e-mail',
            controller: _username,
            maxLength: 500,
          ),
        ),
        FormCell(
          KvField(
            label: 'Senha',
            controller: _password,
            obscure: true,
            maxLength: 10000,
            required: true,
          ),
          wide: true,
        ),
        FormCell(
          KvField(
            label: 'Observações (opcional)',
            controller: _notes,
            maxLength: 10000,
            rows: 3,
          ),
          wide: true,
        ),
      ]);
    } else if (_category == 'conta') {
      cells.addAll([
        FormCell(
          KvField(
            label: 'Plataforma ou serviço',
            controller: _service,
            maxLength: 500,
            hint: 'Ex.: e-mail, rede social',
          ),
        ),
        FormCell(
          KvField(
            label: 'Usuário ou e-mail',
            controller: _username,
            maxLength: 500,
          ),
        ),
        FormCell(
          KvField(
            label: 'Observações (opcional)',
            controller: _notes,
            maxLength: 10000,
            rows: 3,
          ),
          wide: true,
        ),
      ]);
    } else {
      final isDoc = _category == 'documento';
      cells.add(
        FormCell(
          KvField(
            label: isDoc ? 'Referência do documento' : 'Conteúdo privado',
            controller: _content,
            maxLength: 20000,
            rows: 4,
            required: true,
            hint: isDoc
                ? 'Descreva o documento ou informe sua referência. '
                    'Este campo não envia arquivos.'
                : 'Digite o conteúdo que deseja guardar.',
          ),
          wide: true,
        ),
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FormGrid(cells: cells),
          const SizedBox(height: 17),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              KvButton(
                label: _busy
                    ? 'Salvando...'
                    : editing
                        ? 'Salvar alterações'
                        : 'Guardar no cofre',
                onPressed: _busy ? null : _submit,
              ),
              if (editing)
                KvButton(
                  label: 'Cancelar',
                  kind: KvButtonKind.secondary,
                  onPressed: _busy ? null : _cancelEdit,
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ---- Lista --------------------------------------------------------------

  Widget _detail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SelectableText.rich(
        TextSpan(
          style: KV.body(size: 14, height: 1.5),
          children: [
            TextSpan(
              text: '$label ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: value, style: const TextStyle(color: KV.muted)),
          ],
        ),
      ),
    );
  }

  Widget _renderContent(VaultItem item) {
    final data = VaultContent.parse(item.rawContent);

    Widget plain(String text) => SelectableText(
          text,
          style: KV.body(size: 13, color: const Color(0xFFAAAAAA), height: 1.6),
        );

    if (data.isLegacy) return plain(data.legacy ?? '');

    if (item.category == 'senha') {
      final revealed = _revealed[item.id] == true;
      final website = data.field('website') ?? '';
      final username = data.field('username') ?? '';
      final notes = data.field('notes') ?? '';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (website.isNotEmpty) _detail('Site:', website),
          if (username.isNotEmpty) _detail('Usuário/e-mail:', username),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Wrap(
              spacing: 10,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SelectableText.rich(
                  TextSpan(
                    style: KV.body(size: 14, height: 1.5),
                    children: [
                      const TextSpan(
                        text: 'Senha: ',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(
                        text: revealed
                            ? (data.field('password') ?? '')
                            : '••••••••••••',
                        style: const TextStyle(color: KV.muted),
                      ),
                    ],
                  ),
                ),
                KvButton(
                  label: revealed ? 'Ocultar' : 'Revelar',
                  kind: KvButtonKind.secondary,
                  small: true,
                  onPressed: () => setState(() {
                    _revealed[item.id] = !revealed;
                  }),
                ),
              ],
            ),
          ),
          if (notes.isNotEmpty) _detail('Observações:', notes),
        ],
      );
    }

    if (item.category == 'conta') {
      final service = data.field('service') ?? '';
      final username = data.field('username') ?? '';
      final notes = data.field('notes') ?? '';
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (service.isNotEmpty) _detail('Plataforma:', service),
          if (username.isNotEmpty) _detail('Usuário/e-mail:', username),
          if (notes.isNotEmpty) _detail('Observações:', notes),
        ],
      );
    }

    return plain(item.rawContent);
  }

  Widget _buildItemCard(VaultItem item) {
    final narrow = isNarrow(context);

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.category.toUpperCase(),
          style: KV.body(size: 10, color: const Color(0xFFAAAAAA), letterSpacing: 1),
        ),
        const SizedBox(height: 8),
        Text(item.title, style: KV.body(weight: FontWeight.w700)),
        const SizedBox(height: 8),
        _renderContent(item),
      ],
    );

    final actions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        KvButton(
          label: 'Editar',
          kind: KvButtonKind.secondary,
          small: true,
          onPressed: () => _edit(item),
        ),
        const SizedBox(width: 7),
        KvButton(
          label: 'Excluir',
          kind: KvButtonKind.danger,
          small: true,
          onPressed: () => _remove(item),
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        border: Border.all(color: const Color(0xFF2D2D2D)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: narrow
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [body, const SizedBox(height: 16), actions],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: body),
                const SizedBox(width: 20),
                actions,
              ],
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PageHeading(
          eyebrow: 'ÁREA PRIVADA',
          title: 'Meu cofre',
          subtitle:
              'Seus registros são cifrados no backend antes de serem armazenados.',
        ),
        KvPanel(
          key: _panelKey,
          margin: const EdgeInsets.only(top: 0, bottom: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PanelTitle(
                _editing != null ? 'Editar registro' : 'Adicionar registro',
              ),
              const SizedBox(height: 24),
              _buildForm(),
              if (_error.isNotEmpty) ErrorText(_error),
            ],
          ),
        ),
        const SizedBox(height: 12),
        PanelHeading(
          'Registros guardados',
          trailing: Text(
            '${_items.length} item(ns)',
            style: KV.body(color: KV.muted),
          ),
        ),
        if (_items.isEmpty)
          DashedBox(
            child: Padding(
              padding: const EdgeInsets.all(36),
              child: Text(
                'Seu cofre ainda está vazio.',
                textAlign: TextAlign.center,
                style: KV.body(size: 13, color: KV.dim),
              ),
            ),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < _items.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                _buildItemCard(_items[i]),
              ],
            ],
          ),
      ],
    );
  }
}
