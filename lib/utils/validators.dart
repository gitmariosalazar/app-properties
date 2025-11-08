// lib/core/utils/validators.dart
String? emailValidator(String? value) {
  // Si está vacío o solo espacios → permitido (NO requerido)
  if (value == null || value.trim().isEmpty) {
    return null;
  }

  // Si tiene contenido, debe cumplir con formato de email
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegex.hasMatch(value.trim())) {
    return 'Email inválido';
  }

  return null;
}

String? phoneValidator(String? value) {
  // Si está vacío o solo espacios → permitido (NO requerido)
  if (value == null || value.trim().isEmpty) {
    return 'Teléfono requerido';
  }

  // Si tiene contenido, debe cumplir con formato de teléfono
  if (value.trim().length < 7) {
    return 'Teléfono inválido (mín 7 dígitos)';
  }

  return null;
}

String? numberValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Número requerido';
  }
  if (double.tryParse(value.trim()) == null) {
    return 'Número inválido';
  }
  return null;
}

String? requiredValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Campo requerido';
  }
  return null;
}
