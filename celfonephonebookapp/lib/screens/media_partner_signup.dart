// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:image_picker/image_picker.dart';
// import '../supabase/supabase.dart';

// class MediaPartnerSignupPage extends StatefulWidget {
//   const MediaPartnerSignupPage({super.key});

//   @override
//   State<MediaPartnerSignupPage> createState() => _MediaPartnerSignupPageState();
// }

// class _MediaPartnerSignupPageState extends State<MediaPartnerSignupPage> {
//   final _formKey = GlobalKey<FormState>();
//   bool isLoading = false;
//   bool _isPersonSelected = true;

//   // Controllers
//   final mobileController = TextEditingController();
//   final emailController = TextEditingController();
//   final cityController = TextEditingController();
//   final pincodeController = TextEditingController();
//   final addressController = TextEditingController();
//   final personNameController = TextEditingController();
//   final professionController = TextEditingController();
//   final businessNameController = TextEditingController();
//   final keywordsController = TextEditingController();
//   final landlineController = TextEditingController();
//   final landlineCodeController = TextEditingController();

//   String? personPrefix = "Mr.";
//   String? businessPrefix = "M/s.";

//   // Image picker
//   final ImagePicker _picker = ImagePicker();
//   List<File> _selectedImages = [];

//   // Mobile validation
//   Timer? _debounce;
//   bool _isCheckingMobile = false;
//   bool _mobileExists = false;
//   String? _mobileMsg;
//   String _lastCheckToken = "";

//   @override
//   void dispose() {
//     _debounce?.cancel();
//     for (var c in [
//       mobileController,
//       emailController,
//       cityController,
//       pincodeController,
//       addressController,
//       personNameController,
//       professionController,
//       businessNameController,
//       keywordsController,
//       landlineController,
//       landlineCodeController,
//     ]) {
//       c.dispose();
//     }
//     super.dispose();
//   }

//   void _onMobileChanged(String value) {
//     _debounce?.cancel();
//     setState(() {
//       _mobileMsg = null;
//       _mobileExists = false;
//     });

//     final trimmed = value.trim();
//     final isPatternOk = RegExp(r'^[6-9]\d{9}$').hasMatch(trimmed);
//     if (!isPatternOk) return;

//     _debounce = Timer(const Duration(milliseconds: 600), () {
//       _checkMobileExists(trimmed);
//     });
//   }

//   Future<void> _checkMobileExists(String mobile) async {
//     final checkToken = mobile;
//     setState(() {
//       _isCheckingMobile = true;
//       _lastCheckToken = checkToken;
//     });

//     try {
//       final res = await SupabaseService.client
//           .from('profiles')
//           .select('business_name, person_name')
//           .eq('mobile_number', mobile)
//           .maybeSingle();

//       if (!mounted || _lastCheckToken != checkToken) return;

//       if (res != null) {
//         final business = (res['business_name'] as String?)?.trim();
//         final person = (res['person_name'] as String?)?.trim();
//         setState(() {
//           _mobileExists = true;
//           _mobileMsg = business != null && business.isNotEmpty
//               ? "Already registered: $business"
//               : "Already registered: ${person ?? 'Unknown'}";
//         });
//       } else {
//         setState(() {
//           _mobileExists = false;
//           _mobileMsg = "Available";
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _mobileExists = false;
//         _mobileMsg = "Check failed";
//       });
//     } finally {
//       if (mounted && _lastCheckToken == checkToken) {
//         setState(() => _isCheckingMobile = false);
//       }
//     }
//   }

//   Future<void> _pickImages() async {
//     final picked = await _picker.pickMultiImage(imageQuality: 75);
//     if (picked.isNotEmpty) {
//       setState(() {
//         _selectedImages.addAll(picked.map((x) => File(x.path)));
//       });
//     }
//   }

//   void _removeImage(int index) {
//     setState(() => _selectedImages.removeAt(index));
//   }

//   Future<void> addProfileRecord() async {
//     if (!_formKey.currentState!.validate()) return;
//     if (_mobileExists) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Mobile number already registered")),
//       );
//       return;
//     }

//     setState(() => isLoading = true);

//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final userId = prefs.getString("userId");
//       final userName = prefs.getString("username");
//       if (userId == null || userName == null)
//         throw Exception("User not logged in");

//       final profile = {
//         "mobile_number": mobileController.text.trim(),
//         "email": emailController.text.trim(),
//         "city": cityController.text.trim(),
//         "pincode": pincodeController.text.trim(),
//         "address": addressController.text.trim(),
//         "person_name": personNameController.text.trim(),
//         "person_prefix": personPrefix,
//         "business_name": businessNameController.text.trim(),
//         "business_prefix": businessPrefix,
//         "user_type": _isPersonSelected ? "person" : "business",
//         "keywords": keywordsController.text.trim(),
//         "landline": landlineController.text.trim(),
//         "landline_code": landlineCodeController.text.trim(),
//       };

//       await SupabaseService.client.from("profiles").insert(profile);

//       // Earnings logic (unchanged)
//       int earningsToAdd = 0;
//       bool hasBasicInfo =
//           profile["mobile_number"].toString().isNotEmpty &&
//           profile["city"].toString().isNotEmpty &&
//           profile["pincode"].toString().isNotEmpty &&
//           profile["address"].toString().isNotEmpty &&
//           ((_isPersonSelected &&
//                   profile["person_name"].toString().isNotEmpty) ||
//               (!_isPersonSelected &&
//                   profile["business_name"].toString().isNotEmpty));

//       if (hasBasicInfo) earningsToAdd += 1;
//       if (profile["keywords"].toString().isNotEmpty) earningsToAdd += 1;
//       if (profile["email"].toString().isNotEmpty) earningsToAdd += 0;

//       final now = DateTime.now().toUtc();
//       final todayStart = DateTime.utc(now.year, now.month, now.day);
//       final todayEnd = DateTime.utc(now.year, now.month, now.day, 23, 59, 59);

//       final existing = await SupabaseService.client
//           .from("data_entry_table")
//           .select()
//           .eq("user_id", userId)
//           .gte("created_at", todayStart.toIso8601String())
//           .lte("created_at", todayEnd.toIso8601String())
//           .maybeSingle();

//       if (existing != null) {
//         await SupabaseService.client
//             .from("data_entry_table")
//             .update({
//               "count": (existing["count"] as int) + 1,
//               "earnings": (existing["earnings"] as int) + earningsToAdd,
//               "updated_at": now.toIso8601String(),
//             })
//             .eq("id", existing["id"]);
//       } else {
//         await SupabaseService.client.from("data_entry_table").insert({
//           "user_id": userId,
//           "user_name": userName,
//           "count": 1,
//           "earnings": earningsToAdd,
//           "created_at": now.toIso8601String(),
//           "updated_at": now.toIso8601String(),
//         });
//       }

