// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:image_picker/image_picker.dart';
// import '../supabase/supabase.dart'; // your wrapper

// class ProfilePage extends StatefulWidget {
//   const ProfilePage({super.key});

//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage> {
//   bool _isLoading = false;
//   String? _userId;
//   Map<String, dynamic> _profileData = {};
//   String? _editingField; // track which field is in edit mode
//   final Map<String, TextEditingController> _controllers = {};

//   final ImagePicker _picker = ImagePicker();
//   List<String> _uploadedImages = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadUserProfile();
//   }

//   Future<void> _loadUserProfile() async {
//     setState(() => _isLoading = true);
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       _userId = prefs.getString("userId");

//       if (_userId == null) {
//         debugPrint("⚠️ userId not found in SharedPreferences");
//         return;
//       }

//       final data = await SupabaseService.client
//           .from("profiles")
//           .select()
//           .eq("id", _userId as Object)
//           .maybeSingle();

//       if (data != null) {
//         _profileData = data;
//         for (final field in _profileData.keys) {
//           _controllers[field] = TextEditingController(
//             text: _profileData[field]?.toString() ?? "",
//           );
//         }
//         _uploadedImages = List<String>.from(data['product_image'] ?? []);
//       }
//     } catch (e) {
//       debugPrint("⚠️ Error loading profile: $e");
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   Future<void> _updateField(String fieldName) async {
//     if (_userId == null) return;

//     final newValue = _controllers[fieldName]?.text.trim() ?? "";

//     try {
//       // Build full row data for upsert to avoid NOT NULL constraint errors
//       final upsertData = {
//         "id": _userId!,
//         "business_name": _profileData["business_name"] ?? "",
//         "person_name": _profileData["person_name"] ?? "",
//         "mobile_number": _profileData["mobile_number"] ?? "",
//         "address": _profileData["address"] ?? "",
//         "keywords": _profileData["keywords"] ?? "",
//         "description": _profileData["description"] ?? "",
//         "city": _profileData["city"] ?? "",
//         "pincode": _profileData["pincode"] ?? "",
//         "whats_app": _profileData["whats_app"] ?? "",
//         "email": _profileData["email"] ?? "",
//         "password": _profileData["password"] ?? "",
//         // Add other NOT NULL fields if any
//       };

//       // Update only the edited field
//       upsertData[fieldName] = newValue;

//       // Upsert the complete row
//       await SupabaseService.client.from("profiles").upsert(upsertData);

//       setState(() {
//         _profileData[fieldName] = newValue;
//         _editingField = null;
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("$fieldName updated successfully")),
//       );
//     } catch (e) {
//       debugPrint("⚠️ Failed to update $fieldName: $e");
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Failed to update $fieldName")));
//     }
//   }

//   Future<void> _pickAndUploadImage() async {
//     final picked = await _picker.pickImage(source: ImageSource.gallery);
//     if (picked == null || _userId == null) return;

//     final file = File(picked.path);
//     final fileName = "${DateTime.now().millisecondsSinceEpoch}_${picked.name}";

//     try {
//       final storagePath = "product_images/$_userId/$fileName";
//       await SupabaseService.client.storage
//           .from("uploads") // bucket name in Supabase
//           .upload(storagePath, file);

//       final publicUrl = SupabaseService.client.storage
//           .from("uploads")
//           .getPublicUrl(storagePath);

//       _uploadedImages.add(publicUrl);

//       // update array column in profiles
//       await SupabaseService.client
//           .from("profiles")
//           .update({"product_image": _uploadedImages})
//           .eq("id", _userId!);

//       setState(() {});
//     } catch (e) {
//       debugPrint("⚠️ Image upload failed: $e");
//     }
//   }

//   Widget _buildField(String label, String fieldName) {
//     // Ensure controller exists
//     if (!_controllers.containsKey(fieldName)) {
//       _controllers[fieldName] = TextEditingController(
//         text: _profileData[fieldName]?.toString() ?? "",
//       );
//     }

//     final controller = _controllers[fieldName]!;
//     final value = controller.text;
//     final displayValue = value.isEmpty ? "<empty>" : value;
//     final isEditing = _editingField == fieldName;

