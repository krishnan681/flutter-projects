// import 'package:celfonephonebookapp/screens/%20search_page.dart';
// import 'package:celfonephonebookapp/screens/signin.dart';
// import 'package:celfonephonebookapp/widgets/carousel_widgets.dart';
// import 'package:celfonephonebookapp/widgets/playbook_carousel.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:lottie/lottie.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import '../supabase/supabase.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// // 🔹 Category Model
// class CategoryItem {
//   final String title;
//   final String image;
//   final String imageTitle;
//   final String keywords;

//   CategoryItem({
//     required this.title,
//     required this.image,
//     required this.imageTitle,
//     required this.keywords,
//   });

//   factory CategoryItem.fromMap(Map<String, dynamic> map) {
//     return CategoryItem(
//       title: map['group_title'] ?? '',
//       image: map['image'] ?? '',
//       imageTitle: map['image_title'] ?? '',
//       keywords: map['image_keywords'] ?? '',
//     );
//   }
// }

// class _HomePageState extends State<HomePage>
//     with SingleTickerProviderStateMixin {
//   String? username;
//   String? userId;

//   // 🔹 Banner & Festival Animation State
//   final SupabaseClient supabase = SupabaseService.client;
//   List<Map<String, dynamic>> banners = [];
//   bool isLoading = true;
//   int currentIndex = 0;

//   // 🔹 Categories
//   List<CategoryItem> categoriesFromBackend = [];
//   bool isCategoriesLoading = true;

//   // 🔹 A–Z Letters
//   final List<String> letters = List.generate(
//     26,
//     (index) => String.fromCharCode(65 + index),
//   );

//   @override
//   void initState() {
//     super.initState();
//     _loadCachedUserData();
//     _loadBanners();
//     _loadCategories();
//   }

//   Future<void> _loadCachedUserData() async {
//     final prefs = await SharedPreferences.getInstance();
//     username = prefs.getString("username");
//     userId = prefs.getString("userId");

//     if (username == null || username!.isEmpty) {
//       Future.delayed(const Duration(seconds: 3), () {
//         if (context.mounted) {
//           showDialog(
//             context: context,
//             builder: (context) {
//               return AlertDialog(
//                 title: const Text("Welcome Celfon5G+ Phonebook"),
//                 content: const Text("Log in for more features"),
//                 actions: [
//                   TextButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: const Text("Later"),
//                   ),
//                   TextButton(
//                     onPressed: () {
//                       Navigator.pop(context);
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (_) => const SigninPage()),
//                       );
//                     },
//                     child: const Text("Log In"),
//                   ),
//                 ],
//               );
//             },
//           );
//         }
//       });
//     }
//   }

//   Future<void> _loadBanners() async {
//     try {
//       final response = await supabase.from('app_banner').select();
//       final data = (response as List)
//           .map(
//             (e) => {
//               "image_url": e['image_url'] as String,
//               "festival": e['festival'] as String? ?? "default",
//             },
//           )
//           .toList();

//       setState(() {
//         banners = data;
//         isLoading = false;
//       });
//     } catch (e) {
//       debugPrint("Error fetching banners: $e");
//       setState(() => isLoading = false);
//     }
//   }

//   Future<void> _loadCategories() async {
//     try {
//       final response = await supabase.from('tiles_titles').select();
//       final data = (response as List)
//           .map((e) => CategoryItem.fromMap(e))
//           .toList();

//       setState(() {
//         categoriesFromBackend = data;
//         isCategoriesLoading = false;
//       });
//     } catch (e) {
//       debugPrint("Error fetching categories: $e");
//       setState(() => isCategoriesLoading = false);
//     }
//   }

//   void _goToSearch(BuildContext context, {String? category}) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => SearchPage(category: category)),
//     );
//   }

//   // 🔹 Quick Search Grid Widget
//   Widget _buildQuickSearch() {
//     if (isCategoriesLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     return GridView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: categoriesFromBackend.length,
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 1, // 👈 one full-width tile per row
//         mainAxisSpacing: 12,
//         childAspectRatio: 5, // 👈 adjust height (4–6 works well)
//       ),
//       itemBuilder: (context, index) {
//         final category = categoriesFromBackend[index];

//         return GestureDetector(
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => SearchPage(category: category.keywords),
//               ),
//             );
//           },
//           child: Container(
//             width: double.infinity,
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(14),
//               border: Border.all(
//                 color: Colors.blueAccent.shade100.withOpacity(0.4),
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 5,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Row(
//               children: [
//                 // Left side image
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(10),
//                   child: category.image.isNotEmpty
//                       ? Image.network(
//                           category.image,
//                           height: 50,
//                           width: 50,
//                           fit: BoxFit.cover,
//                         )
//                       : Container(
//                           height: 50,
//                           width: 50,
//                           color: Colors.blue[50],
//                           child: const Icon(
//                             Icons.category,
//                             color: Colors.blueAccent,
//                             size: 28,
//                           ),
//                         ),
//                 ),

//                 const SizedBox(width: 14),

//                 // Right side text
//                 Expanded(
//                   child: Text(
//                     category.title,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.black87,
//                     ),
//                   ),
//                 ),

//                 // Optional forward arrow
//                 const Icon(
//                   Icons.arrow_forward_ios_rounded,
//                   size: 16,
//                   color: Colors.grey,
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: CustomScrollView(
//         slivers: [
//           // 🔹 Fixed Search Bar
//           SliverAppBar(
//             pinned: true,
//             backgroundColor: Colors.white,
//             elevation: 4,
//             title: GestureDetector(
//               onTap: () => _goToSearch(context),
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 8,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.blue[100],
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.grey.shade300),
//                 ),
//                 child: Row(
//                   children: const [
//                     Icon(Icons.search, color: Colors.grey),
//                     SizedBox(width: 8),
//                     Text(
//                       "Search Firms, Persons, Products, Brands",
//                       style: TextStyle(
//                         color: Colors.grey,
//                         fontSize: 17, // <-- Add your desired font size here
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),