//       final entryName = _isPersonSelected
//           ? personNameController.text.trim()
//           : businessNameController.text.trim();

//       final inserted = await SupabaseService.client
//           .from("data_entry_name")
//           .insert({
//             "user_id": userId,
//             "username": userName,
//             "entry_name": entryName,
//             "created_at": now.toIso8601String(),
//             "updated_at": now.toIso8601String(),
//           })
//           .select()
//           .maybeSingle();

//       if (earningsToAdd > 0 && inserted != null) {
//         await SupabaseService.client
//             .from("data_entry_name")
//             .update({"scheme": "You've Earned ₹$earningsToAdd"})
//             .eq("id", inserted["id"]);
//       }

//       // Reset form
//       for (var c in [
//         mobileController,
//         emailController,
//         cityController,
//         pincodeController,
//         addressController,
//         personNameController,
//         professionController,
//         businessNameController,
//         keywordsController,
//         landlineController,
//         landlineCodeController,
//       ]) {
//         c.clear();
//       }
//       setState(() {
//         personPrefix = "Mr.";
//         businessPrefix = "M/s.";
//         _selectedImages.clear();
//       });

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Profile saved successfully!"),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => isLoading = false);
//     }
//   }

//   // Validators
//   String? validateMobile(String? v) {
//     if (v == null || v.isEmpty) return "Required";
//     if (!RegExp(r'^[6-9]\d{9}$').hasMatch(v)) return "Invalid mobile";
//     return null;
//   }

//   String? validatePincode(String? v) {
//     if (v == null || v.isEmpty) return "Required";
//     if (!RegExp(r'^\d{6}$').hasMatch(v)) return "Invalid pincode";
//     return null;
//   }

//   String? mandatory(String? v) =>
//       (v?.trim().isEmpty ?? true) ? "Required" : null;

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final mobile = mobileController.text.trim();
//     final mobileValid = RegExp(r'^[6-9]\d{9}$').hasMatch(mobile);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Add New Entry"),
//         elevation: 0,
//         backgroundColor: theme.colorScheme.surface,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Card(
//           elevation: 4,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   // === Toggle ===
//                   _buildToggle(theme),

//                   const SizedBox(height: 24),

//                   // === Mobile Field ===
//                   _buildMobileField(theme, mobileValid),

//                   const SizedBox(height: 20),

//                   // === Conditional Fields ===
//                   if (_isPersonSelected)
//                     ..._buildPersonFields(theme)
//                   else
//                     ..._buildBusinessFields(theme),

//                   const SizedBox(height: 20),

//                   // === Image Upload ===
//                   _buildImageSection(theme),

//                   const SizedBox(height: 28),

