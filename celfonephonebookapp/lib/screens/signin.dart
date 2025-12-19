// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '../supabase/supabase.dart';
// import 'homepage_shell.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import './signup.dart';

// class SigninPage extends StatefulWidget {
//   const SigninPage({super.key});

//   @override
//   State<SigninPage> createState() => _SigninPageState();
// }

// class _SigninPageState extends State<SigninPage> {
//   final PageController _pageController = PageController();

//   // Step 1 – Mobile
//   final _mobileController = TextEditingController();
//   bool _isChecking = false;
//   String? _mobileError;

//   // Step 2 – New user registration
//   final _nameController = TextEditingController();
//   String _prefix = 'Mr';

//   @override
//   void dispose() {
//     _pageController.dispose();
//     _mobileController.dispose();
//     _nameController.dispose();
//     super.dispose();
//   }

//   // ──────────────────────────────────────────────────────────────
//   // 1. Validate mobile & decide login vs registration
//   // ──────────────────────────────────────────────────────────────
//   Future<void> _checkAndProceed() async {
//     final mobile = _mobileController.text.trim();

//     if (!RegExp(r'^[6-9]\d{9}$').hasMatch(mobile)) {
//       setState(() {
//         _mobileError = 'Enter a valid 10-digit Indian mobile number';
//       });
//       return;
//     }

//     setState(() {
//       _isChecking = true;
//       _mobileError = null;
//     });

//     try {
//       final profile = await SupabaseService.client
//           .from('profiles')
//           .select('id, business_name, person_name, person_prefix')
//           .eq('mobile_number', mobile)
//           .maybeSingle();

//       if (profile != null) {
//         final business = (profile['business_name'] as String?)?.trim();
//         final person = (profile['person_name'] as String?)?.trim();
//         final username = (business != null && business.isNotEmpty)
//             ? business
//             : (person ?? '');

//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString('username', username);
//         await prefs.setString('userId', profile['id'].toString());
//         await prefs.setString('mobile_number', mobile);

//         if (mounted) {
//           ScaffoldMessenger.of(
//             context,
//           ).showSnackBar(SnackBar(content: Text('Welcome back, $username!')));
//           Navigator.pushAndRemoveUntil(
//             context,
//             MaterialPageRoute(builder: (_) => const HomePageShell()),
//             (route) => false,
//           );
//         }
//       } else {
//         _pageController.animateToPage(
//           1,
//           duration: const Duration(milliseconds: 400),
//           curve: Curves.easeInOut,
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Error: $e')));
//       }
//     } finally {
//       if (mounted) setState(() => _isChecking = false);
//     }
//   }

//   // ──────────────────────────────────────────────────────────────
//   // 2. Register new user
//   // ──────────────────────────────────────────────────────────────
//   Future<void> _registerAndLogin() async {
//     final name = _nameController.text.trim();
//     final mobile = _mobileController.text.trim();

//     if (name.isEmpty) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Please enter your name')));
//       return;
//     }

//     try {
//       final result = await SupabaseService.client
//           .from('profiles')
//           .insert({
//             'mobile_number': mobile,
//             'person_name': name,
//             'person_prefix': _prefix,
//             'user_type': 'person',
//             'password': 'signpost',
//           })
//           .select()
//           .single();

//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('username', name);
//       await prefs.setString('userId', result['id'].toString());
//       await prefs.setString('mobile_number', mobile);

//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text('Welcome to the app!')));
//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(builder: (_) => const HomePageShell()),
//           (route) => false,
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Registration failed: $e')));
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading:
//             _pageController.hasClients &&
//                 (_pageController.page?.round() ?? 0) == 1
//             ? IconButton(
//                 icon: const Icon(Icons.arrow_back_ios, color: Colors.black54),
//                 onPressed: () => _pageController.previousPage(
//                   duration: const Duration(milliseconds: 300),
//                   curve: Curves.ease,
//                 ),
//               )
//             : null,
//       ),
//       body: PageView(
//         controller: _pageController,
//         physics: const NeverScrollableScrollPhysics(),
//         children: [
//           // ────────────────────── STEP 1 ──────────────────────
//           SafeArea(
//             child: ListView(
//               padding: const EdgeInsets.symmetric(horizontal: 32),
//               children: [
//                 const SizedBox(height: 20),
//                 const Text(
//                   "Welcome Back",
//                   style: TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   "Enter your mobile number to Login",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(fontSize: 15, color: Colors.grey[600]),
//                 ),
//                 const SizedBox(height: 40),

//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(20),
//                   child: Image.asset(
//                     'assets/images/MBNO.jpg',
//                     height: 220,
//                     fit: BoxFit.contain,
//                     errorBuilder: (_, __, ___) => const SizedBox(),
//                   ),
//                 ),
//                 const SizedBox(height: 50),

