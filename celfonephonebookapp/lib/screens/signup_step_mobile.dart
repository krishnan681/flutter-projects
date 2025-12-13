// lib/screens/signup_step_mobile.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupStepMobile extends StatefulWidget {
  const SignupStepMobile({super.key});

  @override
  State<SignupStepMobile> createState() => _SignupStepMobileState();
}

class _SignupStepMobileState extends State<SignupStepMobile> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  final _mobileController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isChecking = false;
  bool _agreedToTerms = false;
  String? _mobileError;
  String _prefix = 'Mr';

  final supabase = Supabase.instance.client;

  @override
  void dispose() {
    _pageController.dispose();
    _mobileController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _next() {
    _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _checkMobileAndProceed() async {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to Terms & Privacy Policy')),
      );
      return;
    }

    final input = _mobileController.text.trim();

    if (input.isEmpty || input.length != 10 || !input.startsWith('9')) {
      setState(
        () => _mobileError = 'Enter a valid 10-digit number starting with 9',
      );
      return;
    }

    final fullMobile = '09$input'; // → 09XXXXXXXXXX

    setState(() {
      _isChecking = true;
      _mobileError = null;
    });

    try {
      final response = await supabase
          .from('profiles')
          .select(
            'id, mobile_number, person_name, business_name, person_prefix',
          )
          .eq('mobile_number', fullMobile)
          .maybeSingle();

      if (response != null) {
        // USER EXISTS → Auto login (same logic as your SigninPage)
        final personName = response['person_name']?.toString().trim();
        final businessName = response['business_name']?.toString().trim();
        final username = (businessName != null && businessName.isNotEmpty)
            ? businessName
            : (personName ?? '');

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('mobile_number', fullMobile);
        await prefs.setString('username', username);
        await prefs.setString('userId', response['id'].toString());

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Welcome back!')));
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/home', (route) => false);
        }
      } else {
        // New user → go to name screen
        _next();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isChecking = false);
    }
  }

  Future<void> _registerAndLogin() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter your name')));
      return;
    }

    final fullMobile = '09${_mobileController.text.trim()}';

    try {
      final result = await supabase
          .from('profiles')
          .insert({
            'mobile_number': fullMobile,
            'person_name': name,
            'person_prefix': _prefix,
            'user_type': 'person',
            'password': 'signpost',
          })
          .select()
          .single();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('mobile_number', fullMobile);
      await prefs.setString('username', name);
      await prefs.setString('userId', result['id'].toString());

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Welcome to Celfon5G+!')));
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/home', (route) => false);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Registration failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black54),
                onPressed: () => _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease,
                ),
              )
            : null,
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // STEP 1: Mobile Number
          SafeArea(
            child: ListView(
              // ← THIS FIXES OVERFLOW
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              children: [
                const SizedBox(height: 20),
                const Text(
                  "Verify Number",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "Please enter your phone number to continue",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),

                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/MBNO.jpg',
                    height: 240,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 50),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: TextField(
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    maxLength: 10,
                    style: const TextStyle(fontSize: 18),
                    decoration: InputDecoration(
                      hintText: 'Enter your mobile number',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      counterText: '',
                      border: InputBorder.none,
                      errorText: _mobileError,
                      errorStyle: const TextStyle(fontSize: 12),
                      prefixIcon: const Icon(
                        Icons.phone_android,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                Row(
                  children: [
                    Checkbox(
                      value: _agreedToTerms,
                      activeColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onChanged: (v) =>
                          setState(() => _agreedToTerms = v ?? false),
                    ),
                    Expanded(
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(color: Colors.black54, fontSize: 13),
                          children: [
                            TextSpan(
                              text:
                                  "By continuing, I confirm that I have read & agree to the ",
                            ),
                            TextSpan(
                              text: "Terms & conditions",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(text: " and "),
                            TextSpan(
                              text: "Privacy policy",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isChecking ? null : _checkMobileAndProceed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4285F4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 4,
                    ),
                    child: _isChecking
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            "Continue",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),

          // STEP 2: New User Registration
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              children: [
                const SizedBox(height: 40),
                const Text(
                  "Welcome!",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  "Your number: 09${_mobileController.text}",
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),

                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Your Full Name',
                    prefixIcon: const Icon(Icons.person_outline),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                DropdownButtonFormField<String>(
                  value: _prefix,
                  items: ['Mr', 'Ms', 'Mrs', 'Dr']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => _prefix = v!),
                  decoration: InputDecoration(
                    labelText: 'Prefix',
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease,
                        ),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text("Back"),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _nameController.text.trim().isEmpty
                            ? null
                            : _registerAndLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4285F4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          "Complete Registration",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