//           // 🔹 Top Banner with Festival Animation
//           SliverToBoxAdapter(
//             child: SizedBox(
//               height: 100,
//               child: Stack(
//                 children: [
//                   if (isLoading)
//                     const Center(child: CircularProgressIndicator())
//                   else if (banners.isEmpty)
//                     const Center(child: Text("No banners available"))
//                   else
//                     CarouselSlider.builder(
//                       itemCount: banners.length,
//                       options: CarouselOptions(
//                         height: 100,
//                         autoPlay: true,
//                         enlargeCenterPage: true,
//                         viewportFraction: 0.9,
//                         onPageChanged: (index, reason) {
//                           setState(() {
//                             currentIndex = index;
//                           });
//                         },
//                       ),
//                       itemBuilder: (context, index, realIdx) {
//                         final banner = banners[index];
//                         return ClipRRect(
//                           borderRadius: BorderRadius.circular(16),
//                           child: Image.network(
//                             banner['image_url'],
//                             fit: BoxFit.cover,
//                             width: double.infinity,
//                           ),
//                         );
//                       },
//                     ),

//                   if (banners.isNotEmpty)
//                     Positioned.fill(
//                       child: IgnorePointer(
//                         ignoring: true,
//                         // child: Lottie.asset(
//                         //   _getFestivalAnimation(
//                         //     banners[currentIndex]['festival'],
//                         //   ),
//                         //   fit: BoxFit.cover,
//                         //   repeat: true,
//                         // ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ),

//           // 🔹 Rest of the Content
//           SliverList(
//             delegate: SliverChildListDelegate([
//               const SizedBox(height: 16),

//               // A-Z Horizontal Scroll
//               SizedBox(
//                 height: 60,
//                 child: ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   padding: const EdgeInsets.symmetric(horizontal: 12),
//                   itemCount: letters.length,
//                   itemBuilder: (context, index) {
//                     final letter = letters[index];
//                     return Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 6),
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.blueAccent,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           padding: const EdgeInsets.symmetric(horizontal: 16),
//                         ),
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) =>
//                                   SearchPage(selectedLetter: letter),
//                             ),
//                           );
//                         },
//                         child: Text(
//                           letter,
//                           style: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               const SizedBox(height: 24),

//               const CarouselWidget(
//                 images: [
//                   "assets/images/images1.png",
//                   "assets/images/images2.png",
//                   "assets/images/images3.png",
//                 ],
//               ),
//               const SizedBox(height: 24),

//               // 🔹 Quick Search Section
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 8,
//                 ),
//                 child: SizedBox(
//                   width: double.infinity, // ✅ makes it 100% width
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         "Fast Find",
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       SizedBox(
//                         width: double.infinity, // 👈 inner 100%
//                         child: _buildQuickSearch(),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 24),

//               // Play Book
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Padding(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: 16.0,
//                       vertical: 8.0,
//                     ),
//                     child: Text(
//                       "Play Book",
//                       style: TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87,
//                       ),
//                     ),
//                   ),
//                   SizedBox(
//                     height: 400,
//                     child: PlayBookWidget(
//                       images: [
//                         "assets/images/book1.png",
//                         "assets/images/book2.png",
//                         "assets/images/book3.png",
//                       ],
//                       links: [
//                         "https://play.google.com/store/books/details/Lion_Dr_Er_J_Shivakumaar_Chief_Editor_COIMBATORE_N?id=nCpLDwAAQBAJ",
//                         "https://play.google.com/store/books/details/Lion_Dr_Er_J_Shivakumaar_COIMBATORE_2025_26_Indust?id=sCE6EQAAQBAJ",
//                         "https://play.google.com/store/books/details/Lion_Dr_Er_J_Shivakumaar_COIMBATORE_2024_Industria?id=kwgSEQAAQBAJ",
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ]),
//           ),
//         ],
//       ),
//     );
//   }
// }
// import 'dart:async';
// import 'dart:ui';
// import 'dart:math';
// import 'package:celfonephonebookapp/screens/%20search_page.dart';
// import 'package:celfonephonebookapp/screens/signin.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import '../supabase/supabase.dart';
// import 'package:celfonephonebookapp/screens/book_store_page.dart'; // NEW

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class CategoryItem {
//   final String title;
//   final String image;
//   final String imageTitle;
//   final String keywords;

//   CategoryItem({
//     required this.title,
//     required this.image,
//     required this.imageTitle,
//     required this.keywords,
//   });

//   factory CategoryItem.fromMap(Map<String, dynamic> map) {
//     return CategoryItem(
//       title: map['group_title'] ?? '',
//       image: map['image'] ?? '',
//       imageTitle: map['image_title'] ?? '',
//       keywords: map['image_keywords'] ?? '',
//     );
//   }
// }

// class _HomePageState extends State<HomePage>
//     with SingleTickerProviderStateMixin {
//   String? username;
//   String? userId;

//   final SupabaseClient supabase = SupabaseService.client;
//   List<Map<String, dynamic>> banners = [];
//   bool isLoadingBanners = true;
//   int currentBannerIndex = 0;

//   List<CategoryItem> categoriesFromBackend = [];
//   bool isCategoriesLoading = true;

//   List<Map<String, dynamic>> popularProducts = [];
//   bool isProductsLoading = true;

//   bool _showAllProducts = false;
//   final int _initialItemCount = 6;

//   late AnimationController _controller;
//   Timer? _autoRefreshTimer;
//   final GlobalKey<RefreshIndicatorState> _refreshKey =
//       GlobalKey<RefreshIndicatorState>();

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 8),
//     )..repeat(reverse: true);

//     _loadCachedUserData();
//     _loadBanners();
//     _loadCategories();
//     _loadPopularProducts();

//     _autoRefreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
//       if (mounted) _loadPopularProducts();
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     _autoRefreshTimer?.cancel();
//     super.dispose();
//   }

//   /* -------------------------- REFRESH -------------------------- */
//   Future<void> _pullToRefresh() async {
//     await Future.wait([
//       _loadBanners(),
//       _loadCategories(),
//       _loadPopularProducts(),
//     ]);
//   }

//   /* -------------------------- USER -------------------------- */
//   Future<void> _loadCachedUserData() async {
//     final prefs = await SharedPreferences.getInstance();
//     final savedUsername = prefs.getString("username");
//     final savedUserId = prefs.getString("userId");

//     setState(() {
//       username = savedUsername;
//       userId = savedUserId;
//     });

//     if ((savedUsername == null || savedUsername.isEmpty) && mounted) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (!mounted) return;
//         showGeneralDialog(
//           context: context,
//           barrierDismissible: true,
//           transitionDuration: const Duration(milliseconds: 400),
//           pageBuilder: (_, __, ___) => const SizedBox.shrink(),
//           transitionBuilder: (_, anim1, anim2, child) => Transform.scale(
//             scale: anim1.value,
//             child: Opacity(opacity: anim1.value, child: _buildFancyDialog()),
//           ),
//         );
//       });
//     }
//   }

