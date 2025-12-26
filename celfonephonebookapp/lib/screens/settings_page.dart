// import 'package:celfonephonebookapp/screens/media_partner_signup.dart';
// import 'package:celfonephonebookapp/screens/optionMenuPage.dart';
// import 'package:celfonephonebookapp/supabase/supabase.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:celfonephonebookapp/screens/admin_panel_page.dart';
// import 'package:celfonephonebookapp/screens/profile_settings_page.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import './signup.dart';
// import './signin.dart';
// import 'homepage_shell.dart';

// // SettingsPage (main entry)
// class SettingsPage extends StatefulWidget {
//   const SettingsPage({super.key});

//   @override
//   State<SettingsPage> createState() => _SettingsPageState();
// }

// class _SettingsPageState extends State<SettingsPage> {
//   String? displayName;
//   bool _isLoading = true;
//   bool isAdmin = false;
//   bool isSignedIn = false;
//   @override
//   void initState() {
//     super.initState();
//     _loadUserProfile();
//     _checkAdmin();
//   }

//   Future<void> _loadUserProfile() async {
//     setState(() => _isLoading = true);
//     final prefs = await SharedPreferences.getInstance();
//     final cachedUserName = prefs.getString('username');
//     final userId = prefs.getString('userId');
//     setState(() {
//       displayName = cachedUserName;
//       _isLoading = false;
//     });
//   }

//   Future<void> _checkAdmin() async {
//     final prefs = await SharedPreferences.getInstance();
//     final userId = prefs.getString('userId');

//     if (userId != null) {
//       isSignedIn = true;
//       final response = await SupabaseService.client
//           .from('profiles')
//           .select('is_admin')
//           .eq('id', userId)
//           .single();

//       if (response != null && response['is_admin'] == true) {
//         setState(() {
//           isAdmin = true;
//         });
//       }
//     } else {
//       setState(() {
//         isSignedIn = false;
//         isAdmin = false;
//       });
//     }
//   }
//   Future<void> _logout(BuildContext context) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final favorites = prefs.getStringList('favorites_') ?? [];
//       await prefs.clear();
//       await prefs.setStringList('favorites_', favorites);

//       if (context.mounted) {
//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(builder: (_) => const HomePageShell()),
//               (route) => false,
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Logout failed: $e")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bool isSignedIn = displayName != null && displayName!.isNotEmpty;
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Settings"),
//         centerTitle: true,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           Column(
//             children: [
//               CircleAvatar(
//                 radius: 40,
//                 backgroundColor: Colors.blue.shade100,
//                 child: Text(
//                   (displayName != null && displayName!.isNotEmpty)
//                       ? displayName![0].toUpperCase()
//                       : "U",
//                   style: const TextStyle(
//                       fontSize: 28, fontWeight: FontWeight.bold),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 displayName ?? "Guest User",
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const SizedBox(height: 20),
//             ],
//           ),

//           // Auth options for guest
//           if (!isSignedIn) ...[
//             Card(
//               child: ListTile(
//                 title: const Text("Sign In"),
//                 trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (_) => const SigninPage()),
//                   );
//                 },
//               ),
//             ),
//             Card(
//               child: ListTile(
//                 title: const Text("Sign Up"),
//                 trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (_) => const SignupPage()),
//                   );
//                 },
//               ),
//             ),
//             const Divider(),
//           ],

//           // PROFILE SETTINGS
//           Card(
//             child: ListTile(
//               title: const Text("Profile Settings"),
//               trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//               subtitle: const Text("Update your profile and business details"),
//               onTap: () {
//                 if (isSignedIn) {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (_) => const ProfilePage()),
//                   );
//                 } else {
//                   showDialog(
//                     context: context,
//                     builder: (_) => AlertDialog(
//                       title: const Text("Not Logged In"),
//                       content: const Text(
//                           "You need to log in to access Profile Settings."),
//                       actions: [
//                         TextButton(
//                           onPressed: () {
//                             Navigator.of(context).pop();
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (_) => const SigninPage()),
//                             );
//                           },
//                           child: const Text("OK"),
//                         ),
//                       ],
//                     ),
//                   );
//                 }
//               },
//             ),
//           ),
//           if (isSignedIn)
//             Card(
//               child: ListTile(
//                 title: const Text("Media Partner"),
//                 subtitle: const Text("Earn Plenty with your Data"),
//                 trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => const OptionMenuPage(), // <- add your page here
//                     ),
//                   );
//                 },
//               ),
//             ),

