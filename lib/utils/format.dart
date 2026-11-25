/// Equivalente a `toLocaleString("pt-BR")`: 25/11/2026 18:05:00
String formatDateTime(DateTime? value) {
  if (value == null) return 'Data indisponível';
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(value.day)}/${two(value.month)}/${value.year} '
      '${two(value.hour)}:${two(value.minute)}:${two(value.second)}';
}