//                   // === Submit Button ===
//                   _buildSubmitButton(theme),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildToggle(ThemeData theme) {
//     return Container(
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: ToggleButtons(
//         borderRadius: BorderRadius.circular(12),
//         selectedColor: Colors.white,
//         fillColor: theme.colorScheme.primary,
//         color: theme.colorScheme.onSurface,
//         isSelected: [_isPersonSelected, !_isPersonSelected],
//         onPressed: (i) => setState(() => _isPersonSelected = i == 0),
//         children: const [
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//             child: Text("Person"),
//           ),
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//             child: Text("Business"),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMobileField(ThemeData theme, bool mobileValid) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         TextFormField(
//           controller: mobileController,
//           keyboardType: TextInputType.phone,
//           decoration: InputDecoration(
//             labelText: "Mobile Number *",
//             prefixText: "+91 ",
//             prefixStyle: const TextStyle(fontWeight: FontWeight.bold),
//             suffixIcon: _isCheckingMobile
//                 ? const SizedBox(
//                     width: 20,
//                     height: 20,
//                     child: CircularProgressIndicator(strokeWidth: 2),
//                   )
//                 : mobileValid
//                 ? (_mobileExists
//                       ? const Icon(Icons.error, color: Colors.red)
//                       : const Icon(Icons.check_circle, color: Colors.green))
//                 : null,
//             border: const OutlineInputBorder(),
//           ),
//           validator: validateMobile,
//           onChanged: _onMobileChanged,
//         ),
//         if (_mobileMsg != null)
//           Padding(
//             padding: const EdgeInsets.only(top: 6, left: 4),
//             child: Text(
//               _mobileMsg!,
//               style: TextStyle(
//                 fontSize: 12,
//                 color: _mobileExists ? Colors.red : Colors.green,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   List<Widget> _buildPersonFields(ThemeData theme) => [
//     _buildTextField(personNameController, "Person Name *", Icons.person),
//     const SizedBox(height: 16),
//     _buildPrefixRadio(
//       "Prefix",
//       personPrefix,
//       (v) => setState(() => personPrefix = v),
//     ),
//     const SizedBox(height: 16),
//     _buildTextField(businessNameController, "Firm Name", Icons.business),
//     const SizedBox(height: 16),
//     _buildTextField(
//       cityController,
//       "City *",
//       Icons.location_city,
//       validator: mandatory,
//     ),
//     const SizedBox(height: 16),
//     _buildTextField(
//       pincodeController,
//       "Pincode *",
//       Icons.pin,
//       validator: validatePincode,
//     ),
//     const SizedBox(height: 16),
//     _buildTextField(
//       addressController,
//       "Address *",
//       Icons.home,
//       maxLines: 2,
//       validator: mandatory,
//     ),
//     const SizedBox(height: 16),
//     _buildTextField(
//       professionController,
//       "Profession",
//       Icons.work,
//       onChanged: (v) => keywordsController.text = v,
//     ),
//     const SizedBox(height: 16),
//     _buildTextField(emailController, "Email", Icons.email),
//     const SizedBox(height: 16),
//     Row(
//       children: [
//         Expanded(
//           child: _buildTextField(
//             landlineCodeController,
//             "STD Code",
//             Icons.dialpad,
//             keyboard: TextInputType.number,
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           flex: 2,
//           child: _buildTextField(landlineController, "Landline", Icons.phone),
//         ),
//       ],
//     ),
//   ];

//   List<Widget> _buildBusinessFields(ThemeData theme) => [
//     _buildTextField(
//       businessNameController,
//       "Business Name *",
//       Icons.store,
//       validator: mandatory,
//     ),
//     const SizedBox(height: 16),
//     _buildTextField(
//       personNameController,
//       "Contact Person",
//       Icons.person_outline,
//     ),
//     const SizedBox(height: 16),
//     _buildPrefixRadio(
//       "Prefix",
//       personPrefix,
//       (v) => setState(() => personPrefix = v),
//     ),
//     const SizedBox(height: 16),
//     _buildTextField(
//       cityController,
//       "City *",
//       Icons.location_city,
//       validator: mandatory,
//     ),
//     const SizedBox(height: 16),
//     _buildTextField(
//       pincodeController,
//       "Pincode *",
//       Icons.pin,
//       validator: validatePincode,
//     ),
//     const SizedBox(height: 16),
//     _buildTextField(
//       addressController,
//       "Address *",
//       Icons.home,
//       maxLines: 2,
//       validator: mandatory,
//     ),
//     const SizedBox(height: 16),
//     _buildTextField(
//       professionController,
//       "Products/Services",
//       Icons.category,
//       onChanged: (v) => keywordsController.text = v,
//     ),
//     const SizedBox(height: 16),
//     _buildTextField(emailController, "Email", Icons.email),
//     const SizedBox(height: 16),
//     Row(
//       children: [
//         Expanded(
//           child: _buildTextField(
//             landlineCodeController,
//             "STD Code",
//             Icons.dialpad,
//             keyboard: TextInputType.number,
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           flex: 2,
//           child: _buildTextField(landlineController, "Landline", Icons.phone),
//         ),
//       ],
//     ),
//   ];

//   Widget _buildPrefixRadio(
//     String label,
//     String? value,
//     Function(String?) onChanged,
//   ) {
//     return Row(
//       children: [
//         Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w600)),
//         Radio<String>(value: "Mr.", groupValue: value, onChanged: onChanged),
//         const Text("Mr."),
//         Radio<String>(value: "Ms.", groupValue: value, onChanged: onChanged),
//         const Text("Ms."),
//       ],
//     );
//   }

//   Widget _buildTextField(
//     TextEditingController controller,
//     String label,
//     IconData icon, {
//     int maxLines = 1,
//     TextInputType? keyboard,
//     String? Function(String?)? validator,
//     Function(String)? onChanged,
//   }) {
//     return TextFormField(
//       controller: controller,
//       maxLines: maxLines,
//       keyboardType: keyboard,
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(icon, size: 20),
//         border: const OutlineInputBorder(),
//       ),
//       validator: validator,
//       onChanged: onChanged,
//     );
//   }

//   Widget _buildImageSection(ThemeData theme) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text("Upload Photos (Optional)", style: theme.textTheme.titleMedium),
//         const SizedBox(height: 12),
//         if (_selectedImages.isEmpty)
//           OutlinedButton.icon(
//             onPressed: _pickImages,
//             icon: const Icon(Icons.add_a_photo),
//             label: const Text("Add Images"),
//           )
//         else
//           Wrap(
//             spacing: 12,
//             runSpacing: 12,
//             children: _selectedImages.asMap().entries.map((e) {
//               return Stack(
//                 children: [
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(12),
//                     child: Image.file(
//                       e.value,
//                       width: 100,
//                       height: 100,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                   Positioned(
//                     top: 4,
//                     right: 4,
//                     child: IconButton(
//                       icon: const Icon(
//                         Icons.close,
//                         color: Colors.white,
//                         size: 18,
//                       ),
//                       onPressed: () => _removeImage(e.key),
//                       style: IconButton.styleFrom(
//                         backgroundColor: Colors.black54,
//                       ),
//                     ),
//                   ),
//                 ],
//               );
//             }).toList(),
//           ),
//       ],
//     );
//   }

//   Widget _buildSubmitButton(ThemeData theme) {
//     return SizedBox(
//       height: 56,
//       child: ElevatedButton.icon(
//         onPressed: isLoading ? null : addProfileRecord,
//         icon: isLoading
//             ? const SizedBox(
//                 width: 20,
//                 height: 20,
//                 child: CircularProgressIndicator(
//                   color: Colors.white,
//                   strokeWidth: 2,
//                 ),
//               )
//             : const Icon(Icons.save),
//         label: Text(
//           isLoading
//               ? "Saving..."
//               : _isPersonSelected
//               ? "Save Person Profile"
//               : "Save Business Profile",
//           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//         ),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: theme.colorScheme.primary,
//           foregroundColor: Colors.white,
//           elevation: 2,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/supabase.dart';

class MediaPartnerSignupPage extends StatefulWidget {
  const MediaPartnerSignupPage({super.key});

  @override
  State<MediaPartnerSignupPage> createState() => _MediaPartnerSignupPageState();
}

class _MediaPartnerSignupPageState extends State<MediaPartnerSignupPage> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool _isPersonSelected = true;

  // Controllers
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final cityController = TextEditingController();
  final pincodeController = TextEditingController();
  final addressController = TextEditingController();
  final personNameController = TextEditingController();
  final professionController = TextEditingController();
  final businessNameController = TextEditingController();
  final keywordsController = TextEditingController();
  final landlineController = TextEditingController();
  final landlineCodeController = TextEditingController();

  String? personPrefix = "Mr.";

  // Mobile check
  Timer? _debounce;
  bool _isCheckingMobile = false;
  bool _mobileExists = false;
  String? _mobileMsg;
  String _lastCheckToken = "";

  // Help visibility flags — only ONE will be true at a time
  bool _mobileHelpVisible = false;
  bool _personNameHelpVisible = false;
  bool _businessNameHelpVisible = false;
  bool _cityHelpVisible = false;
  bool _pincodeHelpVisible = false;
  bool _addressHelpVisible = false;
  bool _professionHelpVisible = false;
  bool _emailHelpVisible = false;
  bool _landlineCodeHelpVisible = false;
  bool _landlineHelpVisible = false;

  @override
  void dispose() {
    _debounce?.cancel();
    for (var c in [
      mobileController,
      emailController,
      cityController,
      pincodeController,
      addressController,
      personNameController,
      professionController,
      businessNameController,
      keywordsController,
      landlineController,
      landlineCodeController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // Hide all help texts, then show only the one we want
  void _showOnlyThisHelp(void Function() showThis) {
    setState(() {
      _mobileHelpVisible = false;
      _personNameHelpVisible = false;
      _businessNameHelpVisible = false;
      _cityHelpVisible = false;
      _pincodeHelpVisible = false;
      _addressHelpVisible = false;
      _professionHelpVisible = false;
      _emailHelpVisible = false;
      _landlineCodeHelpVisible = false;
      _landlineHelpVisible = false;

      showThis(); // Now show only this one
    });
  }

  // Clear mode-specific fields when switching Person/Business
  void _clearModeSpecificFields() {
    if (_isPersonSelected) {
      businessNameController.clear();
    } else {
      personNameController.clear();
      professionController.clear();
      personPrefix = "Mr.";
      keywordsController.clear();
    }
    _showOnlyThisHelp(() {}); // Hide all help
  }

  // Mobile duplicate check
  void _onMobileChanged(String value) {
    _debounce?.cancel();
    setState(() {
      _mobileMsg = null;
      _mobileExists = false;
    });

    final trimmed = value.trim();
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(trimmed)) return;

    _debounce = Timer(const Duration(milliseconds: 600), () {
      _checkMobileExists(trimmed);
    });
  }

  Future<void> _checkMobileExists(String mobile) async {
    final token = mobile;
    setState(() {
      _isCheckingMobile = true;
      _lastCheckToken = token;
    });

    try {
      final res = await SupabaseService.client
          .from('profiles')
          .select('business_name, person_name')
          .eq('mobile_number', mobile)
          .maybeSingle();

      if (!mounted || _lastCheckToken != token) return;

      if (res != null) {
        final business = (res['business_name'] as String?)?.trim();
        final person = (res['person_name'] as String?)?.trim();
        setState(() {
          _mobileExists = true;
          _mobileMsg = business != null && business.isNotEmpty
              ? "Already registered: $business"
              : "Already registered: ${person ?? 'Unknown'}";
        });
      } else {
        setState(() {
          _mobileExists = false;
          _mobileMsg = "Available";
        });
      }
    } catch (e) {
      setState(() {
        _mobileExists = false;
        _mobileMsg = "Check failed";
      });
    } finally {
      if (mounted && _lastCheckToken == token) {
        setState(() => _isCheckingMobile = false);
      }
    }
  }

  // Submit
  Future<void> addProfileRecord() async {
    if (!_formKey.currentState!.validate()) {
      _showAlert(
        "Missing Fields",
        "Please fill all required fields correctly.",
      );
      return;
    }
    if (_mobileExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mobile number already registered")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString("userId");
      final userName = prefs.getString("username");
      if (userId == null || userName == null)
        throw Exception("User not logged in");

      final Map<String, dynamic> profile = {
        "mobile_number": mobileController.text.trim(),
        "user_type": _isPersonSelected ? "person" : "business",

        if (personNameController.text.trim().isNotEmpty)
          "person_name": personNameController.text.trim(),
        if (personPrefix != null && personNameController.text.trim().isNotEmpty)
          "person_prefix": personPrefix,

        if (!_isPersonSelected)
          "business_name": businessNameController.text.trim(),
        if (!_isPersonSelected) "business_prefix": "M/s.",

        if (_isPersonSelected && businessNameController.text.trim().isNotEmpty)
          "business_name": businessNameController.text.trim(),

        "city": cityController.text.trim(),
        "pincode": pincodeController.text.trim(),
        "address": addressController.text.trim(),
        "email": emailController.text.trim().isNotEmpty
            ? emailController.text.trim()
            : null,
        "keywords": keywordsController.text.trim().isNotEmpty
            ? keywordsController.text.trim()
            : null,
        "landline": landlineController.text.trim().isNotEmpty
            ? landlineController.text.trim()
            : null,
        "landline_code": landlineCodeController.text.trim().isNotEmpty
            ? landlineCodeController.text.trim()
            : null,
      };

      profile.removeWhere((k, v) => v == null || (v is String && v.isEmpty));

      await SupabaseService.client.from("profiles").insert(profile);

      // Earnings logic (unchanged)
      int earningsToAdd = 0;
      final hasBasicInfo =
          cityController.text.trim().isNotEmpty &&
          pincodeController.text.trim().isNotEmpty &&
          addressController.text.trim().isNotEmpty &&
          ((_isPersonSelected && personNameController.text.trim().isNotEmpty) ||
              (!_isPersonSelected &&
                  businessNameController.text.trim().isNotEmpty));

      if (hasBasicInfo) earningsToAdd += 1;
      if (keywordsController.text.trim().isNotEmpty) earningsToAdd += 1;

      final now = DateTime.now().toUtc();
      final todayStart = DateTime.utc(now.year, now.month, now.day);
      final todayEnd = DateTime.utc(now.year, now.month, now.day, 23, 59, 59);

      final existing = await SupabaseService.client
          .from("data_entry_table")
          .select()
          .eq("user_id", userId)
          .gte("created_at", todayStart.toIso8601String())
          .lte("created_at", todayEnd.toIso8601String())
          .maybeSingle();

      if (existing != null) {
        await SupabaseService.client
            .from("data_entry_table")
            .update({
              "count": (existing["count"] as int) + 1,
              "earnings": (existing["earnings"] as int) + earningsToAdd,
              "updated_at": now.toIso8601String(),
            })
            .eq("id", existing["id"]);
      } else {
        await SupabaseService.client.from("data_entry_table").insert({
          "user_id": userId,
          "user_name": userName,
          "count": 1,
          "earnings": earningsToAdd,
          "created_at": now.toIso8601String(),
          "updated_at": now.toIso8601String(),
        });
      }

      final displayName = _isPersonSelected
          ? "${personPrefix ?? "Mr."} ${personNameController.text.trim()}"
          : businessNameController.text.trim();

      final inserted = await SupabaseService.client
          .from("data_entry_name")
          .insert({
            "user_id": userId,
            "username": userName,
            "entry_name": displayName.isNotEmpty ? displayName : "Unknown",
            "created_at": now.toIso8601String(),
            "updated_at": now.toIso8601String(),
          })
          .select()
          .maybeSingle();

      if (earningsToAdd > 0 && inserted != null) {
        await SupabaseService.client
            .from("data_entry_name")
            .update({"scheme": "You've Earned ₹$earningsToAdd"})
            .eq("id", inserted["id"]);
      }

      // CLEAN RESET
      for (var c in [
        mobileController,
        emailController,
        cityController,
        pincodeController,
        addressController,
        personNameController,
        professionController,
        businessNameController,
        keywordsController,
        landlineController,
        landlineCodeController,
      ]) {
        c.clear();
      }
      personPrefix = "Mr.";
      _showOnlyThisHelp(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 26),
              SizedBox(width: 12),
              Text(
                "Saved successfully!",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // Validators
  String? validateMobile(String? v) {
    if (v == null || v.isEmpty) return "Required";
    if (v.length != 10) return "Exactly 10 digits required";
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(v)) return "Must start with 6-9";
    return null;
  }

  String? validatePincode(String? v) {
    if (v == null || v.isEmpty) return "Required";
    if (v.length != 6) return "Pincode must be exactly 6 digits";
    return null;
  }

  String? mandatory(String? v) =>
      (v?.trim().isEmpty ?? true) ? "Required" : null;

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _helpText(String text, bool visible) {
    if (!visible) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          color: Colors.red,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // SMART TEXTFIELD — CLEAN & SIMPLE
  Widget _smartTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String helpText,
    required bool isHelpVisible,
    required VoidCallback onTapShowHelp,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Function(String)? onChanged,
    bool isRequired = true,
    int? maxLength,
  }) {
    final bool isNumberField =
        keyboardType == TextInputType.phone ||
        keyboardType == TextInputType.number;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          maxLength: maxLength,
          inputFormatters: [
            if (isNumberField) FilteringTextInputFormatter.digitsOnly,
            if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
          ],
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, size: 20),
            filled: true,
            fillColor: Colors.white,
            counterText: "",
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey, width: 0.6),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.blueAccent,
                width: 1.2,
              ),
            ),
          ),
          validator: isRequired ? validator : null,
          onChanged: onChanged,
          onTap: onTapShowHelp, // This hides others & shows only this help
        ),
        _helpText(helpText, isHelpVisible && controller.text.isEmpty),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f6fa),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 40,
                  horizontal: 20,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xff0072ff), Color(0xff00c6ff)],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Media Partner Data Entry",
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildModeButton("Person", true),
                        const SizedBox(width: 12),
                        _buildModeButton("Business", false),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Mobile
                      _smartTextField(
                        controller: mobileController,
                        label: "Mobile Number *",
                        icon: Icons.phone,
                        helpText:
                            "Type 10 digits with get Country code (+91), without gap. Don't Type Land Line",
                        isHelpVisible: _mobileHelpVisible,
                        onTapShowHelp: () =>
                            _showOnlyThisHelp(() => _mobileHelpVisible = true),
                        keyboardType: TextInputType.phone,
                        validator: validateMobile,
                        onChanged: _onMobileChanged,
                        maxLength: 10,
                      ),
                      if (_mobileMsg != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6, right: 280),
                          child: Text(
                            _mobileMsg!,
                            style: TextStyle(
                              fontSize: 12,
                              color: _mobileExists ? Colors.red : Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),

                      // Conditional Fields
                      Column(
                        children: _isPersonSelected
                            ? _personFields()
                            : _businessFields(),
                      ),

                      const SizedBox(height: 28),
                      _buildSubmitButton(),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeButton(String title, bool isPerson) {
    final active = _isPersonSelected == isPerson;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_isPersonSelected != isPerson) {
            setState(() => _isPersonSelected = isPerson);
            _clearModeSpecificFields();
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.4),
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: active ? const Color(0xff0072ff) : Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _personFields() => [
    _smartTextField(
      controller: personNameController,
      label: "Person Name *",
      icon: Icons.person,
      helpText: "Type Initial at the end",
      isHelpVisible: _personNameHelpVisible,
      onTapShowHelp: () =>
          _showOnlyThisHelp(() => _personNameHelpVisible = true),
      validator: mandatory,
    ),
    const SizedBox(height: 12),
    _prefixRadio(
      "Prefix",
      personPrefix,
      (v) => setState(() => personPrefix = v),
    ),
    const SizedBox(height: 12),
    _smartTextField(
      controller: cityController,
      label: "City *",
      icon: Icons.location_city,
      helpText: "Type City Name. Don't Use Petnames (Kovai Etc.)",
      isHelpVisible: _cityHelpVisible,
      onTapShowHelp: () => _showOnlyThisHelp(() => _cityHelpVisible = true),
      validator: mandatory,
    ),
    const SizedBox(height: 12),
    _smartTextField(
      controller: pincodeController,
      label: "Pincode *",
      icon: Icons.pin,
      helpText: "Type 6 Digits Continuously Without Gap",
      isHelpVisible: _pincodeHelpVisible,
      onTapShowHelp: () => _showOnlyThisHelp(() => _pincodeHelpVisible = true),
      validator: validatePincode,
      keyboardType: TextInputType.number,
      maxLength: 6,
    ),
    const SizedBox(height: 12),
    _smartTextField(
      controller: addressController,
      label: "Address *",
      icon: Icons.home,
      helpText:
          "Type Door Number, Street, Flat No, Apartment Name, Landmark, Area Name etc.",
      isHelpVisible: _addressHelpVisible,
      onTapShowHelp: () => _showOnlyThisHelp(() => _addressHelpVisible = true),
      maxLines: 2,
      validator: mandatory,
    ),
    const SizedBox(height: 12),
    _smartTextField(
      controller: professionController,
      label: "Profession",
      icon: Icons.work,
      helpText: "Job / business type",
      isHelpVisible: _professionHelpVisible,
      onTapShowHelp: () =>
          _showOnlyThisHelp(() => _professionHelpVisible = true),
      onChanged: (v) => keywordsController.text = v,
      isRequired: false,
    ),
    const SizedBox(height: 12),
    _smartTextField(
      controller: emailController,
      label: "Email",
      icon: Icons.email,
      helpText: "type Correctly if only Available",
      isHelpVisible: _emailHelpVisible,
      onTapShowHelp: () => _showOnlyThisHelp(() => _emailHelpVisible = true),
      isRequired: false,
    ),
    const SizedBox(height: 12),
    Row(
      children: [
        Expanded(
          child: _smartTextField(
            controller: landlineCodeController,
            label: "STD Code",
            icon: Icons.dialpad,
            helpText:
                "Type Only Landline, if Available. Don't Type Mobile Number here.",
            isHelpVisible: _landlineCodeHelpVisible,
            onTapShowHelp: () =>
                _showOnlyThisHelp(() => _landlineCodeHelpVisible = true),
            keyboardType: TextInputType.number,
            maxLength: 5,
            isRequired: false,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: _smartTextField(
            controller: landlineController,
            label: "Landline",
            icon: Icons.phone,
            helpText:
                "Type Only Landline, if Available. Don't Type Mobile Number here.",
            isHelpVisible: _landlineHelpVisible,
            onTapShowHelp: () =>
                _showOnlyThisHelp(() => _landlineHelpVisible = true),
            keyboardType: TextInputType.number,
            maxLength: 10,
            isRequired: false,
          ),
        ),
      ],
    ),
  ];

  List<Widget> _businessFields() => [
    _smartTextField(
      controller: businessNameController,
      label: "Business Name *",
      icon: Icons.store,
      helpText: "Enter Your Full business name",
      isHelpVisible: _businessNameHelpVisible,
      onTapShowHelp: () =>
          _showOnlyThisHelp(() => _businessNameHelpVisible = true),
      validator: mandatory,
    ),
    const SizedBox(height: 12),
    _smartTextField(
      controller: personNameController,
      label: "Contact Person",
      icon: Icons.person_outline,
      helpText: "Optional",
      isHelpVisible: _personNameHelpVisible,
      onTapShowHelp: () =>
          _showOnlyThisHelp(() => _personNameHelpVisible = true),
      isRequired: false,
    ),
    const SizedBox(height: 12),
    _prefixRadio(
      "Prefix",
      personPrefix,
      (v) => setState(() => personPrefix = v),
    ),
    const SizedBox(height: 12),
    _smartTextField(
      controller: cityController,
      label: "City *",
      icon: Icons.location_city,
      helpText: "Type City Name. Don't Use Petnames (Kovai Etc.)",
      isHelpVisible: _cityHelpVisible,
      onTapShowHelp: () => _showOnlyThisHelp(() => _cityHelpVisible = true),
      validator: mandatory,
    ),
    const SizedBox(height: 12),
    _smartTextField(
      controller: pincodeController,
      label: "Pincode *",
      icon: Icons.pin,
      helpText: "Type 6 Digits Continuously Without Gap",
      isHelpVisible: _pincodeHelpVisible,
      onTapShowHelp: () => _showOnlyThisHelp(() => _pincodeHelpVisible = true),
      validator: validatePincode,
      keyboardType: TextInputType.number,
      maxLength: 6,
    ),
    const SizedBox(height: 12),
    _smartTextField(
      controller: addressController,
      label: "Address *",
      icon: Icons.home,
      helpText:
          "Type Door Number, Street, Flat No, Apartment Name, Landmark, Area Name etc.",
      isHelpVisible: _addressHelpVisible,
      onTapShowHelp: () => _showOnlyThisHelp(() => _addressHelpVisible = true),
      maxLines: 2,
      validator: mandatory,
    ),
    const SizedBox(height: 12),
    _smartTextField(
      controller: professionController,
      label: "Products/Services",
      icon: Icons.category,
      helpText: "Enter your Products (Use Comma)",
      isHelpVisible: _professionHelpVisible,
      onTapShowHelp: () =>
          _showOnlyThisHelp(() => _professionHelpVisible = true),
      onChanged: (v) => keywordsController.text = v,
      isRequired: false,
    ),
    const SizedBox(height: 12),
    _smartTextField(
      controller: emailController,
      label: "Email",
      icon: Icons.email,
      helpText: "Type Correctly, Only If Available",
      isHelpVisible: _emailHelpVisible,
      onTapShowHelp: () => _showOnlyThisHelp(() => _emailHelpVisible = true),
      isRequired: false,
    ),
    const SizedBox(height: 12),
    Row(
      children: [
        Expanded(
          child: _smartTextField(
            controller: landlineCodeController,
            label: "STD Code",
            icon: Icons.dialpad,
            helpText:
                "Type Only Landline, if Available. Don't Type Mobile Number here.",
            isHelpVisible: _landlineCodeHelpVisible,
            onTapShowHelp: () =>
                _showOnlyThisHelp(() => _landlineCodeHelpVisible = true),
            keyboardType: TextInputType.number,
            maxLength: 5,
            isRequired: false,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: _smartTextField(
            controller: landlineController,
            label: "Landline",
            icon: Icons.phone,
            helpText:
                "Type Only Landline, if Available. Don't Type Mobile Number here.",
            isHelpVisible: _landlineHelpVisible,
            onTapShowHelp: () =>
                _showOnlyThisHelp(() => _landlineHelpVisible = true),
            keyboardType: TextInputType.number,
            maxLength: 10,
            isRequired: false,
          ),
        ),
      ],
    ),
  ];

  Widget _prefixRadio(
    String label,
    String? value,
    Function(String?) onChanged,
  ) {
    return Row(
      children: [
        Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w600)),
        Radio<String>(value: "Mr.", groupValue: value, onChanged: onChanged),
        const Text("Mr."),
        Radio<String>(value: "Ms.", groupValue: value, onChanged: onChanged),
        const Text("Ms."),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Center(
      child: ElevatedButton(
        onPressed: isLoading ? null : addProfileRecord,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff0072ff),
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              )
            : Text(
                _isPersonSelected
                    ? "Save Person Profile"
                    : "Save Business Profile",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

// class MediaPartnerSignupPage extends StatefulWidget {
//   const MediaPartnerSignupPage({super.key});

//   @override
//   State<MediaPartnerSignupPage> createState() => _MediaPartnerSignupPageState();
// }

// class _MediaPartnerSignupPageState extends State<MediaPartnerSignupPage> {
//   File? _imageFile;
//   final picker = ImagePicker();
//   final textRecognizer = TextRecognizer();
//   final _formKey = GlobalKey<FormState>();

//   // Controllers
//   final mobileController = TextEditingController();
//   final emailController = TextEditingController();
//   final businessNameController = TextEditingController();
//   final addressController = TextEditingController();
//   final cityController = TextEditingController();
//   final pincodeController = TextEditingController();
//   final ownerController = TextEditingController();
//   final productController = TextEditingController();

//   // -----------------------------------------------------------------
//   // 1. Pick Image
//   // -----------------------------------------------------------------
//   Future<void> _pickImage(ImageSource source) async {
//     try {
//       final picked = await picker.pickImage(source: source, imageQuality: 85);
//       if (picked == null) return;

//       final file = File(picked.path);
//       setState(() => _imageFile = file);
//       await _runOcrAndFill(file);
//     } catch (e) {
//       _showAlert('Error', 'Failed to pick image: $e');
//     }
//   }

//   // -----------------------------------------------------------------
//   // 2. OCR + Auto-fill
//   // -----------------------------------------------------------------
//   Future<void> _runOcrAndFill(File image) async {
//     try {
//       final inputImage = InputImage.fromFile(image);
//       final recognized = await textRecognizer.processImage(inputImage);
//       final rawText = recognized.text;

//       if (rawText.trim().isEmpty) {
//         _showAlert('OCR', 'No text detected in the image.');
//         return;
//       }

//       final extracted = _extractFields(rawText);

//       // Auto-fill only if field is empty
//       if (mobileController.text.isEmpty) {
//         mobileController.text = extracted.mobile ?? '';
//       }
//       if (emailController.text.isEmpty) {
//         emailController.text = extracted.email ?? '';
//       }
//       if (businessNameController.text.isEmpty) {
//         businessNameController.text = extracted.business ?? '';
//       }
//       if (addressController.text.isEmpty) {
//         addressController.text = extracted.address ?? '';
//       }
//       if (cityController.text.isEmpty) {
//         cityController.text = extracted.city ?? '';
//       }
//       if (pincodeController.text.isEmpty) {
//         pincodeController.text = extracted.pincode ?? '';
//       }
//       if (ownerController.text.isEmpty) {
//         ownerController.text = extracted.owner ?? '';
//       }
//       if (productController.text.isEmpty) {
//         productController.text = extracted.products ?? '';
//       }

//       _showOcrResult(rawText, extracted);
//     } catch (e) {
//       _showAlert('Error', 'OCR failed: $e');
//     }
//   }

//   // -----------------------------------------------------------------
//   // 3. Smart Field Extraction
//   // -----------------------------------------------------------------
//   ({
//     String? mobile,
//     String? email,
//     String? business,
//     String? owner,
//     String? products,
//     String? address,
//     String? city,
//     String? pincode,
//   })
//   _extractFields(String text) {
//     final lines = text
//         .split('\n')
//         .map((l) => l.trim())
//         .where((l) => l.isNotEmpty)
//         .toList();
//     final lowerText = text.toLowerCase();

//     String? mobile, email, business, owner, products, address, city, pincode;

//     // ---- 1. Mobile (more flexible patterns) ----
//     final mobileRegex = RegExp(
//       r'(?:\b(?:ph|phone|mob|mobile|contact|tel)[:.\-\s]*)?(?:\+91[\s\-]*)?(\d{3,5}[\s\-]?\d{5,7})',
//       caseSensitive: false,
//     );
//     final matches = mobileRegex.allMatches(text);
//     if (matches.isNotEmpty) {
//       // Pick the first likely 10-digit one
//       for (final m in matches) {
//         final raw = m.group(1) ?? '';
//         final digits = raw.replaceAll(RegExp(r'\D'), '');
//         if (digits.length == 10) {
//           mobile = digits;
//           break;
//         }
//       }
//     }

//     // ---- 2. Email ----
//     final emailMatch = RegExp(
//       r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
//     ).firstMatch(text);
//     if (emailMatch != null) email = emailMatch.group(0);

//     // ---- 3. Pincode + City ----
//     final pinMatch = RegExp(r'\b\d{6}\b').firstMatch(text);
//     if (pinMatch != null) {
//       pincode = pinMatch.group(0);
//       final line = lines.firstWhere(
//         (l) => l.contains(pincode!),
//         orElse: () => '',
//       );
//       final beforePin = line.split(pincode!).first.trim();
//       if (beforePin.isNotEmpty) {
//         city = beforePin.split(RegExp(r'\s+')).last;
//       }
//     }

//     // ---- 4. Owner / Proprietor ----
//     for (int i = 0; i < lines.length; i++) {
//       final lower = lines[i].toLowerCase();
//       if (lower.contains('prop') ||
//           lower.contains('owner') ||
//           lower.contains('proprietor') ||
//           lower.contains('contact') ||
//           lower.contains('mr.') ||
//           lower.contains('mrs.') ||
//           lower.contains('ms.')) {
//         owner = lines[i].contains(':')
//             ? lines[i].split(':').last.trim()
//             : lines[i].trim();
//         break;
//       }

//       // If next line contains a designation, take current as owner
//       if (i < lines.length - 1) {
//         final next = lines[i + 1].toLowerCase();
//         if (next.contains('director') ||
//             next.contains('founder') ||
//             next.contains('ceo') ||
//             next.contains('manager') ||
//             next.contains('partner') ||
//             next.contains('consultant') ||
//             next.contains('executive')) {
//           owner = lines[i].trim();
//           break;
//         }
//       }
//     }

//     // ---- 5. Products / Services ----
//     for (final line in lines) {
//       final lower = line.toLowerCase();
//       if (lower.contains('deal') ||
//           lower.contains('product') ||
//           lower.contains('service') ||
//           lower.contains('manufactur') ||
//           lower.contains('trader') ||
//           lower.contains('supplier') ||
//           lower.contains('distributor') ||
//           lower.contains('wholesale') ||
//           lower.contains('retail') ||
//           lower.contains('specialized')) {
//         products = line.contains(':')
//             ? line.split(':').last.trim()
//             : line.trim();
//         break;
//       }
//     }

//     // ---- 6. City fallback (common Indian cities) ----
//     final cityKeywords = [
//       'mumbai',
//       'delhi',
//       'bangalore',
//       'bengaluru',
//       'kolkata',
//       'chennai',
//       'hyderabad',
//       'pune',
//       'ahmedabad',
//       'jaipur',
//       'surat',
//       'lucknow',
//       'nagpur',
//       'indore',
//       'bhopal',
//       'coimbatore',
//       'vadodara',
//       'rajkot',
//     ];
//     if (city == null) {
//       final found = cityKeywords.firstWhere(
//         lowerText.contains,
//         orElse: () => '',
//       );
//       city = found.isEmpty ? null : found;
//     }

//     // ---- 7. Address (longest line that is not a known field) ----
//     final possibleAddresses = lines.where((l) {
//       final lower = l.toLowerCase();
//       if (mobile != null && lower.contains(mobile!)) return false;
//       if (email != null && lower.contains(email!)) return false;
//       if (pincode != null && lower.contains(pincode!)) return false;
//       if (owner != null && lower.contains(owner!.toLowerCase())) return false;
//       if (products != null && lower.contains(products!.toLowerCase()))
//         return false;
//       return l.length >= 12;
//     }).toList();

//     if (possibleAddresses.isNotEmpty) {
//       possibleAddresses.sort((a, b) => b.length.compareTo(a.length));
//       address = possibleAddresses.first;
//     }

//     // ---- 8. Business name (keywords or first non-contact line) ----
//     final companyKeywords = [
//       'pvt',
//       'ltd',
//       'llp',
//       'inc',
//       'corp',
//       'solutions',
//       'enterprises',
//       'traders',
//       'industries',
//       'technologies',
//       'agency',
//       'company',
//       'studio',
//       'store',
//       'shop',
//     ];
//     for (final line in lines) {
//       final lower = line.toLowerCase();
//       if (companyKeywords.any(lower.contains)) {
//         business = line;
//         break;
//       }
//     }
//     // Fallback: first line that does NOT contain mobile/email/pincode
//     business ??= lines.firstWhere((l) {
//       final lower = l.toLowerCase();
//       return !(mobile != null && lower.contains(mobile!)) &&
//           !(email != null && lower.contains(email!)) &&
//           !(pincode != null && lower.contains(pincode!));
//     }, orElse: () => lines.isNotEmpty ? lines.first : '');
//     if (business!.isEmpty) business = null;

//     return (
//       mobile: mobile,
//       email: email,
//       business: business,
//       owner: owner,
//       products: products,
//       address: address,
//       city: city,
//       pincode: pincode,
//     );
//   }

//   // -----------------------------------------------------------------
//   // 4. Show OCR Result
//   // -----------------------------------------------------------------
//   void _showOcrResult(
//     String raw,
//     ({
//       String? mobile,
//       String? email,
//       String? business,
//       String? owner,
//       String? products,
//       String? address,
//       String? city,
//       String? pincode,
//     })
//     extracted,
//   ) {
//     final buffer = StringBuffer()
//       ..writeln('=== Full OCR Text ===')
//       ..writeln(raw)
//       ..writeln('\n=== Extracted Fields ===')
//       ..writeln('Mobile   : ${extracted.mobile ?? "-"}')
//       ..writeln('Email    : ${extracted.email ?? "-"}')
//       ..writeln('Business : ${extracted.business ?? "-"}')
//       ..writeln('Owner    : ${extracted.owner ?? "-"}')
//       ..writeln('Products : ${extracted.products ?? "-"}')
//       ..writeln('Address  : ${extracted.address ?? "-"}')
//       ..writeln('City     : ${extracted.city ?? "-"}')
//       ..writeln('Pincode  : ${extracted.pincode ?? "-"}');

//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('OCR Result'),
//         content: SizedBox(
//           width: double.maxFinite,
//           child: SingleChildScrollView(child: Text(buffer.toString())),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }

//   // -----------------------------------------------------------------
//   // 5. Alert
//   // -----------------------------------------------------------------
//   void _showAlert(String title, String message) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text(title),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }

//   // -----------------------------------------------------------------
//   // 6. Submit Form
//   // -----------------------------------------------------------------
//   void _submitForm() {
//     if (_formKey.currentState!.validate()) {
//       _showAlert(
//         'Success',
//         'Form Submitted!\n\n'
//             'Mobile: ${mobileController.text}\n'
//             'Email: ${emailController.text}\n'
//             'Business: ${businessNameController.text}\n'
//             'Owner: ${ownerController.text}\n'
//             'Products: ${productController.text}\n'
//             'Address: ${addressController.text}\n'
//             'City: ${cityController.text}\n'
//             'Pincode: ${pincodeController.text}',
//       );
//     }
//   }

//   // -----------------------------------------------------------------
//   // UI
//   // -----------------------------------------------------------------
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Media Partner Signup')),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // Camera & Gallery Buttons
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
//                 onPressed: () => _pickImage(ImageSource.camera),
//                 child: const Text('Access Camera'),
//               ),
//               const SizedBox(height: 8),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//                 onPressed: () => _pickImage(ImageSource.gallery),
//                 child: const Text('Browse Photos'),
//               ),
//               const SizedBox(height: 16),

//               // Selected Image Preview
//               if (_imageFile != null)
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(12),
//                   child: Image.file(
//                     _imageFile!,
//                     height: 180,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               const SizedBox(height: 24),

//               const Text(
//                 'Media Partner Form',
//                 style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 20),

//               // ---------- Form Fields ----------
//               TextFormField(
//                 controller: mobileController,
//                 keyboardType: TextInputType.phone,
//                 decoration: const InputDecoration(
//                   labelText: '*Mobile Number',
//                   prefixText: '+91 ',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (v) =>
//                     (v?.isEmpty ?? true) ? 'Mobile is required' : null,
//               ),
//               const SizedBox(height: 12),

//               TextFormField(
//                 controller: emailController,
//                 keyboardType: TextInputType.emailAddress,
//                 decoration: const InputDecoration(
//                   labelText: 'Email ID',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (v) {
//                   if (v == null || v.isEmpty) return null; // optional
//                   final emailRegex = RegExp(
//                     r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
//                   );
//                   return emailRegex.hasMatch(v) ? null : 'Invalid email';
//                 },
//               ),
//               const SizedBox(height: 12),

//               TextFormField(
//                 controller: businessNameController,
//                 decoration: const InputDecoration(
//                   labelText: 'Business Name',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (v) =>
//                     (v?.isEmpty ?? true) ? 'Business name required' : null,
//               ),
//               const SizedBox(height: 12),

//               TextFormField(
//                 controller: ownerController,
//                 decoration: const InputDecoration(
//                   labelText: 'Owner / Proprietor Name',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (v) =>
//                     (v?.isEmpty ?? true) ? 'Owner name required' : null,
//               ),
//               const SizedBox(height: 12),

//               TextFormField(
//                 controller: productController,
//                 decoration: const InputDecoration(
//                   labelText: 'Products / Services',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (v) =>
//                     (v?.isEmpty ?? true) ? 'Products/Services required' : null,
//               ),
//               const SizedBox(height: 12),

//               TextFormField(
//                 controller: addressController,
//                 maxLines: 3,
//                 decoration: const InputDecoration(
//                   labelText: 'Address',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (v) =>
//                     (v?.isEmpty ?? true) ? 'Address required' : null,
//               ),
//               const SizedBox(height: 12),

//               Row(
//                 children: [
//                   Expanded(
//                     child: TextFormField(
//                       controller: cityController,
//                       decoration: const InputDecoration(
//                         labelText: 'City',
//                         border: OutlineInputBorder(),
//                       ),
//                       validator: (v) =>
//                           (v?.isEmpty ?? true) ? 'City required' : null,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: TextFormField(
//                       controller: pincodeController,
//                       keyboardType: TextInputType.number,
//                       decoration: const InputDecoration(
//                         labelText: 'Pincode',
//                         border: OutlineInputBorder(),
//                       ),
//                       validator: (v) {
//                         if (v == null || v.isEmpty) return 'Pincode required';
//                         return v.length == 6 ? null : 'Must be 6 digits';
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 32),

//               // Submit Button
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.deepPurple,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                 ),
//                 onPressed: _submitForm,
//                 child: const Text(
//                   'Submit Form',
//                   style: TextStyle(fontSize: 18, color: Colors.white),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     // Close ML Kit first
//     textRecognizer.close();

//     // Then dispose controllers
//     mobileController.dispose();
//     emailController.dispose();
//     businessNameController.dispose();
//     addressController.dispose();
//     cityController.dispose();
//     pincodeController.dispose();
//     ownerController.dispose();
//     productController.dispose();

//     super.dispose();
//   }
// }
