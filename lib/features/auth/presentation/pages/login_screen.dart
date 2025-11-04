import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:app_properties/core/di/injection.dart' as di;
import 'package:app_properties/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:app_properties/utils/responsive_utils.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<AuthBloc>(),
      child: const LoginView(),
    );
  }
}

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  // For responsive paddings and sizes
  late double logoSize;
  late double fieldSpacing;
  late double buttonSpacing;
  late double sidePadding;
  late double cardRadius;
  late double formVerticalPad;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = context.isTablet;

    // Responsive values
    logoSize = isTablet ? 150 : 90;
    fieldSpacing = isTablet ? 28 : 16;
    buttonSpacing = isTablet ? 28 : 16;
    sidePadding = isTablet ? 60 : 24;
    cardRadius = context.largeBorderRadiusValue;
    formVerticalPad = isTablet ? 48 : 32;

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceBright,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: sidePadding,
                vertical: formVerticalPad,
              ),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: sidePadding * 0.55,
                  vertical: formVerticalPad * 0.6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.94),
                  borderRadius: BorderRadius.circular(cardRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.09),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo
                    Container(
                      height: logoSize,
                      margin: EdgeInsets.only(bottom: fieldSpacing * 2),
                      child: Material(
                        elevation: 4,
                        shape: const CircleBorder(),
                        color: Colors.white,
                        child: Padding(
                          padding: EdgeInsets.all(isTablet ? 18 : 9),
                          child: Image.asset(
                            'assets/images/epaa.png',
                            height: logoSize,
                            width: logoSize,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.water_drop_rounded,
                                size: logoSize,
                                color: theme.colorScheme.primary,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    // Welcome Text
                    Text(
                      'Bienvenido de nuevo',
                      style: context.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                        letterSpacing: 0.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    context.vSpace(0.006),
                    Text(
                      'Inicie sesión para continuar',
                      style: context.bodyLarge.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    context.vSpace(0.04),
                    // Email Field
                    _LoginInputField(
                      controller: _emailController,
                      icon: Icons.person_outline,
                      hintText: 'Usuario',
                      keyboardType: TextInputType.text,
                      isPassword: false,
                      isTablet: isTablet,
                    ),
                    context.vSpace(0.018),
                    // Password Field
                    _LoginInputField(
                      controller: _passwordController,
                      icon: Icons.lock_outline,
                      hintText: 'Contraseña',
                      keyboardType: TextInputType.visiblePassword,
                      isPassword: true,
                      isTablet: isTablet,
                      isPasswordVisible: _isPasswordVisible,
                      onTogglePassword: () => setState(
                        () => _isPasswordVisible = !_isPasswordVisible,
                      ),
                      obscureText: !_isPasswordVisible,
                    ),
                    context.vSpace(0.03),
                    // Login Button
                    BlocConsumer<AuthBloc, AuthState>(
                      listener: (context, state) {
                        if (state is AuthSuccess) {
                          context.go('/home');
                        } else if (state is AuthFailure) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.message),
                              backgroundColor: theme.colorScheme.error,
                            ),
                          );
                        }
                      },
                      builder: (context, state) {
                        return _LoginButton(
                          text: 'Iniciar Sesión',
                          loading: state is AuthLoading,
                          isTablet: isTablet,
                          onPressed: state is AuthLoading
                              ? null
                              : () {
                                  context.read<AuthBloc>().add(
                                    LoginEvent(
                                      email: _emailController.text.trim(),
                                      password: _passwordController.text,
                                    ),
                                  );
                                },
                        );
                      },
                    ),
                    context.vSpace(0.01),
                    // Forgot Password Link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // Add navigation or logic for forgot password
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.primary,
                          textStyle: context.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.1,
                          ),
                        ),
                        child: const Text('¿Olvidó su contraseña?'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

// Custom input field for login form
class _LoginInputField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String hintText;
  final TextInputType? keyboardType;
  final bool isPassword;
  final bool isTablet;
  final bool obscureText;
  final bool isPasswordVisible;
  final VoidCallback? onTogglePassword;

  const _LoginInputField({
    required this.controller,
    required this.icon,
    required this.hintText,
    this.keyboardType,
    this.isPassword = false,
    this.isTablet = false,
    this.obscureText = false,
    this.isPasswordVisible = false,
    this.onTogglePassword,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconSize = isTablet ? 28.0 : 24.0;
    final fontSize = isTablet ? 19.0 : 15.5;
    final radius = context.mediumBorderRadiusValue * 1.2;

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword ? obscureText : false,
      style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(
          icon,
          size: iconSize,
          color: theme.colorScheme.primary,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  size: iconSize,
                  color: Colors.grey[500],
                ),
                onPressed: onTogglePassword,
                tooltip: isPasswordVisible ? 'Ocultar' : 'Mostrar',
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(radius)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
        contentPadding: EdgeInsets.symmetric(
          vertical: isTablet ? 19 : 13,
          horizontal: isTablet ? 18 : 12,
        ),
      ),
    );
  }
}

// Custom Login Button
class _LoginButton extends StatelessWidget {
  final String text;
  final bool loading;
  final bool isTablet;
  final VoidCallback? onPressed;

  const _LoginButton({
    required this.text,
    required this.loading,
    required this.isTablet,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final radius = context.mediumBorderRadiusValue * 1.3;
    final height = isTablet ? 60.0 : 50.0;
    final fontSize = isTablet ? 20.0 : 17.0;

    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: isTablet ? 18 : 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          backgroundColor: context.isTablet
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          minimumSize: Size(double.infinity, height),
        ),
        child: loading
            ? SizedBox(
                height: 25,
                width: 25,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize,
                  letterSpacing: 0.2,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
