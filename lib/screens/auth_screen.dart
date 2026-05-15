import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _yearController = TextEditingController();
  bool _isLogin = true;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'HYSM ALUMNI',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
                ),
                const SizedBox(height: 40),
                if (!_isLogin) ...[
                  TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Full Name')),
                  TextField(controller: _yearController, decoration: const InputDecoration(labelText: 'Graduation Year'), keyboardType: TextInputType.number),
                ],
                TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
                TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
                const SizedBox(height: 24),
                auth.isLoading 
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                      onPressed: () async {
                        try {
                          if (_isLogin) {
                            await auth.signIn(_emailController.text, _passwordController.text);
                          } else {
                            await auth.signUp(
                              email: _emailController.text,
                              password: _passwordController.text,
                              fullName: _nameController.text,
                              gradYear: int.parse(_yearController.text.isEmpty ? '0' : _yearController.text),
                            );
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Registration successful!'), backgroundColor: Colors.green),
                              );
                            }
                          }
                        } on AuthException catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.message), backgroundColor: Colors.red),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('An error occurred. Please try again.'), backgroundColor: Colors.red),
                            );
                          }
                        }
                      },
                      child: Text(_isLogin ? 'Login' : 'Register'),
                    ),
                TextButton(
                  onPressed: () => setState(() => _isLogin = !_isLogin),
                  child: Text(_isLogin ? 'Create Account' : 'Already have an account? Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