//   /* -------------------------- DATA -------------------------- */
//   Future<void> _loadBanners() async {
//     try {
//       final response = await supabase.from('app_banner').select();
//       final data = (response as List).map((e) {
//         return {
//           "image_url": e['image_url'] as String,
//           "festival": e['festival'] as String? ?? "default",
//         };
//       }).toList();

//       if (mounted) {
//         setState(() {
//           banners = data;
//           isLoadingBanners = false;
//         });
//       }
//     } catch (e) {
//       debugPrint("Error fetching banners: $e");
//       if (mounted) {
//         setState(() => isLoadingBanners = false);
//       }
//     }
//   }

//   Future<void> _loadCategories() async {
//     try {
//       final response = await supabase.from('tiles_titles').select();
//       final data = (response as List)
//           .map((e) => CategoryItem.fromMap(e))
//           .toList();

//       if (mounted) {
//         setState(() {
//           categoriesFromBackend = data;
//           isCategoriesLoading = false;
//         });
//       }
//     } catch (e) {
//       debugPrint("Error fetching categories: $e");
//       if (mounted) {
//         setState(() => isCategoriesLoading = false);
//       }
//     }
//   }

//   Future<void> _loadPopularProducts() async {
//     try {
//       final response = await supabase
//           .from('popular_keywords')
//           .select('keyword, display_name, count, image_url')
//           .order('count', ascending: false);

//       if (mounted) {
//         setState(() {
//           popularProducts = (response as List).cast<Map<String, dynamic>>();
//           isProductsLoading = false;
//         });
//       }
//     } catch (e) {
//       debugPrint('Error: $e');
//       if (mounted) {
//         setState(() => isProductsLoading = false);
//       }
//     }
//   }

//   /* -------------------------- NAVIGATION -------------------------- */
//   void _goToSearch(BuildContext context, {String? category}) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => SearchPage(category: category)),
//     );
//   }

//   IconData _getIconFromKeywords(String? keywords) {
//     if (keywords == null) return Icons.category;
//     final lower = keywords.toLowerCase();
//     if (lower.contains('plumbing')) return Icons.plumbing;
//     if (lower.contains('electric')) return Icons.electrical_services;
//     if (lower.contains('handyman')) return Icons.handyman;
//     if (lower.contains('clean')) return Icons.cleaning_services;
//     if (lower.contains('paint')) return Icons.format_paint;
//     if (lower.contains('gold')) return Icons.monetization_on;
//     if (lower.contains('foundary')) return Icons.factory;
//     if (lower.contains('pvc')) return Icons.circle;
//     if (lower.contains('taxi') || lower.contains('rapido'))
//       return Icons.local_taxi;
//     return Icons.build;
//   }