//     return ListTile(
//       title: isEditing
//           ? TextField(
//               controller: controller,
//               autofocus: true,
//               decoration: InputDecoration(
//                 labelText: label,
//                 hintText: "Enter $label",
//               ),
//               onSubmitted: (_) {
//                 _updateField(fieldName); // Save when Enter is pressed
//               },
//             )
//           : Text("$label: $displayValue"),
//       trailing: IconButton(
//         icon: Icon(
//           isEditing ? Icons.check : Icons.edit,
//           color: isEditing ? Colors.green : Colors.blue,
//         ),
//         onPressed: () {
//           if (isEditing) {
//             _updateField(fieldName); // Save edited value
//           } else {
//             setState(() => _editingField = fieldName);
//           }
//         },
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Profile")),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : RefreshIndicator(
//               onRefresh: _loadUserProfile,
//               child: ListView(
//                 padding: const EdgeInsets.all(8),
//                 children: [
//                   _buildField("Busines Name", "business_name"),
//                   _buildField("Person Name", "person_name"),
//                   // _buildField("Mobile Number", "mobile_number"),
//                   _buildField("Address", "address"),
//                   _buildField("Keywords", "keywords"),
//                   // _buildField("Description", "description"),
//                   _buildField("City", "city"),
//                   _buildField("Pincode", "pincode"),
//                   _buildField("WhatsApp", "whats_app"),
//                   _buildField("Email", "email"),
//                   // _buildField("Password", "password"),
//                   // const Divider(),
//                   // const Text("Product Images",
//                   //     style:
//                   //     TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//                   // Wrap(
//                   //   spacing: 8,
//                   //   runSpacing: 8,
//                   //   children: [
//                   //     ..._uploadedImages.map(
//                   //           (url) => ClipRRect(
//                   //         borderRadius: BorderRadius.circular(8),
//                   //         child: Image.network(url,
//                   //             width: 100, height: 100, fit: BoxFit.cover),
//                   //       ),
//                   //     ),
//                   //     GestureDetector(
//                   //       onTap: _pickAndUploadImage,
//                   //       child: Container(
//                   //         width: 100,
//                   //         height: 100,
//                   //         decoration: BoxDecoration(
//                   //           border: Border.all(color: Colors.grey),
//                   //           borderRadius: BorderRadius.circular(8),
//                   //         ),
//                   //         child: const Icon(Icons.add_a_photo),
//                   //       ),
//                   //     )
//                   //   ],
//                   // ),
//                 ],
//               ),
//             ),
//     );
//   }
// }
//new
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:image_picker/image_picker.dart';
// import '../supabase/supabase.dart'; // your wrapper

// class ProfilePage extends StatefulWidget {
//   const ProfilePage({super.key});

//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage> {
//   bool _isLoading = false;
//   String? _userId;
//   Map<String, dynamic> _profileData = {};
//   String? _editingField;
//   final Map<String, TextEditingController> _controllers = {};
//   final ImagePicker _picker = ImagePicker();
//   List<String> _uploadedImages = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadUserProfile();
//   }

//   Future<void> _loadUserProfile() async {
//     setState(() => _isLoading = true);
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       _userId = prefs.getString("userId");

//       if (_userId == null) {
//         _showSnackBar("User ID not found", Colors.red);
//         return;
//       }

//       final data = await SupabaseService.client
//           .from("profiles")
//           .select()
//           .eq("id", _userId as Object)
//           .maybeSingle();