//           // ADMIN PANEL
//           Card(
//             child: ListTile(
//               title: const Text("Admin Panel"),
//               trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//               subtitle: const Text("Access advanced admin features"),
//               onTap: isAdmin
//                   ? () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => const AdminPanelPage(),
//                   ),
//                 );
//               }
//                   : null, // disable tap if not admin
//               enabled: isAdmin, // makes it look disabled
//             ),
//           ),

//           // NOTIFICATION SETTINGS
//           Card(
//             child: ListTile(
//               title: const Text("Notification Settings"),
//               trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//               onTap: () {
//                 // TODO: Navigate to Notification Settings Page
//               },
//             ),
//           ),

//           // NEW: ORDER FORM
//           Card(
//             child: ListTile(
//               title: const Text("Order Form"),
//               trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//               subtitle: const Text("Choose your listing type"),
//               onTap: () {
//                 showModalBottomSheet(
//                   context: context,
//                   isScrollControlled: true,
//                   backgroundColor: Colors.transparent,
//                   builder: (_) => const OrderFormSheet(),
//                 );
//               },
//             ),
//           ),
//           const Divider(),

//           // Logout for logged-in user
//           if (isSignedIn)
//             Card(
//               child: ListTile(
//                 title: const Text("Logout"),
//                 trailing: const Icon(Icons.logout, color: Colors.red),
//                 onTap: () => _logout(context),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// // ORDER FORM SHEET WITH ALL THREE CARD TYPES
// class OrderFormSheet extends StatelessWidget {
//   const OrderFormSheet({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return DraggableScrollableSheet(
//       initialChildSize: 0.85,
//       maxChildSize: 0.95,
//       minChildSize: 0.45,
//       builder: (context, scroll) => Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius:
//           const BorderRadius.vertical(top: Radius.circular(28)),
//         ),
//         child: ListView(
//           controller: scroll,
//           children: [
//             Text(
//               'Choose Listing Type',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 24),
//             FreeListingCard(onTap: () {
//               Navigator.push(context,
//                   MaterialPageRoute(builder: (_) => const FreeListingProvisionPage())
//               );
//             }),
//             const SizedBox(height: 18),
//             BoldListingCard(onTap: () {
//               Navigator.push(context,
//                   MaterialPageRoute(builder: (_) => const BoldListingDetailPage())
//               );
//             }),
//             const SizedBox(height: 18),
//             PremiumListingCard(onTap: () {
//               Navigator.push(context,
//                   MaterialPageRoute(builder: (_) => const PremiumListingDetailPage())
//               );
//             }),
//             const SizedBox(height: 24),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // Free Listing Card
// class FreeListingCard extends StatelessWidget {
//   final VoidCallback onTap;
//   const FreeListingCard({required this.onTap, super.key});
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 1,
//       child: InkWell(
//         onTap: onTap,
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text("Sample Business", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 8),
//               Text("98989 XXXXX", style: TextStyle(fontSize: 17)),
//               const SizedBox(height: 4),
//               Text("Coimbatore", style: TextStyle(fontSize: 15, color: Colors.grey[700])),
//               const SizedBox(height: 12),
//               Row(
//                 children: [
//                   ElevatedButton.icon(icon: Icon(Icons.call), label: Text("Call"), onPressed: () {}),
//                   SizedBox(width: 8),
//                   ElevatedButton.icon(icon: Icon(Icons.info_outline), label: Text("Enquiry"), onPressed: () {}),
//                   SizedBox(width: 8),
//                   IconButton(icon: Icon(Icons.favorite_border), onPressed: () {}),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // Bold Listing Card
// class BoldListingCard extends StatelessWidget {
//   final VoidCallback onTap;
//   const BoldListingCard({required this.onTap, super.key});
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       color: Colors.blue[50],
//       child: InkWell(
//         onTap: onTap,
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text("Bold Sample Business", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 8),
//               Text("98989 XXXXX", style: TextStyle(fontSize: 17)),
//               const SizedBox(height: 4),
//               Text("Chennai", style: TextStyle(fontSize: 15, color: Colors.grey[700])),
//               const SizedBox(height: 12),
//               Row(
//                 children: [
//                   ElevatedButton.icon(icon: Icon(Icons.call), label: Text("Call"), onPressed: () {}),
//                   SizedBox(width: 8),
//                   ElevatedButton.icon(icon: Icon(Icons.info_outline), label: Text("Enquiry"), onPressed: () {}),
//                   SizedBox(width: 8),
//                   IconButton(icon: Icon(Icons.favorite), onPressed: () {}),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // Premium Listing Card
// class PremiumListingCard extends StatelessWidget {
//   final VoidCallback onTap;
//   const PremiumListingCard({required this.onTap, super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 10,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       margin: const EdgeInsets.symmetric(horizontal: 8),
//       child: InkWell(
//         onTap: onTap,
//         child: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 Color(0xFFFFF6B7), // Light gold
//                 Color(0xFFD5A800), // Deep gold
//               ],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(
//                 color: Color(0xFFD5A800).withOpacity(0.5),
//                 blurRadius: 12,
//                 offset: Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Padding(
//             padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 CircleAvatar(
//                   radius: 32,
//                   backgroundColor: Colors.white,
//                   child: Text(
//                     "P",
//                     style: TextStyle(
//                       fontSize: 34,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFFD5A800), // Gold
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 18),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "Premium Sample Biz",
//                         style: TextStyle(
//                           fontSize: 28,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.deepOrange, // Gold
//                           shadows: [
//                             Shadow(
//                               blurRadius: 6,
//                               color: Colors.black26,
//                               offset: Offset(0, 1),
//                             )
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 9),
//                       Text(
//                         "98989 XXXXX",
//                         style: TextStyle(
//                           fontSize: 18,
//                           color: Color(0xFF8C7000), // Golden brown
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         "Bangalore",
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Color(0xFFC0B283), // Pale gold
//                         ),
//                       ),
//                       const SizedBox(height: 15),
//                       Row(
//                         children: [
//                           ElevatedButton.icon(
//                             icon: Icon(Icons.call, color: Color(0xFFD5A800)),
//                             label: Text("Call",
//                                 style: TextStyle(
//                                   color: Color(0xFFD5A800),
//                                   fontWeight: FontWeight.bold,
//                                 )),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.white,
//                               shadowColor: Colors.amber,
//                               elevation: 2,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(6),
//                                 side: BorderSide(color: Color(0xFFD5A800), width: 1.2),
//                               ),
//                             ),
//                             onPressed: () {},
//                           ),
//                           SizedBox(width: 10),
//                           ElevatedButton.icon(
//                             icon: Icon(Icons.info_outline, color: Color(0xFFD5A800)),
//                             label: Text("Enquiry",
//                                 style: TextStyle(
//                                   color: Color(0xFFD5A800),
//                                   fontWeight: FontWeight.bold,
//                                 )),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.white,
//                               shadowColor: Colors.amber,
//                               elevation: 2,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(6),
//                                 side: BorderSide(color: Color(0xFFD5A800), width: 1.2),
//                               ),
//                             ),
//                             onPressed: () {},
//                           ),
//                           SizedBox(width: 10),
//                           IconButton(
//                             icon: Icon(Icons.favorite, color: Color(0xFFCEAB58), size: 28),
//                             onPressed: () {},
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // FREE: Card Tap Opens "provisions over" with Upgrade Button
// class FreeListingProvisionPage extends StatelessWidget {
//   const FreeListingProvisionPage({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Free Listing")),
//       body: Center(
//         child: Card(
//           elevation: 3,
//           margin: EdgeInsets.all(32),
//           child: Padding(
//             padding: const EdgeInsets.all(24.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(Icons.lock_outline, size: 46, color: Colors.redAccent),
//                 const SizedBox(height: 16),
//                 Text("Free listing provisions over.", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.pop(context); // Back to order form or upgrade logic
//                   },
//                   child: Text("Upgrade"),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // BOLD: Card Tap Opens Full Digital Visiting Card
// class BoldListingDetailPage extends StatelessWidget {
//   const BoldListingDetailPage({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Business Visiting Card")),
//       body: ListView(
//         padding: const EdgeInsets.all(22),
//         children: [
//           Text("Bold Sample Business", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 10),
//           Text("98989 XXXXX", style: TextStyle(fontSize: 18)),
//           Text("Chennai", style: TextStyle(fontSize: 16, color: Colors.grey[600])),
//           const SizedBox(height: 24),
//           TabBarSection(),
//           const SizedBox(height: 14),
//           Text("Activity", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
//           Text("Business activity details displayed here."),
//           const SizedBox(height: 14),
//           Text("Description", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
//           Text("About the business, services, and other information."),
//         ],
//       ),
//     );
//   }
// }

