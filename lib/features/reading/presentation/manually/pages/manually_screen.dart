import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:app_properties/components/text/acometida_id_input_formatter.dart';
import 'package:app_properties/utils/responsive_utils.dart';
import 'package:app_properties/features/reading/presentation/manually/blocs/index.dart';

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
      body: BlocConsumer<ReadingManuallyBloc, ReadingManuallyState>(
        listener: (context, state) {
          debugPrint('ReadingManuallyState cambiado: $state');
          if (state is ReadingManuallyLoaded) {
            context.push(
              '/form',
              extra: {'reading': state.reading, 'mode': 'manual'},
            );
          } else if (state is ReadingManuallyError) {
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
          final isLoading = state is ReadingManuallyLoading;

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
                      color: theme.colorScheme.surfaceContainerHighest,
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
                              AcometidaIdInputFormatter(),
                            ],
                            validator: (value) => AcometidaIdValidator.validate(
                              value,
                              isRequired: true,
                            ),
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) {
                              if (!isLoading &&
                                  (_formKey.currentState?.validate() ??
                                      false)) {
                                final acometidaId = _acometidaIdController.text
                                    .trim();
                                context.read<ReadingManuallyBloc>().add(
                                  LoadReadingManuallyInfo(acometidaId),
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
                                            context
                                                .read<ReadingManuallyBloc>()
                                                .add(
                                                  LoadReadingManuallyInfo(
                                                    acometidaId,
                                                  ),
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
                                          context.pop();
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