//       if (data != null) {
//         _profileData = data;
//         for (final field in _profileData.keys) {
//           _controllers[field] = TextEditingController(
//             text: _profileData[field]?.toString() ?? "",
//           );
//         }
//         _uploadedImages = List<String>.from(data['product_image'] ?? []);
//       }
//     } catch (e) {
//       _showSnackBar("Error loading profile: $e", Colors.red);
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   Future<void> _updateField(String fieldName) async {
//     if (_userId == null) return;

//     final newValue = _controllers[fieldName]?.text.trim() ?? "";
//     try {
//       final upsertData = {
//         "id": _userId!,
//         "business_name": _profileData["business_name"] ?? "",
//         "person_name": _profileData["person_name"] ?? "",
//         "mobile_number": _profileData["mobile_number"] ?? "",
//         "address": _profileData["address"] ?? "",
//         "keywords": _profileData["keywords"] ?? "",
//         "description": _profileData["description"] ?? "",
//         "city": _profileData["city"] ?? "",
//         "pincode": _profileData["pincode"] ?? "",
//         "whats_app": _profileData["whats_app"] ?? "",
//         "email": _profileData["email"] ?? "",
//         "password": _profileData["password"] ?? "",
//       };
//       upsertData[fieldName] = newValue;

//       await SupabaseService.client.from("profiles").upsert(upsertData);

//       setState(() {
//         _profileData[fieldName] = newValue;
//         _editingField = null;
//       });
//       _showSnackBar("$fieldName updated successfully", Colors.green);
//     } catch (e) {
//       _showSnackBar("Failed to update $fieldName", Colors.red);
//     }
//   }

//   Future<void> _pickAndUploadImage() async {
//     final picked = await _picker.pickImage(source: ImageSource.gallery);
//     if (picked == null || _userId == null) return;

//     final file = File(picked.path);
//     final fileName = "${DateTime.now().millisecondsSinceEpoch}_${picked.name}";

//     try {
//       final storagePath = "product_images/$_userId/$fileName";
//       await SupabaseService.client.storage
//           .from("uploads")
//           .upload(storagePath, file);

//       final publicUrl = SupabaseService.client.storage
//           .from("uploads")
//           .getPublicUrl(storagePath);

//       _uploadedImages.add(publicUrl);
//       await SupabaseService.client
//           .from("profiles")
//           .update({"product_image": _uploadedImages})
//           .eq("id", _userId!);

//       setState(() {});
//       _showSnackBar("Image uploaded successfully", Colors.green);
//     } catch (e) {
//       _showSnackBar("Image upload failed: $e", Colors.red);
//     }
//   }

//   Future<void> _deleteImage(String url) async {
//     if (_userId == null) return;
//     try {
//       _uploadedImages.remove(url);
//       await SupabaseService.client
//           .from("profiles")
//           .update({"product_image": _uploadedImages})
//           .eq("id", _userId!);
//       setState(() {});
//       _showSnackBar("Image deleted successfully", Colors.green);
//     } catch (e) {
//       _showSnackBar("Failed to delete image", Colors.red);
//     }
//   }

//   void _showSnackBar(String message, Color color) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: color,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//       ),
//     );
//   }

//   Widget _buildField(String label, String fieldName) {
//     if (!_controllers.containsKey(fieldName)) {
//       _controllers[fieldName] = TextEditingController(
//         text: _profileData[fieldName]?.toString() ?? "",
//       );
//     }

//     final controller = _controllers[fieldName]!;
//     final value = controller.text;
//     final displayValue = value.isEmpty ? "<empty>" : value;
//     final isEditing = _editingField == fieldName;

//     return Card(
//       elevation: 2,
//       margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Row(
//           children: [
//             Expanded(
//               child: isEditing
//                   ? TextField(
//                       controller: controller,
//                       autofocus: true,
//                       decoration: InputDecoration(
//                         labelText: label,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         filled: true,
//                         fillColor: Colors.grey[100],
//                       ),
//                       onSubmitted: (_) => _updateField(fieldName),
//                     )
//                   : Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           label,
//                           style: TextStyle(
//                             color: Colors.grey[600],
//                             fontSize: 14,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           displayValue,
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                     ),
//             ),
//             IconButton(
//               icon: Icon(
//                 isEditing ? Icons.check_circle : Icons.edit,
//                 color: isEditing ? Colors.teal : Colors.blue,
//               ),
//               onPressed: () {
//                 if (isEditing) {
//                   _updateField(fieldName);
//                 } else {
//                   setState(() => _editingField = fieldName);
//                 }
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Colors.blue[700]!, Colors.blue[400]!],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: const BorderRadius.only(
//           bottomLeft: Radius.circular(20),
//           bottomRight: Radius.circular(20),
//         ),
//       ),
//       child: Column(
//         children: [
//           CircleAvatar(
//             radius: 50,
//             backgroundColor: Colors.white,
//             child: _profileData["business_name"] != null
//                 ? Text(
//                     _profileData["business_name"].toString()[0].toUpperCase(),
//                     style: const TextStyle(fontSize: 40, color: Colors.blue),
//                   )
//                 : const Icon(Icons.person, size: 50, color: Colors.blue),
//           ),
//           const SizedBox(height: 12),
//           Text(
//             _profileData["business_name"] ?? "Your Profile",
//             style: const TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             _profileData["email"] ?? "email@example.com",
//             style: const TextStyle(fontSize: 16, color: Colors.white70),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildImageGallery() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           child: Text(
//             "Product Images",
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.blue[800],
//             ),
//           ),
//         ),
//         SizedBox(
//           height: 120,
//           child: ListView(
//             scrollDirection: Axis.horizontal,
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             children: [
//               ..._uploadedImages.map(
//                 (url) => Stack(
//                   children: [
//                     Container(
//                       margin: const EdgeInsets.only(right: 8),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(8),
//                         child: Image.network(
//                           url,
//                           width: 100,
//                           height: 100,
//                           fit: BoxFit.cover,
//                           errorBuilder: (context, error, stackTrace) =>
//                               const Icon(Icons.broken_image, size: 50),
//                         ),
//                       ),
//                     ),
//                     Positioned(
//                       top: 0,
//                       right: 8,
//                       child: IconButton(
//                         icon: const Icon(Icons.delete, color: Colors.red),
//                         onPressed: () => _deleteImage(url),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               GestureDetector(
//                 onTap: _pickAndUploadImage,
//                 child: Container(
//                   width: 100,
//                   height: 100,
//                   margin: const EdgeInsets.only(right: 8),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey),
//                     borderRadius: BorderRadius.circular(8),
//                     color: Colors.grey[200],
//                   ),
//                   child: const Icon(Icons.add_a_photo, color: Colors.grey),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Your Profile"),
//         backgroundColor: Colors.blue[700],
//         elevation: 0,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : RefreshIndicator(
//               onRefresh: _loadUserProfile,
//               child: CustomScrollView(
//                 slivers: [
//                   SliverToBoxAdapter(child: _buildHeader()),
//                   SliverToBoxAdapter(child: const SizedBox(height: 16)),
//                   SliverList(
//                     delegate: SliverChildListDelegate([
//                       _buildField("Business Name", "business_name"),
//                       _buildField("Person Name", "person_name"),
//                       _buildField("Address", "address"),
//                       _buildField("Keywords", "keywords"),
//                       _buildField("City", "city"),
//                       _buildField("Pincode", "pincode"),
//                       _buildField("WhatsApp", "whats_app"),
//                       _buildField("Email", "email"),
//                     ]),
//                   ),
//                   SliverToBoxAdapter(child: _buildImageGallery()),
//                   SliverToBoxAdapter(child: const SizedBox(height: 80)),
//                 ],
//               ),
//             ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _pickAndUploadImage,
//         backgroundColor: Colors.teal,
//         child: const Icon(Icons.add_a_photo),
//       ),
//     );
//   }
// }

//new2

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:percent_indicator/circular_percent_indicator.dart';
// import '../supabase/supabase.dart'; // your Supabase wrapper

// class ProfilePage extends StatefulWidget {
//   const ProfilePage({super.key});

//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage> {
//   bool _isLoading = false;
//   String? _userId;
//   Map<String, dynamic> _profileData = {};
//   String? _editingField;
//   final Map<String, TextEditingController> _controllers = {};
//   final ImagePicker _picker = ImagePicker();
//   List<String> _uploadedImages = [];
//   double _profileCompletion = 0.0;

//   @override
//   void initState() {
//     super.initState();
//     _loadUserProfile();
//   }

//   Future<void> _loadUserProfile() async {
//     setState(() => _isLoading = true);
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       _userId = prefs.getString("userId");

//       if (_userId == null) {
//         _showSnackBar("User ID not found", Icons.error, Colors.red);
//         return;
//       }

//       final data = await SupabaseService.client
//           .from("profiles")
//           .select()
//           .eq("id", _userId as Object)
//           .maybeSingle();

//       if (data != null) {
//         _profileData = data;
//         for (final field in _profileData.keys) {
//           _controllers[field] = TextEditingController(
//             text: _profileData[field]?.toString() ?? "",
//           );
//         }
//         _uploadedImages = List<String>.from(data['product_image'] ?? []);
//         _calculateProfileCompletion();
//       }
//     } catch (e) {
//       _showSnackBar("Error loading profile: $e", Icons.error, Colors.red);
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   void _calculateProfileCompletion() {
//     const relevantFields = [
//       'business_name',
//       'person_name',
//       'mobile_number',
//       'address',
//       'keywords',
//       'description',
//       'city',
//       'pincode',
//       'whats_app',
//       'email',
//     ];
//     int filledFields = relevantFields
//         .where(
//           (field) =>
//               _profileData[field] != null &&
//               _profileData[field].toString().trim().isNotEmpty,
//         )
//         .length;
//     // Add bonus for images if any exist
//     if (_uploadedImages.isNotEmpty) filledFields += 1;
//     final totalFields = relevantFields.length + 1; // +1 for images
//     _profileCompletion = (filledFields / totalFields) * 100;
//   }

//   Future<void> _updateField(String fieldName) async {
//     if (_userId == null) return;

//     final newValue = _controllers[fieldName]?.text.trim() ?? "";
//     try {
//       final upsertData = {
//         "id": _userId!,
//         "business_name": _profileData["business_name"] ?? "",
//         "person_name": _profileData["person_name"] ?? "",
//         "mobile_number": _profileData["mobile_number"] ?? "",
//         "address": _profileData["address"] ?? "",
//         "keywords": _profileData["keywords"] ?? "",
//         "description": _profileData["description"] ?? "",
//         "city": _profileData["city"] ?? "",
//         "pincode": _profileData["pincode"] ?? "",
//         "whats_app": _profileData["whats_app"] ?? "",
//         "email": _profileData["email"] ?? "",
//         "password": _profileData["password"] ?? "",
//       };
//       upsertData[fieldName] = newValue;

//       await SupabaseService.client.from("profiles").upsert(upsertData);

//       setState(() {
//         _profileData[fieldName] = newValue;
//         _editingField = null;
//         _calculateProfileCompletion();
//       });
//       _showSnackBar(
//         "$fieldName updated successfully",
//         Icons.check,
//         Colors.green,
//       );
//     } catch (e) {
//       _showSnackBar("Failed to update $fieldName", Icons.error, Colors.red);
//     }
//   }

//   Future<void> _pickAndUploadImage() async {
//     final picked = await _picker.pickImage(source: ImageSource.gallery);
//     if (picked == null || _userId == null) return;

//     final file = File(picked.path);
//     final fileName = "${DateTime.now().millisecondsSinceEpoch}_${picked.name}";

//     try {
//       final storagePath = "product_images/$_userId/$fileName";
//       await SupabaseService.client.storage
//           .from("uploads")
//           .upload(storagePath, file);

//       final publicUrl = SupabaseService.client.storage
//           .from("uploads")
//           .getPublicUrl(storagePath);

//       _uploadedImages.add(publicUrl);
//       await SupabaseService.client
//           .from("profiles")
//           .update({"product_image": _uploadedImages})
//           .eq("id", _userId!);

//       setState(() {
//         _calculateProfileCompletion();
//       });
//       _showSnackBar("Image uploaded successfully", Icons.check, Colors.green);
//     } catch (e) {
//       _showSnackBar("Image upload failed: $e", Icons.error, Colors.red);
//     }
//   }

//   Future<void> _deleteImage(String url) async {
//     if (_userId == null) return;
//     try {
//       _uploadedImages.remove(url);
//       await SupabaseService.client
//           .from("profiles")
//           .update({"product_image": _uploadedImages})
//           .eq("id", _userId!);
//       setState(() {
//         _calculateProfileCompletion();
//       });
//       _showSnackBar("Image deleted successfully", Icons.check, Colors.green);
//     } catch (e) {
//       _showSnackBar("Failed to delete image", Icons.error, Colors.red);
//     }
//   }

//   void _showSnackBar(String message, IconData icon, Color color) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(icon, color: Colors.white),
//             const SizedBox(width: 8),
//             Expanded(child: Text(message)),
//           ],
//         ),
//         backgroundColor: color,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         duration: const Duration(seconds: 3),
//       ),
//     );
//   }

//   Widget _buildField(String label, String fieldName, IconData icon) {
//     if (!_controllers.containsKey(fieldName)) {
//       _controllers[fieldName] = TextEditingController(
//         text: _profileData[fieldName]?.toString() ?? "",
//       );
//     }

//     final controller = _controllers[fieldName]!;
//     final value = controller.text;
//     final displayValue = value.isEmpty ? "<empty>" : value;
//     final isEditing = _editingField == fieldName;

//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         curve: Curves.easeInOut,
//         decoration: BoxDecoration(
//           color: isEditing ? Colors.white : Colors.grey[100],
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.2),
//               blurRadius: 6,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: ListTile(
//           leading: Icon(icon, color: const Color.fromARGB(255, 27, 79, 194)),
//           title: isEditing
//               ? TextField(
//                   controller: controller,
//                   autofocus: true,
//                   decoration: InputDecoration(
//                     labelText: label,
//                     border: InputBorder.none,
//                     contentPadding: const EdgeInsets.symmetric(horizontal: 16),
//                   ),
//                   onSubmitted: (_) => _updateField(fieldName),
//                 )
//               : Text(displayValue, style: const TextStyle(fontSize: 16)),
//           trailing: IconButton(
//             icon: Icon(
//               isEditing ? Icons.check_circle : Icons.edit,
//               color: isEditing ? Colors.amber : Colors.purple[700],
//             ),
//             onPressed: () {
//               if (isEditing) {
//                 _updateField(fieldName);
//               } else {
//                 setState(() => _editingField = fieldName);
//               }
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.purple[700],
//         borderRadius: const BorderRadius.only(
//           bottomLeft: Radius.circular(24),
//           bottomRight: Radius.circular(24),
//         ),
//       ),
//       child: Row(
//         children: [
//           CircleAvatar(
//             radius: 40,
//             backgroundColor: Colors.amber[200],
//             child: _profileData["business_name"] != null
//                 ? Text(
//                     _profileData["business_name"].toString()[0].toUpperCase(),
//                     style: TextStyle(fontSize: 32, color: Colors.purple[800]),
//                   )
//                 : const Icon(Icons.person, size: 40, color: Colors.purple),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   _profileData["business_name"] ?? "Your Profile",
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   _profileData["email"] ?? "email@example.com",
//                   style: const TextStyle(fontSize: 14, color: Colors.white70),
//                 ),
//               ],
//             ),
//           ),
//           Tooltip(
//             message: "Complete your profile by filling all fields",
//             child: CircularPercentIndicator(
//               radius: 30.0,
//               lineWidth: 6.0,
//               percent: _profileCompletion / 100,
//               center: Text(
//                 "${_profileCompletion.round()}%",
//                 style: const TextStyle(color: Colors.white, fontSize: 14),
//               ),
//               progressColor: Colors.amber,
//               backgroundColor: Colors.white24,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildImageGallery() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           child: Text(
//             "Product Images",
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.purple[800],
//             ),
//           ),
//         ),
//         SizedBox(
//           height: 140,
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             itemCount: _uploadedImages.length + 1,
//             itemBuilder: (context, index) {
//               if (index == _uploadedImages.length) {
//                 return GestureDetector(
//                   onTap: _pickAndUploadImage,
//                   child: Container(
//                     width: 120,
//                     height: 120,
//                     margin: const EdgeInsets.only(right: 8),
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey),
//                       borderRadius: BorderRadius.circular(12),
//                       color: Colors.grey[200],
//                     ),
//                     child: const Icon(Icons.add_a_photo, color: Colors.grey),
//                   ),
//                 );
//               }
//               final url = _uploadedImages[index];
//               return Stack(
//                 children: [
//                   Container(
//                     margin: const EdgeInsets.only(right: 8),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(12),
//                       child: Image.network(
//                         url,
//                         width: 120,
//                         height: 120,
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) =>
//                             const Icon(Icons.broken_image, size: 50),
//                       ),
//                     ),
//                   ),
//                   Positioned(
//                     top: 0,
//                     right: 8,
//                     child: IconButton(
//                       icon: const Icon(Icons.delete, color: Colors.red),
//                       onPressed: () => _deleteImage(url),
//                     ),
//                   ),
//                 ],
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Profile"),
//         backgroundColor: Colors.purple[700],
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _loadUserProfile,
//             tooltip: "Refresh Profile",
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : CustomScrollView(
//               slivers: [
//                 SliverToBoxAdapter(child: _buildHeader()),
//                 SliverToBoxAdapter(child: const SizedBox(height: 16)),
//                 SliverList(
//                   delegate: SliverChildListDelegate([
//                     _buildField(
//                       "Business Name",
//                       "business_name",
//                       Icons.business,
//                     ),
//                     _buildField("Person Name", "person_name", Icons.person),
//                     _buildField("Mobile Number", "mobile_number", Icons.phone),
//                     _buildField("Address", "address", Icons.location_on),
//                     _buildField("Keywords", "keywords", Icons.tag),
//                     _buildField(
//                       "Description",
//                       "description",
//                       Icons.description,
//                     ),
//                     _buildField("City", "city", Icons.location_city),
//                     _buildField("Pincode", "pincode", Icons.pin_drop),
//                     _buildField("WhatsApp", "whats_app", Icons.chat),
//                     _buildField("Email", "email", Icons.email),
//                   ]),
//                 ),
//                 SliverToBoxAdapter(child: _buildImageGallery()),
//                 SliverToBoxAdapter(child: const SizedBox(height: 80)),
//               ],
//             ),
//       // floatingActionButton: ScaleTransition(
//       //   scale: Tween<double>(begin: 1.0, end: 1.2).animate(
//       //     CurvedAnimation(
//       //       parent: AnimationController(
//       //         vsync: Navigator.of(context),
//       //         duration: const Duration(milliseconds: 200),
//       //       )..repeat(reverse: true),
//       //       curve: Curves.easeInOut,
//       //     ),
//       //   ),
//       //   child: FloatingActionButton(
//       //     onPressed: _pickAndUploadImage,
//       //     backgroundColor: Colors.amber,
//       //     child: const Icon(Icons.add_a_photo),
//       //     tooltip: "Add Product Image",
//       //   ),
//       // ),
//     );
//   }
// }
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../supabase/supabase.dart';

// ---------------------------------------------------------------------
// Helper: Title case
// ---------------------------------------------------------------------
extension StringCasing on String {
  String toTitleCase() =>
      split(' ').map((s) => s[0].toUpperCase() + s.substring(1)).join(' ');
}

// ---------------------------------------------------------------------
// MAIN PAGE
// ---------------------------------------------------------------------
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // ------------------- STATE -------------------
  bool _isLoading = false;
  String? _userId;
  Map<String, dynamic> _profileData = {};
  bool _isBulkEditing = false; // Only bulk edit mode
  final Map<String, TextEditingController> _controllers = {};
  final ImagePicker _picker = ImagePicker();
  List<String> _uploadedImages = [];
  double _profileCompletion = 0.0;

  // ------------------- COLORS (NO PURPLE, NO GRADIENT) -------------------
  static const Color primaryColor = Color(0xFF00695C); // Deep Teal
  static const Color accentColor = Color(0xFFFFC107); // Amber
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;

  // ------------------- EXCLUDED FIELDS -------------------
  final Set<String> _excludedFields = {
    'created_at',
    'user_type',
    'mobile_number',
    'promo_code',
    'isprime',
    'is_admin',
    'updated_at',
    'activity',
    'discount',
    'priority',
  };

  // ------------------- EDITABLE FIELDS -------------------
  final List<String> _editableFields = [
    'business_name',
    'person_name',
    'address',
    'keywords',
    'description',
    'city',
    'pincode',
    'whats_app',
    'email',
  ];

  // ------------------- LIFECYCLE -------------------
  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // ------------------- LOAD PROFILE -------------------
  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getString("userId");

      if (_userId == null) {
        _showSnackBar("User ID not found", Icons.error, Colors.red);
        return;
      }

      final data = await SupabaseService.client
          .from("profiles")
          .select()
          .eq("id", _userId as Object)
          .maybeSingle();

      if (data != null) {
        _profileData = data;
        _initControllers();
        _uploadedImages = List<String>.from(data['product_image'] ?? []);
        _calculateProfileCompletion();
      }
    } catch (e) {
      _showSnackBar("Error loading profile: $e", Icons.error, Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _initControllers() {
    for (final field in _editableFields) {
      _controllers[field] = TextEditingController(
        text: _profileData[field]?.toString() ?? "",
      );
    }
  }

  // ------------------- PROFILE COMPLETION -------------------
  void _calculateProfileCompletion() {
    int filled = _editableFields
        .where(
          (f) =>
              _profileData[f] != null &&
              _profileData[f].toString().trim().isNotEmpty,
        )
        .length;

    if (_uploadedImages.isNotEmpty) filled++;

    final total = _editableFields.length + 1;
    _profileCompletion = (filled / total) * 100;
  }

  void _refreshCompletion() => setState(_calculateProfileCompletion);

  // ------------------- BULK SAVE -------------------
  Future<void> _saveAllFields() async {
    if (_userId == null) return;

    try {
      final updateMap = <String, dynamic>{};
      for (final field in _editableFields) {
        final value = _controllers[field]?.text.trim() ?? "";
        updateMap[field] = value;
        _profileData[field] = value;
      }

      await SupabaseService.client
          .from("profiles")
          .update(updateMap)
          .eq("id", _userId!);

      setState(() {
        _isBulkEditing = false;
        _refreshCompletion();
      });
      _showSnackBar("Profile updated successfully!", Icons.check, Colors.green);
    } catch (e) {
      _showSnackBar("Save failed: $e", Icons.error, Colors.red);
    }
  }

  // ------------------- IMAGE UPLOAD -------------------
  Future<void> _pickAndUploadImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null || _userId == null) return;

    final file = File(picked.path);
    final fileName = "${DateTime.now().millisecondsSinceEpoch}_${picked.name}";

    try {
      final storagePath = "product_images/$_userId/$fileName";
      await SupabaseService.client.storage
          .from("uploads")
          .upload(storagePath, file);

      final publicUrl = SupabaseService.client.storage
          .from("uploads")
          .getPublicUrl(storagePath);

      _uploadedImages.add(publicUrl);
      await SupabaseService.client
          .from("profiles")
          .update({"product_image": _uploadedImages})
          .eq("id", _userId!);

      setState(() => _refreshCompletion());
      _showSnackBar("Image uploaded", Icons.check, Colors.green);
    } catch (e) {
      _showSnackBar("Upload failed: $e", Icons.error, Colors.red);
    }
  }

  // ------------------- IMAGE DELETE -------------------
  Future<void> _deleteImage(String url) async {
    if (_userId == null) return;
    try {
      _uploadedImages.remove(url);
      await SupabaseService.client
          .from("profiles")
          .update({"product_image": _uploadedImages})
          .eq("id", _userId!);
      setState(() => _refreshCompletion());
      _showSnackBar("Image deleted", Icons.check, Colors.green);
    } catch (e) {
      _showSnackBar("Delete failed", Icons.error, Colors.red);
    }
  }

  // ------------------- SNACKBAR -------------------
  void _showSnackBar(String message, IconData icon, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ------------------- THREE-DOT MENU -------------------
  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Refresh Profile'),
            onTap: () {
              Navigator.pop(context);
              _loadUserProfile();
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Profile'),
            onTap: () {
              Navigator.pop(context);
              setState(() => _isBulkEditing = true);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ------------------- ICON MAPPER -------------------
  IconData _iconForField(String field) {
    const map = {
      'business_name': Icons.business,
      'person_name': Icons.person,
      'address': Icons.location_on,
      'keywords': Icons.tag,
      'description': Icons.description,
      'city': Icons.location_city,
      'pincode': Icons.pin_drop,
      'whats_app': Icons.chat,
      'email': Icons.email,
    };
    return map[field] ?? Icons.info;
  }

  // ------------------- HEADER -------------------
  Widget _buildHeader() {
    return Container(
      color: primaryColor,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: accentColor,
            child: _profileData["business_name"] != null
                ? Text(
                    _profileData["business_name"].toString()[0].toUpperCase(),
                    style: const TextStyle(fontSize: 32, color: Colors.white),
                  )
                : const Icon(Icons.person, size: 40, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _profileData["business_name"] ?? "Your Profile",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _profileData["email"] ?? "email@example.com",
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
          CircularPercentIndicator(
            radius: 30.0,
            lineWidth: 6.0,
            percent: _profileCompletion / 100,
            center: Text(
              "${_profileCompletion.round()}%",
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            progressColor: accentColor,
            backgroundColor: Colors.white24,
          ),
        ],
      ),
    );
  }

  // ------------------- READ-ONLY FIELD ROW -------------------
  Widget _buildReadOnlyField(String label, String fieldName, IconData icon) {
    final value = _profileData[fieldName]?.toString() ?? "";
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: primaryColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value.isEmpty ? "<empty>" : value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------- BULK EDIT FORM -------------------
  Widget _buildBulkEditForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.edit, color: primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    "Edit Profile",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ..._editableFields.map((field) {
                final label = field.replaceAll('_', ' ').toTitleCase();
                final icon = _iconForField(field);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextField(
                    controller: _controllers[field],
                    decoration: InputDecoration(
                      labelText: label,
                      prefixIcon: Icon(icon, color: primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _saveAllFields,
                      icon: const Icon(Icons.save),
                      label: const Text("Save All"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() => _isBulkEditing = false);
                        _initControllers(); // Reset values
                      },
                      icon: const Icon(Icons.cancel),
                      label: const Text("Cancel"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------- IMAGE GALLERY -------------------
  Widget _buildImageGallery() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            "Product Images",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _uploadedImages.length + 1,
            itemBuilder: (context, index) {
              if (index == _uploadedImages.length) {
                return GestureDetector(
                  onTap: _pickAndUploadImage,
                  child: Container(
                    width: 120,
                    height: 120,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[200],
                    ),
                    child: const Icon(Icons.add_a_photo, color: Colors.grey),
                  ),
                );
              }
              final url = _uploadedImages[index];
              return Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        url,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) =>
                            const Icon(Icons.broken_image, size: 50),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteImage(url),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // ------------------- BUILD -------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            color: Colors.white,
            onPressed: () => _showMenu(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickAndUploadImage,
        backgroundColor: accentColor,
        child: const Icon(Icons.add_a_photo, color: Colors.white),
        tooltip: "Add Product Image",
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader()),
                SliverToBoxAdapter(child: const SizedBox(height: 16)),

                // BULK EDIT MODE
                if (_isBulkEditing)
                  SliverToBoxAdapter(child: _buildBulkEditForm())
                else
                  SliverList(
                    delegate: SliverChildListDelegate([
                      _buildReadOnlyField(
                        "Business Name",
                        "business_name",
                        Icons.business,
                      ),
                      _buildReadOnlyField(
                        "Person Name",
                        "person_name",
                        Icons.person,
                      ),
                      _buildReadOnlyField(
                        "Address",
                        "address",
                        Icons.location_on,
                      ),
                      _buildReadOnlyField("Keywords", "keywords", Icons.tag),
                      _buildReadOnlyField(
                        "Description",
                        "description",
                        Icons.description,
                      ),
                      _buildReadOnlyField("City", "city", Icons.location_city),
                      _buildReadOnlyField("Pincode", "pincode", Icons.pin_drop),
                      _buildReadOnlyField("WhatsApp", "whats_app", Icons.chat),
                      _buildReadOnlyField("Email", "email", Icons.email),
                    ]),
                  ),

                SliverToBoxAdapter(child: _buildImageGallery()),
                SliverToBoxAdapter(child: const SizedBox(height: 80)),
              ],
            ),
    );
  }
}
