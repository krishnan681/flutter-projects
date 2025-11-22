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

    if (userId != null) {
      try {
        final response = await SupabaseService.client
            .from('profiles')
            .select('is_admin')
            .eq('id', userId)
            .single();

        if (response != null && response['is_admin'] == true) {
          setState(() => isAdmin = true);
        }
      } catch (e) {
        debugPrint("Admin check failed: $e");
      }
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
                // === Profile Header ===
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF1E88E5),
                          Color.fromARGB(255, 172, 214, 246),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 42,
                          backgroundColor: Colors.white,
                          child: Text(
                            (displayName?.isNotEmpty == true)
                                ? displayName![0].toUpperCase()
                                : "U",
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E88E5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          displayName ?? "Guest User",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
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
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // === Auth Cards (Guest Only) ===
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
                          const SizedBox(height: 12),
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
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                // === Main Menu Items ===
                SliverList(
                  delegate: SliverChildListDelegate([
                    _buildMenuItem(
                      title: "Profile Settings",
                      subtitle: "Update your profile and business details",
                      icon: Icons.person_outline,
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
                        subtitle: "Earn Plenty with your Data",
                        icon: Icons.monetization_on,
                        color: Colors.orange,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const OptionMenuPage(),
                          ),
                        ),
                      ),
                    _buildMenuItem(
                      title: "Admin Panel",
                      subtitle: "Access advanced admin features",
                      icon: Icons.admin_panel_settings,
                      color: Colors.purple,
                      onTap: isAdmin
                          ? () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AdminPanelPage(),
                              ),
                            )
                          : null,
                      enabled: isAdmin,
                    ),
                    _buildMenuItem(
                      title: "Notification Settings",
                      icon: Icons.notifications_outlined,
                      onTap: () {
                        // TODO
                      },
                    ),
                    _buildMenuItem(
                      title: "Order Form",
                      subtitle: "Choose your listing type",
                      icon: Icons.shopping_cart_outlined,
                      color: Colors.indigo,
                      onTap: () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const OrderFormSheet(),
                      ),
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
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required String title,
    String? subtitle,
    required IconData icon,
    Color? color,
    required VoidCallback? onTap,
    bool enabled = true,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          enabled: enabled,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 8,
          ),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (color ?? Colors.blue).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color ?? Colors.blue, size: 26),
          ),
          title: Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                )
              : null,
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey,
          ),
          onTap: onTap,
        ),
      ),
    );
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
}

