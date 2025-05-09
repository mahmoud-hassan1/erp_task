import 'package:erp_task/core/utils/routes.dart';
import 'package:erp_task/core/utils/widgets/show_snack_bar.dart';
import 'package:erp_task/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erp_task/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class EmailVerificationView extends StatelessWidget {
  const EmailVerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Verification'),
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            showSnackBar(context, content: state.message);
          } else if (state is AuthAuthenticated) {
            context.pushReplacement(AppRoutes.home);
          }
        },
        builder: (context, state) {
          return ModalProgressHUD(
            inAsyncCall: state is AuthLoading,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.mark_email_unread,
                      size: 80,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Verify Your Email',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'We have sent you an email verification link. Please check your email and click the link to verify your account.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        context.read<AuthCubit>().checkAuthStatus();
                      },
                      child: const Text('I have verified my email'),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        context.read<AuthCubit>().resendVerificationEmail();
                      },
                      child: const Text('Resend verification email'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
