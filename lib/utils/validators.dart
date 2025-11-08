// lib/core/utils/validators.dart
String? emailValidator(String? value) {
  if (value == null || value.trim().isEmpty) return 'Email requerido';
  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
    return 'Email inválido';
  }
  return null;
}

String? phoneValidator(String? value) {
  if (value == null || value.trim().isEmpty) return 'Teléfono requerido';
  if (value.trim().length < 7) return 'Teléfono inválido (mín 7 dígitos)';
  return null;
}

String? numberValidator(String? value) {
  if (value == null || value.trim().isEmpty) return 'Número requerido';
  if (double.tryParse(value.trim()) == null) return 'Número inválido';
  return null;
}

String? requiredValidator(String? value) {
  if (value == null || value.trim().isEmpty) return 'Campo requerido';
  return null;
}
