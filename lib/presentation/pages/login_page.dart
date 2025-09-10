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
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
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

  void manualLogin(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showError(context, 'Please enter email and password.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await supabase.auth.signInWithPassword(email: email, password: password);

      if (res.user == null) {
        showError(context, 'Login failed. Please check your credentials.');
        return;
      }

 
      if (res.user!.emailConfirmedAt == null) {
        showError(context, 'Please verify your email first by clicking the link sent to your inbox.');
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

      final Map<String, dynamic>? response = await supabase
          .from('users')
          .select('role_id, roles(name)')
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) {
        showError(context, 'User record not found.');
        context.go('/login');
        return;
      }

 
      final dynamic rolesField = response['roles'];
      String? roleName;

      if (rolesField == null) {
  
        final dynamic roleId = response['role_id'];
        if (roleId != null) {
          final Map<String, dynamic>? roleResp = await supabase
              .from('roles')
              .select('name')
              .eq('id', roleId)
              .maybeSingle();
          roleName = roleResp?['name'] as String?;
        }
      } else if (rolesField is List && rolesField.isNotEmpty) {
        final first = rolesField.first;
        if (first is Map && first['name'] != null) {
          roleName = first['name'] as String;
        }
      } else if (rolesField is Map && rolesField['name'] != null) {
        roleName = rolesField['name'] as String;
      }

      if (roleName == null) {
        showError(context, 'User role not found.');
        context.go('/login');
        return;
      }

 
      switch (roleName.toLowerCase()) {
        case 'customer':
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
