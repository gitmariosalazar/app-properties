import 'package:flutter/services.dart';

/// Formateador personalizado para validar Sector (1-40) y Cuenta (1 o más),
/// con inserción y control automático/manual del guion.
class AcometidaIdInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text;
    final oldText = oldValue.text;

    // Permitir entrada vacía
    if (newText.isEmpty) {
      return newValue;
    }

    // Eliminar caracteres que no sean dígitos o guion
    String cleaned = newText.replaceAll(RegExp(r'[^0-9-]'), '');

    // Prevenir cero inicial
    if (!cleaned.contains('-') && cleaned.startsWith('0')) {
      return oldValue;
    }

    // Prevenir múltiples guiones
    if (cleaned.contains('-')) {
      final parts = cleaned.split('-');
      if (parts.length > 2) {
        return oldValue;
      }
      // Prevenir cero inicial antes del guion
      if (parts[0].startsWith('0')) {
        return oldValue;
      }
      // Prevenir cero inicial en Cuenta
      if (parts.length == 2 && parts[1].startsWith('0')) {
        return oldValue;
      }
    }

    // Manejar eliminación
    if (newText.length < oldText.length) {
      return TextEditingValue(
        text: cleaned,
        selection: TextSelection.collapsed(offset: newValue.selection.end),
      );
    }

    // Manejar entrada antes del guion (Sector: 1-40)
    if (!cleaned.contains('-')) {
      // Verificar un solo dígito (1-9)
      if (cleaned.length == 1) {
        final number = int.tryParse(cleaned);
        if (number != null && number >= 1 && number <= 9) {
          // Permitir guion manual después de 1-4
          if (newText.endsWith('-') && number >= 1 && number <= 4) {
            return TextEditingValue(
              text: '$cleaned-',
              selection: TextSelection.collapsed(offset: cleaned.length + 1),
            );
          }
          // Agregar guion automático para 5-9
          if (number >= 5) {
            return TextEditingValue(
              text: '$cleaned-',
              selection: TextSelection.collapsed(offset: cleaned.length + 1),
            );
          }
          return newValue; // Mantener 1-4 sin guion
        }
      }
      // Verificar dos dígitos (10-40)
      if (cleaned.length == 2) {
        final firstDigit = int.tryParse(cleaned[0]);
        final number = int.tryParse(cleaned);
        if (firstDigit != null && number != null) {
          if (firstDigit >= 1 && firstDigit <= 3) {
            // Permitir 10-39 (cualquier segundo dígito 0-9)
            if (number >= 10 && number <= 39) {
              return TextEditingValue(
                text: '$cleaned-',
                selection: TextSelection.collapsed(offset: cleaned.length + 1),
              );
            }
          } else if (firstDigit == 4 && number == 40) {
            // Permitir solo 40 para el primer dígito 4
            return TextEditingValue(
              text: '$cleaned-',
              selection: TextSelection.collapsed(offset: cleaned.length + 1),
            );
          }
        }
      }
      // Manejar caso especial: después de 4, permitir cualquier dígito pero forzar 4-X
      if (cleaned.length >= 2 && cleaned.startsWith('4')) {
        final secondChar = cleaned[1];
        if (secondChar != '0') {
          return TextEditingValue(
            text: '4-$secondChar',
            selection: TextSelection.collapsed(offset: 3),
          );
        }
      }
      // Prevenir más de dos dígitos antes del guion
      if (cleaned.length > 2) {
        return oldValue;
      }
    }

    // Permitir entrada después del guion (Cuenta)
    if (cleaned.contains('-')) {
      final parts = cleaned.split('-');
      final sector = int.tryParse(parts[0]);
      if (sector != null && sector >= 1 && sector <= 40) {
        return TextEditingValue(
          text: cleaned,
          selection: TextSelection.collapsed(offset: newValue.selection.end),
        );
      }
      return oldValue;
    }

    return oldValue;
  }
}

class AcometidaIdValidator {
  static String? validate(String? value, {bool isRequired = true}) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      if (isRequired) {
        return 'Por favor, ingrese un ID de acometida válido';
      }
      return null;
    }
    final regex = RegExp(r'^([1-9]|[1-3][0-9]|40)-[1-9]\d*$');
    if (!regex.hasMatch(trimmed)) {
      return 'Formato inválido. Sector (1-40) seguido de guion y Cuenta (1 o más) (ej., 1-256 o 12-256)';
    }
    return null;
  }
}
