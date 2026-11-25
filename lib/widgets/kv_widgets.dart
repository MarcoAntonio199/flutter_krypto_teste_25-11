import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

/// Mesmo breakpoint do CSS (`@media (max-width: 760px)`).
bool isNarrow(BuildContext context) => MediaQuery.sizeOf(context).width <= 760;

// ---------------------------------------------------------------------------
// Textos
// ---------------------------------------------------------------------------

/// `.eyebrow`: "[ TEXTO ]" em mono, com colchetes cinza.
class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.bottom = 22});

  final String text;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    const bracket = TextStyle(color: Color(0xFF777777));
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Text.rich(
        TextSpan(
          style: KV.mono(size: 11, letterSpacing: 2),
          children: [
            const TextSpan(text: '[ ', style: bracket),
            TextSpan(
              text: text.toUpperCase(),
              style: const TextStyle(color: Colors.white),
            ),
            const TextSpan(text: ' ]', style: bracket),
          ],
        ),
      ),
    );
  }
}

/// `.error`: texto branco com barra lateral.
class ErrorText extends StatelessWidget {
  const ErrorText(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        padding: const EdgeInsets.only(left: 12),
        decoration: const BoxDecoration(
          border: Border(left: BorderSide(color: Colors.white, width: 2)),
        ),
        child: Text(message, style: KV.body(size: 13, height: 1.5)),
      ),
    );
  }
}

class SuccessText extends StatelessWidget {
  const SuccessText(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Text(message, style: KV.body(size: 13, color: KV.success)),
    );
  }
}

/// `.notice`: aviso discreto com fundo levemente amarelado.
class NoticeBox extends StatelessWidget {
  const NoticeBox(this.text, {super.key, this.top = 22});

  final String text;
  final double top;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: top),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: BoxDecoration(
        color: KV.noticeBg,
        border: Border.all(color: KV.noticeBorder),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(text, style: KV.body(size: 12, color: KV.gray, height: 1.8)),
    );
  }
}

/// Quadradinho branco (`.dot` / `.event-dot` — sem cantos arredondados).
class Dot extends StatelessWidget {
  const Dot({super.key});

  @override
  Widget build(BuildContext context) => Container(
        width: 6,
        height: 6,
        color: Colors.white,
      );
}

// ---------------------------------------------------------------------------
// Links e botões
// ---------------------------------------------------------------------------

class KvLink extends StatefulWidget {
  const KvLink({
    super.key,
    required this.text,
    required this.onTap,
    this.size = 12,
    this.color = Colors.white,
    this.hoverColor,
    this.underline = false,
    this.thickness = 1,
    this.weight = FontWeight.w400,
  });

  final String text;
  final VoidCallback onTap;
  final double size;
  final Color color;
  final Color? hoverColor;
  final bool underline;
  final double thickness;
  final FontWeight weight;

  @override
  State<KvLink> createState() => _KvLinkState();
}

class _KvLinkState extends State<KvLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final color = _hover ? (widget.hoverColor ?? widget.color) : widget.color;
    final underlined = widget.underline || _hover;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            widget.text,
            style: KV.body(
              size: widget.size,
              color: color,
              weight: widget.weight,
            ).copyWith(
              decoration:
                  underlined ? TextDecoration.underline : TextDecoration.none,
              decorationColor: color,
              decorationThickness: widget.thickness,
            ),
          ),
        ),
      ),
    );
  }
}

enum KvButtonKind { primary, secondary, danger }

/// `.primary`, `.secondary` e `.danger`: botões retangulares, fonte mono,
/// que invertem as cores no hover.
class KvButton extends StatefulWidget {
  const KvButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.kind = KvButtonKind.primary,
    this.small = false,
    this.full = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final KvButtonKind kind;
  final bool small;
  final bool full;

  @override
  State<KvButton> createState() => _KvButtonState();
}

