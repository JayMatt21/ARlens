import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController middleInitialController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final supabase = Supabase.instance.client;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 241, 170, 165),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Register New Account',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              
              buildFieldBox(firstNameController, 'First Name'),
              const SizedBox(height: 10),
              buildFieldBox(middleInitialController, 'Middle Initial'),
              const SizedBox(height: 10),
              buildFieldBox(lastNameController, 'Last Name'),
              const SizedBox(height: 10),
              buildFieldBox(addressController, 'Address'),
              const SizedBox(height: 10),
              buildFieldBox(mobileController, 'Mobile Number', keyboardType: TextInputType.phone),
              const SizedBox(height: 10),
              buildFieldBox(emailController, 'Email', keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 10),
              buildFieldBox(passwordController, 'Password', obscureText: true),
              const SizedBox(height: 10),
              buildFieldBox(confirmPasswordController, 'Confirm Password', obscureText: true),
              
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : ElevatedButton(
                      onPressed: () => registerUser(context),
                      child: const Text('Register'),
                    ),
            ],
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
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        obscureText: obscureText,
        keyboardType: keyboardType,
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
      final res = await supabase.auth.signUp(email: email, password: password);

      if (res.user == null) {
        _showSnackBar(context, 'Registration failed: Unknown error.');
        setState(() => _isLoading = false);
        return;
      }

      final userId = res.user!.id;

      await supabase.from('users').insert({
        'id': userId,
        'first_name': firstName,
        'middle_initial': middleInitial,
        'last_name': lastName,
        'address': address,
        'mobile_number': mobile,
        'role_id': await _getDefaultRoleId(),
      });

      _showSnackBar(
          context,
          'Registration successful! Please check your email '
          'to verify your account before logging in.');

        Navigator.pushReplacementNamed(context, '/verify-otp', arguments: email);
      } on AuthException catch (e) {
        _showSnackBar(context, 'Registration error: ${e.message}');
      } on PostgrestException catch (e) {
        _showSnackBar(context, 'Database error: ${e.message}');
      } catch (e) {
        _showSnackBar(context, 'Unexpected error: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }

  Future<String> _getDefaultRoleId() async {
    final role = await supabase
        .from('roles')
        .select('id')
        .eq('name', 'User')
        .single();

    if (role['id'] == null) {
      throw Exception('Default role not found');
    }

    return role['id'];
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
