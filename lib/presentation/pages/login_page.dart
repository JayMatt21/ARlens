import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final supabase = Supabase.instance.client;

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        _routeBasedOnRole(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 241, 170, 165),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Login to Senfrost',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : ElevatedButton(
                        onPressed: () => manualLogin(context),
                        child: const Text('Login'),
                      ),
                TextButton(
                  onPressed: () => context.go('/register'),
                  child: const Text('Register now'),
                ),
                TextButton(
                  onPressed: () => _showForgotPasswordDialog(),
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Or login with',
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Image.asset('assets/icons/google.png'),
                      onPressed: () => signInWithGoogle(context),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: Image.asset('assets/icons/facebook.png'),
                      onPressed: () => signInWithFacebook(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final forgotEmailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: TextField(
          controller: forgotEmailController,
          decoration: const InputDecoration(
            labelText: 'Enter your registered email',
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final email = forgotEmailController.text.trim();
              if (email.isEmpty) {
                showError(context, 'Please enter your email.');
                return;
              }
              Navigator.pop(context);
              _sendPasswordResetEmail(email);
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _sendPasswordResetEmail(String email) async {
    setState(() => _isLoading = true);
    try {
      await supabase.auth.resetPasswordForEmail(email);
      showError(context, 'Password reset email sent! Please check your inbox.');
    } catch (e) {
      showError(context, 'Failed to send reset email: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void manualLogin(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showError(context, 'Please enter email and password.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user == null) {
        showError(context, 'Login failed. Please check your credentials.');
        return;
      }

      if (res.user!.emailConfirmedAt == null) {
        showError(context,
            'Please verify your email first by clicking the link sent to your inbox.');
        return;
      }

      await _routeBasedOnRole(context);
    } catch (e) {
      showError(context, 'Login error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _routeBasedOnRole(BuildContext context) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      context.go('/login');
      return;
    }

    try {
      final Map<String, dynamic>? userRecord = await supabase
          .from('users')
          .select('role_id')
          .eq('id', user.id)
          .maybeSingle();

      if (userRecord == null) {
        showError(context, 'User record not found.');
        context.go('/login');
        return;
      }

      final roleId = userRecord['role_id'] as String?;
      if (roleId == null) {
        showError(context, 'Role not assigned.');
        context.go('/login');
        return;
      }

      final Map<String, dynamic>? roleRecord = await supabase
          .from('roles')
          .select('name')
          .eq('id', roleId)
          .maybeSingle();

      final roleName = roleRecord?['name'] as String?;
      if (roleName == null) {
        showError(context, 'Role not found.');
        context.go('/login');
        return;
      }

      switch (roleName.toLowerCase()) {
        case 'customer':
        case 'user':
          context.go('/customer-home');
          break;
        case 'admin':
          context.go('/admin');
          break;
        case 'technician':
          context.go('/technician');
          break;
        default:
          showError(context, 'Unknown role: $roleName');
          context.go('/login');
      }
    } catch (e) {
      showError(context, 'Error fetching role: $e');
      context.go('/login');
    }
  }

  void signInWithGoogle(BuildContext context) async {
    try {
      await supabase.auth.signInWithOAuth(OAuthProvider.google);
    } catch (e) {
      showError(context, 'Google login failed: $e');
    }
  }

  void signInWithFacebook(BuildContext context) async {
    try {
      await supabase.auth.signInWithOAuth(OAuthProvider.facebook);
    } catch (e) {
      showError(context, 'Facebook login failed: $e');
    }
  }

  void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