//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 20,
//                     vertical: 8,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.grey[50],
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(color: Colors.grey[300]!),
//                   ),
//                   child: TextField(
//                     controller: _mobileController,
//                     keyboardType: TextInputType.phone,
//                     inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                     maxLength: 10,
//                     style: const TextStyle(fontSize: 18),
//                     decoration: InputDecoration(
//                       hintText: 'Enter 10-digit mobile number',
//                       hintStyle: TextStyle(color: Colors.grey[500]),
//                       counterText: '',
//                       border: InputBorder.none,
//                       errorText: _mobileError,
//                       errorStyle: const TextStyle(fontSize: 12),
//                       prefixIcon: const Icon(
//                         Icons.phone_android,
//                         color: Colors.blue,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 30),

//                 SizedBox(
//                   height: 56,
//                   child: ElevatedButton(
//                     onPressed: _isChecking ? null : _checkAndProceed,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF4285F4),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                       elevation: 4,
//                     ),
//                     child: _isChecking
//                         ? const SizedBox(
//                             height: 24,
//                             width: 24,
//                             child: CircularProgressIndicator(
//                               color: Colors.white,
//                               strokeWidth: 2.5,
//                             ),
//                           )
//                         : const Text(
//                             "Login",
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                           ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),

//                 Center(
//                   child: TextButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (_) => const SignupPage()),
//                       );
//                     },
//                     child: const Text(
//                       "Create an Account? Sign Up",
//                       style: TextStyle(
//                         fontSize: 15,
//                         color: Colors.blue,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 40),
//               ],
//             ),
//           ),

//           // ────────────────────── STEP 2 ──────────────────────
//           SafeArea(
//             child: ListView(
//               padding: const EdgeInsets.symmetric(horizontal: 32),
//               children: [
//                 const SizedBox(height: 40),
//                 const Text(
//                   "Almost there!",
//                   style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 12),
//                 Text(
//                   "Mobile: ${_mobileController.text}",
//                   style: TextStyle(color: Colors.grey[600], fontSize: 16),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 60),

//                 TextField(
//                   controller: _nameController,
//                   decoration: InputDecoration(
//                     labelText: 'Your Full Name',
//                     prefixIcon: const Icon(Icons.person_outline),
//                     filled: true,
//                     fillColor: Colors.grey[50],
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),

//                 DropdownButtonFormField<String>(
//                   value: _prefix,
//                   items: ['Mr', 'Ms', 'Mrs', 'Dr']
//                       .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//                       .toList(),
//                   onChanged: (v) => setState(() => _prefix = v!),
//                   decoration: InputDecoration(
//                     labelText: 'Prefix',
//                     filled: true,
//                     fillColor: Colors.grey[50],
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 50),

//                 Row(
//                   children: [
//                     Expanded(
//                       child: OutlinedButton(
//                         onPressed: () => _pageController.previousPage(
//                           duration: const Duration(milliseconds: 300),
//                           curve: Curves.ease,
//                         ),
//                         style: OutlinedButton.styleFrom(
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(30),
//                           ),
//                         ),
//                         child: const Text("Back"),
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: ElevatedButton(
//                         onPressed: _registerAndLogin,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF4285F4),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(30),
//                           ),
//                         ),
//                         child: const Text(
//                           "Complete Registration",
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 40),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import '../supabase/supabase.dart';
// import 'homepage_shell.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import './signup.dart';

// class SigninPage extends StatefulWidget {
//   const SigninPage({super.key});

//   @override
//   State<SigninPage> createState() => _SigninPageState();
// }

// class _SigninPageState extends State<SigninPage> {
//   final _formKey = GlobalKey<FormState>();
//   final mobileController = TextEditingController();
//   bool _isLoading = false;

//   Future<void> _signIn() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isLoading = true);

//     final mobile = mobileController.text.trim();

//     try {
//       // 🔎 Check profiles table
//       final profile = await SupabaseService.client
//           .from("profiles")
//           .select("id, business_name, person_name")
//           .eq("mobile_number", mobile)
//           .maybeSingle();

//       if (profile == null) {
//         // ❌ Not found → show alert with Signup option
//         if (mounted) {
//           await showDialog(
//             context: context,
//             builder: (context) => AlertDialog(
//               title: const Text("Invalid Mobile Number"),
//               content: const Text(
//                 "This mobile number is not registered. Please sign up first.",
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(builder: (_) => const SignupPage()),
//                     );
//                   },
//                   child: const Text("Sign Up"),
//                 ),
//               ],
//             ),
//           );
//         }
//       } else {
//         // ✅ Found → resolve name preference
//         final business = (profile["business_name"] as String?)?.trim();
//         final person = (profile["person_name"] as String?)?.trim();

