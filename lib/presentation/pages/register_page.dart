import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final supabase = Supabase.instance.client;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController middleInitialController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFD0E8FF),
              Color(0xFF9BBDDF),
              Color(0xFFF9FBFC),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 36),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Register New Account',
                  style: TextStyle(
                    color: Color(0xFF0D3B66),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                buildFieldBox(firstNameController, 'First Name'),
                const SizedBox(height: 12),
                buildFieldBox(middleInitialController, 'Middle Initial'),
                const SizedBox(height: 12),
                buildFieldBox(lastNameController, 'Last Name'),
                const SizedBox(height: 12),
                buildFieldBox(addressController, 'Address'),
                const SizedBox(height: 12),
                buildFieldBox(mobileController, 'Mobile Number', keyboardType: TextInputType.phone),
                const SizedBox(height: 12),
                buildFieldBox(emailController, 'Email', keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 12),
                buildPasswordBox(passwordController, 'Password', _showPassword, () {
                  setState(() => _showPassword = !_showPassword);
                }),
                const SizedBox(height: 12),
                buildPasswordBox(confirmPasswordController, 'Confirm Password', _showConfirmPassword, () {
                  setState(() => _showConfirmPassword = !_showConfirmPassword);
                }),
                const SizedBox(height: 28),
                _isLoading
                    ? const CircularProgressIndicator(color: Color(0xFF1976D2))
                    : SizedBox(
                        width: 300,
                        child: ElevatedButton(
                          onPressed: () => registerUser(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1976D2),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(35),
                            ),
                            elevation: 6,
                            shadowColor: Colors.blueAccent,
                            textStyle: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: const Text(
                            'Register',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                const SizedBox(height: 26),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(color: Color(0xFF566573)),
                    ),
                    GestureDetector(
                      onTap: () {
                        context.go('/login');
                      },
                      child: const Text(
                        "Login here",
                        style: TextStyle(
                          color: Color(0xFF1976D2),
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
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

  Widget buildFieldBox(
    TextEditingController controller,
    String label, {
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return SizedBox(
      width: 300,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color(0xFF154360),
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
          filled: true,
          fillColor: Color(0xFFF9FBFC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF9BBDDF), width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF9BBDDF), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
          ),
        ),
        style: const TextStyle(
          color: Color(0xFF0D3B66),
          fontSize: 16,
        ),
        obscureText: obscureText,
        keyboardType: keyboardType,
      ),
    );
  }

  Widget buildPasswordBox(
    TextEditingController controller,
    String label,
    bool isVisible,
    VoidCallback onToggle,
  ) {
    return SizedBox(
      width: 300,
      child: TextField(
        controller: controller,
        obscureText: !isVisible,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color(0xFF154360),
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
          filled: true,
          fillColor: Color(0xFFF9FBFC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF9BBDDF), width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF9BBDDF), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              isVisible ? Icons.visibility : Icons.visibility_off,
              color: Color(0xFF1976D2),
            ),
            onPressed: onToggle,
          ),
        ),
        style: const TextStyle(
          color: Color(0xFF0D3B66),
          fontSize: 16,
        ),
      ),
    );
  }

  Future<void> registerUser(BuildContext context) async {
    final email = emailController.text.trim();
    final firstName = firstNameController.text.trim();
    final middleInitial = middleInitialController.text.trim();
    final lastName = lastNameController.text.trim();
    final address = addressController.text.trim();
    final mobile = mobileController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (email.isEmpty ||
        firstName.isEmpty ||
        lastName.isEmpty ||
        address.isEmpty ||
        mobile.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showSnackBar(context, 'Please fill out all required fields.');
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar(context, 'Passwords do not match.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final _ = await supabase.from('users').insert({
        'email': email,
        'first_name': firstName,
        'middle_initial': middleInitial,
        'last_name': lastName,
        'address': address,
        'mobile_number': mobile,
        'role_id': await _getDefaultRoleId(),
        'is_verified': false,
        'password': password,
      });

      final response = await supabase.functions.invoke(
        'send-otp',
        body: {'email': email},
      );

      try {
        final status = (response as dynamic).status;
        if (status != 200) {
          throw Exception('Failed to send OTP (status $status)');
        }
      } catch (_) {}

      context.go('/verify-otp', extra: email);
    } catch (e) {
      _showSnackBar(context, 'Registration error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<String> _getDefaultRoleId() async {
    try {
      final role = await supabase
          .from('roles')
          .select('id')
          .eq('name', 'User')
          .single();

      final id = role['id'];
      if (id == null) {
        throw Exception('Default role not found');
      }
      return id as String;
    } on PostgrestException catch (e) {
      throw Exception('Database error while fetching role: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error while fetching role: $e');
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