// // A sample TabBar for products (builds a TabBarView with dummy tabs)
// class TabBarSection extends StatelessWidget {
//   const TabBarSection({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 3,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           TabBar(
//             isScrollable: true,
//             labelColor: Colors.blue,
//             unselectedLabelColor: Colors.grey,
//             indicatorColor: Colors.blue,
//             tabs: [
//               Tab(text: "Product 1"),
//               Tab(text: "Product 2"),
//               Tab(text: "Product 3"),
//             ],
//           ),
//           Container(
//             height: 90,
//             child: TabBarView(
//               children: [
//                 Center(child: Text("Product 1 details...")),
//                 Center(child: Text("Product 2 details...")),
//                 Center(child: Text("Product 3 details...")),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // PREMIUM: Card Tap Opens Digital Visiting Card (can expand as needed)
// class PremiumListingDetailPage extends StatelessWidget {
//   const PremiumListingDetailPage({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Premium Digital Card")),
//       body: ListView(
//         padding: const EdgeInsets.all(22),
//         children: [
//           Row(
//             children: [
//               CircleAvatar(
//                 radius: 34,
//                 backgroundColor: Colors.white,
//                 child: Text("P", style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
//               ),
//               SizedBox(width: 22),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text("Premium Sample Biz", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
//                   Text("98989 XXXXX", style: TextStyle(fontSize: 18, color: Colors.indigo)),
//                   Text("Bangalore", style: TextStyle(fontSize: 16, color: Colors.purple[700])),
//                 ],
//               ),
//             ],
//           ),
//           const SizedBox(height: 18),
//           TabBarSection(),
//           const SizedBox(height: 14),
//           Text("Activity", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
//           Text("Premium business activity goes here."),
//           const SizedBox(height: 14),
//           Text("Description", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
//           Text("Extended information about services, rewards, and more."),
//         ],
//       ),
//     );
//   }
// }
// import 'package:celfonephonebookapp/screens/media_partner_signup.dart';
// import 'package:celfonephonebookapp/screens/optionMenuPage.dart';
// import 'package:celfonephonebookapp/supabase/supabase.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:celfonephonebookapp/screens/admin_panel_page.dart';
// import 'package:celfonephonebookapp/screens/profile_settings_page.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import './signup.dart';
// import './signin.dart';
// import 'homepage_shell.dart';