// ORDER FORM SHEET
class OrderFormSheet extends StatelessWidget {
  const OrderFormSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                children: [
                  const Text(
                    "Choose Your Listing Type",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FreeListingCard(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FreeListingProvisionPage(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  BoldListingCard(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BoldListingDetailPage(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  PremiumListingCard(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PremiumListingDetailPage(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// FREE LISTING CARD
class FreeListingCard extends StatelessWidget {
  final VoidCallback onTap;
  const FreeListingCard({required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return _buildListingCard(
      context: context,
      title: "Sample Business",
      phone: "98989 XXXXX",
      location: "Coimbatore",
      bgColor: Colors.grey[50],
      titleColor: Colors.black87,
      onTap: onTap,
      favoriteIcon: Icons.favorite_border,
    );
  }
}

// BOLD LISTING CARD
class BoldListingCard extends StatelessWidget {
  final VoidCallback onTap;
  const BoldListingCard({required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return _buildListingCard(
      context: context,
      title: "Bold Sample Business",
      phone: "98989 XXXXX",
      location: "Chennai",
      bgColor: Colors.blue[50],
      titleColor: Colors.blue[900],
      onTap: onTap,
      favoriteIcon: Icons.favorite,
      isBold: true,
    );
  }
}

// PREMIUM LISTING CARD
class PremiumListingCard extends StatelessWidget {
  final VoidCallback onTap;
  const PremiumListingCard({required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFF6B7), Color(0xFFF9D423)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: Colors.white,
                child: Text(
                  "P",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD4AF37),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Premium Sample Biz",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD4AF37),
                        shadows: [
                          Shadow(
                            blurRadius: 4,
                            color: Colors.black26,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "98989 XXXXX",
                      style: TextStyle(fontSize: 17, color: Color(0xFF8B6F47)),
                    ),
                    Text(
                      "Bangalore",
                      style: TextStyle(fontSize: 15, color: Color(0xFFB8860B)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _goldButton(icon: Icons.call, label: "Call"),
                        const SizedBox(width: 8),
                        _goldButton(icon: Icons.info_outline, label: "Enquiry"),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(
                            Icons.favorite,
                            color: Color(0xFFD4AF37),
                            size: 28,
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _goldButton({required IconData icon, required String label}) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Color(0xFFD4AF37)),
      label: Text(
        label,
        style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Color(0xFFD4AF37), width: 1.5),
        ),
      ),
      onPressed: () {},
    );
  }
}

// REUSABLE LISTING CARD
Widget _buildListingCard({
  required BuildContext context,
  required String title,
  required String phone,
  required String location,
  Color? bgColor,
  Color? titleColor,
  required VoidCallback onTap,
  required IconData favoriteIcon,
  bool isBold = false,
}) {
  return Card(
    color: bgColor,
    elevation: isBold ? 4 : 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: titleColor ?? Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(phone, style: const TextStyle(fontSize: 17)),
            const SizedBox(height: 4),
            Text(
              location,
              style: TextStyle(fontSize: 15, color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.call),
                  label: const Text("Call"),
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.info_outline),
                  label: const Text("Enquiry"),
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
                IconButton(icon: Icon(favoriteIcon), onPressed: () {}),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

// FREE → Upgrade Page
class FreeListingProvisionPage extends StatelessWidget {
  const FreeListingProvisionPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Free Listing")),
      body: Center(
        child: Card(
          elevation: 6,
          margin: const EdgeInsets.all(32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_clock, size: 64, color: Colors.orange[700]),
                const SizedBox(height: 20),
                const Text(
                  "Free Listing Limit Reached",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Upgrade to continue adding listings.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Upgrade Now",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// BOLD → Digital Visiting Card
class BoldListingDetailPage extends StatelessWidget {
  const BoldListingDetailPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Business Visiting Card")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "Bold Sample Business",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text("98989 XXXXX", style: TextStyle(fontSize: 18)),
          Text(
            "Chennai",
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          const TabBarSection(),
          const SizedBox(height: 20),
          const Text(
            "Activity",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const Text("Business activity details displayed here."),
          const SizedBox(height: 16),
          const Text(
            "Description",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const Text("About the business, services, and other information."),
        ],
      ),
    );
  }
}

// PREMIUM → Digital Card
class PremiumListingDetailPage extends StatelessWidget {
  const PremiumListingDetailPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Premium Digital Card")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: Colors.amber[100],
                child: Text(
                  "P",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[800],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Premium Sample Biz",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                  Text("98989 XXXXX", style: TextStyle(fontSize: 17)),
                  Text(
                    "Bangalore",
                    style: TextStyle(fontSize: 15, color: Colors.amber),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const TabBarSection(),
          const SizedBox(height: 20),
          const Text(
            "Activity",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const Text("Premium business activity goes here."),
          const SizedBox(height: 16),
          const Text(
            "Description",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const Text("Extended information about services, rewards, and more."),
        ],
      ),
    );
  }
}

// FIXED TAB BAR SECTION
class TabBarSection extends StatelessWidget {
  const TabBarSection({Key? key})
    : super(key: key); // Removed `const` and `super.key`

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TabBar(
            isScrollable: true,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            tabs: [
              Tab(text: "Product 1"),
              Tab(text: "Product 2"),
              Tab(text: "Product 3"),
            ],
          ),
          Container(
            height: 100,
            child: const TabBarView(
              children: [
                Center(child: Text("Product 1 details...")),
                Center(child: Text("Product 2 details...")),
                Center(child: Text("Product 3 details...")),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
