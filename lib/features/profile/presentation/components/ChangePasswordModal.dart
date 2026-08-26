import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_properties/features/profile/presentation/cubit/change_password_cubit.dart';
import 'package:app_properties/features/profile/presentation/cubit/change_password_state.dart';

class ChangePasswordModal extends StatefulWidget {
  final String userId;

  const ChangePasswordModal({super.key, required this.userId});

  @override
  State<ChangePasswordModal> createState() => _ChangePasswordModalState();
}

class _ChangePasswordModalState extends State<ChangePasswordModal> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  // Estados de validación en tiempo real
  PasswordStrength _passwordStrength = PasswordStrength.none;
  bool _passwordsMatch = false;
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_validateNewPassword);
    _confirmPasswordController.addListener(_validateConfirmPassword);
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateNewPassword() {
    final password = _newPasswordController.text;

    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasLowercase = password.contains(RegExp(r'[a-z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

      final score = [
        _hasMinLength,
        _hasUppercase,
        _hasLowercase,
        _hasNumber,
        _hasSpecialChar,
      ].where((e) => e).length;

      if (password.isEmpty) {
        _passwordStrength = PasswordStrength.none;
      } else if (score <= 2) {
        _passwordStrength = PasswordStrength.weak;
      } else if (score <= 4) {
        _passwordStrength = PasswordStrength.medium;
      } else {
        _passwordStrength = PasswordStrength.strong;
      }
    });

    _validateConfirmPassword();
  }

  void _validateConfirmPassword() {
    setState(() {
      _passwordsMatch =
          _confirmPasswordController.text.isNotEmpty &&
          _newPasswordController.text == _confirmPasswordController.text;
    });
  }

  bool get _isFormValid {
    return _oldPasswordController.text.isNotEmpty &&
        _passwordStrength == PasswordStrength.strong &&
        _passwordsMatch;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (!_isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor, completa todos los requisitos de seguridad',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    context.read<ChangePasswordCubit>().changePassword(
      userId: widget.userId,
      oldPassword: _oldPasswordController.text,
      newPassword: _newPasswordController.text,
      confirmNewPassword: _confirmPasswordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<ChangePasswordCubit, ChangePasswordState>(
      listener: (context, state) {
        if (state is ChangePasswordSuccess) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Contraseña actualizada con éxito'),
                ],
              ),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is ChangePasswordFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text(state.message)),
                ],
              ),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is ChangePasswordLoading;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.lock_reset_rounded, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              const Text(
                'Cambiar contraseña',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Contraseña actual
                  _buildPasswordField(
                    controller: _oldPasswordController,
                    label: 'Contraseña actual',
                    obscure: _obscureOld,
                    onToggle: () => setState(() => _obscureOld = !_obscureOld),
                    enabled: !isLoading,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingresa tu contraseña actual';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Nueva contraseña
                  _buildPasswordField(
                    controller: _newPasswordController,
                    label: 'Nueva contraseña',
                    obscure: _obscureNew,
                    onToggle: () => setState(() => _obscureNew = !_obscureNew),
                    enabled: !isLoading,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingresa una nueva contraseña';
                      }
                      if (_passwordStrength != PasswordStrength.strong) {
                        return 'La contraseña no es lo suficientemente segura';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  // Indicador de fortaleza
                  if (_newPasswordController.text.isNotEmpty) ...[
                    _buildStrengthIndicator(),
                    const SizedBox(height: 12),
                    _buildRequirementsChecklist(),
                    const SizedBox(height: 8),
                  ],

                  // Confirmar contraseña
                  _buildPasswordField(
                    controller: _confirmPasswordController,
                    label: 'Confirmar nueva contraseña',
                    obscure: _obscureConfirm,
                    onToggle: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                    enabled: !isLoading,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Confirma tu nueva contraseña';
                      }
                      if (!_passwordsMatch) {
                        return 'Las contraseñas no coinciden';
                      }
                      return null;
                    },
                  ),

                  // Indicador de coincidencia
                  if (_confirmPasswordController.text.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          _passwordsMatch ? Icons.check_circle : Icons.cancel,
                          size: 18,
                          color: _passwordsMatch ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _passwordsMatch
                              ? 'Las contraseñas coinciden'
                              : 'Las contraseñas no coinciden',
                          style: TextStyle(
                            fontSize: 13,
                            color: _passwordsMatch ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: (isLoading || !_isFormValid) ? null : _submit,
              style: FilledButton.styleFrom(
                minimumSize: const Size(140, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Cambiar contraseña'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    required bool enabled,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      enabled: enabled,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 1.8,
          ),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            size: 22,
          ),
          onPressed: onToggle,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildStrengthIndicator() {
    Color color;
    String label;
    double progress;

    switch (_passwordStrength) {
      case PasswordStrength.weak:
        color = Colors.red;
        label = 'Débil';
        progress = 0.33;
        break;
      case PasswordStrength.medium:
        color = Colors.orange;
        label = 'Media';
        progress = 0.66;
        break;
      case PasswordStrength.strong:
        color = Colors.green;
        label = 'Fuerte';
        progress = 1.0;
        break;
      case PasswordStrength.none:
        color = Colors.grey;
        label = '';
        progress = 0.0;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.shade200,
                  color: color,
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRequirementsChecklist() {
    return Column(
      children: [
        _buildRequirementItem('Mínimo 8 caracteres', _hasMinLength),
        _buildRequirementItem('Al menos una mayúscula', _hasUppercase),
        _buildRequirementItem('Al menos una minúscula', _hasLowercase),
        _buildRequirementItem('Al menos un número', _hasNumber),
        _buildRequirementItem('Al menos un carácter especial', _hasSpecialChar),
      ],
    );
  }

  Widget _buildRequirementItem(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: isValid ? Colors.green : Colors.grey.shade400,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.5,
              color: isValid ? Colors.green.shade700 : Colors.grey.shade600,
              fontWeight: isValid ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

enum PasswordStrength { none, weak, medium, strong }