// class SettingsPage extends StatefulWidget {
//   const SettingsPage({super.key});

//   @override
//   State<SettingsPage> createState() => _SettingsPageState();
// }

// class _SettingsPageState extends State<SettingsPage> {
//   String? displayName;
//   bool _isLoading = true;
//   bool isAdmin = false;
//   bool isSignedIn = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadUserProfile();
//     _checkAdmin();
//   }

//   Future<void> _loadUserProfile() async {
//     setState(() => _isLoading = true);
//     final prefs = await SharedPreferences.getInstance();
//     final cachedUserName = prefs.getString('username');
//     final userId = prefs.getString('userId');
//     setState(() {
//       displayName = cachedUserName;
//       isSignedIn = userId != null;
//       _isLoading = false;
//     });
//   }

//   Future<void> _checkAdmin() async {
//     final prefs = await SharedPreferences.getInstance();
//     final userId = prefs.getString('userId');

//     if (userId == null) {
//       setState(() => isAdmin = false);
//       return;
//     }

//     try {
//       final response = await SupabaseService.client
//           .from('profiles')
//           .select('is_admin')
//           .eq('id', userId)
//           .single();

//       setState(() => isAdmin = (response['is_admin'] == true));
//     } catch (e) {
//       debugPrint('Admin check error: $e');
//       setState(() => isAdmin = false);
//     }
//   }

//   Future<void> _logout(BuildContext context) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final favorites = prefs.getStringList('favorites_') ?? [];
//       await prefs.clear();
//       await prefs.setStringList('favorites_', favorites);

//       if (context.mounted) {
//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(builder: (_) => const HomePageShell()),
//           (route) => false,
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Logout failed: $e")));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bool showAuth = !isSignedIn;

