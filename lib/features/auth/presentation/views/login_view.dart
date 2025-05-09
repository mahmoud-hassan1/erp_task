import 'package:erp_task/core/utils/routes.dart';
import 'package:erp_task/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erp_task/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:erp_task/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:erp_task/core/utils/widgets/show_snack_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().signIn(
            _emailController.text.trim(),
            _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            showSnackBar(context, content: state.message);
          }
          else if (state is AuthAuthenticated) {
            context.pushReplacement(AppRoutes.home);
          }
          else if (state is AuthUnverified) {
            _emailController.clear();
            _passwordController.clear();
            context.push(AppRoutes.verifyEmail);
          }
        },
        builder: (context, state) {
          return ModalProgressHUD(
            inAsyncCall: state is AuthLoading,
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Welcome Back',
                      style: Theme.of(context).textTheme.displayMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    AuthTextField(
                      controller: _emailController,
                      labelText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      controller: _passwordController,
                      labelText: 'Password',
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _handleLogin,
                      child: const Text('Login'),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        _passwordController.clear();
                        _emailController.clear();
                        context.push(AppRoutes.signup);
                      },
                      child: const Text('Don\'t have an account? Sign up'),
                    ),
                  ],
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
} 