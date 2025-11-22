import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_text_field.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthController()..mode = AuthMode.register,
      child: Consumer<AuthController>(
        builder: (_, c, __) => Scaffold(
          appBar: AppBar(title: const Text('Register')),
          body: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AuthTextField(controller: c.firstName, label: 'First Name', icon: Icons.person_outline),
                  const SizedBox(height: 15),
                  AuthTextField(controller: c.lastName, label: 'Last Name', icon: Icons.person_outline),
                  const SizedBox(height: 15),
                  AuthTextField(controller: c.middleName, label: 'Middle Name (Optional)', icon: Icons.badge_outlined),
                  const SizedBox(height: 15),
                  AuthTextField(controller: c.email, label: 'Email', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 15),
                  AuthTextField(controller: c.password, label: 'Password', icon: Icons.lock_outline, obscure: !c.passwordVisible),
                  const SizedBox(height: 15),
                  AuthTextField(controller: c.confirmPassword, label: 'Confirm Password', icon: Icons.lock_reset_outlined, obscure: !c.confirmPasswordVisible),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final error = await c.submit();
                      if (error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                      } else {
                        // Navigate to home
                      }
                    },
                    child: const Text('REGISTER'),
                  ),
                  TextButton(
                    onPressed: c.toggleForm,
                    child: const Text('Already have an account? Login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