class _KvButtonState extends State<KvButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final hover = enabled && _hover;

    final Color bg;
    final Color fg;
    final Color border;
    switch (widget.kind) {
      case KvButtonKind.primary:
        bg = hover ? const Color(0xFFDCDCDC) : Colors.white;
        fg = Colors.black;
        border = Colors.white;
        break;
      case KvButtonKind.secondary:
        bg = hover ? Colors.white : Colors.black;
        fg = hover ? Colors.black : Colors.white;
        border = hover ? Colors.white : const Color(0xFF777777);
        break;
      case KvButtonKind.danger:
        bg = hover ? Colors.white : Colors.black;
        fg = hover ? Colors.black : Colors.white;
        border = Colors.white;
        break;
    }

    final padding = widget.small
        ? const EdgeInsets.symmetric(horizontal: 11, vertical: 8)
        : const EdgeInsets.symmetric(horizontal: 17, vertical: 12);

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onPressed,
          onHover: (value) => setState(() => _hover = value),
          borderRadius: BorderRadius.circular(3),
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          focusColor: const Color(0x22FFFFFF),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: widget.full ? double.infinity : null,
            padding: padding,
            decoration: BoxDecoration(
              color: bg,
              border: Border.all(color: border),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              widget.label,
              textAlign: TextAlign.center,
              style: KV.mono(
                size: 12,
                color: fg,
                weight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Painéis
// ---------------------------------------------------------------------------

/// `.panel`
class KvPanel extends StatelessWidget {
  const KvPanel({
    super.key,
    required this.child,
    this.margin = const EdgeInsets.only(top: 20, bottom: 22),
  });

  final Widget child;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: margin,
      padding: EdgeInsets.all(isNarrow(context) ? 20 : 26),
      decoration: BoxDecoration(
        color: KV.panel,
        border: Border.all(color: KV.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: child,
    );
  }
}

/// `.panel-heading`: título em mono maiúsculo com linha embaixo.
class PanelHeading extends StatelessWidget {
  const PanelHeading(this.title, {super.key, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.only(bottom: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: KV.borderSoft)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              title.toUpperCase(),
              style: KV.mono(
                size: 16,
                weight: FontWeight.w600,
                letterSpacing: 0.6,
              ),
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 16), trailing!],
        ],
      ),
    );
  }
}

/// `h2` dentro de painel (Space Grotesk 18).
class PanelTitle extends StatelessWidget {
  const PanelTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: KV.grotesk(size: 18));
}

/// `.page-heading`: eyebrow + h1 + subtítulo, com ação opcional à direita.
class PageHeading extends StatelessWidget {
  const PageHeading({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    this.action,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final narrow = isNarrow(context);
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Eyebrow(eyebrow),
        Text(
          title,
          style: KV.grotesk(
            size: narrow ? 34 : 40,
            height: 1.12,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 10),
        Text(subtitle, style: KV.body(color: KV.muted, height: 1.7)),
      ],
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 36),
      child: (narrow || action == null)
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                text,
                if (action != null)
                  Padding(padding: const EdgeInsets.only(top: 24), child: action),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: text),
                const SizedBox(width: 24),
                action!,
              ],
            ),
    );
  }
}

/// Grade com N colunas de mesma altura (`display: grid` do CSS).
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.columns,
    required this.gap,
    required this.children,
  });

  final int columns;
  final double gap;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (columns <= 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) SizedBox(height: gap),
            children[i],
          ],
        ],
      );
    }

    final rows = <Widget>[];
    for (var start = 0; start < children.length; start += columns) {
      final cells = <Widget>[];
      for (var c = 0; c < columns; c++) {
        final index = start + c;
        if (c > 0) cells.add(SizedBox(width: gap));
        cells.add(
          Expanded(
            child: index < children.length
                ? children[index]
                : const SizedBox.shrink(),
          ),
        );
      }
      if (rows.isNotEmpty) rows.add(SizedBox(height: gap));
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: cells,
          ),
        ),
      );
    }
    return Column(children: rows);
  }
}

// ---------------------------------------------------------------------------
// Formulários
// ---------------------------------------------------------------------------

