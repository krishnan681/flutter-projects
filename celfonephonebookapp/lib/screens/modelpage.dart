// import 'package:celfonephonebookapp/supabase/supabase.dart';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
//
// class ModelPage extends StatefulWidget {
//   final Map<String, dynamic> profile;
//   const ModelPage({super.key, required this.profile});
//   @override
//   State<ModelPage> createState() => _ModelPageState();
// }
//
// class _ModelPageState extends State<ModelPage>
//     with SingleTickerProviderStateMixin {
//   late PageController _pageController;
//   late TabController _tabController;
//   int _currentPage = 0;
//
//   // 🔹 Images from users_table.cover_photo
//   List<String> _images = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController();
//     _tabController = TabController(length: 2, vsync: this);
//
//     final String profileId = widget.profile['id']?.toString() ?? "";
//     _loadCoverPhoto(profileId);
//   }
//
//   Future<void> _loadCoverPhoto(String profileId) async {
//     if (profileId.isEmpty) return;
//
//     try {
//       final usersRow = await SupabaseService.client
//           .from('users_table')
//           .select('cover_photo')
//           .eq('user_id', profileId)
//           .maybeSingle();
//
//       if (usersRow != null &&
//           usersRow['cover_photo'] != null &&
//           usersRow['cover_photo'].toString().isNotEmpty) {
//         setState(() {
//           _images = [usersRow['cover_photo'].toString()];
//         });
//       }
//     } catch (e) {
//       debugPrint('Error loading cover_photo: $e');
//     }
//   }
//
//   @override
//   void dispose() {
//     _pageController.dispose();
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   String formatMobile(String number) {
//     if (number.length >= 5) return "${number.substring(0, 5)} XXXXX";
//     return number;
//   }
//
//   Future<void> _makePhoneCall(String number) async =>
//       await launchUrl(Uri(scheme: 'tel', path: number));
//   Future<void> _openWhatsApp(String number) async => await launchUrl(
//     Uri.parse("https://wa.me/$number"),
//     mode: LaunchMode.externalApplication,
//   );
//   Future<void> _sendSMS(String number) async =>
//       await launchUrl(Uri(scheme: 'sms', path: number));
//   Future<void> _sendEmail(String email) async =>
//       await launchUrl(Uri(scheme: 'mailto', path: email));
//
//   Widget _infoTile(IconData icon, String value, Color iconColor) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: iconColor.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(icon, color: iconColor, size: 20),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Text(
//                 //   title,
//                 //   style: const TextStyle(
//                 //     fontSize: 14,
//                 //     fontWeight: FontWeight.bold,
//                 //   ),
//                 // ),
//                 const SizedBox(height: 2),
//                 Text(
//                   value,
//                   style: const TextStyle(fontSize: 14, color: Colors.black87),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _circularActionButton({
//     required IconData icon,
//     required Color color,
//     required VoidCallback? onPressed,
//   }) {
//     return GestureDetector(
//       onTap: onPressed,
//       child: Container(
//         width: 60,
//         height: 60,
//         decoration: BoxDecoration(
//           color: color,
//           shape: BoxShape.circle,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.2),
//               blurRadius: 8,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Icon(icon, color: Colors.white, size: 28),
//       ),
//     );
//   }
//
//   void _showFavoriteModal(String name, String mobile) {
//     if (mobile.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Mobile number not available")),
//       );
//       return;
//     }
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => Container(
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         child: FavoriteOptionsModal(name: name, mobile: mobile),
//       ),
//     );
//   }
//
//   Widget _premiumProductCard(
//       String title,
//       String? description,
//       Color primaryColor,
//       ) {
//     return Card(
//       elevation: 0,
//       color: primaryColor.withOpacity(0.08),
//       margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: ExpansionTile(
//         backgroundColor: Colors.transparent,
//         collapsedBackgroundColor: Colors.transparent,
//         collapsedShape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//         leading: CircleAvatar(
//           radius: 18,
//           backgroundColor: primaryColor,
//           child: const Icon(Icons.inventory_2, color: Colors.white, size: 18),
//         ),
//         title: Text(
//           title,
//           style: const TextStyle(
//             fontWeight: FontWeight.w600,
//             fontSize: 15.5,
//             color: Colors.black87,
//           ),
//         ),
//         children: description != null && description.isNotEmpty
//             ? [
//           Text(
//             description,
//             style: const TextStyle(
//               color: Colors.black87,
//               height: 1.5,
//               fontSize: 14,
//             ),
//           ),
//         ]
//             : [],
//       ),
//     );
//   }
//
//   Widget _productsSummaryTile(
//       List<Map<String, String>> products,
//       Color iconColor,
//       ) {
//     final productNames = products.map((p) => p["name"]!).join(", ");
//     return _infoTile(Icons.inventory_2, productNames, iconColor);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final profile = widget.profile;
//
//     final bool isPrime = profile['is_prime'] == true;
//     final String subscription =
//     (profile['subscription'] ?? '').toString().toLowerCase();
//     final String tier = isPrime || subscription == 'gold'
//         ? 'gold'
//         : subscription == 'business'
//         ? 'business'
//         : 'normal';
//
//     final Color primaryColor =
//     tier == 'gold' ? Colors.amber[700]! : Colors.pink;
//     final Color lightColor = tier == 'gold' ? Colors.amber : Colors.pink;
//
//     final String profileId = profile['id']?.toString() ?? "";
//     final String mobile = profile["mobile_number"]?.toString() ?? "";
//     final String whatsApp = profile["whats_app"]?.toString() ?? mobile;
//     final String email = profile["email"]?.toString() ?? "";
//     final String personName = profile["person_name"]?.toString() ?? "";
//     final String businessName = profile["business_name"]?.toString() ?? "";
//     final String displayName = businessName.isNotEmpty
//         ? businessName
//         : personName.isNotEmpty
//         ? personName
//         : "User";
//
//     // images now come from state: _images (loaded from users_table.cover_photo)
//     final address = profile["address"]?.toString() ?? "";
//     final description = profile["description"]?.toString() ?? "";
//     final city = profile["city"]?.toString() ?? "";
//     final pincode = profile["pincode"]?.toString() ?? "";
//     final landline = profile["landline"]?.toString() ?? "";
//     final landlineCode = profile["landline_code"]?.toString() ?? "";
//
//     List<Map<String, String>> productList = [];
//     final keywords = profile["keywords"];
//     if (keywords != null) {
//       if (keywords is List) {
//         for (var item in keywords) {
//           if (item is Map) {
//             productList.add({
//               "name": (item["name"] ?? item["title"] ?? "Product").toString(),
//               "description":
//               (item["description"] ?? item["desc"] ?? "").toString(),
//             });
//           } else {
//             productList.add({"name": item.toString(), "description": ""});
//           }
//         }
//       } else if (keywords is String) {
//         if (keywords.contains(":")) {
//           for (var line in keywords.split(',')) {
//             if (line.contains(':')) {
//               final parts = line.split(':');
//               productList.add({
//                 "name": parts[0].trim(),
//                 "description": parts.sublist(1).join(":").trim(),
//               });
//             } else {
//               productList.add({"name": line.trim(), "description": ""});
//             }
//           }
//         } else {
//           productList = keywords
//               .split(',')
//               .map((e) =>
//           {"name": e.trim(), "description": ""} as Map<String, String>)
//               .toList();
//         }
//       }
//     }
//
//     Widget actionButtons = Padding(
//       padding: const EdgeInsets.symmetric(vertical: 30),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           _circularActionButton(
//             icon: Icons.call,
//             color: Colors.green,
//             onPressed: mobile.isNotEmpty ? () => _makePhoneCall(mobile) : null,
//           ),
//           _circularActionButton(
//             icon: FontAwesomeIcons.whatsapp,
//             color: const Color(0xFF25D366),
//             onPressed:
//             whatsApp.isNotEmpty ? () => _openWhatsApp(whatsApp) : null,
//           ),
//           _circularActionButton(
//             icon: FontAwesomeIcons.commentDots,
//             color: Colors.blue,
//             onPressed: mobile.isNotEmpty ? () => _sendSMS(mobile) : null,
//           ),
//           _circularActionButton(
//             icon: FontAwesomeIcons.envelope,
//             color: Colors.orange[700]!,
//             onPressed: email.isNotEmpty ? () => _sendEmail(email) : null,
//           ),
//         ],
//       ),
//     );
//
//     // PREMIUM HEADER — WITH BACK + FAVORITE + CENTERED CAMERA
//     Widget premiumHeader = SizedBox(
//       height: 220,
//       child: Stack(
//         children: [
//           // Background image from users_table.cover_photo
//           if (_images.isNotEmpty)
//             PageView.builder(
//               controller: _pageController,
//               itemCount: _images.length,
//               onPageChanged: (i) => setState(() => _currentPage = i),
//               itemBuilder: (_, i) => Image.network(
//                 _images[i],
//                 fit: BoxFit.cover,
//                 width: double.infinity,
//               ),
//             )
//           else
//             Container(color: primaryColor.withOpacity(0.12)),
//
//           // Centered camera icon when no images
//           if (_images.isEmpty)
//             Center(
//               child: Container(
//                 width: 100,
//                 height: 100,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   shape: BoxShape.circle,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black26,
//                       blurRadius: 20,
//                       offset: const Offset(0, 8),
//                     ),
//                   ],
//                 ),
//                 child: Icon(Icons.photo_camera, color: primaryColor, size: 56),
//               ),
//             ),
//
//           // Back Button
//           Positioned(
//             top: 16,
//             left: 16,
//             child: CircleAvatar(
//               radius: 22,
//               backgroundColor: Colors.white.withOpacity(0.9),
//               child: IconButton(
//                 icon: const Icon(
//                   Icons.arrow_back_ios_new,
//                   color: Colors.black87,
//                   size: 20,
//                 ),
//                 onPressed: () => Navigator.pop(context),
//               ),
//             ),
//           ),
//
//           // Favorite Button
//           Positioned(
//             top: 16,
//             right: 16,
//             child: CircleAvatar(
//               radius: 22,
//               backgroundColor: Colors.white.withOpacity(0.9),
//               child: IconButton(
//                 icon: const Icon(
//                   Icons.favorite_border,
//                   color: Colors.pink,
//                   size: 24,
//                 ),
//                 onPressed: () => _showFavoriteModal(displayName, mobile),
//               ),
//             ),
//           ),
//
//           // Dots indicator
//           if (_images.isNotEmpty)
//             Positioned(
//               bottom: 12,
//               left: 0,
//               right: 0,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: List.generate(
//                   _images.length,
//                       (i) => AnimatedContainer(
//                     duration: const Duration(milliseconds: 300),
//                     margin: const EdgeInsets.symmetric(horizontal: 4),
//                     width: _currentPage == i ? 12 : 8,
//                     height: 8,
//                     decoration: BoxDecoration(
//                       color: _currentPage == i ? Colors.white : Colors.white60,
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//
//     // GOLD & BUSINESS USERS
//     if (tier == "gold" || tier == "business") {
//       return Scaffold(
//         backgroundColor: Colors.white,
//         body: SafeArea(
//           child: Column(
//             children: [
//               premiumHeader,
//               Padding(
//                 padding:
//                 const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//                 child: Row(
//                   children: [
//                     CircleAvatar(
//                       radius: 32,
//                       backgroundColor: lightColor.withOpacity(0.2),
//                       child: Text(
//                         displayName[0].toUpperCase(),
//                         style: TextStyle(
//                           fontSize: 28,
//                           fontWeight: FontWeight.bold,
//                           color: primaryColor,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             displayName,
//                             style: const TextStyle(
//                               fontSize: 22,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           if (personName.isNotEmpty && businessName.isNotEmpty)
//                             Text(
//                               personName,
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: Colors.grey[600],
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 14,
//                         vertical: 8,
//                       ),
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [primaryColor, primaryColor.withOpacity(0.7)],
//                         ),
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                       child: const Row(
//                         children: [
//                           Icon(Icons.verified, color: Colors.white, size: 20),
//                           SizedBox(width: 6),
//                           Text(
//                             "",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 14,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               TabBar(
//                 controller: _tabController,
//                 labelColor: primaryColor,
//                 indicatorColor: primaryColor,
//                 tabs: const [
//                   Tab(text: "About"),
//                   Tab(text: "Products"),
//                 ],
//               ),
//               Expanded(
//                 child: TabBarView(
//                   controller: _tabController,
//                   children: [
//                     SingleChildScrollView(
//                       padding: const EdgeInsets.all(20),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           if (address.isNotEmpty ||
//                               city.isNotEmpty ||
//                               pincode.isNotEmpty)
//                             _infoTile(
//                               Icons.location_on,
//                               "$address, $city, $pincode",
//                               Colors.redAccent,
//                             ),
//                           if (mobile.isNotEmpty)
//                             _infoTile(
//                               Icons.phone,
//                               formatMobile(mobile),
//                               Colors.green,
//                             ),
//                           if (landline.isNotEmpty)
//                             _infoTile(
//                               Icons.phone,
//                               landlineCode.isNotEmpty
//                                   ? "$landlineCode $landline"
//                                   : landline,
//                               Colors.green,
//                             ),
//                           if (email.isNotEmpty)
//                             _infoTile(
//                               Icons.email,
//                               email,
//                               Colors.orange,
//                             ),
//                           if (productList.isNotEmpty) ...[
//                             const SizedBox(height: 20),
//                             _productsSummaryTile(productList, lightColor),
//                           ],
//                           if (description.isNotEmpty) ...[
//                             const SizedBox(height: 20),
//                             const Text(
//                               "Description",
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               description,
//                               style: const TextStyle(height: 1.5),
//                             ),
//                           ],
//                           actionButtons,
//                         ],
//                       ),
//                     ),
//                     productList.isEmpty
//                         ? const Center(
//                       child: Text(
//                         "No products listed",
//                         style: TextStyle(
//                           color: Colors.grey,
//                           fontSize: 16,
//                         ),
//                       ),
//                     )
//                         : ListView.builder(
//                       padding: EdgeInsets.zero,
//                       itemCount: productList.length,
//                       itemBuilder: (_, i) => _premiumProductCard(
//                         productList[i]["name"]!,
//                         productList[i]["description"]!.isNotEmpty
//                             ? productList[i]["description"]
//                             : null,
//                         primaryColor,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//
//     // FREE USERS (unchanged)
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0.5,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
//           onPressed: () => Navigator.pop(context),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.favorite_border, size: 28),
//             onPressed: () => _showFavoriteModal(displayName, mobile),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               displayName,
//               style:
//               const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 24),
//             if (address.isNotEmpty || city.isNotEmpty || pincode.isNotEmpty)
//               _infoTile(
//                 Icons.location_on,
//                 "$address, $city, $pincode",
//                 Colors.redAccent,
//               ),
//             if (mobile.isNotEmpty)
//               _infoTile(
//                 Icons.phone,
//                 formatMobile(mobile),
//                 Colors.green,
//               ),
//             if (landline.isNotEmpty)
//               _infoTile(
//                 Icons.phone,
//                 landlineCode.isNotEmpty ? "$landlineCode $landline" : landline,
//                 Colors.green,
//               ),
//             if (email.isNotEmpty)
//               _infoTile(Icons.email, email, Colors.orange),
//             if (description.isNotEmpty) ...[
//               const SizedBox(height: 16),
//               const Text(
//                 "Description",
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 description,
//                 style: const TextStyle(height: 1.5, fontSize: 15),
//               ),
//             ],
//             if (productList.isNotEmpty) ...[
//               const SizedBox(height: 24),
//               const SizedBox(height: 8),
//               Text(
//                 productList.map((p) => p["name"]!).join(", "),
//                 style: const TextStyle(fontSize: 15),
//               ),
//             ],
//             const SizedBox(height: 40),
//             actionButtons,
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // FavoriteOptionsModal — unchanged
// class FavoriteOptionsModal extends StatefulWidget {
//   final String name;
//   final String mobile;
//   const FavoriteOptionsModal({
//     Key? key,
//     required this.name,
//     required this.mobile,
//   }) : super(key: key);
//   @override
//   State<FavoriteOptionsModal> createState() => _FavoriteOptionsModalState();
// }
//
// class _FavoriteOptionsModalState extends State<FavoriteOptionsModal> {
//   String? selectedOption;
//   final List<String> options = [
//     "My Buyers",
//     "My Sellers",
//     "Family & Friends",
//     "My List",
//   ];
//   bool isLoading = false;
//
//   Future<void> _saveFavorite() async {
//     if (selectedOption == null) return;
//     setState(() => isLoading = true);
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final userId = prefs.getString("userId");
//       if (userId == null) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text("Please log in first")));
//         return;
//       }
//       final existingGroups = await Supabase.instance.client
//           .from("favorites_groups")
//           .select()
//           .eq("group_name", selectedOption!)
//           .eq("user_id", userId);
//       dynamic groupId;
//       if (existingGroups.isNotEmpty) {
//         groupId = existingGroups[0]['id'];
//       } else {
//         final inserted = await Supabase.instance.client
//             .from("favorites_groups")
//             .insert({"group_name": selectedOption, "user_id": userId})
//             .select()
//             .single();
//         groupId = inserted['id'];
//       }
//       final existingMember = await Supabase.instance.client
//           .from("group_members")
//           .select()
//           .eq("group_id", groupId)
//           .eq("mobile_number", widget.mobile);
//       if (existingMember.isNotEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("${widget.name} is already in $selectedOption"),
//           ),
//         );
//       } else {
//         await Supabase.instance.client.from("group_members").insert({
//           "group_id": groupId,
//           "member_name": widget.name,
//           "mobile_number": widget.mobile,
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("${widget.name} saved to $selectedOption")),
//         );
//         Navigator.pop(context);
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Error: $e")));
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             "Save ${widget.name} to Group",
//             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 12),
//           ...options.map(
//                 (option) => CheckboxListTile(
//               title: Text(option),
//               value: selectedOption == option,
//               onChanged: (val) => setState(() => selectedOption = option),
//             ),
//           ),
//           const SizedBox(height: 16),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.redAccent,
//                 ),
//                 onPressed: () => setState(() => selectedOption = null),
//                 child: const Text("Clear"),
//               ),
//               ElevatedButton(
//                 onPressed: isLoading ? null : _saveFavorite,
//                 child: isLoading
//                     ? const SizedBox(
//                   width: 16,
//                   height: 16,
//                   child: CircularProgressIndicator(
//                     strokeWidth: 2,
//                     color: Colors.white,
//                   ),
//                 )
//                     : const Text("Save"),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
// // import 'package:celfonephonebookapp/supabase/supabase.dart';
// // import 'package:flutter/material.dart';
// // import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// // import 'package:url_launcher/url_launcher.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:supabase_flutter/supabase_flutter.dart';
// //
// // class ModelPage extends StatefulWidget {
// //   final Map<String, dynamic> profile;
// //   const ModelPage({super.key, required this.profile});
// //   @override
// //   State<ModelPage> createState() => _ModelPageState();
// // }
// //
// // class _ModelPageState extends State<ModelPage>
// //     with SingleTickerProviderStateMixin {
// //   late PageController _pageController;
// //   late TabController _tabController;
// //   int _currentPage = 0;
// //
// //   // 🔹 Images from users_table.cover_photo
// //   List<String> _images = [];
// //
// //   // 🔹 Products from product_table, grouped by product_desc
// //   List<Map<String, dynamic>> _priorityProducts = [];
// //   List<Map<String, dynamic>> _secondaryProducts = [];
// //   bool _isLoadingProducts = false;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _pageController = PageController();
// //     _tabController = TabController(length: 2, vsync: this);
// //
// //     final String profileId = widget.profile['id']?.toString() ?? "";
// //     _loadCoverPhoto(profileId);
// //     _loadProducts(profileId);
// //   }
// //
// //   Future<void> _loadCoverPhoto(String profileId) async {
// //     if (profileId.isEmpty) return;
// //
// //     try {
// //       final usersRow = await SupabaseService.client
// //           .from('users_table')
// //           .select('cover_photo')
// //           .eq('user_id', profileId)
// //           .maybeSingle();
// //
// //       if (usersRow != null &&
// //           usersRow['cover_photo'] != null &&
// //           usersRow['cover_photo'].toString().isNotEmpty) {
// //         setState(() {
// //           _images = [usersRow['cover_photo'].toString()];
// //         });
// //       }
// //     } catch (e) {
// //       debugPrint('Error loading cover_photo: $e');
// //     }
// //   }
// //
// //   Future<void> _loadProducts(String profileId) async {
// //     if (profileId.isEmpty) return;
// //
// //     setState(() => _isLoadingProducts = true);
// //
// //     try {
// //       // 1️⃣ Get product_des_table rows for this user
// //       final desRows = await SupabaseService.client
// //           .from('product_des_table')
// //           .select('prod_des_id, product_desc')
// //           .eq('userId', profileId);
// //
// //       if (desRows == null || desRows.isEmpty) {
// //         if (!mounted) return;
// //         setState(() {
// //           _priorityProducts = [];
// //           _secondaryProducts = [];
// //           _isLoadingProducts = false;
// //         });
// //         return;
// //       }
// //
// //       final List prodDesList = desRows as List;
// //       final Map<String, String> desById = {};
// //       final List<String> prodDesIds = [];
// //
// //       for (final row in prodDesList) {
// //         final id = row['prod_des_id']?.toString();
// //         final desc = row['product_desc']?.toString();
// //         if (id != null) {
// //           prodDesIds.add(id);
// //           if (desc != null) desById[id] = desc;
// //         }
// //       }
// //
// //       if (prodDesIds.isEmpty) {
// //         if (!mounted) return;
// //         setState(() {
// //           _priorityProducts = [];
// //           _secondaryProducts = [];
// //           _isLoadingProducts = false;
// //         });
// //         return;
// //       }
// //
// //       // 2️⃣ Get products from product_table for those prod_des_id
// //       final productRows = await SupabaseService.client
// //           .from('product_table')
// //           .select(
// //         'product_id, prod_des_id, product_name, product_image, product_description, price',
// //       )
// //           .filter('prod_des_id', 'in', prodDesIds);
// //
// //       List<Map<String, dynamic>> priority = [];
// //       List<Map<String, dynamic>> secondary = [];
// //
// //       if (productRows is List) {
// //         for (final row in productRows) {
// //           final prodDesId = row['prod_des_id']?.toString();
// //           if (prodDesId == null) continue;
// //
// //           final descType = desById[prodDesId]; // "priority" / "secondary"
// //           final product = {
// //             'id': row['product_id'],
// //             'name': row['product_name'],
// //             'image': row['product_image'],
// //             'description': row['product_description'],
// //             'price': row['price'],
// //           };
// //
// //           if (descType == 'priority') {
// //             priority.add(product);
// //           } else if (descType == 'secondary') {
// //             secondary.add(product);
// //           }
// //         }
// //       }
// //
// //       if (!mounted) return;
// //       setState(() {
// //         _priorityProducts = priority;
// //         _secondaryProducts = secondary;
// //         _isLoadingProducts = false;
// //       });
// //     } catch (e) {
// //       debugPrint('Error loading products: $e');
// //       if (!mounted) return;
// //       setState(() => _isLoadingProducts = false);
// //     }
// //   }
// //
// //   @override
// //   void dispose() {
// //     _pageController.dispose();
// //     _tabController.dispose();
// //     super.dispose();
// //   }
// //
// //   String formatMobile(String number) {
// //     if (number.length >= 5) return "${number.substring(0, 5)} XXXXX";
// //     return number;
// //   }
// //
// //   Future<void> _makePhoneCall(String number) async =>
// //       await launchUrl(Uri(scheme: 'tel', path: number));
// //   Future<void> _openWhatsApp(String number) async => await launchUrl(
// //     Uri.parse("https://wa.me/$number"),
// //     mode: LaunchMode.externalApplication,
// //   );
// //   Future<void> _sendSMS(String number) async =>
// //       await launchUrl(Uri(scheme: 'sms', path: number));
// //   Future<void> _sendEmail(String email) async =>
// //       await launchUrl(Uri(scheme: 'mailto', path: email));
// //
// //   Widget _infoTile(IconData icon, String value, Color iconColor) {
// //     return Container(
// //       margin: const EdgeInsets.symmetric(vertical: 6),
// //       child: Row(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Container(
// //             width: 40,
// //             height: 40,
// //             decoration: BoxDecoration(
// //               color: iconColor.withOpacity(0.1),
// //               shape: BoxShape.circle,
// //             ),
// //             child: Icon(icon, color: iconColor, size: 20),
// //           ),
// //           const SizedBox(width: 12),
// //           Expanded(
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 const SizedBox(height: 2),
// //                 Text(
// //                   value,
// //                   style: const TextStyle(fontSize: 14, color: Colors.black87),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _circularActionButton({
// //     required IconData icon,
// //     required Color color,
// //     required VoidCallback? onPressed,
// //   }) {
// //     return GestureDetector(
// //       onTap: onPressed,
// //       child: Container(
// //         width: 60,
// //         height: 60,
// //         decoration: BoxDecoration(
// //           color: color,
// //           shape: BoxShape.circle,
// //           boxShadow: [
// //             BoxShadow(
// //               color: Colors.black.withOpacity(0.2),
// //               blurRadius: 8,
// //               offset: const Offset(0, 4),
// //             ),
// //           ],
// //         ),
// //         child: Icon(icon, color: Colors.white, size: 28),
// //       ),
// //     );
// //   }
// //
// //   void _showFavoriteModal(String name, String mobile) {
// //     if (mobile.isEmpty) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text("Mobile number not available")),
// //       );
// //       return;
// //     }
// //     showModalBottomSheet(
// //       context: context,
// //       isScrollControlled: true,
// //       backgroundColor: Colors.transparent,
// //       builder: (_) => Container(
// //         decoration: const BoxDecoration(
// //           color: Colors.white,
// //           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
// //         ),
// //         child: FavoriteOptionsModal(name: name, mobile: mobile),
// //       ),
// //     );
// //   }
// //
// //   Widget _premiumProductCard({
// //     required String title,
// //     String? description,
// //     String? imageUrl,
// //     String? price,
// //     required Color primaryColor,
// //   }) {
// //     return Card(
// //       elevation: 0,
// //       color: primaryColor.withOpacity(0.08),
// //       margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// //       child: ExpansionTile(
// //         backgroundColor: Colors.transparent,
// //         collapsedBackgroundColor: Colors.transparent,
// //         collapsedShape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(16),
// //         ),
// //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// //         tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //         childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
// //         leading: CircleAvatar(
// //           radius: 18,
// //           backgroundColor: primaryColor,
// //           child: const Icon(Icons.inventory_2, color: Colors.white, size: 18),
// //         ),
// //         title: Text(
// //           title,
// //           style: const TextStyle(
// //             fontWeight: FontWeight.w600,
// //             fontSize: 15.5,
// //             color: Colors.black87,
// //           ),
// //         ),
// //         children: [
// //           if (imageUrl != null && imageUrl.isNotEmpty) ...[
// //             ClipRRect(
// //               borderRadius: BorderRadius.circular(12),
// //               child: Image.network(
// //                 imageUrl,
// //                 height: 160,
// //                 width: double.infinity,
// //                 fit: BoxFit.cover,
// //               ),
// //             ),
// //             const SizedBox(height: 8),
// //           ],
// //           if (price != null) ...[
// //             Text(
// //               'Price: $price',
// //               style: TextStyle(
// //                 fontWeight: FontWeight.bold,
// //                 color: primaryColor,
// //                 fontSize: 14,
// //               ),
// //             ),
// //             const SizedBox(height: 4),
// //           ],
// //           if (description != null && description.isNotEmpty)
// //             Text(
// //               description,
// //               style: const TextStyle(
// //                 color: Colors.black87,
// //                 height: 1.5,
// //                 fontSize: 14,
// //               ),
// //             ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _productsSummaryTile(
// //       List<Map<String, String>> products,
// //       Color iconColor,
// //       ) {
// //     final productNames = products.map((p) => p["name"]!).join(", ");
// //     return _infoTile(Icons.inventory_2, productNames, iconColor);
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final profile = widget.profile;
// //
// //     final bool isPrime = profile['is_prime'] == true;
// //     final String subscription =
// //     (profile['subscription'] ?? '').toString().toLowerCase();
// //     final String tier = isPrime || subscription == 'gold'
// //         ? 'gold'
// //         : subscription == 'business'
// //         ? 'business'
// //         : 'normal';
// //
// //     final Color primaryColor =
// //     tier == 'gold' ? Colors.amber[700]! : Colors.pink;
// //     final Color lightColor = tier == 'gold' ? Colors.amber : Colors.pink;
// //
// //     final String profileId = profile['id']?.toString() ?? "";
// //     final String mobile = profile["mobile_number"]?.toString() ?? "";
// //     final String whatsApp = profile["whats_app"]?.toString() ?? mobile;
// //     final String email = profile["email"]?.toString() ?? "";
// //     final String personName = profile["person_name"]?.toString() ?? "";
// //     final String businessName = profile["business_name"]?.toString() ?? "";
// //     final String displayName = businessName.isNotEmpty
// //         ? businessName
// //         : personName.isNotEmpty
// //         ? personName
// //         : "User";
// //
// //     final address = profile["address"]?.toString() ?? "";
// //     final description = profile["description"]?.toString() ?? "";
// //     final city = profile["city"]?.toString() ?? "";
// //     final pincode = profile["pincode"]?.toString() ?? "";
// //     final landline = profile["landline"]?.toString() ?? "";
// //     final landlineCode = profile["landline_code"]?.toString() ?? "";
// //
// //     // 🔹 all products combined (for summary text / free view)
// //     final allProducts = [..._priorityProducts, ..._secondaryProducts];
// //
// //     Widget actionButtons = Padding(
// //       padding: const EdgeInsets.symmetric(vertical: 30),
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //         children: [
// //           _circularActionButton(
// //             icon: Icons.call,
// //             color: Colors.green,
// //             onPressed: mobile.isNotEmpty ? () => _makePhoneCall(mobile) : null,
// //           ),
// //           _circularActionButton(
// //             icon: FontAwesomeIcons.whatsapp,
// //             color: const Color(0xFF25D366),
// //             onPressed:
// //             whatsApp.isNotEmpty ? () => _openWhatsApp(whatsApp) : null,
// //           ),
// //           _circularActionButton(
// //             icon: FontAwesomeIcons.commentDots,
// //             color: Colors.blue,
// //             onPressed: mobile.isNotEmpty ? () => _sendSMS(mobile) : null,
// //           ),
// //           _circularActionButton(
// //             icon: FontAwesomeIcons.envelope,
// //             color: Colors.orange[700]!,
// //             onPressed: email.isNotEmpty ? () => _sendEmail(email) : null,
// //           ),
// //         ],
// //       ),
// //     );
// //
// //     // PREMIUM HEADER — WITH BACK + FAVORITE + CENTERED CAMERA
// //     Widget premiumHeader = SizedBox(
// //       height: 220,
// //       child: Stack(
// //         children: [
// //           // Background image from users_table.cover_photo
// //           if (_images.isNotEmpty)
// //             PageView.builder(
// //               controller: _pageController,
// //               itemCount: _images.length,
// //               onPageChanged: (i) => setState(() => _currentPage = i),
// //               itemBuilder: (_, i) => Image.network(
// //                 _images[i],
// //                 fit: BoxFit.cover,
// //                 width: double.infinity,
// //               ),
// //             )
// //           else
// //             Container(color: primaryColor.withOpacity(0.12)),
// //
// //           // Centered camera icon when no images
// //           if (_images.isEmpty)
// //             Center(
// //               child: Container(
// //                 width: 100,
// //                 height: 100,
// //                 decoration: BoxDecoration(
// //                   color: Colors.white,
// //                   shape: BoxShape.circle,
// //                   boxShadow: [
// //                     BoxShadow(
// //                       color: Colors.black26,
// //                       blurRadius: 20,
// //                       offset: const Offset(0, 8),
// //                     ),
// //                   ],
// //                 ),
// //                 child: Icon(Icons.photo_camera, color: primaryColor, size: 56),
// //               ),
// //             ),
// //
// //           // Back Button
// //           Positioned(
// //             top: 16,
// //             left: 16,
// //             child: CircleAvatar(
// //               radius: 22,
// //               backgroundColor: Colors.white.withOpacity(0.9),
// //               child: IconButton(
// //                 icon: const Icon(
// //                   Icons.arrow_back_ios_new,
// //                   color: Colors.black87,
// //                   size: 20,
// //                 ),
// //                 onPressed: () => Navigator.pop(context),
// //               ),
// //             ),
// //           ),
// //
// //           // Favorite Button
// //           Positioned(
// //             top: 16,
// //             right: 16,
// //             child: CircleAvatar(
// //               radius: 22,
// //               backgroundColor: Colors.white.withOpacity(0.9),
// //               child: IconButton(
// //                 icon: const Icon(
// //                   Icons.favorite_border,
// //                   color: Colors.pink,
// //                   size: 24,
// //                 ),
// //                 onPressed: () => _showFavoriteModal(displayName, mobile),
// //               ),
// //             ),
// //           ),
// //
// //           // Dots indicator
// //           if (_images.isNotEmpty)
// //             Positioned(
// //               bottom: 12,
// //               left: 0,
// //               right: 0,
// //               child: Row(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: List.generate(
// //                   _images.length,
// //                       (i) => AnimatedContainer(
// //                     duration: const Duration(milliseconds: 300),
// //                     margin: const EdgeInsets.symmetric(horizontal: 4),
// //                     width: _currentPage == i ? 12 : 8,
// //                     height: 8,
// //                     decoration: BoxDecoration(
// //                       color: _currentPage == i ? Colors.white : Colors.white60,
// //                       borderRadius: BorderRadius.circular(4),
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             ),
// //         ],
// //       ),
// //     );
// //
// //     // GOLD & BUSINESS USERS
// //     if (tier == "gold" || tier == "business") {
// //       return Scaffold(
// //         backgroundColor: Colors.white,
// //         body: SafeArea(
// //           child: Column(
// //             children: [
// //               premiumHeader,
// //               Padding(
// //                 padding:
// //                 const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
// //                 child: Row(
// //                   children: [
// //                     CircleAvatar(
// //                       radius: 32,
// //                       backgroundColor: lightColor.withOpacity(0.2),
// //                       child: Text(
// //                         displayName[0].toUpperCase(),
// //                         style: TextStyle(
// //                           fontSize: 28,
// //                           fontWeight: FontWeight.bold,
// //                           color: primaryColor,
// //                         ),
// //                       ),
// //                     ),
// //                     const SizedBox(width: 16),
// //                     Expanded(
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Text(
// //                             displayName,
// //                             style: const TextStyle(
// //                               fontSize: 22,
// //                               fontWeight: FontWeight.bold,
// //                             ),
// //                           ),
// //                           if (personName.isNotEmpty &&
// //                               businessName.isNotEmpty)
// //                             Text(
// //                               personName,
// //                               style: TextStyle(
// //                                 fontSize: 14,
// //                                 color: Colors.grey[600],
// //                               ),
// //                             ),
// //                         ],
// //                       ),
// //                     ),
// //                     Container(
// //                       padding: const EdgeInsets.symmetric(
// //                         horizontal: 14,
// //                         vertical: 8,
// //                       ),
// //                       decoration: BoxDecoration(
// //                         gradient: LinearGradient(
// //                           colors: [primaryColor, primaryColor.withOpacity(0.7)],
// //                         ),
// //                         borderRadius: BorderRadius.circular(30),
// //                       ),
// //                       child: const Row(
// //                         children: [
// //                           Icon(Icons.verified, color: Colors.white, size: 20),
// //                           SizedBox(width: 6),
// //                           Text(
// //                             "",
// //                             style: TextStyle(
// //                               color: Colors.white,
// //                               fontWeight: FontWeight.bold,
// //                               fontSize: 14,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               TabBar(
// //                 controller: _tabController,
// //                 labelColor: primaryColor,
// //                 indicatorColor: primaryColor,
// //                 tabs: const [
// //                   Tab(text: "About"),
// //                   Tab(text: "Products"),
// //                 ],
// //               ),
// //               Expanded(
// //                 child: TabBarView(
// //                   controller: _tabController,
// //                   children: [
// //                     // ABOUT TAB
// //                     SingleChildScrollView(
// //                       padding: const EdgeInsets.all(20),
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           if (address.isNotEmpty ||
// //                               city.isNotEmpty ||
// //                               pincode.isNotEmpty)
// //                             _infoTile(
// //                               Icons.location_on,
// //                               "$address, $city, $pincode",
// //                               Colors.redAccent,
// //                             ),
// //                           if (mobile.isNotEmpty)
// //                             _infoTile(
// //                               Icons.phone,
// //                               formatMobile(mobile),
// //                               Colors.green,
// //                             ),
// //                           if (landline.isNotEmpty)
// //                             _infoTile(
// //                               Icons.phone,
// //                               landlineCode.isNotEmpty
// //                                   ? "$landlineCode $landline"
// //                                   : landline,
// //                               Colors.green,
// //                             ),
// //                           if (email.isNotEmpty)
// //                             _infoTile(
// //                               Icons.email,
// //                               email,
// //                               Colors.orange,
// //                             ),
// //                           if (allProducts.isNotEmpty) ...[
// //                             const SizedBox(height: 20),
// //                             _productsSummaryTile(
// //                               allProducts
// //                                   .map(
// //                                     (p) => {
// //                                   "name":
// //                                   (p["name"] ?? "").toString(),
// //                                 },
// //                               )
// //                                   .toList(),
// //                               lightColor,
// //                             ),
// //                           ],
// //                           if (description.isNotEmpty) ...[
// //                             const SizedBox(height: 20),
// //                             const Text(
// //                               "Description",
// //                               style: TextStyle(
// //                                 fontSize: 16,
// //                                 fontWeight: FontWeight.bold,
// //                               ),
// //                             ),
// //                             const SizedBox(height: 8),
// //                             Text(
// //                               description,
// //                               style: const TextStyle(height: 1.5),
// //                             ),
// //                           ],
// //                           actionButtons,
// //                         ],
// //                       ),
// //                     ),
// //
// //                     // PRODUCTS TAB
// //                     _isLoadingProducts
// //                         ? const Center(
// //                       child: CircularProgressIndicator(),
// //                     )
// //                         : (_priorityProducts.isEmpty &&
// //                         _secondaryProducts.isEmpty)
// //                         ? const Center(
// //                       child: Text(
// //                         "No products listed",
// //                         style: TextStyle(
// //                           color: Colors.grey,
// //                           fontSize: 16,
// //                         ),
// //                       ),
// //                     )
// //                         : ListView(
// //                       padding: EdgeInsets.zero,
// //                       children: [
// //                         if (_priorityProducts.isNotEmpty) ...[
// //                           const Padding(
// //                             padding: EdgeInsets.fromLTRB(
// //                                 16, 12, 16, 4),
// //                             child: Text(
// //                               "Priority Products",
// //                               style: TextStyle(
// //                                 fontSize: 16,
// //                                 fontWeight: FontWeight.bold,
// //                               ),
// //                             ),
// //                           ),
// //                           ..._priorityProducts.map(
// //                                 (p) => _premiumProductCard(
// //                               title:
// //                               (p["name"] ?? "").toString(),
// //                               description:
// //                               (p["description"] ?? "")
// //                                   .toString(),
// //                               imageUrl:
// //                               (p["image"] ?? "").toString(),
// //                               price: p["price"] as String?,
// //                               primaryColor: primaryColor,
// //                             ),
// //                           ),
// //                         ],
// //                         if (_secondaryProducts.isNotEmpty) ...[
// //                           const Padding(
// //                             padding: EdgeInsets.fromLTRB(
// //                                 16, 16, 16, 4),
// //                             child: Text(
// //                               "Other Products",
// //                               style: TextStyle(
// //                                 fontSize: 16,
// //                                 fontWeight: FontWeight.bold,
// //                               ),
// //                             ),
// //                           ),
// //                           ..._secondaryProducts.map(
// //                                 (p) => _premiumProductCard(
// //                               title:
// //                               (p["name"] ?? "").toString(),
// //                               description:
// //                               (p["description"] ?? "")
// //                                   .toString(),
// //                               imageUrl:
// //                               (p["image"] ?? "").toString(),
// //                               price: p["price"] as String?,
// //                               primaryColor: primaryColor,
// //                             ),
// //                           ),
// //                         ],
// //                       ],
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       );
// //     }
// //
// //     // FREE USERS
// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       appBar: AppBar(
// //         backgroundColor: Colors.white,
// //         elevation: 0.5,
// //         leading: IconButton(
// //           icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
// //           onPressed: () => Navigator.pop(context),
// //         ),
// //         actions: [
// //           IconButton(
// //             icon: const Icon(Icons.favorite_border, size: 28),
// //             onPressed: () => _showFavoriteModal(displayName, mobile),
// //           ),
// //         ],
// //       ),
// //       body: SingleChildScrollView(
// //         padding: const EdgeInsets.all(20),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Text(
// //               displayName,
// //               style:
// //               const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
// //             ),
// //             const SizedBox(height: 24),
// //             if (address.isNotEmpty || city.isNotEmpty || pincode.isNotEmpty)
// //               _infoTile(
// //                 Icons.location_on,
// //                 "$address, $city, $pincode",
// //                 Colors.redAccent,
// //               ),
// //             if (mobile.isNotEmpty)
// //               _infoTile(
// //                 Icons.phone,
// //                 formatMobile(mobile),
// //                 Colors.green,
// //               ),
// //             if (landline.isNotEmpty)
// //               _infoTile(
// //                 Icons.phone,
// //                 landlineCode.isNotEmpty ? "$landlineCode $landline" : landline,
// //                 Colors.green,
// //               ),
// //             if (email.isNotEmpty)
// //               _infoTile(Icons.email, email, Colors.orange),
// //             if (description.isNotEmpty) ...[
// //               const SizedBox(height: 16),
// //               const Text(
// //                 "Description",
// //                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
// //               ),
// //               const SizedBox(height: 8),
// //               Text(
// //                 description,
// //                 style: const TextStyle(height: 1.5, fontSize: 15),
// //               ),
// //             ],
// //             if (allProducts.isNotEmpty) ...[
// //               const SizedBox(height: 24),
// //               const SizedBox(height: 8),
// //               Text(
// //                 allProducts
// //                     .map((p) => (p["name"] ?? "").toString())
// //                     .join(", "),
// //                 style: const TextStyle(fontSize: 15),
// //               ),
// //             ],
// //             const SizedBox(height: 40),
// //             actionButtons,
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // // FavoriteOptionsModal — unchanged
// // class FavoriteOptionsModal extends StatefulWidget {
// //   final String name;
// //   final String mobile;
// //   const FavoriteOptionsModal({
// //     Key? key,
// //     required this.name,
// //     required this.mobile,
// //   }) : super(key: key);
// //   @override
// //   State<FavoriteOptionsModal> createState() => _FavoriteOptionsModalState();
// // }
// //
// // class _FavoriteOptionsModalState extends State<FavoriteOptionsModal> {
// //   String? selectedOption;
// //   final List<String> options = [
// //     "My Buyers",
// //     "My Sellers",
// //     "Family & Friends",
// //     "My List",
// //   ];
// //   bool isLoading = false;
// //
// //   Future<void> _saveFavorite() async {
// //     if (selectedOption == null) return;
// //     setState(() => isLoading = true);
// //     try {
// //       final prefs = await SharedPreferences.getInstance();
// //       final userId = prefs.getString("userId");
// //       if (userId == null) {
// //         ScaffoldMessenger.of(
// //           context,
// //         ).showSnackBar(const SnackBar(content: Text("Please log in first")));
// //         return;
// //       }
// //       final existingGroups = await Supabase.instance.client
// //           .from("favorites_groups")
// //           .select()
// //           .eq("group_name", selectedOption!)
// //           .eq("user_id", userId);
// //       dynamic groupId;
// //       if (existingGroups.isNotEmpty) {
// //         groupId = existingGroups[0]['id'];
// //       } else {
// //         final inserted = await Supabase.instance.client
// //             .from("favorites_groups")
// //             .insert({"group_name": selectedOption, "user_id": userId})
// //             .select()
// //             .single();
// //         groupId = inserted['id'];
// //       }
// //       final existingMember = await Supabase.instance.client
// //           .from("group_members")
// //           .select()
// //           .eq("group_id", groupId)
// //           .eq("mobile_number", widget.mobile);
// //       if (existingMember.isNotEmpty) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(
// //             content: Text("${widget.name} is already in $selectedOption"),
// //           ),
// //         );
// //       } else {
// //         await Supabase.instance.client.from("group_members").insert({
// //           "group_id": groupId,
// //           "member_name": widget.name,
// //           "mobile_number": widget.mobile,
// //         });
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(content: Text("${widget.name} saved to $selectedOption")),
// //         );
// //         Navigator.pop(context);
// //       }
// //     } catch (e) {
// //       ScaffoldMessenger.of(
// //         context,
// //       ).showSnackBar(SnackBar(content: Text("Error: $e")));
// //     } finally {
// //       setState(() => isLoading = false);
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Padding(
// //       padding: const EdgeInsets.all(16),
// //       child: Column(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           Text(
// //             "Save ${widget.name} to Group",
// //             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //           ),
// //           const SizedBox(height: 12),
// //           ...options.map(
// //                 (option) => CheckboxListTile(
// //               title: Text(option),
// //               value: selectedOption == option,
// //               onChanged: (val) => setState(() => selectedOption = option),
// //             ),
// //           ),
// //           const SizedBox(height: 16),
// //           Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //             children: [
// //               ElevatedButton(
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: Colors.redAccent,
// //                 ),
// //                 onPressed: () => setState(() => selectedOption = null),
// //                 child: const Text("Clear"),
// //               ),
// //               ElevatedButton(
// //                 onPressed: isLoading ? null : _saveFavorite,
// //                 child: isLoading
// //                     ? const SizedBox(
// //                   width: 16,
// //                   height: 16,
// //                   child: CircularProgressIndicator(
// //                     strokeWidth: 2,
// //                     color: Colors.white,
// //                   ),
// //                 )
// //                     : const Text("Save"),
// //               ),
// //             ],
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
import 'package:celfonephonebookapp/supabase/supabase.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ModelPage extends StatefulWidget {
  final Map<String, dynamic> profile;
  const ModelPage({super.key, required this.profile});

  @override
  State<ModelPage> createState() => _ModelPageState();
}

class _ModelPageState extends State<ModelPage> with TickerProviderStateMixin {
  late PageController _pageController;
  late TabController _tabController;
  int _currentPage = 0;

  List<String> _images = [];
  List<Map<String, dynamic>> _priorityProducts = [];
  List<Map<String, dynamic>> _secondaryProducts = [];
  bool _isLoadingProducts = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    final String profileId = widget.profile['id']?.toString() ?? "";
    _loadCoverPhoto(profileId);
    _loadProducts(profileId);
  }

  Future<void> _loadCoverPhoto(String profileId) async {
    if (profileId.isEmpty) return;
    try {
      final row = await SupabaseService.client
          .from('users_table')
          .select('cover_photo')
          .eq('user_id', profileId)
          .maybeSingle();

      if (row != null && (row['cover_photo']?.toString().isNotEmpty ?? false)) {
        setState(() {
          _images = [row['cover_photo'].toString()];
        });
      }
    } catch (e) {
      debugPrint('Cover photo error: $e');
    }
  }

  Future<void> _loadProducts(String profileId) async {
    if (profileId.isEmpty) return;
    setState(() => _isLoadingProducts = true);

    try {
      final desRows = await SupabaseService.client
          .from('product_des_table')
          .select('prod_des_id, product_desc')
          .eq('userId', profileId);

      if (desRows == null || desRows.isEmpty) {
        setState(() {
          _priorityProducts = [];
          _secondaryProducts = [];
          _isLoadingProducts = false;
        });
        return;
      }

      final List list = desRows;
      final Map<String, String> descMap = {};
      final List<String> ids = [];

      for (var r in list) {
        String? id = r['prod_des_id']?.toString();
        String? desc = r['product_desc']?.toString();
        if (id != null) {
          ids.add(id);
          if (desc != null) descMap[id] = desc;
        }
      }

      if (ids.isEmpty) {
        setState(() => _isLoadingProducts = false);
        return;
      }

      final prodRows = await SupabaseService.client
          .from('product_table')
          .select(
            'product_id, prod_des_id, product_name, product_image, product_description, price',
          )
          .inFilter('prod_des_id', ids);

      List<Map<String, dynamic>> priority = [];
      List<Map<String, dynamic>> secondary = [];

      for (var row in prodRows) {
        String? desId = row['prod_des_id']?.toString();
        if (desId == null) continue;

        final product = {
          'id': row['product_id'],
          'name': row['product_name'],
          'image': row['product_image'],
          'description': row['product_description'],
          'price': row['price']?.toString(),
        };

        if (descMap[desId] == 'priority') {
          priority.add(product);
        } else {
          secondary.add(product);
        }
      }

      setState(() {
        _priorityProducts = priority;
        _secondaryProducts = secondary;
        _isLoadingProducts = false;
      });
    } catch (e) {
      debugPrint('Product load error: $e');
      setState(() => _isLoadingProducts = false);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  String formatMobile(String n) =>
      n.length >= 5 ? "${n.substring(0, 5)} XXXXX" : n;

  Future<void> _call(String n) async => launchUrl(Uri(scheme: 'tel', path: n));
  Future<void> _wa(String n) async => launchUrl(
    Uri.parse("https://wa.me/$n"),
    mode: LaunchMode.externalApplication,
  );
  Future<void> _sms(String n) async => launchUrl(Uri(scheme: 'sms', path: n));
  Future<void> _mail(String e) async =>
      launchUrl(Uri(scheme: 'mailto', path: e));
  Future<void> _web(String url) async {
    if (!url.startsWith('http')) url = 'https://$url';
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  Widget _btn(IconData i, Color c, VoidCallback? tap) => GestureDetector(
    onTap: tap,
    child: Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: c,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Icon(i, color: Colors.white, size: 28),
    ),
  );

  void _favModal(String name, String mobile) {
    if (mobile.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Mobile not available")));
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: FavoriteOptionsModal(name: name, mobile: mobile),
      ),
    );
  }

  Widget _premiumCard(Map<String, dynamic> p, Color color) => Card(
    elevation: 0,
    color: color.withOpacity(0.08),
    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: ExpansionTile(
      tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: color,
        child: Icon(Icons.inventory_2, color: Colors.white, size: 18),
      ),
      title: Text(
        p['name'] ?? "",
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15.5),
      ),
      children: [
        if (p['image'] != null && p['image'].isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              p['image'],
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        SizedBox(height: 8),
        if (p['price'] != null && p['price'].isNotEmpty)
          Text(
            'Price: ${p['price']}',
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        if (p['description'] != null && p['description'].isNotEmpty)
          Text(
            p['description'],
            style: TextStyle(color: Colors.black87, height: 1.5),
          ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;

    final bool isPrime = profile['is_prime'] == true;
    final String sub = (profile['subscription'] ?? '').toString().toLowerCase();

    // TIER LOGIC
    String tier;
    if (isPrime || sub == 'gold') {
      tier = 'gold';
    } else if (sub == 'business') {
      tier = 'business';
    } else if (sub == 'normal_business' || sub == 'normal business') {
      tier = 'normal_business';
    } else {
      tier = 'free';
    }

    // COLORS
    Color primaryColor;
    Color lightColor;

    switch (tier) {
      case 'gold':
        primaryColor = Colors.amber[700]!;
        lightColor = Colors.amber;
        break;
      case 'business':
        primaryColor = Colors.pink;
        lightColor = Colors.pinkAccent;
        break;
      case 'normal_business':
        primaryColor = const Color(0xFF6366F1); // Change this color anytime
        lightColor = primaryColor.withOpacity(0.3);
        break;
      default:
        primaryColor = Colors.grey[700]!;
        lightColor = Colors.grey;
    }

    final bool isPremium =
        tier == 'gold' || tier == 'business' || tier == 'normal_business';
    final bool showProductTab = tier == 'gold'; // Only Gold gets Products tab

    // Initialize TabController only if needed
    if (showProductTab) {
      _tabController = TabController(length: 2, vsync: this);
    }

    final String mobile = profile['mobile_number']?.toString() ?? '';
    final String whatsapp = profile['whats_app']?.toString() ?? mobile;
    final String email = profile['email']?.toString() ?? '';
    final String website = (profile['web_site']?.toString() ?? '').trim();
    final String namePrefix = (profile['person_prefix'] ?? '').toString();
    final String personName = profile['person_name'] ?? '';
    final String businessName = profile['business_name'] ?? '';
    final String displayName = businessName.isNotEmpty
        ? businessName
        : personName.isNotEmpty
        ? '$namePrefix $personName'.trim()
        : 'User';
    final String keyword = profile['keywords'] ?? '';
    final String address = profile['address'] ?? '';
    final String city = profile['city'] ?? '';
    final String pin = profile['pincode'] ?? '';
    final String landline = profile['landline'] ?? '';
    final String landCode = profile['landline_code'] ?? '';
    final String fullLandline = landCode.isNotEmpty
        ? '$landCode$landline'
        : landline;
    final String desc = profile['description'] ?? '';

    final allProducts = [..._priorityProducts, ..._secondaryProducts];

    Widget actionButtons = Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _btn(
                Icons.call,
                Colors.green,
                mobile.isNotEmpty ? () => _call(mobile) : null,
              ),
              _btn(
                FontAwesomeIcons.whatsapp,
                Color(0xFF25D366),
                whatsapp.isNotEmpty ? () => _wa(whatsapp) : null,
              ),
              _btn(
                FontAwesomeIcons.commentDots,
                Colors.blue,
                mobile.isNotEmpty ? () => _sms(mobile) : null,
              ),
              _btn(
                FontAwesomeIcons.envelope,
                Colors.orange[700]!,
                email.isNotEmpty ? () => _mail(email) : null,
              ),
            ],
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (website.isNotEmpty)
                _btn(
                  FontAwesomeIcons.globe,
                  Colors.purple,
                  () => _web(website),
                ),
              if (website.isNotEmpty && landline.isNotEmpty)
                SizedBox(width: 40),
              if (landline.isNotEmpty)
                GestureDetector(
                  onTap: () => _call(fullLandline),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 153, 0, 255),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        "telephone",
                        style: TextStyle(fontSize: 32, color: Colors.white),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );

    Widget premiumHeader = SizedBox(
      height: 220,
      child: Stack(
        children: [
          if (_images.isNotEmpty)
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FullScreenImageGallery(
                    images: _images,
                    initialIndex: _currentPage,
                  ),
                ),
              ),
              child: PageView.builder(
                controller: _pageController,
                itemCount: _images.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (_, i) => Image.network(
                  _images[i],
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            )
          else
            Container(color: primaryColor.withOpacity(0.12)),

          if (_images.isEmpty)
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(Icons.photo_camera, color: primaryColor, size: 56),
              ),
            ),
          Positioned(
            top: 16,
            left: 16,
            child: CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white70,
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios_new),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white70,
              child: IconButton(
                icon: Icon(Icons.favorite_border, color: Colors.pink, size: 24),
                onPressed: () => _favModal(displayName, mobile),
              ),
            ),
          ),
          if (_images.isNotEmpty)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _images.length,
                  (i) => AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == i ? 12 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == i ? Colors.white : Colors.white60,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    // PREMIUM UI
    if (isPremium) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              premiumHeader,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: lightColor.withOpacity(0.2),
                      child: Text(
                        displayName[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (keyword.isNotEmpty)
                            Text(
                              keyword,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ONLY GOLD GETS TABS
              if (showProductTab)
                TabBar(
                  controller: _tabController,
                  labelColor: primaryColor,
                  indicatorColor: primaryColor,
                  tabs: [
                    Tab(text: "About"),
                    Tab(text: "Products"),
                  ],
                ),

              Expanded(
                child: showProductTab
                    ? TabBarView(
                        controller: _tabController,
                        children: [
                          // ABOUT TAB (same for all)
                          SingleChildScrollView(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                actionButtons,
                                if (personName.isNotEmpty)
                                  _info(
                                    Icons.person,
                                    Colors.blue,
                                    "$namePrefix $personName".trim(),
                                  ),
                                if (address.isNotEmpty ||
                                    city.isNotEmpty ||
                                    pin.isNotEmpty)
                                  _info(
                                    Icons.location_on,
                                    Colors.redAccent,
                                    "$address, $city, $pin".trim(),
                                  ),
                                if (mobile.isNotEmpty)
                                  _info(
                                    Icons.phone,
                                    Colors.green,
                                    formatMobile(mobile),
                                  ),
                                if (landline.isNotEmpty)
                                  _info(
                                    Icons.phone,
                                    Colors.teal,
                                    landCode.isNotEmpty
                                        ? "$landCode XXXXX"
                                        : "XXXXX",
                                  ),
                                if (email.isNotEmpty)
                                  _info(Icons.email, Colors.orange, email),
                                if (website.isNotEmpty)
                                  _info(Icons.language, Colors.purple, website),
                                if (desc.isNotEmpty) ...[
                                  SizedBox(height: 20),
                                  Text(
                                    "Description",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(desc, style: TextStyle(height: 1.5)),
                                ],
                              ],
                            ),
                          ),
                          // PRODUCTS TAB (only Gold)
                          _isLoadingProducts
                              ? Center(child: CircularProgressIndicator())
                              : allProducts.isEmpty
                              ? Center(
                                  child: Text(
                                    "No products listed",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                              : ListView(
                                  children: [
                                    if (_priorityProducts.isNotEmpty)
                                      ..._priorityProducts.map(
                                        (p) => _premiumCard(p, primaryColor),
                                      ),
                                    if (_secondaryProducts.isNotEmpty) ...[
                                      Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Text(
                                          "Other Products",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      ..._secondaryProducts.map(
                                        (p) => _premiumCard(p, primaryColor),
                                      ),
                                    ],
                                  ],
                                ),
                        ],
                      )
                    : SingleChildScrollView(
                        // Business & Normal Business — only About
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            actionButtons,
                            if (personName.isNotEmpty)
                              _info(
                                Icons.person,
                                Colors.blue,
                                "$namePrefix $personName".trim(),
                              ),
                            if (address.isNotEmpty ||
                                city.isNotEmpty ||
                                pin.isNotEmpty)
                              _info(
                                Icons.location_on,
                                Colors.redAccent,
                                "$address, $city, $pin".trim(),
                              ),
                            if (mobile.isNotEmpty)
                              _info(
                                Icons.phone,
                                Colors.green,
                                formatMobile(mobile),
                              ),
                            if (landline.isNotEmpty)
                              _info(
                                Icons.phone,
                                Colors.teal,
                                landCode.isNotEmpty
                                    ? "$landCode XXXXX"
                                    : "XXXXX",
                              ),
                            if (email.isNotEmpty)
                              _info(Icons.email, Colors.orange, email),
                            if (website.isNotEmpty)
                              _info(Icons.language, Colors.purple, website),
                            if (desc.isNotEmpty) ...[
                              SizedBox(height: 20),
                              Text(
                                "Description",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(desc, style: TextStyle(height: 1.5)),
                            ],
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      );
    }

    // FREE USER — Basic layout (unchanged)
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite_border),
            onPressed: () => _favModal(displayName, mobile),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              businessName.isNotEmpty ? businessName : "Profile",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            if (keyword.isNotEmpty) ...[
              SizedBox(height: 10),
              Text(
                keyword,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            SizedBox(height: 20),
            actionButtons,
            if (personName.isNotEmpty)
              _info(
                Icons.person,
                Colors.blue,
                "$namePrefix $personName".trim(),
              ),
            if (address.isNotEmpty || city.isNotEmpty || pin.isNotEmpty)
              _info(
                Icons.location_on,
                Colors.redAccent,
                "$address, $city, $pin".trim(),
              ),
            if (mobile.isNotEmpty)
              _info(Icons.phone, Colors.green, formatMobile(mobile)),
            if (landline.isNotEmpty)
              _info(
                Icons.phone,
                Colors.teal,
                landCode.isNotEmpty ? "$landCode XXXXX" : "XXXXX",
              ),
            if (email.isNotEmpty) _info(Icons.email, Colors.orange, email),
            if (website.isNotEmpty)
              _info(Icons.language, Colors.purple, website),
            if (desc.isNotEmpty) ...[
              SizedBox(height: 20),
              Text(
                "Description",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(desc),
            ],
            if (allProducts.isNotEmpty) ...[
              SizedBox(height: 24),
              Text(
                "Products/Services:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                allProducts
                    .map((p) => p['name'] ?? '')
                    .where((n) => n.isNotEmpty)
                    .join(", "),
              ),
            ],
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _info(IconData icon, Color color, String text) => Container(
    margin: EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Icon(icon, color: color, size: 22),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 15, color: Colors.black87),
          ),
        ),
      ],
    ),
  );
}

class FullScreenImageGallery extends StatelessWidget {
  final List<String> images;
  final int initialIndex;
  const FullScreenImageGallery({
    Key? key,
    required this.images,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: PhotoViewGallery.builder(
        scrollPhysics: const BouncingScrollPhysics(),
        builder: (context, index) => PhotoViewGalleryPageOptions(
          imageProvider: NetworkImage(images[index]),
          initialScale: PhotoViewComputedScale.contained,
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 4,
          heroAttributes: PhotoViewHeroAttributes(
            tag: images[index] + index.toString(),
          ),
        ),
        itemCount: images.length,
        loadingBuilder: (context, event) =>
            const Center(child: CircularProgressIndicator(color: Colors.white)),
        pageController: PageController(initialPage: initialIndex),
      ),
    );
  }
}

class FavoriteOptionsModal extends StatefulWidget {
  final String name;
  final String mobile;
  const FavoriteOptionsModal({
    Key? key,
    required this.name,
    required this.mobile,
  }) : super(key: key);

  @override
  State<FavoriteOptionsModal> createState() => _FavoriteOptionsModalState();
}

class _FavoriteOptionsModalState extends State<FavoriteOptionsModal> {
  String? selectedOption;
  final List<String> options = [
    "My Buyers",
    "My Sellers",
    "Family & Friends",
    "My List",
  ];
  bool isLoading = false;

  Future<void> _saveFavorite() async {
    if (selectedOption == null) return;
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString("userId");
      if (userId == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Please log in first")));
        return;
      }

      final existingGroups = await Supabase.instance.client
          .from("favorites_groups")
          .select()
          .eq("group_name", selectedOption!)
          .eq("user_id", userId);

      dynamic groupId;
      if (existingGroups.isNotEmpty) {
        groupId = existingGroups[0]['id'];
      } else {
        final inserted = await Supabase.instance.client
            .from("favorites_groups")
            .insert({"group_name": selectedOption, "user_id": userId})
            .select()
            .single();
        groupId = inserted['id'];
      }

      final existingMember = await Supabase.instance.client
          .from("group_members")
          .select()
          .eq("group_id", groupId)
          .eq("mobile_number", widget.mobile);

      if (existingMember.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${widget.name} is already in $selectedOption"),
          ),
        );
      } else {
        await Supabase.instance.client.from("group_members").insert({
          "group_id": groupId,
          "member_name": widget.name,
          "mobile_number": widget.mobile,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${widget.name} saved to $selectedOption")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Save ${widget.name} to Group",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...options.map(
            (option) => CheckboxListTile(
              title: Text(option),
              value: selectedOption == option,
              onChanged: (val) => setState(() => selectedOption = option),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                onPressed: () => setState(() => selectedOption = null),
                child: const Text("Clear"),
              ),
              ElevatedButton(
                onPressed: isLoading ? null : _saveFavorite,
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("Save"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