//     return Scaffold(
//       backgroundColor: const Color(0xFFF8FAFC),
//       appBar: AppBar(
//         title: const Text("Settings"),
//         centerTitle: true,
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         foregroundColor: Colors.black87,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : CustomScrollView(
//               slivers: [
//                 // Profile Header
//                 SliverToBoxAdapter(
//                   child: Container(
//                     margin: const EdgeInsets.all(20),
//                     padding: const EdgeInsets.all(24),
//                     decoration: BoxDecoration(
//                       gradient: const LinearGradient(
//                         colors: [
//                           Color(0xFF1E88E5),
//                           Color.fromARGB(255, 172, 214, 246),
//                         ],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                       borderRadius: BorderRadius.circular(20),
//                       boxShadow: const [
//                         BoxShadow(
//                           color: Colors.black12,
//                           blurRadius: 12,
//                           offset: Offset(0, 6),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       children: [
//                         CircleAvatar(
//                           radius: 42,
//                           backgroundColor: Colors.white,
//                           child: Text(
//                             (displayName?.isNotEmpty == true)
//                                 ? displayName![0].toUpperCase()
//                                 : "U",
//                             style: const TextStyle(
//                               fontSize: 36,
//                               fontWeight: FontWeight.bold,
//                               color: Color(0xFF1E88E5),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 12),
//                         Text(
//                           displayName ?? "Guest User",
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           isSignedIn
//                               ? "Welcome back!"
//                               : "Sign in to unlock features",
//                           style: const TextStyle(
//                             color: Colors.white70,
//                             fontSize: 14,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),

//                 // Guest Login Cards
//                 if (showAuth)
//                   SliverToBoxAdapter(
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 20),
//                       child: Column(
//                         children: [
//                           _buildActionCard(
//                             title: "Sign In",
//                             icon: Icons.login,
//                             color: Colors.blue,
//                             onTap: () => Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) => const SigninPage(),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 12),
//                           _buildActionCard(
//                             title: "Sign Up",
//                             icon: Icons.person_add,
//                             color: Colors.green,
//                             onTap: () => Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) => const SignupPage(),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 20),
//                         ],
//                       ),
//                     ),
//                   ),

//                 // Menu Items
//                 SliverList(
//                   delegate: SliverChildListDelegate([
//                     _buildMenuItem(
//                       title: "Profile Settings",
//                       subtitle: "Update your profile and business details",
//                       icon: Icons.person_outline,
//                       onTap: isSignedIn
//                           ? () => Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) => const ProfilePage(),
//                               ),
//                             )
//                           : () => _showLoginRequired(context),
//                     ),

//                     if (isSignedIn)
//                       _buildMenuItem(
//                         title: "Media Partner",
//                         subtitle: "Earn Plenty with your Data",
//                         icon: Icons.monetization_on,
//                         color: Colors.orange,
//                         onTap: () => Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => const OptionMenuPage(),
//                           ),
//                         ),
//                       ),

//                     _buildMenuItem(
//                       title: "Admin Panel",
//                       subtitle: "Access advanced admin features",
//                       icon: Icons.admin_panel_settings,
//                       color: Colors.purple,
//                       onTap: isAdmin
//                           ? () => Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) => const AdminPanelPage(),
//                               ),
//                             )
//                           : null,
//                       enabled: isAdmin,
//                     ),

//                     _buildMenuItem(
//                       title: "Notification Settings",
//                       icon: Icons.notifications_outlined,
//                       onTap: () {},
//                     ),

//                     // SUBSCRIPTION PLAN
//                     _buildMenuItem(
//                       title: "Subscription Plan",
//                       subtitle: "View and upgrade your branding package",
//                       icon: Icons.subscriptions_outlined,
//                       color: Colors.deepOrange,
//                       onTap: isSignedIn
//                           ? () => Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) => const SubscriptionPlan(),
//                               ),
//                             )
//                           : () => _showLoginRequired(context),
//                     ),

//                     if (isSignedIn)
//                       Padding(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 20,
//                           vertical: 10,
//                         ),
//                         child: _buildActionCard(
//                           title: "Logout",
//                           icon: Icons.logout,
//                           color: Colors.red,
//                           onTap: () => _logout(context),
//                         ),
//                       ),

//                     const SizedBox(height: 40),
//                   ]),
//                 ),
//               ],
//             ),
//     );
//   }

//   Widget _buildActionCard({
//     required String title,
//     required IconData icon,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return Card(
//       elevation: 3,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(16),
//         onTap: onTap,
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Icon(icon, color: color, size: 28),
//               ),
//               const SizedBox(width: 16),
//               Text(
//                 title,
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const Spacer(),
//               const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildMenuItem({
//     required String title,
//     String? subtitle,
//     required IconData icon,
//     Color? color,
//     required VoidCallback? onTap,
//     bool enabled = true,
//   }) {
//     return Opacity(
//       opacity: enabled ? 1.0 : 0.5,
//       child: Card(
//         margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
//         elevation: 2,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         child: ListTile(
//           enabled: enabled,
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 20,
//             vertical: 8,
//           ),
//           leading: Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: (color ?? Colors.blue).withOpacity(0.1),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(icon, color: color ?? Colors.blue, size: 26),
//           ),
//           title: Text(
//             title,
//             style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
//           ),
//           subtitle: subtitle != null
//               ? Text(
//                   subtitle,
//                   style: TextStyle(fontSize: 13, color: Colors.grey[600]),
//                 )
//               : null,
//           trailing: const Icon(
//             Icons.arrow_forward_ios,
//             size: 16,
//             color: Colors.grey,
//           ),
//           onTap: onTap,
//         ),
//       ),
//     );
//   }