InputDecoration kvDecoration({String? hint}) {
  OutlineInputBorder outline(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(3),
        borderSide: BorderSide(color: color, width: width),
      );

  return InputDecoration(
    hintText: hint,
    hintStyle: KV.body(color: const Color(0xFF777777)),
    filled: true,
    fillColor: Colors.black,
    contentPadding: const EdgeInsets.all(12),
    counterText: '',
    border: outline(KV.inputBorder),
    enabledBorder: outline(KV.inputBorder),
    focusedBorder: outline(Colors.white, 2),
    errorBorder: outline(Colors.white),
    focusedErrorBorder: outline(Colors.white, 2),
    disabledBorder: outline(KV.borderSoft),
    errorStyle: KV.body(size: 12, color: Colors.white),
  );
}

/// `<label>` com o campo embaixo.
class FieldLabel extends StatelessWidget {
  const FieldLabel({super.key, required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: KV.body(size: 12, color: const Color(0xFFE5E5E5)),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class KvField extends StatelessWidget {
  const KvField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.obscure = false,
    this.keyboardType,
    this.maxLength,
    this.rows = 1,
    this.required = false,
    this.validator,
    this.autofillHints,
    this.inputFormatters,
    this.textInputAction,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final int? maxLength;

  /// Mais de 1 vira uma área de texto (`<textarea rows=N>`).
  final int rows;
  final bool required;
  final String? Function(String value)? validator;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    final multiline = rows > 1;
    return FieldLabel(
      label: label,
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: multiline ? TextInputType.multiline : keyboardType,
        textInputAction: textInputAction,
        minLines: multiline ? rows : 1,
        maxLines: multiline ? null : 1,
        maxLength: maxLength,
        inputFormatters: inputFormatters,
        autofillHints: autofillHints,
        style: KV.body(),
        cursorColor: Colors.white,
        decoration: kvDecoration(hint: hint),
        validator: (value) {
          final text = value ?? '';
          if (required && text.trim().isEmpty) return 'Preencha este campo.';
          return validator?.call(text);
        },
      ),
    );
  }
}

class KvOption {
  const KvOption(this.value, this.label);

  final String value;
  final String label;
}

class KvSelect extends StatelessWidget {
  const KvSelect({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<KvOption> options;

  /// null desabilita o campo (como `disabled` no <select>).
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return FieldLabel(
      label: label,
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        dropdownColor: Colors.black,
        iconEnabledColor: Colors.white,
        iconDisabledColor: KV.dim,
        style: KV.body(),
        decoration: kvDecoration(),
        items: [
          for (final option in options)
            DropdownMenuItem<String>(
              value: option.value,
              child: Text(option.label, style: KV.body()),
            ),
        ],
        onChanged: onChanged == null
            ? null
            : (selected) {
                if (selected != null) onChanged!(selected);
              },
      ),
    );
  }
}

class FormCell {
  const FormCell(this.child, {this.wide = false});

  final Widget child;

  /// `.wide { grid-column: 1 / -1 }` — ocupa a linha inteira.
  final bool wide;
}

/// `.vault-form` / `.form`: grade de 2 colunas (1 no celular) com campos
/// "wide" ocupando a linha toda.
class FormGrid extends StatelessWidget {
  const FormGrid({super.key, required this.cells, this.gap = 17});

  final List<FormCell> cells;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final twoColumns = !isNarrow(context);
    final rows = <Widget>[];
    var i = 0;
    while (i < cells.length) {
      final cell = cells[i];
      Widget row;
      if (!twoColumns || cell.wide) {
        row = cell.child;
        i += 1;
      } else {
        final next = (i + 1 < cells.length && !cells[i + 1].wide)
            ? cells[i + 1]
            : null;
        row = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: cell.child),
            SizedBox(width: gap),
            Expanded(child: next?.child ?? const SizedBox.shrink()),
          ],
        );
        i += next == null ? 1 : 2;
      }
      if (rows.isNotEmpty) rows.add(SizedBox(height: gap));
      rows.add(row);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows,
    );
  }
}

// ---------------------------------------------------------------------------
// Borda tracejada (estado vazio do cofre)
// ---------------------------------------------------------------------------

class DashedBox extends StatelessWidget {
  const DashedBox({
    super.key,
    required this.child,
    this.color = const Color(0xFF3B3B3B),
    this.radius = 10,
  });

  final Widget child;
  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(color: color, radius: radius),
      child: SizedBox(width: double.infinity, child: child),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
    const dash = 6.0;
    const gap = 4.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}
