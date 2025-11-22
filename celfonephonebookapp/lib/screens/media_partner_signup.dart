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
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
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
  String? businessPrefix = "M/s.";

  // Image picker
  final ImagePicker _picker = ImagePicker();
  List<File> _selectedImages = [];

  // OCR
  final TextRecognizer _textRecognizer = TextRecognizer();
  File? _ocrImageFile;
  bool _ocrRunning = false;

  // Mobile validation
  Timer? _debounce;
  bool _isCheckingMobile = false;
  bool _mobileExists = false;
  String? _mobileMsg;
  String _lastCheckToken = "";

  // Help visibility flags
  bool _mobileHelpVisible = false;
  bool _emailHelpVisible = false;
  bool _cityHelpVisible = false;
  bool _pincodeHelpVisible = false;
  bool _addressHelpVisible = false;
  bool _personNameHelpVisible = false;
  bool _businessNameHelpVisible = false;
  bool _professionHelpVisible = false;
  bool _landlineCodeHelpVisible = false;
  bool _landlineHelpVisible = false;

  // Prefix removal flags
  bool _mobilePrefixRemoved = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _textRecognizer.close();
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

  // ────────────────────── Mobile Check ──────────────────────
  void _onMobileChanged(String value) {
    _debounce?.cancel();
    setState(() {
      _mobileMsg = null;
      _mobileExists = false;
    });

    final trimmed = value.trim();
    final isPatternOk = RegExp(r'^[6-9]\d{9}$').hasMatch(trimmed);
    if (!isPatternOk) return;

    _debounce = Timer(const Duration(milliseconds: 600), () {
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
      if (mounted && _lastCheckToken == checkToken) {
        setState(() => _isCheckingMobile = false);
      }
    }
  }

  // ────────────────────── Image Picker ──────────────────────
  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 75);
    if (picked.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(picked.map((x) => File(x.path)));
      });
    }
  }

  void _removeImage(int index) {
    setState(() => _selectedImages.removeAt(index));
  }

  // ────────────────────── OCR (Business Only) ──────────────────────
  Future<void> _pickOcrImage(ImageSource source) async {
    if (!_isPersonSelected) {
      final picked = await _picker.pickImage(source: source, imageQuality: 85);
      if (picked == null) return;
      final file = File(picked.path);
      setState(() {
        _ocrImageFile = file;
        _ocrRunning = true;
      });
      await _runOcrAndFill(file);
      setState(() => _ocrRunning = false);
    }
  }

  Future<void> _runOcrAndFill(File image) async {
    try {
      final inputImage = InputImage.fromFile(image);
      final recognized = await _textRecognizer.processImage(inputImage);
      final rawText = recognized.text;

      if (rawText.trim().isEmpty) {
        _showAlert('OCR', 'No text detected in the image.');
        return;
      }

      final extracted = _extractFields(rawText);

      if (mobileController.text.isEmpty)
        mobileController.text = extracted.mobile ?? '';
      if (emailController.text.isEmpty)
        emailController.text = extracted.email ?? '';
      if (businessNameController.text.isEmpty)
        businessNameController.text = extracted.business ?? '';
      if (addressController.text.isEmpty)
        addressController.text = extracted.address ?? '';
      if (cityController.text.isEmpty)
        cityController.text = extracted.city ?? '';
      if (pincodeController.text.isEmpty)
        pincodeController.text = extracted.pincode ?? '';
      if (personNameController.text.isEmpty)
        personNameController.text = extracted.owner ?? '';
      if (professionController.text.isEmpty)
        professionController.text = extracted.products ?? '';

      _showOcrResult(rawText, extracted);
    } catch (e) {
      _showAlert('Error', 'OCR failed: $e');
    }
  }

  // ────────────────────── SMART OCR EXTRACTION (HIGH ACCURACY) ──────────────────────
  ({
    String? mobile,
    String? email,
    String? business,
    String? owner,
    String? products,
    String? address,
    String? city,
    String? pincode,
  })
  _extractFields(String rawText) {
    final lines = rawText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      return (
        mobile: null,
        email: null,
        business: null,
        owner: null,
        products: null,
        address: null,
        city: null,
        pincode: null,
      );
    }

    final lowerText = rawText.toLowerCase();
    String? mobile, email, business, owner, products, address, city, pincode;

    // 1. MOBILE
    final mobilePatterns = [
      RegExp(r'\+91[\s\-]?(\d{5}[\s\-]?\d{5})'),
      RegExp(r'91[\s\-]?(\d{5}[\s\-]?\d{5})'),
      RegExp(r'0?(\d{5}[\s\-]?\d{5})'),
      RegExp(r'\((\d{3,5})\)\s*\d{3,4}[\s\-]?\d{4}'),
      RegExp(r'(\d{3,5})[\s\-]?\d{3,4}[\s\-]?\d{4}'),
    ];

    for (final pattern in mobilePatterns) {
      final match = pattern.firstMatch(rawText);
      if (match != null) {
        final digits = match.group(1)!.replaceAll(RegExp(r'\D'), '');
        if (digits.length == 10) {
          mobile = digits;
          break;
        }
      }
    }

    // 2. EMAIL
    final emailMatch = RegExp(
      r'\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\b',
    ).firstMatch(rawText);
    if (emailMatch != null) {
      final candidate = emailMatch.group(0)!;
      if (!candidate.contains('..') && !candidate.endsWith('.')) {
        email = candidate;
      }
    }

    // 3. PINCODE + CITY
    final pinMatch = RegExp(r'\b\d{6}\b').firstMatch(rawText);
    if (pinMatch != null) {
      pincode = pinMatch.group(0);
      final pinLine = lines.firstWhere(
        (l) => l.contains(pincode!),
        orElse: () => '',
      );
      if (pinLine.isNotEmpty) {
        final parts = pinLine
            .split(RegExp(r'[\s,]+'))
            .map((s) => s.trim())
            .toList();
        final pinIndex = parts.indexWhere((p) => p == pincode);
        if (pinIndex > 0) {
          final before = parts.sublist(0, pinIndex);
          city = before.lastWhere(
            (word) => word.length > 2 && !RegExp(r'\d').hasMatch(word),
            orElse: () => before.isNotEmpty ? before.last : '',
          );
        }
      }
    }

    // 4. OWNER NAME
    final titlePatterns = [
      RegExp(
        r'\b(Mr\.?|Ms\.?|Mrs\.?|Dr\.?|Shri\.?|Smt\.?)\s+([A-Za-z\s]+)',
        caseSensitive: false,
      ),
      RegExp(
        r'\b(Proprietor|Owner|Contact Person|Partner|Director|CEO)\s*[:\-]?\s*([A-Za-z\s]+)',
        caseSensitive: false,
      ),
    ];

    for (final pattern in titlePatterns) {
      final match = pattern.firstMatch(rawText);
      if (match != null) {
        owner = match.group(2)!.trim();
        break;
      }
    }

    if (owner == null) {
      final firstLine = lines.first;
      if (RegExp(
        r'\b(Mr|Ms|Mrs|Dr|Shri|Smt)\b',
        caseSensitive: false,
      ).hasMatch(firstLine)) {
        owner = firstLine;
      }
    }

    // 5. BUSINESS NAME
    final companyKeywords = [
      'pvt',
      'ltd',
      'llp',
      'inc',
      'corp',
      'solutions',
      'enterprises',
      'industries',
      'technologies',
      'agency',
      'company',
      'studio',
      'store',
      'shop',
      'traders',
      'works',
      'infra',
      'buildcon',
    ];

    for (int i = 0; i < lines.length && i < 3; i++) {
      final line = lines[i].toLowerCase();
      if (companyKeywords.any(line.contains)) {
        business = lines[i];
        break;
      }
    }

    if (business == null) {
      final topHalf = lines.take((lines.length / 2).ceil()).toList();
      topHalf.sort((a, b) => b.length.compareTo(a.length));
      business = topHalf.firstWhere(
        (l) =>
            l.length > 10 &&
            !l.contains(mobile ?? '') &&
            !l.contains(email ?? ''),
        orElse: () => '',
      );
      if (business.isEmpty) business = null;
    }

    // 6. PRODUCTS / SERVICES
    final productKeywords = [
      'deal',
      'product',
      'service',
      'manufactur',
      'trader',
      'supplier',
      'distributor',
      'wholesale',
      'retail',
      'sell',
      'provide',
      'offer',
    ];

    for (final line in lines) {
      final lower = line.toLowerCase();
      if (productKeywords.any(lower.contains)) {
        products = line.contains(':')
            ? line.split(':').last.trim()
            : line.trim();
        break;
      }
    }

    // 7. ADDRESS
    final excludePatterns = [
      mobile,
      email,
      pincode,
      owner,
      products,
      business,
    ].whereType<String>().map((s) => s.toLowerCase()).toList();

    final addressCandidates = <String>[];
    StringBuffer current = StringBuffer();

    for (final line in lines) {
      final lower = line.toLowerCase();
      final isExcluded = excludePatterns.any(lower.contains);
      final isShort = line.length < 12;

      if (isExcluded || isShort) {
        if (current.isNotEmpty && current.toString().trim().length > 20) {
          addressCandidates.add(current.toString().trim());
        }
        current.clear();
      } else {
        if (current.isNotEmpty) current.write(' ');
        current.write(line);
      }
    }
    if (current.isNotEmpty && current.toString().trim().length > 20) {
      addressCandidates.add(current.toString().trim());
    }

    if (addressCandidates.isNotEmpty) {
      addressCandidates.sort((a, b) => b.length.compareTo(a.length));
      address = addressCandidates.first;
    }

    // 8. CITY FALLBACK
    if (city == null) {
      final indianCities = [
        'mumbai',
        'delhi',
        'bangalore',
        'bengaluru',
        'kolkata',
        'chennai',
        'hyderabad',
        'pune',
        'ahmedabad',
        'jaipur',
        'surat',
        'lucknow',
        'nagpur',
        'indore',
        'bhopal',
        'coimbatore',
        'vadodara',
        'rajkot',
      ];
      final found = indianCities.firstWhere(
        lowerText.contains,
        orElse: () => '',
      );
      if (found.isNotEmpty) city = found[0].toUpperCase() + found.substring(1);
    }

    return (
      mobile: mobile,
      email: email,
      business: business,
      owner: owner,
      products: products,
      address: address,
      city: city,
      pincode: pincode,
    );
  }

  void _showOcrResult(String raw, var extracted) {
    final buffer = StringBuffer()
      ..writeln('=== Full OCR Text ===')
      ..writeln(raw)
      ..writeln('\n=== Extracted Fields ===')
      ..writeln('Mobile   : ${extracted.mobile ?? "-"}')
      ..writeln('Email    : ${extracted.email ?? "-"}')
      ..writeln('Business : ${extracted.business ?? "-"}')
      ..writeln('Owner    : ${extracted.owner ?? "-"}')
      ..writeln('Products : ${extracted.products ?? "-"}')
      ..writeln('Address  : ${extracted.address ?? "-"}')
      ..writeln('City     : ${extracted.city ?? "-"}')
      ..writeln('Pincode  : ${extracted.pincode ?? "-"}');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('OCR Result'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(child: Text(buffer.toString())),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

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

  // ────────────────────── SUBMIT + NAVIGATE TO EARNINGS ──────────────────────
  Future<void> addProfileRecord() async {
    if (!_formKey.currentState!.validate()) {
      _showAlert("Missing Fields", "Please fill all required fields.");
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
      if (userId == null || userName == null) {
        throw Exception("User not logged in");
      }

      final profile = {
        "mobile_number": mobileController.text.trim(),
        " user_type": _isPersonSelected ? "person" : "business",
        "keywords": keywordsController.text.trim(),
        "landline": landlineController.text.trim(),
        "landline_code": landlineCodeController.text.trim(),
      };

      await SupabaseService.client.from("profiles").insert(profile);

      // Earnings
      int earningsToAdd = 0;
      final hasBasicInfo =
          profile["mobile_number"].toString().isNotEmpty &&
          profile["city"].toString().isNotEmpty &&
          profile["pincode"].toString().isNotEmpty &&
          profile["address"].toString().isNotEmpty &&
          ((_isPersonSelected &&
                  profile["person_name"].toString().isNotEmpty) ||
              (!_isPersonSelected &&
                  profile["business_name"].toString().isNotEmpty));
      if (hasBasicInfo) earningsToAdd += 1;
      if (profile["keywords"].toString().isNotEmpty) earningsToAdd += 1;

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

      final entryName = _isPersonSelected
          ? personNameController.text.trim()
          : businessNameController.text.trim();

      final inserted = await SupabaseService.client
          .from("data_entry_name")
          .insert({
            "user_id": userId,
            "username": userName,
            "entry_name": entryName,
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

      // Reset form
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
      setState(() {
        personPrefix = "Mr.";
        // business = "M/s.";
        _selectedImages.clear();
        _ocrImageFile = null;
        _mobilePrefixRemoved = false;
        _mobileHelpVisible = _emailHelpVisible = _cityHelpVisible =
            _pincodeHelpVisible = _addressHelpVisible = _personNameHelpVisible =
                _businessNameHelpVisible = _professionHelpVisible =
                    _landlineCodeHelpVisible = _landlineHelpVisible = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile saved successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      if (mounted) {
        Navigator.pushNamed(context, '/earning_details');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ────────────────────── Validators ──────────────────────
  String? validateMobile(String? v) {
    if (v == null || v.isEmpty) return "Required";
    if (v.length != 10) return "Exactly 10 digits required";
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(v)) return "Must start with 6-9";
    return null;
  }

  String? validatePincode(String? v) {
    if (v == null || v.isEmpty) return "Required";
    if (!RegExp(r'^\d{6}$').hasMatch(v)) return "Must be 6 digits";
    return null;
  }

  String? mandatory(String? v) =>
      (v?.trim().isEmpty ?? true) ? "Required" : null;

  // ────────────────────── HELP TEXT WIDGET ──────────────────────
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

  // ────────────────────── REUSABLE SMART TEXT FIELD ──────────────────────
  Widget _smartTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String helpText,
    required bool Function() isHelpVisible,
    required VoidCallback onTapShowHelp,
    int maxLines = 1,
    TextInputType? keyboard,
    String? Function(String?)? validator,
    Function(String)? onChanged,
    bool isRequired = true,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final showHelp = isHelpVisible() && controller.text.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboard,
          inputFormatters:
              inputFormatters ??
              (keyboard == TextInputType.phone
                  ? [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(
                        10,
                      ), // ← ENFORCED 10 DIGITS
                    ]
                  : null),
          decoration: InputDecoration(
            labelText: label,
            // prefixText: hasPrefix && !prefixRemoved ? prefixText : null,
            prefixStyle: const TextStyle(fontWeight: FontWeight.bold),
            prefixIcon: Icon(icon, size: 20),
            filled: true,
            fillColor: Colors.white,
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
          onChanged: (v) {
            onChanged?.call(v);
            if (controller.text.isNotEmpty) setState(() {});
          },
          onTap: () {
            // if (hasPrefix &&
            //     !prefixRemoved &&
            //     controller.text.startsWith(prefixText!)) {
            //   final raw = controller.text.substring(prefixText.length);
            //   controller.text = raw;
            //   controller.selection = TextSelection.fromPosition(
            //     TextPosition(offset: raw.length),
            //   );
            //   onPrefixRemoved?.call(true);
            // }
            onTapShowHelp();
          },
          onEditingComplete: () => setState(() {}),
        ),
        _helpText(helpText, showHelp),
      ],
    );
  }

  // ────────────────────── UI ──────────────────────
  @override
  Widget build(BuildContext context) {
    final mobile = mobileController.text.trim();
    final mobileValid = RegExp(r'^[6-9]\d{9}$').hasMatch(mobile);

    return Scaffold(
      backgroundColor: const Color(0xfff4f6fa),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Gradient Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 40,
                  horizontal: 20,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xff0072ff), Color(0xff00c6ff)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
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

              // Form Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xfff4f6fa),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // OCR Buttons (Business only)
                        if (!_isPersonSelected) ...[
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _ocrRunning
                                      ? null
                                      : () => _pickOcrImage(ImageSource.camera),
                                  style: ElevatedButton.styleFrom(
                                    elevation: 3,
                                    backgroundColor: const Color(0xffff7043),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    shadowColor: Colors.deepOrange.withOpacity(
                                      0.3,
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.camera_alt_outlined,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        "Scan Card",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _ocrRunning
                                      ? null
                                      : () =>
                                            _pickOcrImage(ImageSource.gallery),
                                  style: ElevatedButton.styleFrom(
                                    elevation: 3,
                                    backgroundColor: const Color(0xff3949ab),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    shadowColor: Colors.indigo.withOpacity(0.3),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.photo_library_outlined,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        "Browse",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  height: 1,
                                  color: Colors.grey.shade400,
                                ),
                                Container(
                                  color: const Color(0xfff4f6fa),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: const Text(
                                    "or",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_ocrImageFile != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _ocrImageFile!,
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          const SizedBox(height: 12),
                        ],

                        // Mobile Field
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _smartTextField(
                            controller: mobileController,
                            label: "Mobile Number *",
                            icon: Icons.phone,
                            helpText:
                                "Enter exactly 10 digits (starts with 6-9)",
                            isHelpVisible: () => _mobileHelpVisible,
                            onTapShowHelp: () =>
                                setState(() => _mobileHelpVisible = true),
                            keyboard: TextInputType.phone,
                            validator: validateMobile,
                            onChanged: _onMobileChanged,
                            // ADD THIS: Limit to exactly 10 digits
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(
                                10,
                              ), // ← NEW: Max 10 chars
                            ],
                          ),
                        ),
                        if (_mobileMsg != null &&
                            !(_mobileHelpVisible &&
                                mobileController.text.isEmpty))
                          Padding(
                            padding: const EdgeInsets.only(top: 6, left: 20),
                            child: Text(
                              _mobileMsg!,
                              style: TextStyle(
                                fontSize: 12,
                                color: _mobileExists
                                    ? Colors.red
                                    : Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),

                        // Conditional Fields
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: _isPersonSelected
                                ? _personFields()
                                : _businessFields(),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Images
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildImageSection(),
                        ),

                        const SizedBox(height: 28),

                        // Submit
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildSubmitButton(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // UI Widgets
  Widget _buildModeButton(String title, bool isPerson) {
    final isActive = _isPersonSelected == isPerson;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isPersonSelected = isPerson),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isActive ? const Color(0xff0072ff) : Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
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
      helpText: "Enter full name (e.g. John Doe)",
      isHelpVisible: () => _personNameHelpVisible,
      onTapShowHelp: () => setState(() => _personNameHelpVisible = true),
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
      controller: businessNameController,
      label: "Firm Name",
      icon: Icons.business,
      helpText: "Optional: Enter company name if any",
      isHelpVisible: () => _businessNameHelpVisible,
      onTapShowHelp: () => setState(() => _businessNameHelpVisible = true),
      isRequired: false,
    ),
    const SizedBox(height: 12),
    _smartTextField(
      controller: cityController,
      label: "City *",
      icon: Icons.location_city,
      helpText: "Enter city name (e.g. Mumbai)",
      isHelpVisible: () => _cityHelpVisible,
      onTapShowHelp: () => setState(() => _cityHelpVisible = true),
      validator: mandatory,
    ),
    const SizedBox(height: 12),
    _smartTextField(
      controller: pincodeController,
      label: "Pincode *",
      icon: Icons.pin,
      helpText: "Enter 6-digit pincode",
      isHelpVisible: () => _pincodeHelpVisible,
      onTapShowHelp: () => setState(() => _pincodeHelpVisible = true),
      validator: validatePincode,
      keyboard: TextInputType.number,
    ),
    const SizedBox(height: 12),
    _smartTextField(
      controller: addressController,
      label: "Address *",
      icon: Icons.home,
      helpText: "Enter complete address with landmarks",
      isHelpVisible: () => _addressHelpVisible,
      onTapShowHelp: () => setState(() => _addressHelpVisible = true),
      maxLines: 2,
      validator: mandatory,
    ),
    const SizedBox(height: 12),
    _smartTextField(
      controller: professionController,
      label: "Profession",
      icon: Icons.work,
      helpText: "Enter your job or business type",
      isHelpVisible: () => _professionHelpVisible,
      onTapShowHelp: () => setState(() => _professionHelpVisible = true),
      onChanged: (v) => keywordsController.text = v,
      isRequired: false,
    ),
    const SizedBox(height: 12),
    _smartTextField(
      controller: emailController,
      label: "Email",
      icon: Icons.email,
      helpText: "Enter valid email (e.g. name@domain.com)",
      isHelpVisible: () => _emailHelpVisible,
      onTapShowHelp: () => setState(() => _emailHelpVisible = true),
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
            helpText: "Enter area code (e.g. 022)",
            isHelpVisible: () => _landlineCodeHelpVisible,
            onTapShowHelp: () =>
                setState(() => _landlineCodeHelpVisible = true),
            keyboard: TextInputType.number,
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
            helpText: "Enter landline number",
            isHelpVisible: () => _landlineHelpVisible,
            onTapShowHelp: () => setState(() => _landlineHelpVisible = true),
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
      helpText: "Enter full business name",
      isHelpVisible: () => _businessNameHelpVisible,
      onTapShowHelp: () => setState(() => _businessNameHelpVisible = true),
      validator: mandatory,
    ),
    const SizedBox(height: 12),
    _smartTextField(
      controller: personNameController,
      label: "Contact Person",
      icon: Icons.person_outline,
      helpText: "Enter contact person's name",
      isHelpVisible: () => _personNameHelpVisible,
      onTapShowHelp: () => setState(() => _personNameHelpVisible = true),
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
      helpText: "Enter city name (e.g. Mumbai)",
      isHelpVisible: () => _cityHelpVisible,
      onTapShowHelp: () => setState(() => _cityHelpVisible = true),
      validator: mandatory,
    ),
    const SizedBox(height: 12),
    _smartTextField(
      controller: pincodeController,
      label: "Pincode *",
      icon: Icons.pin,
      helpText: "Enter 6-digit pincode",
      isHelpVisible: () => _pincodeHelpVisible,
      onTapShowHelp: () => setState(() => _pincodeHelpVisible = true),
      validator: validatePincode,
      keyboard: TextInputType.number,
    ),
    const SizedBox(height: 12),
    _smartTextField(
      controller: addressController,
      label: "Address *",
      icon: Icons.home,
      helpText: "Enter complete business address",
      isHelpVisible: () => _addressHelpVisible,
      onTapShowHelp: () => setState(() => _addressHelpVisible = true),
      maxLines: 2,
      validator: mandatory,
    ),
    const SizedBox(height: 12),
    _smartTextField(
      controller: professionController,
      label: "Products/Services",
      icon: Icons.category,
      helpText: "List main products or services",
      isHelpVisible: () => _professionHelpVisible,
      onTapShowHelp: () => setState(() => _professionHelpVisible = true),
      onChanged: (v) => keywordsController.text = v,
      isRequired: false,
    ),
    const SizedBox(height: 12),
    _smartTextField(
      controller: emailController,
      label: "Email",
      icon: Icons.email,
      helpText: "Enter business email",
      isHelpVisible: () => _emailHelpVisible,
      onTapShowHelp: () => setState(() => _emailHelpVisible = true),
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
            helpText: "Enter STD code (e.g. 022)",
            isHelpVisible: () => _landlineCodeHelpVisible,
            onTapShowHelp: () =>
                setState(() => _landlineCodeHelpVisible = true),
            keyboard: TextInputType.number,
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
            helpText: "Enter landline number",
            isHelpVisible: () => _landlineHelpVisible,
            onTapShowHelp: () => setState(() => _landlineHelpVisible = true),
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

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Upload Photos (Optional)",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        if (_selectedImages.isEmpty)
          OutlinedButton.icon(
            onPressed: _pickImages,
            icon: const Icon(Icons.add_a_photo),
            label: const Text("Add Images"),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.blueAccent),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          )
        else
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _selectedImages.asMap().entries.map((e) {
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      e.value,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18,
                      ),
                      onPressed: () => _removeImage(e.key),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black54,
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
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
                style: const TextStyle(
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