//         final username = (business != null && business.isNotEmpty)
//             ? business
//             : (person ?? "");

//         final userId = profile["id"].toString();

//         // Save to local storage
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString("username", username);
//         await prefs.setString("userId", userId);

//         debugPrint("✅ Logged in as $username ($userId)");

//         if (mounted) {
//           Navigator.pushAndRemoveUntil(
//             context,
//             MaterialPageRoute(builder: (_) => const HomePageShell()),
//             (route) => false,
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text("Error: $e")));
//       }
//     }

//     if (mounted) setState(() => _isLoading = false);
//   }

//   String? validateMobile(String? value) {
//     if (value == null || value.isEmpty) return "Enter mobile number";
//     if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
//       return "Enter valid Indian mobile number";
//     }
//     return null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[200],
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Card(
//             elevation: 6,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(20),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Text(
//                       "Sign In",
//                       style: TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 20),

//                     // Mobile Input
//                     TextFormField(
//                       controller: mobileController,
//                       decoration: const InputDecoration(
//                         labelText: "Mobile Number",
//                         border: OutlineInputBorder(),
//                         prefixIcon: Icon(Icons.phone),
//                       ),
//                       keyboardType: TextInputType.phone,
//                       validator: validateMobile,
//                     ),
//                     const SizedBox(height: 20),

//                     // Sign In Button
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: _isLoading ? null : _signIn,
//                         style: ElevatedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(vertical: 14),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         child: _isLoading
//                             ? const CircularProgressIndicator(
//                                 color: Colors.white,
//                               )
//                             : const Text(
//                                 "Sign In",
//                                 style: TextStyle(fontSize: 16),
//                               ),
//                       ),
//                     ),

//                     const SizedBox(height: 12),

//                     // Signup link
//                     TextButton(
//                       onPressed: () {
//                         Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(builder: (_) => const SignupPage()),
//                         );
//                       },
//                       child: const Text("Create an Account? Sign Up"),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import '../supabase/supabase.dart';
import 'homepage_shell.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './signup.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final _formKey = GlobalKey<FormState>();
  final mobileController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final mobile = mobileController.text.trim();

    try {
      // 🔎 Check profiles table
      final profile = await SupabaseService.client
          .from("profiles")
          .select("id, business_name, person_name")
          .eq("mobile_number", mobile)
          .maybeSingle();

      if (profile == null) {
        // ❌ Not found → show alert with Signup option
        if (mounted) {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text("Not Registered"),
              content: const Text(
                "This mobile number is not registered. Please sign up to continue.",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const SignupPage()),
                    );
                  },
                  child: const Text("Sign Up"),
                ),
              ],
            ),
          );
        }
      } else {
        // ✅ Found → resolve name preference
        final business = (profile["business_name"] as String?)?.trim();
        final person = (profile["person_name"] as String?)?.trim();
        final username = (business != null && business.isNotEmpty)
            ? business
            : (person ?? "");
        final userId = profile["id"].toString();

        // 💾 Save to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("username", username);
        await prefs.setString("userId", userId);

        // 🆕 Ensure users_table row exists (insert only if not exists)
        try {
          final existing = await SupabaseService.client
              .from('users_table')
              .select('id')
              .eq('user_id', userId)
              .maybeSingle();

          if (existing == null) {
            await SupabaseService.client.from('users_table').insert({
              'user_id': userId,
              'user_name': username,
            });
          }
        } catch (e) {
          debugPrint('Error ensuring users_table row: $e');
        }

        debugPrint("✅ Logged in as $username ($userId)");

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomePageShell()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  String? validateMobile(String? value) {
    if (value == null || value.isEmpty) return "Enter mobile number";
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
      return "Enter valid Indian mobile number";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo / Icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3F51B5),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3F51B5).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.phone_android_rounded,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                const Text(
                  "Welcome Back",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Sign in with your registered mobile number",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                const SizedBox(height: 48),

                // Form Card
                Container(
                  constraints: const BoxConstraints(maxWidth: 420),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Mobile Field
                        TextFormField(
                          controller: mobileController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: "Mobile Number",
                            hintText: "Enter 10-digit number",
                            prefixIcon: const Icon(Icons.phone_android),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Color(0xFF3F51B5),
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          validator: validateMobile,
                        ),
                        const SizedBox(height: 32),

                        // Sign In Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _signIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3F51B5),
                              foregroundColor: Colors.white,
                              elevation: 6,
                              shadowColor: const Color(
                                0xFF3F51B5,
                              ).withOpacity(0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  )
                                : const Text(
                                    "Sign In",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Sign Up Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "New to Celfone5G+? ",
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SignupPage(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Create Account",
                                style: TextStyle(
                                  color: Color(0xFF3F51B5),
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
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