//   void _showLoginRequired(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text("Login Required"),
//         content: const Text("You need to log in to access this feature."),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => const SigninPage()),
//               );
//             },
//             child: const Text("Sign In"),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ====================== SUBSCRIPTION PLAN WITH OFFER PRICING ======================
// class SubscriptionPlan extends StatefulWidget {
//   const SubscriptionPlan({super.key});

//   @override
//   State<SubscriptionPlan> createState() => _SubscriptionPlanState();
// }

// class _SubscriptionPlanState extends State<SubscriptionPlan> {
//   bool isYearly = true;

//   final Map<String, Map<String, String>> plans = {
//     "FREE LISTING": {"monthly": "FREE", "yearly": "FREE"},
//     "NORMAL LISTING": {"monthly": "₹200", "yearly": "₹2,000"},
//     "PRIORITY LISTING": {"monthly": "₹500", "yearly": "₹5,000"},
//     "PREMIUM LISTING": {"monthly": "₹750", "yearly": "₹7,500"},
//   };

//   String getMonthlyPrice(String plan) => plans[plan]!["monthly"]!;
//   String getYearlyPrice(String plan) => plans[plan]!["yearly"]!;

//   String getSavings(String plan) {
//     if (plan == "FREE LISTING") return "";
//     final monthly = double.parse(
//       plans[plan]!["monthly"]!.replaceAll("₹", "").trim(),
//     );
//     final yearly = double.parse(
//       plans[plan]!["yearly"]!.replaceAll("₹", "").replaceAll(",", "").trim(),
//     );
//     final saved = (monthly * 12) - yearly;
//     return saved > 0 ? "Save ₹${saved.toInt()}" : "";
//   }

//   // Define border color for each plan
//   Color getBorderColor(String title) {
//     switch (title) {
//       case "FREE LISTING":
//         return Colors.grey.shade600;
//       case "NORMAL LISTING":
//         return const Color.fromARGB(255, 255, 0, 251); // Your purple/pink
//       case "PRIORITY LISTING":
//         return const Color.fromARGB(255, 255, 221, 0); // Gold
//       case "PREMIUM LISTING":
//         return const Color.fromARGB(255, 255, 208, 0); // Premium Gold
//       default:
//         return Colors.grey;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xffF7F7F7),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//         title: const Text(
//           "Branding Ads Subscription",
//           style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(18),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               "Tariff & Facilities",
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
//             ),
//             const SizedBox(height: 16),

//             // Monthly / Yearly Toggle
//             Center(
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 8,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(30),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black12,
//                       blurRadius: 8,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     _toggleButton("Monthly", !isYearly),
//                     const SizedBox(width: 8),
//                     _toggleButton("Yearly", isYearly),
//                     if (isYearly)
//                       Container(margin: const EdgeInsets.only(left: 1)),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 30),

//             // PLAN CARDS — Now ALL have colored borders
//             buildPlanCard(
//               title: "FREE LISTING",
//               color: Colors.grey.shade800,
//               features: [
//                 true,
//                 true,
//                 true,
//                 false,
//                 false,
//                 false,
//                 false,
//                 false,
//                 false,
//                 false,
//                 false,
//                 false,
//               ],
//             ),
//             buildPlanCard(
//               title: "NORMAL LISTING",
//               color: const Color.fromARGB(255, 255, 0, 251),
//               features: [
//                 true,
//                 true,
//                 true,
//                 true,
//                 true,
//                 true,
//                 true,
//                 false,
//                 false,
//                 false,
//                 false,
//                 false,
//               ],
//             ),
//             buildPlanCard(
//               title: "PRIORITY LISTING",
//               color: const Color.fromARGB(255, 255, 221, 0),
//               features: [
//                 true,
//                 true,
//                 true,
//                 true,
//                 true,
//                 true,
//                 true,
//                 true,
//                 false,
//                 false,
//                 false,
//                 false,
//               ],
//             ),
//             buildPlanCard(
//               title: "PREMIUM LISTING",
//               color: const Color.fromARGB(255, 255, 221, 0),
//               features: [
//                 true,
//                 true,
//                 true,
//                 true,
//                 true,
//                 true,
//                 true,
//                 true,
//                 true,
//                 true,
//                 true,
//                 true,
//               ],
//               isPopular: true,
//             ),

