import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'home_page.dart';

// No need for 'registration_page.dart' import as it's merged here

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore instance

  // Controllers for authentication
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Controllers for registration fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();

  bool _isLogin = true;
  bool _loading = false;

  void _toggleForm() {
    setState(() {
      _isLogin = !_isLogin;
      // Clear all fields when switching form mode
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      _firstNameController.clear();
      _lastNameController.clear();
      _middleNameController.clear();
    });
  }

  Future<void> _submit() async {
    if (_loading) return;
    setState(() => _loading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      if (_isLogin) {
        // --- LOGIN LOGIC ---
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        // --- REGISTRATION LOGIC ---
        if (password != _confirmPasswordController.text.trim()) {
          throw 'Passwords do not match.';
        }

        // 1. Create the Firebase Auth user
        final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        final User? user = userCredential.user;

        if (user != null) {
          // 2. Save additional user data to Firestore
          await _firestore.collection('users').doc(user.uid).set({
            'firstName': _firstNameController.text.trim(),
            'lastName': _lastNameController.text.trim(),
            'middleName': _middleNameController.text.trim(),
            'email': user.email,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      // 3. Navigate to HomePage on success
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }

    } on FirebaseAuthException catch (e) {
      _showSnackBar(e.message ?? 'Authentication error');
    } catch (e) {
      _showSnackBar(e.toString()); // For non-Firebase errors (e.g., password mismatch)
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message.contains(']') ? message.split(']').last.trim() : message)),
      );
    }
  }


 // Define a fixed width for all input fields
final double _inputWidth = 350.0;

@override
Widget build(BuildContext context) {
  // We use LayoutBuilder to determine the height available to the body.
  // This allows the SingleChildScrollView to fill the height and apply vertical centering.
  return Scaffold(
    appBar: AppBar(title: Text(_isLogin ? 'Login' : 'Register')),
    body: LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          // Constrains the scrollable content to the height of the screen minus the AppBar.
          // This is essential for mainAxisAlignment.center to work correctly.
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight, // Min height is the full available screen height
            ),
            child: Center( // <-- 1. HORIZONTAL CENTERING
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  // 2. VERTICAL CENTERING
                  mainAxisAlignment: MainAxisAlignment.center, 
                  // 3. EXPLICIT HORIZONTAL CENTERING of children within the Column
                  crossAxisAlignment: CrossAxisAlignment.center, 
                  children: [
                    if (!_isLogin) ...[
                      // --- Registration Fields ---
                      Container( 
                        width: _inputWidth,
                        child: TextField(
                          controller: _firstNameController,
                          decoration: const InputDecoration(labelText: 'First Name'),
                        ),
                      ),
                      const SizedBox(height: 10),

                      Container( 
                        width: _inputWidth,
                        child: TextField(
                          controller: _lastNameController,
                          decoration: const InputDecoration(labelText: 'Last Name'),
                        ),
                      ),
                      const SizedBox(height: 10),

                      Container( 
                        width: _inputWidth,
                        child: TextField(
                          controller: _middleNameController,
                          decoration: const InputDecoration(labelText: 'Middle Name (Optional)'),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    
                    // --- Shared Fields ---
                    Container( 
                      width: _inputWidth,
                      child: TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Container( 
                      width: _inputWidth,
                      child: TextField(
                        controller: _passwordController,
                        decoration: const InputDecoration(labelText: 'Password'),
                        obscureText: true,
                      ),
                    ),
                    const SizedBox(height: 10),

                    if (!_isLogin) 
                      // Confirm Password (Only for Registration)
                      Container( 
                        width: _inputWidth,
                        child: TextField(
                          controller: _confirmPasswordController,
                          decoration: const InputDecoration(labelText: 'Confirm Password'),
                          obscureText: true,
                        ),
                      ),

                    const SizedBox(height: 20),
                    
                    // --- Button ---
                    SizedBox( 
                      width: _inputWidth,
                      child: _loading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: _submit,
                              child: Text(_isLogin ? 'Login' : 'Register'),
                            ),
                    ),

                    TextButton(
                      onPressed: _toggleForm,
                      child: Text(_isLogin ? 'Create an account' : 'Already have an account?'),
                    ),
                  ],
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
