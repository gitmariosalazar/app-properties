import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:app_properties/features/manually/presentation/bloc/manually_bloc.dart';
import 'package:app_properties/utils/responsive_utils.dart';

class ManualEntryScreen extends StatefulWidget {
  const ManualEntryScreen({super.key});

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  final TextEditingController _acometidaIdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = context.isTablet;
    final sidePadding = isTablet ? 48.0 : 18.0;
    final cardRadius = context.largeBorderRadiusValue;
    final verticalSpace = isTablet ? 32.0 : 20.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ingresar Acometida ID',
          style: context.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
            color: Colors.white,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocConsumer<ManuallyBloc, ManuallyState>(
        listener: (context, state) {
          if (state is ManuallyLoaded) {
            debugPrint('ManuallyLoaded state: ${state.data}');
            context.push('/view-data', extra: {'data': state.data['data']});
          } else if (state is ManuallyFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is ManuallyLoading;

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withOpacity(0.08),
                  theme.colorScheme.background,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: sidePadding,
                    vertical: verticalSpace,
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: sidePadding * 0.7,
                      vertical: verticalSpace * 1.1,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.98),
                      borderRadius: BorderRadius.circular(cardRadius),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 7),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Icon(
                            Icons.edit_document,
                            size: isTablet ? 56 : 36,
                            color: theme.colorScheme.primary,
                          ),
                          context.vSpace(0.012),
                          Text(
                            'Ingrese el ID de la Acometida',
                            style: context.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary,
                              letterSpacing: 0.15,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          context.vSpace(0.022),
                          TextFormField(
                            controller: _acometidaIdController,
                            enabled: !isLoading,
                            decoration: InputDecoration(
                              labelText: 'Acometida ID (ej: 1-256 o 12-256)',
                              labelStyle: context.bodyMedium.copyWith(
                                color: theme.colorScheme.primary.withOpacity(
                                  0.7,
                                ),
                                fontWeight: FontWeight.w500,
                              ),
                              prefixIcon: Icon(
                                Icons.edit,
                                color: theme.colorScheme.primary,
                                size: context.iconMedium,
                              ),
                              filled: true,
                              fillColor: theme.colorScheme.surface.withOpacity(
                                0.98,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  cardRadius * 0.7,
                                ),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  cardRadius * 0.7,
                                ),
                                borderSide: BorderSide(
                                  color: theme.colorScheme.outline.withOpacity(
                                    0.32,
                                  ),
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  cardRadius * 0.7,
                                ),
                                borderSide: BorderSide(
                                  color: theme.colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  cardRadius * 0.7,
                                ),
                                borderSide: BorderSide(
                                  color: theme.colorScheme.error,
                                  width: 2,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  cardRadius * 0.7,
                                ),
                                borderSide: BorderSide(
                                  color: theme.colorScheme.error,
                                  width: 2,
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: isTablet ? 18 : 12,
                                horizontal: 16,
                              ),
                            ),
                            style: context.bodyLarge.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: false,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9-]'),
                              ),
                              _AcometidaIdInputFormatter(),
                            ],
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Por favor, ingrese un ID de acometida válido';
                              }
                              final regex = RegExp(
                                r'^([1-9]|[1-3][0-9]|40)-[1-9]\d*$',
                              );
                              if (!regex.hasMatch(value)) {
                                return 'Formato inválido. Sector (1-40) seguido de guion y Cuenta (1 o más) (ej., 1-256 o 12-256)';
                              }
                              return null;
                            },
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) {
                              if (!isLoading &&
                                  (_formKey.currentState?.validate() ??
                                      false)) {
                                final acometidaId = _acometidaIdController.text
                                    .trim();
                                context.read<ManuallyBloc>().add(
                                  StartManuallyEvent(acometidaId),
                                );
                              }
                            },
                          ),
                          context.vSpace(0.04),
                          Row(
                            children: [
                              Expanded(
                                child: _MenuButton(
                                  color: theme.colorScheme.primary,
                                  icon: Icons.search,
                                  label: 'Consultar',
                                  isLoading: isLoading,
                                  onPressed: isLoading
                                      ? null
                                      : () {
                                          if (_formKey.currentState
                                                  ?.validate() ??
                                              false) {
                                            final acometidaId =
                                                _acometidaIdController.text
                                                    .trim();
                                            context.read<ManuallyBloc>().add(
                                              StartManuallyEvent(acometidaId),
                                            );
                                          }
                                        },
                                ),
                              ),
                              context.hSpace(0.04),
                              Expanded(
                                child: _MenuButton(
                                  color: Colors.redAccent,
                                  icon: Icons.cancel,
                                  label: 'Cancelar',
                                  onPressed: isLoading
                                      ? null
                                      : () {
                                          _acometidaIdController.clear();
                                          context.go(
                                            '/home',
                                          ); // Siempre va al home
                                        },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _acometidaIdController.dispose();
    super.dispose();
  }
}

// Formateador personalizado para validar Sector (1-40) y Cuenta (1 o más), con guion automático y manual
class _AcometidaIdInputFormatter extends TextInputFormatter {
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

    return TextEditingValue(
      text: cleaned,
      selection: TextSelection.collapsed(offset: newValue.selection.end),
    );
  }
}

/// Botón atractivo y responsivo con estado de carga e ícono
class _MenuButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _MenuButton({
    required this.color,
    required this.icon,
    required this.label,
    this.isLoading = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final radius = context.mediumBorderRadiusValue * 1.5;
    final isTablet = context.isTablet;
    final height = isTablet ? 60.0 : 50.0;
    final fontSize = isTablet ? 18.0 : 15.5;

    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 4,
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 20 : 12,
            vertical: isTablet ? 14 : 10,
          ),
          minimumSize: Size(double.infinity, height),
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: isTablet ? 26 : 20, color: Colors.white),
                  SizedBox(width: context.smallSpacing),
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize,
                      letterSpacing: 0.3,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