//             const SizedBox(height: 40),
//             Center(
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.redAccent,
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 70,
//                     vertical: 20,
//                   ),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   elevation: 10,
//                 ),
//                 onPressed: () {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text("Payment gateway in progress!"),
//                     ),
//                   );
//                 },
//                 child: Text(
//                   isYearly
//                       ? "Subscribe Yearly & Save Big!"
//                       : "Subscribe Monthly",
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 60),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _toggleButton(String text, bool selected) {
//     return GestureDetector(
//       onTap: () => setState(() => isYearly = text == "Yearly"),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 250),
//         padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
//         decoration: BoxDecoration(
//           color: selected ? Colors.deepOrange : Colors.transparent,
//           borderRadius: BorderRadius.circular(30),
//         ),
//         child: Text(
//           text,
//           style: TextStyle(
//             color: selected ? Colors.white : Colors.black87,
//             fontWeight: FontWeight.w600,
//             fontSize: 16,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildPlanCard({
//     required String title,
//     required Color color,
//     required List<bool> features,
//     bool isPopular = false,
//   }) {
//     final monthlyPrice = getMonthlyPrice(title);
//     final yearlyPrice = getYearlyPrice(title);
//     final savings = getSavings(title);
//     final borderColor = getBorderColor(title);

//     const featureNames = [
//       "Address",
//       "Communication",
//       "Enquiry",
//       "Highlight",
//       "Description",
//       "Location Map",
//       "Website Link",
//       "Leads",
//       "Product Photos",
//       "Products Description",
//       "Product Pricing",
//       "Product Enquiry",
//     ];

//     return Container(
//       margin: const EdgeInsets.only(bottom: 22),
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: borderColor,
//           width: isPopular ? 3.5 : 2.8,
//         ), // Beautiful colored border
//         boxShadow: [
//           BoxShadow(
//             color: borderColor.withOpacity(0.25),
//             blurRadius: 15,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           if (isPopular)
//             Align(
//               alignment: Alignment.topRight,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 8,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.redAccent,
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: const Text(
//                   "MOST POPULAR",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 12,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),

//           Text(
//             title.toUpperCase(),
//             style: TextStyle(
//               fontSize: 19,
//               fontWeight: FontWeight.bold,
//               color: color,
//             ),
//           ),
//           const SizedBox(height: 14),

//           // Pricing with Offer
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               if (isYearly && title != "FREE LISTING") ...[
//                 Text(
//                   "₹${(double.parse(monthlyPrice.replaceAll("₹", "").trim()) * 12).toInt()}",
//                   style: const TextStyle(
//                     fontSize: 20,
//                     color: Colors.grey,
//                     decoration: TextDecoration.lineThrough,
//                     decorationThickness: 2.8,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//               ],

//               Text(
//                 isYearly ? yearlyPrice : monthlyPrice,
//                 style: TextStyle(
//                   fontSize: isYearly ? 34 : 30,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 6),
//                 child: Text(
//                   isYearly ? "/year" : "/month",
//                   style: TextStyle(color: Colors.grey[600], fontSize: 17),
//                 ),
//               ),
//             ],
//           ),

//           if (isYearly && savings.isNotEmpty)
//             Padding(
//               padding: const EdgeInsets.only(top: 10),
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 14,
//                   vertical: 8,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.green.shade50,
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(color: Colors.green.shade500, width: 1.5),
//                 ),
//                 child: Text(
//                   savings,
//                   style: TextStyle(
//                     color: Colors.green.shade700,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 15,
//                   ),
//                 ),
//               ),
//             ),

//           const SizedBox(height: 20),
//           const Divider(color: Colors.grey, height: 30),
//           const SizedBox(height: 10),

//           // Features List
//           ...List.generate(featureNames.length, (i) {
//             final hasFeature = i < features.length ? features[i] : false;
//             return Padding(
//               padding: const EdgeInsets.symmetric(vertical: 8),
//               child: Row(
//                 children: [
//                   Icon(
//                     hasFeature ? Icons.check_circle : Icons.cancel,
//                     size: 26,
//                     color: hasFeature ? color : Colors.grey[400],
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: Text(
//                       featureNames[i],
//                       style: TextStyle(
//                         fontSize: 16.5,
//                         color: hasFeature ? Colors.black87 : Colors.grey[500],
//                         fontWeight: hasFeature
//                             ? FontWeight.w500
//                             : FontWeight.normal,
//                         decoration: hasFeature
//                             ? null
//                             : TextDecoration.lineThrough,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }),
//         ],
//       ),
//     );
//   }
// }
import 'package:celfonephonebookapp/screens/media_partner_signup.dart';
import 'package:celfonephonebookapp/screens/optionMenuPage.dart';
import 'package:celfonephonebookapp/supabase/supabase.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:celfonephonebookapp/screens/admin_panel_page.dart';
import 'package:celfonephonebookapp/screens/profile_settings_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import './signup.dart';
import './signin.dart';
import 'homepage_shell.dart';
import 'package:celfonephonebookapp/screens/SubscriptionPlan.dart';
import 'package:celfonephonebookapp/screens/find_number.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? displayName;
  bool _isLoading = true;
  bool isAdmin = false;
  bool isSignedIn = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _checkAdmin();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final cachedUserName = prefs.getString('username');
    final userId = prefs.getString('userId');
    setState(() {
      displayName = cachedUserName;
      isSignedIn = userId != null;
      _isLoading = false;
    });
  }

  Future<void> _checkAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      setState(() => isAdmin = false);
      return;
    }

    try {
      final response = await SupabaseService.client
          .from('profiles')
          .select('is_admin')
          .eq('id', userId)
          .single();

      setState(() => isAdmin = (response['is_admin'] == true));
    } catch (e) {
      debugPrint('Admin check error: $e');
      setState(() => isAdmin = false);
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = prefs.getStringList('favorites_') ?? [];
      await prefs.clear();
      await prefs.setStringList('favorites_', favorites);

      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomePageShell()),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Logout failed: $e")));
    }
  }

  void _showLoginRequired(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Login Required"),
        content: const Text("You need to log in to access this feature."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SigninPage()),
              );
            },
            child: const Text("Sign In"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool showAuth = !isSignedIn;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // Compact Profile Header: Avatar left, Name + text right
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF1E88E5),
                          Color.fromARGB(255, 172, 214, 246),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.white,
                          child: Text(
                            (displayName?.isNotEmpty == true)
                                ? displayName![0].toUpperCase()
                                : "U",
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E88E5),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                displayName ?? "Guest User",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isSignedIn
                                    ? "Welcome back!"
                                    : "Sign in to unlock features",
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Guest Sign In / Sign Up Cards
                if (showAuth)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          _buildActionCard(
                            title: "Sign In",
                            icon: Icons.login,
                            color: Colors.blue,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SigninPage(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildActionCard(
                            title: "Sign Up",
                            icon: Icons.person_add,
                            color: Colors.green,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignupPage(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),

                // Menu Items - Clean & Compact
                SliverList(
                  delegate: SliverChildListDelegate([
                    _buildMenuItem(
                      title: "Profile Settings",
                      icon: Icons.person_outline,
                      color: Colors.blue,
                      onTap: isSignedIn
                          ? () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProfilePage(),
                              ),
                            )
                          : () => _showLoginRequired(context),
                    ),
                    if (isSignedIn)
                      _buildMenuItem(
                        title: "Media Partner",
                        icon: Icons.monetization_on,
                        color: Colors.orange,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const OptionMenuPage(),
                          ),
                        ),
                      ),
                    if (isSignedIn)
                      _buildMenuItem(
                        title: "Find Number",
                        icon: Icons.search,
                        color: Colors.teal,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const FindNumberPage(),
                          ),
                        ),
                      ),
                    if (isAdmin)
                      _buildMenuItem(
                        title: "Admin Panel",
                        icon: Icons.admin_panel_settings,
                        color: Colors.purple,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminPanelPage(),
                          ),
                        ),
                      ),
                    _buildMenuItem(
                      title: "Notification Settings",
                      icon: Icons.notifications_outlined,
                      color: Colors.blue,
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      title: "Subscription Plan",
                      icon: Icons.subscriptions_outlined,
                      color: Colors.deepOrange,
                      onTap: isSignedIn
                          ? () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SubscriptionPlan(),
                              ),
                            )
                          : () => _showLoginRequired(context),
                    ),
                    if (isSignedIn)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: _buildActionCard(
                          title: "Logout",
                          icon: Icons.logout,
                          color: Colors.red,
                          onTap: () => _logout(context),
                        ),
                      ),
                    const SizedBox(height: 30),
                  ]),
                ),
              ],
            ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 14),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, size: 15, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
    bool enabled = true,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          enabled: enabled,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 4,
          ),
          leading: Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          title: Text(
            title,
            style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w600),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 15,
            color: Colors.grey,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