//   /* -------------------------- BUILD -------------------------- */
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       body: SafeArea(
//         child: RefreshIndicator(
//           key: _refreshKey,
//           onRefresh: _pullToRefresh,
//           displacement: 80,
//           color: Colors.deepPurple,
//           child: SingleChildScrollView(
//             physics: const AlwaysScrollableScrollPhysics(),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildHeader(),
//                 const SizedBox(height: 20),
//                 _buildCategories(),
//                 const SizedBox(height: 20),
//                 _buildBanner(),
//                 const SizedBox(height: 20),
//                 _buildPopularProductsGrid(),

//                 // BOOK STORE CARD ADDED HERE
//                 // ──────────────────────────────────────────────────────────────
//                 //  Replace the old Padding + BookStoreCard with this:
//                 // ──────────────────────────────────────────────────────────────
//                 const Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                   child: BookStoreCard(),
//                 ),

//                 const SizedBox(height: 30),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   /* -------------------------- HEADER -------------------------- */
//   Widget _buildHeader() {
//     return AnimatedBuilder(
//       animation: _controller,
//       builder: (_, __) {
//         final alignment = Alignment(
//           -1 + 2 * _controller.value,
//           0.3 * (0.5 - _controller.value),
//         );
//         return Container(
//           width: double.infinity,
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: alignment,
//               end: Alignment(-alignment.x, 1.0),
//               colors: const [Color(0xFF4776E6), Color(0xFF8E54E9)],
//             ),
//             borderRadius: const BorderRadius.only(
//               bottomLeft: Radius.circular(30),
//               bottomRight: Radius.circular(30),
//             ),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           "Welcome",
//                           style: TextStyle(color: Colors.white70, fontSize: 14),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           username ?? "Guest User",
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   CircleAvatar(
//                     backgroundColor: Colors.white24,
//                     child: const Icon(Icons.notifications, color: Colors.white),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),
//               GestureDetector(
//                 onTap: () => _goToSearch(context),
//                 child: Container(
//                   height: 45,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: const Row(
//                     children: [
//                       SizedBox(width: 12),
//                       Icon(Icons.search, color: Colors.grey),
//                       SizedBox(width: 12),
//                       Expanded(
//                         child: Text(
//                           "Try plumbing, pvc, Gold",
//                           style: TextStyle(color: Colors.grey, fontSize: 15),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   /* -------------------------- CATEGORIES -------------------------- */
//   Widget _buildCategories() {
//     if (isCategoriesLoading) {
//       return const Padding(
//         padding: EdgeInsets.symmetric(horizontal: 20),
//         child: Center(child: CircularProgressIndicator()),
//       );
//     }

//     final List<Map<String, dynamic>> staticCats = [
//       {'icon': Icons.monetization_on, 'label': 'Gold', 'keywords': 'gold'},
//       {'icon': Icons.factory, 'label': 'Foundary', 'keywords': 'found'},
//       {
//         'icon': Icons.electrical_services,
//         'label': 'Electrics',
//         'keywords': 'electric',
//       },
//       {'icon': Icons.circle, 'label': 'PVC', 'keywords': 'pvc'},
//       {'icon': Icons.local_taxi, 'label': 'Red Taxi', 'keywords': 'redtaxi'},
//       {'icon': Icons.local_taxi, 'label': 'Go Taxi', 'keywords': 'gotaxi'},
//       {'icon': Icons.local_taxi, 'label': 'Rapido', 'keywords': 'rapido'},
//     ];

//     final List<Map<String, dynamic>> backendCats = categoriesFromBackend.map((
//       cat,
//     ) {
//       return {
//         'icon': _getIconFromKeywords(cat.keywords),
//         'label': cat.title,
//         'keywords': cat.keywords,
//       };
//     }).toList();

//     final allCats = [...staticCats, ...backendCats];

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Padding(
//           padding: EdgeInsets.symmetric(horizontal: 20),
//           child: Text(
//             "Popular Categories",
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//         ),
//         const SizedBox(height: 12),
//         SizedBox(
//           height: 90,
//           child: Row(
//             children: [
//               GestureDetector(
//                 onTap: () {
//                   showModalBottomSheet(
//                     context: context,
//                     isScrollControlled: true,
//                     backgroundColor: Colors.transparent,
//                     builder: (_) => _CategoriesBottomSheet(
//                       categories: allCats,
//                       onCategoryTap: (keyword) {
//                         Navigator.pop(context);
//                         _goToSearch(context, category: keyword);
//                       },
//                     ),
//                   );
//                 },
//                 child: Container(
//                   width: 80,
//                   margin: const EdgeInsets.only(left: 20),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       CircleAvatar(
//                         radius: 28,
//                         backgroundColor: Colors.white,
//                         child: const Icon(
//                           Icons.grid_view,
//                           color: Colors.deepPurple,
//                           size: 26,
//                         ),
//                       ),
//                       const SizedBox(height: 6),
//                       const Text(
//                         "View All",
//                         style: TextStyle(fontSize: 13),
//                         textAlign: TextAlign.center,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               Expanded(
//                 child: ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   padding: const EdgeInsets.only(right: 20),
//                   itemCount: allCats.length,
//                   itemBuilder: (_, i) {
//                     final cat = allCats[i];
//                     return Container(
//                       width: 80,
//                       margin: const EdgeInsets.only(right: 12),
//                       child: GestureDetector(
//                         onTap: () => _goToSearch(
//                           context,
//                           category: cat['keywords'] as String,
//                         ),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             CircleAvatar(
//                               radius: 28,
//                               backgroundColor: Colors.white,
//                               child: Icon(
//                                 cat['icon'] as IconData,
//                                 color: Colors.deepPurple,
//                                 size: 26,
//                               ),
//                             ),
//                             const SizedBox(height: 6),
//                             Text(
//                               cat['label'] as String,
//                               style: const TextStyle(fontSize: 13),
//                               textAlign: TextAlign.center,
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   /* -------------------------- BANNER -------------------------- */
//   Widget _buildBanner() {
//     if (isLoadingBanners || banners.isEmpty) {
//       return const Padding(
//         padding: EdgeInsets.symmetric(horizontal: 20),
//         child: SizedBox(
//           height: 160,
//           child: Center(child: CircularProgressIndicator()),
//         ),
//       );
//     }

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: Column(
//         children: [
//           Container(
//             height: 160,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black12.withOpacity(0.05),
//                   blurRadius: 8,
//                   offset: const Offset(0, 3),
//                 ),
//               ],
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(16),
//               child: CarouselSlider.builder(
//                 itemCount: banners.length,
//                 options: CarouselOptions(
//                   height: 160,
//                   autoPlay: true,
//                   enlargeCenterPage: true,
//                   viewportFraction: 1.0,
//                   onPageChanged: (i, _) =>
//                       setState(() => currentBannerIndex = i),
//                 ),
//                 itemBuilder: (_, i, __) {
//                   return Image.network(
//                     banners[i]['image_url'],
//                     key: ValueKey(banners[i]['image_url']),
//                     fit: BoxFit.cover,
//                     width: double.infinity,
//                     height: 160,
//                     errorBuilder: (_, __, ___) => Container(
//                       color: Colors.grey[300],
//                       child: const Icon(
//                         Icons.broken_image,
//                         size: 50,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//           const SizedBox(height: 12),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: banners.asMap().entries.map((e) {
//               return AnimatedContainer(
//                 duration: const Duration(milliseconds: 300),
//                 margin: const EdgeInsets.symmetric(horizontal: 4),
//                 width: currentBannerIndex == e.key ? 20 : 8,
//                 height: 8,
//                 decoration: BoxDecoration(
//                   color: currentBannerIndex == e.key
//                       ? Colors.deepPurple
//                       : Colors.grey[400],
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//               );
//             }).toList(),
//           ),
//         ],
//       ),
//     );
//   }

//   /* -------------------------- POPULAR PRODUCTS -------------------------- */
//   Widget _buildPopularProductsGrid() {
//     if (isProductsLoading) {
//       return const Padding(
//         padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
//         child: Center(child: CircularProgressIndicator()),
//       );
//     }

//     if (popularProducts.isEmpty) {
//       return const Padding(
//         padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//         child: Text(
//           "No popular products yet.",
//           style: TextStyle(color: Colors.grey),
//         ),
//       );
//     }

//     const String defaultImg =
//         'https://img.freepik.com/premium-vector/default-image-icon-vector-missing-picture-page-website-design-mobile-app-no-photo-available_87543-11093.jpg';

//     final displayItems = _showAllProducts
//         ? popularProducts
//         : popularProducts.take(_initialItemCount).toList();

//     final bool showLoadMore = popularProducts.length > _initialItemCount;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 "Popular Products",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               GestureDetector(
//                 onTap: () => _goToSearch(context),
//                 child: const Text(
//                   "View all",
//                   style: TextStyle(color: Colors.deepPurple),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 12),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 12),
//           child: GridView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 3,
//               mainAxisSpacing: 10,
//               crossAxisSpacing: 10,
//               childAspectRatio: 0.75,
//             ),
//             itemCount: displayItems.length,
//             itemBuilder: (context, i) {
//               final item = displayItems[i];
//               final String keyword = item['keyword'] as String;
//               final String displayName = item['display_name'] as String;
//               final int count = item['count'] as int;
//               final String? imageUrl = item['image_url'] as String?;

//               return GestureDetector(
//                 onTap: () => _goToSearch(context, category: keyword),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(14),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black12.withOpacity(0.04),
//                         blurRadius: 5,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(6),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         ClipRRect(
//                           borderRadius: const BorderRadius.vertical(
//                             top: Radius.circular(10),
//                           ),
//                           child: Image.network(
//                             imageUrl ?? defaultImg,
//                             height: 60,
//                             width: double.infinity,
//                             fit: BoxFit.cover,
//                             errorBuilder: (_, __, ___) => Image.network(
//                               defaultImg,
//                               height: 60,
//                               width: double.infinity,
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           displayName,
//                           style: const TextStyle(
//                             fontWeight: FontWeight.w600,
//                             fontSize: 11.5,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         const SizedBox(height: 1),
//                         Text(
//                           "$keyword ($count)",
//                           style: const TextStyle(
//                             fontSize: 10,
//                             color: Colors.deepPurple,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         const SizedBox(height: 6),
//                         SizedBox(
//                           height: 28,
//                           child: ElevatedButton(
//                             onPressed: () =>
//                                 _goToSearch(context, category: keyword),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.deepPurple,
//                               padding: EdgeInsets.zero,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               elevation: 0,
//                             ),
//                             child: const Text(
//                               "View",
//                               style: TextStyle(
//                                 fontSize: 10.5,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//         if (showLoadMore)
//           Center(
//             child: Padding(
//               padding: const EdgeInsets.only(top: 16),
//               child: OutlinedButton(
//                 onPressed: () =>
//                     setState(() => _showAllProducts = !_showAllProducts),
//                 style: OutlinedButton.styleFrom(
//                   foregroundColor: Colors.deepPurple,
//                   side: const BorderSide(color: Colors.deepPurple),
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 32,
//                     vertical: 10,
//                   ),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                 ),
//                 child: Text(
//                   _showAllProducts ? "View Less" : "Load More",
//                   style: const TextStyle(fontWeight: FontWeight.w600),
//                 ),
//               ),
//             ),
//           ),
//         const SizedBox(height: 10),
//       ],
//     );
//   }

//   /* -------------------------- DIALOG -------------------------- */
//   Widget _buildFancyDialog() {
//     return Center(
//       child: Material(
//         color: Colors.transparent,
//         child: Stack(
//           alignment: Alignment.center,
//           children: [
//             _BlurredBackground(),
//             Container(
//               margin: const EdgeInsets.symmetric(horizontal: 28),
//               padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                   colors: [
//                     Color.fromRGBO(0, 0, 0, 1),
//                     Color.fromRGBO(0, 0, 0, 1),
//                   ],
//                 ),
//                 borderRadius: BorderRadius.circular(24),
//                 border: Border.all(
//                   color: const Color.fromARGB(130, 255, 255, 255),
//                   width: 1.5,
//                 ),
//                 boxShadow: const [
//                   BoxShadow(
//                     color: Color.fromRGBO(0, 0, 0, 0.20),
//                     blurRadius: 35,
//                     offset: Offset(0, 16),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: const BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: Colors.amber,
//                     ),
//                     child: const Icon(
//                       Icons.star_rounded,
//                       color: Colors.white,
//                       size: 36,
//                     ),
//                   ),
//                   const SizedBox(height: 18),
//                   const Text(
//                     'Welcome to Celfon5G+',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.w800,
//                       color: Colors.white,
//                       letterSpacing: -0.2,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   const Text(
//                     'Log in to unlock powerful features, connect, and explore.',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 15.5,
//                       color: Color.fromRGBO(255, 255, 255, 0.75),
//                       height: 1.45,
//                     ),
//                   ),
//                   const SizedBox(height: 32),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       TextButton(
//                         style: TextButton.styleFrom(
//                           foregroundColor: const Color.fromRGBO(
//                             255,
//                             255,
//                             255,
//                             0.75,
//                           ),
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 24,
//                             vertical: 12,
//                           ),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(30),
//                             side: const BorderSide(
//                               color: Color.fromRGBO(255, 255, 255, 0.35),
//                               width: 1.3,
//                             ),
//                           ),
//                         ),
//                         onPressed: () => Navigator.pop(context),
//                         child: const Text(
//                           'Later',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                       ElevatedButton.icon(
//                         icon: const Icon(
//                           Icons.login,
//                           color: Colors.white,
//                           size: 19,
//                         ),
//                         label: const Text(
//                           'Log In',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                             color: Colors.white,
//                           ),
//                         ),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF007AFF),
//                           elevation: 9,
//                           shadowColor: const Color.fromRGBO(0, 0, 0, 0.45),
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 28,
//                             vertical: 14,
//                           ),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(30),
//                           ),
//                         ),
//                         onPressed: () {
//                           Navigator.pop(context);
//                           Navigator.of(context).push(
//                             MaterialPageRoute(
//                               builder: (_) => const SigninPage(),
//                             ),
//                           );
//                         },
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class BookStoreCard extends StatelessWidget {
//   const BookStoreCard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       child: Material(
//         color: Colors.transparent,
//         borderRadius: BorderRadius.circular(16),
//         clipBehavior: Clip.antiAlias,
//         child: InkWell(
//           borderRadius: BorderRadius.circular(16),
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => const BookStorePage()),
//             );
//           },
//           child: Container(
//             height: 160,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(16),
//               gradient: const LinearGradient(
//                 colors: [Colors.black87, Colors.black54],
//                 begin: Alignment.centerLeft,
//                 end: Alignment.centerRight,
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.2),
//                   blurRadius: 10,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: const [
//                     Text(
//                       "Visit Our",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Text(
//                       "Directories",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 26,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//                 Stack(
//                   clipBehavior: Clip.none,
//                   children: [
//                     Transform.rotate(
//                       angle: -0.12,
//                       child: Container(
//                         width: 100,
//                         height: 150,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(8),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black26,
//                               blurRadius: 6,
//                               offset: const Offset(2, 2),
//                             ),
//                           ],
//                         ),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(8),
//                           child: Image.network(
//                             'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=400',
//                             fit: BoxFit.cover,
//                             errorBuilder: (_, __, ___) => Container(
//                               color: Colors.grey[700],
//                               child: const Icon(
//                                 Icons.book,
//                                 color: Colors.white70,
//                                 size: 32,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// /* ------------------------------------------------------------- */
// /* BOTTOM SHEET */
// /* ------------------------------------------------------------- */
// class _CategoriesBottomSheet extends StatelessWidget {
//   final List<Map<String, dynamic>> categories;
//   final Function(String) onCategoryTap;

//   const _CategoriesBottomSheet({
//     required this.categories,
//     required this.onCategoryTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return DraggableScrollableSheet(
//       initialChildSize: 0.85,
//       minChildSize: 0.6,
//       maxChildSize: 0.95,
//       expand: false,
//       builder: (_, controller) => Container(
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//         ),
//         child: Column(
//           children: [
//             Container(
//               margin: const EdgeInsets.only(top: 12),
//               width: 40,
//               height: 5,
//               decoration: BoxDecoration(
//                 color: Colors.grey[300],
//                 borderRadius: BorderRadius.circular(2.5),
//               ),
//             ),
//             const SizedBox(height: 12),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     "All Categories",
//                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.close),
//                     onPressed: () => Navigator.pop(context),
//                   ),
//                 ],
//               ),
//             ),
//             const Divider(height: 1),
//             Expanded(
//               child: GridView.builder(
//                 controller: controller,
//                 padding: const EdgeInsets.all(16),
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 4,
//                   mainAxisSpacing: 16,
//                   crossAxisSpacing: 16,
//                   childAspectRatio: 0.9,
//                 ),
//                 itemCount: categories.length,
//                 itemBuilder: (_, i) {
//                   final cat = categories[i];
//                   return GestureDetector(
//                     onTap: () => onCategoryTap(cat['keywords'] as String),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         CircleAvatar(
//                           radius: 28,
//                           backgroundColor: Colors.white,
//                           child: Icon(
//                             cat['icon'] as IconData,
//                             color: Colors.deepPurple,
//                             size: 26,
//                           ),
//                         ),
//                         const SizedBox(height: 6),
//                         Text(
//                           cat['label'] as String,
//                           style: const TextStyle(fontSize: 12),
//                           textAlign: TextAlign.center,
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /* ------------------------------------------------------------- */
// /* BLUR & NOISE */
// /* ------------------------------------------------------------- */
// class _BlurredBackground extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return RepaintBoundary(
//       child: Stack(
//         children: [
//           Positioned.fill(
//             child: Container(color: const Color.fromARGB(102, 0, 0, 0)),
//           ),
//           ...List.generate(3, (_) => Positioned.fill(child: Container())),
//           Positioned.fill(child: CustomPaint(painter: _NoisePainter())),
//         ],
//       ),
//     );
//   }
// }

// class _NoisePainter extends CustomPainter {
//   static final _random = Random(12345);
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()..color = const Color.fromARGB(10, 255, 255, 255);
//     for (int i = 0; i < 800; i++) {
//       final x = _random.nextDouble() * size.width;
//       final y = _random.nextDouble() * size.height;
//       canvas.drawCircle(Offset(x, y), 0.8, paint);
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter old) => false;
// }

// class AnimatedViewAllButton extends StatefulWidget {
//   final String label;
//   final VoidCallback onTap;
//   final double? fontSize;
//   final Color? textColor;

//   const AnimatedViewAllButton({
//     super.key,
//     required this.label,
//     required this.onTap,
//     this.fontSize,
//     this.textColor,
//   });

//   @override
//   State<AnimatedViewAllButton> createState() => _AnimatedViewAllButtonState();
// }

// class _AnimatedViewAllButtonState extends State<AnimatedViewAllButton>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _ctrl;
//   late final Animation<double> _scale;
//   late final Animation<double> _fade;

//   @override
//   void initState() {
//     super.initState();
//     _ctrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 260),
//     );
//     _scale = Tween<double>(
//       begin: 1.0,
//       end: 0.92,
//     ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
//     _fade = Tween<double>(
//       begin: 1.0,
//       end: 0.6,
//     ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
//   }

//   @override
//   void dispose() {
//     _ctrl.dispose();
//     super.dispose();
//   }

//   void _onTap() {
//     _ctrl.forward().then((_) {
//       _ctrl.reverse();
//       widget.onTap();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTapDown: (_) => _ctrl.forward(),
//       onTapUp: (_) => _ctrl.reverse(),
//       onTapCancel: () => _ctrl.reverse(),
//       onTap: _onTap,
//       child: AnimatedBuilder(
//         animation: _ctrl,
//         builder: (_, __) => Transform.scale(
//           scale: _scale.value,
//           child: Opacity(
//             opacity: _fade.value,
//             child: Text(
//               widget.label,
//               style: TextStyle(
//                 fontSize: widget.fontSize ?? 13,
//                 color: widget.textColor ?? Colors.black87,
//                 fontWeight: FontWeight.w600,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../supabase/supabase.dart';
import 'package:celfonephonebookapp/screens/ search_page.dart'; // ← Make sure this path is correct

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SupabaseClient _supabase = SupabaseService.client;

  String welcomeMessage = "Welcome Guest User";

  late final ValueNotifier<bool> _isLoadingBanners = ValueNotifier(true);
  late final ValueNotifier<bool> _isLoadingCategories = ValueNotifier(true);
  late final ValueNotifier<bool> _isLoadingFirms = ValueNotifier(true);

  late final ValueNotifier<List<Map<String, dynamic>>> _banners = ValueNotifier(
    [],
  );
  late final ValueNotifier<List<CategoryItem>> _b2cCategories = ValueNotifier(
    [],
  );
  late final ValueNotifier<List<CategoryItem>> _b2bCategories = ValueNotifier(
    [],
  );
  late final ValueNotifier<List<Map<String, dynamic>>> _popularFirms =
      ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadUserAndWelcome(),
      _loadBanners(),
      _loadCategories(),
      _loadPopularFirms(),
    ]);
  }

  Future<void> _loadUserAndWelcome() async {
    String? name;
    final user = _supabase.auth.currentUser;

    if (user != null) {
      try {
        final data = await _supabase
            .from('profiles')
            .select('person_name, business_name')
            .eq('id', user.id)
            .single();

        name = data['business_name']?.toString().trim();
        if (name == null || name.isEmpty) {
          name = data['person_name']?.toString().trim();
        }
      } catch (e) {
        debugPrint("Profile fetch error: $e");
      }
    }

    if (name == null || name.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      name = prefs.getString("username");
    }

    if (name == null || name.trim().isEmpty || name.toLowerCase() == "guest") {
      name = "Guest User";
    } else {
      name = name.trim();
    }

    setState(() {
      welcomeMessage = "Welcome $name";
    });
  }

  Future<void> _loadBanners() async {
    try {
      final response = await _supabase.from('app_banner').select();
      _banners.value = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint("Banners error: $e");
    } finally {
      _isLoadingBanners.value = false;
    }
  }

  Future<void> _loadCategories() async {
    try {
      final response = await _supabase.from('tiles_titles').select();
      final items = (response as List)
          .map((e) => CategoryItem.fromMap(e as Map<String, dynamic>))
          .toList();

      _b2cCategories.value = items.where((c) => c.isB2C).toList();
      _b2bCategories.value = items.where((c) => c.isB2B).toList();
    } catch (e) {
      debugPrint("Categories error: $e");
    } finally {
      _isLoadingCategories.value = false;
    }
  }

  Future<void> _loadPopularFirms() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('business_name, business_prefix, profile_image, keywords')
          .eq('user_type', 'business')
          .or('is_prime.eq.true,priority.eq.true')
          .order('is_prime', ascending: false)
          .limit(12);

      _popularFirms.value = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint("Popular firms error: $e");
    } finally {
      _isLoadingFirms.value = false;
    }
  }

  void _openSearchPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchPage(category: '')),
    );
  }

  void _goToSearch({String? category, String? letter}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            SearchPage(initialFilter: letter ?? category, category: ''),
      ),
    );
  }

  @override
  void dispose() {
    _isLoadingBanners.dispose();
    _isLoadingCategories.dispose();
    _isLoadingFirms.dispose();
    _banners.dispose();
    _b2cCategories.dispose();
    _b2bCategories.dispose();
    _popularFirms.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: _loadAllData,
        child: Stack(
          children: [
            CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 130,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: Text(
                          welcomeMessage,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 1),
                      _buildAZRow(),

                      ValueListenableBuilder(
                        valueListenable: _isLoadingBanners,
                        builder: (_, loading, __) {
                          if (loading) {
                            return const SizedBox(
                              height: 140,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          return ValueListenableBuilder(
                            valueListenable: _banners,
                            builder: (_, banners, __) {
                              return CarouselSlider(
                                options: CarouselOptions(
                                  height: 140,
                                  autoPlay: true,
                                  viewportFraction: 0.92,
                                  enlargeCenterPage: true,
                                  enlargeFactor: 0.25,
                                ),
                                items: banners.isEmpty
                                    ? [_buildNoOfferBanner()]
                                    : banners
                                          .map(
                                            (b) => _buildBanner(
                                              b['image_url'] ?? '',
                                            ),
                                          )
                                          .toList(),
                              );
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 28),
                      CategorySection(
                        title: "Popular Categories B2C",
                        items: _b2cCategories,
                        isLoading: _isLoadingCategories,
                        demoItems: _demoB2C,
                        onTap: (keyword) => _goToSearch(category: keyword),
                        onMoreTap: _openSearchPage,
                      ),
                      const SizedBox(height: 24),
                      _buildAdCarousel(),
                      const SizedBox(height: 28),

                      CategorySection(
                        title: "Popular Categories B2B",
                        items: _b2bCategories,
                        isLoading: _isLoadingCategories,
                        demoItems: _demoB2B,
                        onTap: (keyword) => _goToSearch(category: keyword),
                        onMoreTap: _openSearchPage,
                      ),

                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Popular Firms",
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ValueListenableBuilder(
                              valueListenable: _isLoadingFirms,
                              builder: (_, loading, __) {
                                if (loading)
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                return ValueListenableBuilder(
                                  valueListenable: _popularFirms,
                                  builder: (_, firms, __) =>
                                      _buildPopularFirmsGrid(firms),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      const DirectoriesSection(),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(top: 0, left: 0, right: 0, child: _buildAppBar()),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Text(
                "Celfon5G+ PHONE BOOK",
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              Spacer(),
            ],
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: _openSearchPage,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: Colors.grey),
                  SizedBox(width: 12),
                  Text(
                    "Search Firms, Persons, Products...",
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAZRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SizedBox(
        height: 76,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: 26,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (context, i) {
            final letter = String.fromCharCode(65 + i);
            return InkWell(
              borderRadius: BorderRadius.circular(40),
              onTap: () => _goToSearch(letter: letter),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  child: Text(
                    letter,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBanner(String url) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 8),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
    ),
  );

  Widget _buildNoOfferBanner() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 8),
    decoration: BoxDecoration(
      color: Colors.grey[300],
      borderRadius: BorderRadius.circular(16),
    ),
    child: const Center(
      child: Text("No Offers", style: TextStyle(fontWeight: FontWeight.w600)),
    ),
  );

  Widget _buildAdCarousel() {
    final List<String> adImages = [
      'assets/images/images1.png',
      'assets/images/images2.png',
      'assets/images/images3.png',
    ];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: CarouselSlider(
        options: CarouselOptions(
          height: 180,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 4),
          viewportFraction: 1.0,
          enlargeCenterPage: false,
        ),
        items: adImages
            .map(
              (path) => Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: AssetImage(path),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildPopularFirmsGrid(List<Map<String, dynamic>> firms) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 26,
        crossAxisSpacing: 6,
        childAspectRatio: 0.9,
      ),
      itemCount: firms.length,
      itemBuilder: (context, i) {
        final firm = firms[i];
        final name = "${firm['business_name'] ?? 'Firm'}".trim();
        final img = firm['profile_image']?.toString().trim();
        final keywords = firm['keywords']?.toString() ?? '';

        return PopularFirmCard(
          name: name,
          imageUrl: img,
          onTap: () => _goToSearch(category: keywords),
        );
      },
    );
  }

  static final _demoB2C = [
    CategoryItem(title: 'Hospital', keywords: 'hospital'),
    CategoryItem(title: 'Hotels', keywords: 'hotel'),
    CategoryItem(title: 'Colleges', keywords: 'college'),
    CategoryItem(title: 'Travel', keywords: 'travel'),
    CategoryItem(title: 'Doctors', keywords: 'doctor'),
    CategoryItem(title: 'Shops', keywords: 'shop'),
    CategoryItem(title: 'Parlour', keywords: 'parlour'),
  ];

  static final _demoB2B = [
    CategoryItem(title: 'Chemical', keywords: 'chemical'),
    CategoryItem(title: 'Electrical', keywords: 'electrical'),
    CategoryItem(title: 'Steel', keywords: 'steel'),
    CategoryItem(title: 'CNC', keywords: 'cnc'),
    CategoryItem(title: 'Electronics', keywords: 'electronics'),
    CategoryItem(title: 'Builder', keywords: 'builder'),
    CategoryItem(title: 'Hydraulic', keywords: 'hydraulic'),
  ];
}

// ——— ALL WIDGETS BELOW ARE UNCHANGED ———
class CategorySection extends StatelessWidget {
  final String title;
  final ValueNotifier<List<CategoryItem>> items;
  final ValueNotifier<bool> isLoading;
  final List<CategoryItem> demoItems;
  final Function(String?) onTap;
  final VoidCallback onMoreTap;

  const CategorySection({
    super.key,
    required this.title,
    required this.items,
    required this.isLoading,
    required this.demoItems,
    required this.onTap,
    required this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),

          ValueListenableBuilder(
            valueListenable: isLoading,
            builder: (_, loading, __) {
              if (loading)
                return const Center(child: CircularProgressIndicator());
              return ValueListenableBuilder(
                valueListenable: items,
                builder: (_, list, __) {
                  final displayItems = (list.isEmpty ? demoItems : list)
                      .take(7)
                      .toList();
                  displayItems.add(
                    CategoryItem(
                      title: "More ${title.contains('B2C') ? 'B2C' : 'B2B'}",
                      keywords: '',
                      isMore: true,
                    ),
                  );
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 0.88,
                          mainAxisSpacing: 6,
                          crossAxisSpacing: 6,
                        ),
                    itemCount: displayItems.length,
                    itemBuilder: (_, i) {
                      final cat = displayItems[i];
                      return cat.isMore
                          ? MoreCategoryTile(
                              title: cat.title,
                              onTap: onMoreTap,
                              textColor: Colors.black,
                            )
                          : CategoryTile(
                              item: cat,
                              onTap: () => onTap(cat.keywords),
                            );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class CategoryTile extends StatelessWidget {
  final CategoryItem item;
  final VoidCallback onTap;
  const CategoryTile({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: Colors.deepPurple.shade50,
            backgroundImage:
                item.image.isNotEmpty && item.image.startsWith('http')
                ? NetworkImage(item.image)
                : null,
            child: item.image.isEmpty || !item.image.startsWith('http')
                ? Icon(
                    CategoryItem.iconFor(item.keywords),
                    color: Colors.deepPurple,
                    size: 30,
                  )
                : null,
          ),

          Text(
            item.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class MoreCategoryTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final Color textColor;
  const MoreCategoryTile({
    super.key,
    required this.title,
    required this.onTap,
    this.textColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: Colors
                .deepPurple
                .shade100, //tochangethe colorofthebackgroundrounded
            child: Text(
              title.replaceAll(" ", "\n"),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color.fromARGB(255, 0, 0, 0),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
        ],
      ),
    );
  }
}

class PopularFirmCard extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final VoidCallback onTap;

  const PopularFirmCard({
    super.key,
    required this.name,
    this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundImage: imageUrl?.startsWith('http') == true
                  ? NetworkImage(imageUrl!)
                  : null,
              child: imageUrl == null || !imageUrl!.startsWith('http')
                  ? const Icon(Icons.business, size: 34)
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DirectoriesSection extends StatelessWidget {
  const DirectoriesSection({super.key});

  void _navigateToSearch(BuildContext context, String keyword) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchPage(initialFilter: keyword, category: ''),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      color: Colors.deepPurple.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Our Directories",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1.45,
            children: [
              InkWell(
                onTap: () => _navigateToSearch(context, "gem jewellery"),
                borderRadius: BorderRadius.circular(16),
                child: const _DirectoryCard(
                  title: "Gem & Jewellery",
                  icon: Icons.diamond,
                  isClickable: true,
                ),
              ),
              InkWell(
                onTap: () => _navigateToSearch(context, "foundry"),
                borderRadius: BorderRadius.circular(16),
                child: const _DirectoryCard(
                  title: "Foundry Directory",
                  icon: Icons.factory,
                  isClickable: true,
                ),
              ),
              const _DirectoryCard(title: "Coimbatore Ebook", icon: Icons.book),
              const _DirectoryCard(
                title: "Bangalore Ebook",
                icon: Icons.location_city,
              ),
              const _DirectoryCard(
                title: "Pollachi Ebook",
                icon: Icons.menu_book,
              ),
              const _DirectoryCard(
                title: "Kalakurichi Ebook",
                icon: Icons.library_books,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DirectoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isClickable;

  const _DirectoryCard({
    required this.title,
    required this.icon,
    this.isClickable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isClickable
              ? Colors.deepPurple.shade300
              : Colors.deepPurple.shade100,
          width: isClickable ? 2.5 : 1,
        ),
        boxShadow: isClickable
            ? [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 32,
            color: isClickable ? Colors.deepPurple : Colors.deepPurple.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.5,
              height: 1.2,
              fontWeight: isClickable ? FontWeight.bold : FontWeight.w600,
              color: isClickable ? Colors.deepPurple : Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class CategoryItem {
  final String title;
  final String image;
  final String keywords;
  final bool isMore;

  CategoryItem({
    required this.title,
    required this.keywords,
    this.image = '',
    this.isMore = false,
  });

  bool get isB2C => keywords.toLowerCase().contains(
    RegExp(r'(hospital|hotel|college|travel|parlour|doctor|shop)'),
  );
  bool get isB2B => keywords.toLowerCase().contains(
    RegExp(r'(chemical|electrical|builder|steel|cnc|hydraulic|electronics)'),
  );

  static IconData iconFor(String keywords) {
    final k = keywords.toLowerCase();
    if (k.contains('hospital')) return Icons.local_hospital;
    if (k.contains('hotel')) return Icons.hotel;
    if (k.contains('college')) return Icons.school;
    if (k.contains('travel')) return Icons.flight_takeoff;
    if (k.contains('doctor')) return Icons.medical_services;
    if (k.contains('shop') || k.contains('parlour')) return Icons.storefront;
    if (k.contains('chemical')) return Icons.science;
    if (k.contains('electrical')) return Icons.electrical_services;
    if (k.contains('steel') || k.contains('builder')) return Icons.construction;
    if (k.contains('cnc') || k.contains('hydraulic'))
      return Icons.precision_manufacturing;
    if (k.contains('electronics')) return Icons.electric_bolt;
    return Icons.category;
  }

  factory CategoryItem.fromMap(Map<String, dynamic> map) {
    return CategoryItem(
      title: map['group_title'] ?? map['title'] ?? '',
      image: map['image'] ?? map['image_url'] ?? '',
      keywords: map['image_keywords'] ?? map['keywords'] ?? '',
    );
  }
}
