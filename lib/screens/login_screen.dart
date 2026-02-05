import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart'; // To access home screen (will update later)

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isLoading = false;
  bool _isRegistering = false; // Toggle between Login and Register

  // Phone + PIN වලින් Login/Register වන Logic එක
  Future<void> _handleAuth() async {
    final phone = _phoneController.text.trim();
    final pin = _pinController.text.trim();
    final name = _nameController.text.trim();

    if (phone.isEmpty || pin.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid Phone and 4-digit PIN'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. අපි Phone එක Email එකක් විදිහට Convert කරනවා (Trick)
      final email = '$phone@saloonrich.com';
      final password = 'pin_$pin'; // PIN එක Password එකක් කරනවා

      final supabase = Supabase.instance.client;

      if (_isRegistering) {
        // --- REGISTER ---
        if (name.isEmpty) {
          throw 'Please enter your Name for registration';
        }

        // A. Supabase Auth එකේ User කෙනෙක් හදනවා
        final AuthResponse res = await supabase.auth.signUp(
          email: email,
          password: password,
        );

        if (res.user != null) {
          // B. අපේ 'users' table එකට විස්තර දානවා
          await supabase.from('users').insert({
            'id': res.user!.id,
            'phone': phone,
            'pin': pin,
            'display_name': name,
            'role': 'client', // Default role
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Registration Successful! Logging in...'),
              ),
            );
          }
        }
      } else {
        // --- LOGIN ---
        await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
      }

      // Login හරි නම් Home එකට යන්න (දැනට නිකන් තියමු)
      if (mounted) {
        // අපි ඊළඟට Home Screen එක හදමු. දැනට Success මැසේජ් එකක් විතරක් දෙමු.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Login Successful!'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error: ${e.toString()}'),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 400,
            ), // Web එකේ ලස්සනට පේන්න
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo & Title
                const Icon(
                  Icons.content_cut,
                  size: 60,
                  color: Color(0xFFFFD700),
                ),
                const SizedBox(height: 20),
                Text(
                  'SALOON RICH',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFFD700),
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _isRegistering ? 'Create New Account' : 'Welcome Back',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 30),

                // Inputs
                if (_isRegistering)
                  _buildTextField(_nameController, 'Your Name', Icons.person),
                if (_isRegistering) const SizedBox(height: 15),

                _buildTextField(
                  _phoneController,
                  'Phone Number',
                  Icons.phone,
                  isNumber: true,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  _pinController,
                  '4-Digit PIN',
                  Icons.lock,
                  isNumber: true,
                  isObscure: true,
                ),

                const SizedBox(height: 30),

                // Main Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleAuth,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : Text(
                            _isRegistering ? 'REGISTER' : 'LOGIN',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // Toggle Button
                TextButton(
                  onPressed: () =>
                      setState(() => _isRegistering = !_isRegistering),
                  child: Text(
                    _isRegistering
                        ? 'Already have an account? Login'
                        : 'New here? Register',
                    style: const TextStyle(color: Colors.white60),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
    bool isObscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLength: isObscure ? 4 : null, // PIN එකට ඉලක්කම් 4යි
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFFFD700)),
        filled: true,
        fillColor: Colors.black,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        labelStyle: const TextStyle(color: Colors.white60),
        counterText: "",
      ),
    );
  }
}
