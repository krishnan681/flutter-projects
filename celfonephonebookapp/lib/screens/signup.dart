import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <-- added for input formatters
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/supabase.dart';
import './homepage_shell.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  String signupType = "business"; // default
  bool isLoading = false;

  // Controllers
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final cityController = TextEditingController();
  final pincodeController = TextEditingController();
  final addressController = TextEditingController();

  // Person
  final personNameController = TextEditingController();
  String? personPrefix = "--"; // default
  final keywordsController = TextEditingController(); // profession/products

  // Business
  final businessNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final landlineController = TextEditingController();
  final landlineCodeController = TextEditingController();

  // --- Focus & Help-text (unchanged) ---
  final Map<TextEditingController, FocusNode> _focusNodes = {};
  final Map<TextEditingController, bool> _showHelp = {};

  @override
  void initState() {
    super.initState();
    _initFocus(
      mobileController,
      "Enter a 10-digit Indian mobile number (starts with 6-9).",
    );
    _initFocus(
      emailController,
      "Enter a valid email address (must contain @).",
    );
    _initFocus(cityController, "Enter the city name.");
    _initFocus(pincodeController, "Enter a 6-digit pincode (numbers only).");
    _initFocus(addressController, "Enter the full address.");
    _initFocus(personNameController, "Enter the person's full name.");
    _initFocus(businessNameController, "Enter the firm / business name.");
    _initFocus(
      keywordsController,
      "Enter profession (person) or products (business).",
    );
    _initFocus(landlineController, "Enter the landline number (numbers only).");
    _initFocus(landlineCodeController, "Enter the STD code (numbers only).");
  }

  void _initFocus(TextEditingController ctrl, String help) {
    final node = FocusNode();
    _focusNodes[ctrl] = node;
    _showHelp[ctrl] = false;
    node.addListener(() => setState(() => _showHelp[ctrl] = node.hasFocus));
  }

  Timer? _debounce;
  bool _isCheckingMobile = false;
  bool _mobileExists = false;
  String? _mobileMsg;
  String _lastCheckToken = "";

  @override
  void dispose() {
    _debounce?.cancel();
    for (final n in _focusNodes.values) n.dispose();
    mobileController.dispose();
    emailController.dispose();
    cityController.dispose();
    pincodeController.dispose();
    addressController.dispose();
    personNameController.dispose();
    keywordsController.dispose();
    businessNameController.dispose();
    descriptionController.dispose();
    landlineController.dispose();
    landlineCodeController.dispose();
    super.dispose();
  }

  // ===== Mobile Check (unchanged) =====
  void _onMobileChanged(String value) {
    _debounce?.cancel();
    setState(() {
      _mobileMsg = null;
      _mobileExists = false;
    });
    final trimmed = value.trim();
    final isPatternOk = RegExp(r'^[6-9]\d{9}$').hasMatch(trimmed);
    if (!isPatternOk) return;
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _checkMobileExists(trimmed);
    });
  }

  Future<void> _checkMobileExists(String mobile) async {
    final checkToken = mobile;
    setState(() {
      _isCheckingMobile = true;
      _lastCheckToken = checkToken;
    });
    try {
      final res = await SupabaseService.client
          .from('profiles')
          .select('business_name, person_name')
          .eq('mobile_number', mobile)
          .maybeSingle();
      if (!mounted || _lastCheckToken != checkToken) return;
      if (res != null) {
        final business = (res['business_name'] as String?)?.trim();
        final person = (res['person_name'] as String?)?.trim();
        setState(() {
          _mobileExists = true;
          _mobileMsg = business != null && business.isNotEmpty
              ? "Mobile already registered with Business: $business"
              : "Mobile already registered with Person: ${person ?? '-'}";
        });
      } else {
        setState(() {
          _mobileExists = false;
          _mobileMsg = "Mobile available [Checkmark]";
        });
      }
    } catch (e) {
      setState(() {
        _mobileExists = false;
        _mobileMsg = "Couldn’t verify mobile (check RLS/connection)";
      });
    } finally {
      if (mounted && _lastCheckToken == checkToken) {
        setState(() => _isCheckingMobile = false);
      }
    }
  }

  // ===== NEW VALIDATORS (added) =====
  String? validateMobile(String? value) {
    if (value == null || value.isEmpty) return "Enter mobile number";
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
      return "Enter valid 10-digit Indian mobile number";
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return "Enter email";
    if (!value.contains('@')) return "Email must contain @";
    return null;
  }

  String? validatePincode(String? value) {
    if (value == null || value.isEmpty) return "Enter pincode";
    if (!RegExp(r'^\d{6}$').hasMatch(value))
      return "Enter valid 6-digit pincode";
    return null;
  }

  String? validateLandline(String? value) {
    if (value == null || value.isEmpty) return null; // optional
    if (!RegExp(r'^\d+$').hasMatch(value))
      return "Landline must contain numbers only";
    return null;
  }

  String? validateStdCode(String? value) {
    if (value == null || value.isEmpty) return null; // optional
    if (!RegExp(r'^\d+$').hasMatch(value))
      return "STD code must contain numbers only";
    return null;
  }

  // ----- Reusable field with help & formatters -----
  Widget _field({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final help = {
      mobileController:
          "Enter a 10-digit Indian mobile number (starts with 6-9).",
      emailController: "Enter a valid email address (must contain @).",
      cityController: "Enter the city name.",
      pincodeController: "Enter a 6-digit pincode (numbers only).",
      addressController: "Enter the full address.",
      personNameController: "Enter the person's full name.",
      businessNameController: "Enter the firm / business name.",
      keywordsController: "Enter profession (person) or products (business).",
      landlineController: "Enter the landline number (numbers only).",
      landlineCodeController: "Enter the STD code (numbers only).",
    }[controller]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          focusNode: _focusNodes[controller],
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            suffixIcon: suffixIcon,
          ),
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          onChanged: controller == mobileController ? _onMobileChanged : null,
        ),
        if (_showHelp[controller]!)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              help,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  // ===== Person Form =====
  Widget _buildPersonForm() => Column(
    children: [
      _field(
        controller: personNameController,
        label: "Person Name",
        validator: (v) => v == null || v.isEmpty ? "Required" : null,
      ),
      DropdownButtonFormField<String>(
        value: personPrefix,
        items: const [
          DropdownMenuItem(value: "--", child: Text("--")),
          DropdownMenuItem(value: "Mr.", child: Text("Mr.")),
          DropdownMenuItem(value: "Ms.", child: Text("Ms.")),
        ],
        onChanged: (val) => setState(() => personPrefix = val),
        decoration: const InputDecoration(labelText: "Prefix"),
      ),
      _field(controller: businessNameController, label: "Firm Name"),
      _field(controller: cityController, label: "City"),
      _field(
        controller: pincodeController,
        label: "Pincode",
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: validatePincode,
      ),
      _field(
        controller: addressController,
        label: "Address",
        validator: (v) => v == null || v.isEmpty ? "Required" : null,
      ),
      _field(controller: keywordsController, label: "Profession"),
      _field(
        controller: emailController,
        label: "Email",
        keyboardType: TextInputType.emailAddress,
        validator: validateEmail,
      ),
      _field(
        controller: landlineController,
        label: "Land Line",
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: validateLandline,
      ),
      _field(
        controller: landlineCodeController,
        label: "STD Code",
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: validateStdCode,
      ),
    ],
  );

  // ===== Business Form =====
  Widget _buildBusinessForm() => Column(
    children: [
      _field(
        controller: businessNameController,
        label: "Firm Name",
        validator: (v) => v == null || v.isEmpty ? "Required" : null,
      ),
      _field(
        controller: personNameController,
        label: "Director / Prop / Partner Name",
      ),
      DropdownButtonFormField<String>(
        value: personPrefix,
        items: const [
          DropdownMenuItem(value: "--", child: Text("--")),
          DropdownMenuItem(value: "Mr.", child: Text("Mr.")),
          DropdownMenuItem(value: "Ms.", child: Text("Ms.")),
        ],
        onChanged: (val) => setState(() => personPrefix = val),
        decoration: const InputDecoration(labelText: "Prefix"),
      ),
      _field(
        controller: cityController,
        label: "City",
        validator: (v) => v == null || v.trim().isEmpty ? "Enter city" : null,
      ),
      _field(
        controller: pincodeController,
        label: "Pincode",
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: validatePincode,
      ),
      _field(
        controller: addressController,
        label: "Address",
        validator: (v) => v == null || v.isEmpty ? "Required" : null,
      ),
      _field(
        controller: keywordsController,
        label: "Products",
        validator: (v) => v == null || v.isEmpty ? "Required" : null,
      ),
      _field(
        controller: emailController,
        label: "Email",
        keyboardType: TextInputType.emailAddress,
        validator: validateEmail,
      ),
      _field(
        controller: landlineController,
        label: "Land Line",
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: validateLandline,
      ),
      _field(
        controller: landlineCodeController,
        label: "STD Code",
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: validateStdCode,
      ),
    ],
  );

  // ===== Signup Submit (unchanged) =====
  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    final mobile = mobileController.text.trim();
    if (_mobileExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_mobileMsg ?? "Mobile already registered")),
      );
      return;
    }
    setState(() => isLoading = true);
    try {
      final Map<String, dynamic> profile = {
        "user_type": signupType,
        "mobile_number": mobile,
        "city": cityController.text.trim(),
        "pincode": pincodeController.text.trim(),
        "address": addressController.text.trim(),
        "email": emailController.text.trim(),
        "person_prefix": personPrefix,
        "landline": landlineController.text.trim(),
        "landline_code": landlineCodeController.text.trim(),
      };
      String displayName = "";
      if (signupType == "person") {
        profile.addAll({
          "person_name": personNameController.text.trim(),
          "business_name": businessNameController.text.trim(),
          "keywords": keywordsController.text.trim(),
        });
        displayName = personNameController.text.trim().isNotEmpty
            ? personNameController.text.trim()
            : businessNameController.text.trim();
      } else {
        profile.addAll({
          "business_name": businessNameController.text.trim(),
          "person_name": personNameController.text.trim(),
          "keywords": keywordsController.text.trim(),
        });
        displayName = businessNameController.text.trim().isNotEmpty
            ? businessNameController.text.trim()
            : personNameController.text.trim();
      }
      await SupabaseService.client.from("profiles").insert(profile);
      if (!mounted) return;
      // Success popup
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text("Registration Successful [Party Popper]"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${displayName.isNotEmpty ? displayName : "User"} Registered successfully.",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text("Username: $mobile"),
              const Text("Password: signpost"),
              const SizedBox(height: 16),
              const Text(
                "[Pin] Note: Take Screenshot and Save/Note.",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomePageShell()),
                  (route) => false,
                );
              },
              child: const Text("Continue"),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mobile = mobileController.text.trim();
    final mobileLooksValid = RegExp(r'^[6-9]\d{9}$').hasMatch(mobile);

    return Scaffold(
      appBar: AppBar(title: const Text("Signup")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ToggleButtons(
              isSelected: [signupType == "person", signupType == "business"],
              onPressed: (index) => setState(
                () => signupType = index == 0 ? "person" : "business",
              ),
              borderRadius: BorderRadius.circular(12),
              selectedColor: Colors.white,
              fillColor: Theme.of(context).primaryColor,
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Icon(Icons.person),
                      SizedBox(width: 8),
                      Text("Person"),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Icon(Icons.business),
                      SizedBox(width: 8),
                      Text("Business"),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Mobile – 10 digits only
                    _field(
                      controller: mobileController,
                      label: "Mobile Number",
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10), // max 10
                      ],
                      validator: validateMobile,
                      suffixIcon: _isCheckingMobile
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : (mobileLooksValid && _mobileMsg != null)
                          ? (_mobileExists
                                ? const Icon(Icons.error, color: Colors.red)
                                : const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  ))
                          : null,
                    ),
                    if (_mobileMsg != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _mobileMsg!,
                            style: TextStyle(
                              color: _mobileExists ? Colors.red : Colors.green,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 10),
                    if (signupType == "person") _buildPersonForm(),
                    if (signupType == "business") _buildBusinessForm(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    onPressed: _signup,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    icon: const Icon(Icons.check_circle),
                    label: Text("Sign Up as ${signupType.capitalize()}"),
                  ),
          ),
        ],
      ),
    );
  }
}

extension StringCasingExtension on String {
  String capitalize() =>
      isEmpty ? this : "${this[0].toUpperCase()}${substring(1)}";
}
