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

// class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
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
//   final List<String> letters = List.generate(26, (index) => String.fromCharCode(65 + index));

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
//           .map((e) => {
//         "image_url": e['image_url'] as String,
//         "festival": e['festival'] as String? ?? "default"
//       })
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
//       final data = (response as List).map((e) => CategoryItem.fromMap(e)).toList();

//       setState(() {
//         categoriesFromBackend = data;
//         isCategoriesLoading = false;
//       });
//     } catch (e) {
//       debugPrint("Error fetching categories: $e");
//       setState(() => isCategoriesLoading = false);
//     }
//   }

//   String _getFestivalAnimation(String festival) {
//     switch (festival.toLowerCase()) {
//       case "diwali":
//         return "assets/animations/fireworks.json"; // 🎆 crackers
//       case "pongal":
//         return "assets/animations/celebrations.json"; // 🪁 kites
//       case "christmas":
//         return "assets/animations/modeltwo.json"; // ❄️ snow
//       default:
//         return "assets/animations/fireworks.json"; // fallback
//     }
//   }

//   void _goToSearch(BuildContext context, {String? category}) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => SearchPage(category: category),
//       ),
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
//               border: Border.all(color: Colors.blueAccent.shade100.withOpacity(0.4)),
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
//                     category.image,
//                     height: 50,
//                     width: 50,
//                     fit: BoxFit.cover,
//                   )
//                       : Container(
//                     height: 50,
//                     width: 50,
//                     color: Colors.blue[50],
//                     child: const Icon(
//                       Icons.category,
//                       color: Colors.blueAccent,
//                       size: 28,
//                     ),
//                   ),
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
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                 decoration: BoxDecoration(
//                   color: Colors.blue[100],
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.grey.shade300),
//                 ),
//                 child: Row(
//                   children: const [
//                     Icon(Icons.search, color: Colors.grey),
//                     SizedBox(width: 8),
//                     Text("Search...", style: TextStyle(color: Colors.grey)),
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
//                         child: Lottie.asset(
//                           _getFestivalAnimation(banners[currentIndex]['festival']),
//                           fit: BoxFit.cover,
//                           repeat: true,
//                         ),
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
//                               builder: (_) => SearchPage(
//                                 selectedLetter: letter,
//                               ),
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
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
//                     padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
import 'dart:async';
import 'dart:ui';
import 'package:celfonephonebookapp/screens/%20search_page.dart';
import 'package:celfonephonebookapp/screens/signin.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../supabase/supabase.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class CategoryItem {
  final String title;
  final String image;
  final String imageTitle;
  final String keywords;

  CategoryItem({
    required this.title,
    required this.image,
    required this.imageTitle,
    required this.keywords,
  });

  factory CategoryItem.fromMap(Map<String, dynamic> map) {
    return CategoryItem(
      title: map['group_title'] ?? '',
      image: map['image'] ?? '',
      imageTitle: map['image_title'] ?? '',
      keywords: map['image_keywords'] ?? '',
    );
  }
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  String? username;
  String? userId;

  // 🔹 Banner & Festival Animation State
  final SupabaseClient supabase = SupabaseService.client;
  List<Map<String, dynamic>> banners = [];
  bool isLoading = true;
  int currentIndex = 0;

  // 🔹 Categories
  List<CategoryItem> categoriesFromBackend = [];
  bool isCategoriesLoading = true;

  // 🔹 Animation Controller for Gradient Header
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    _loadCachedUserData();
    _loadBanners();
    _loadCategories();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _loadCachedUserData() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username");
    userId = prefs.getString("userId");

    if (username == null || username!.isEmpty) {
      Future.delayed(const Duration(seconds: 3), () {
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Welcome Celfon5G+ Phonebook"),
                content: const Text("Log in for more features"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Later"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SigninPage()),
                      );
                    },
                    child: const Text("Log In"),
                  ),
                ],
              );
            },
          );
        }
      });
    }
    setState(() {});
  }

  Future<void> _loadBanners() async {
    try {
      final response = await supabase.from('app_banner').select();
      final data = (response as List)
          .map(
            (e) => {
              "image_url": e['image_url'] as String,
              "festival": e['festival'] as String? ?? "default",
            },
          )
          .toList();

      setState(() {
        banners = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching banners: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadCategories() async {
    try {
      final response = await supabase.from('tiles_titles').select();
      final data = (response as List)
          .map((e) => CategoryItem.fromMap(e))
          .toList();

      setState(() {
        categoriesFromBackend = data;
        isCategoriesLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching categories: $e");
      setState(() => isCategoriesLoading = false);
    }
  }

  void _goToSearch(BuildContext context, {String? category}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchPage(category: category)),
    );
  }

  // 🔹 Auto-Scroll Categories
  Widget _buildQuickSearch() {
    if (isCategoriesLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final categoryCards = categoriesFromBackend.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value;
      final bgColors = [
        const Color(0xFFe8f5e9),
        const Color(0xFFe3f2fd),
        const Color(0xFFf3e5f5),
        const Color(0xFFfff3e0),
        const Color(0xFFede7f6),
      ];
      return CategoryCard(
        title: category.title,
        icon: Icons.category, // Fallback; could map keywords to icons
        bgColor: bgColors[index % bgColors.length],
        onTap: () => _goToSearch(context, category: category.keywords),
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Categories',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.black54,
            ),
          ),
        ),
        SizedBox(
          height: 110,
          child: _AutoScrollCategories(
            categories: [
              CategoryCard(
                title: 'View All',
                icon: Icons.grid_view,
                bgColor: const Color(0xFFffe0b2),
                onTap: () => _goToSearch(context),
              ),
              ...categoryCards,
            ],
          ),
        ),
      ],
    );
  }

  // 🔹 Second Carousel (Static Images)
  Widget _buildSecondCarousel() {
    final images = [
      "assets/images/images1.png",
      "assets/images/images2.png",
      "assets/images/images3.png",
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Featured',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ),
        SizedBox(
          height: 140,
          child: Column(
            children: [
              CarouselSlider.builder(
                itemCount: images.length,
                options: CarouselOptions(
                  height: 120,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  viewportFraction: 0.85,
                  autoPlayCurve: Curves.easeInOut,
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  onPageChanged: (index, reason) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                ),
                itemBuilder: (context, index, realIdx) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      images[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: images.asMap().entries.map((entry) {
                  return Container(
                    width: currentIndex == entry.key ? 10 : 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: currentIndex == entry.key
                          ? Colors.blueAccent
                          : Colors.grey[400],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _headerContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(
              right: 10,
            ), // Added padding to balance with icon
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${username ?? "Guest User"}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 18),
                GestureDetector(
                  onTap: () => _goToSearch(context),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        height: 52,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          children: const [
                            SizedBox(
                              width: 36,
                              height: 36,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.search,
                                  color: Colors.black87,
                                  size: 20,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Try plumbing, handyman...',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10, right: 20),
          child: GestureDetector(
            onTap:
                () {}, // Placeholder; replace with navigation or action as needed
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications,
                size: 24,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ===== Animated Gradient Header =====
          SliverToBoxAdapter(
            child: _controller == null
                ? Container(
                    width: size.width,
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                    child: _headerContent(),
                  )
                : AnimatedBuilder(
                    animation: _controller!,
                    builder: (context, _) {
                      final alignment = Alignment(
                        -1 + 2 * _controller!.value,
                        0.3 * (0.5 - _controller!.value),
                      );
                      return Container(
                        width: size.width,
                        padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: alignment,
                            end: Alignment(-alignment.x, 1.0),
                            colors: const [
                              Color.fromARGB(255, 103, 203, 250),
                              Color(0xFFe0f7fa),
                              Colors.white,
                            ],
                            stops: const [0.0, 0.6, 1.0],
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(32),
                            bottomRight: Radius.circular(32),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.25),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: _headerContent(),
                      );
                    },
                  ),
          ),

          // 🔹 Add Gap and First Carousel (Banners)
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (banners.isEmpty)
                    const Center(child: Text("No banners available"))
                  else
                    Column(
                      children: [
                        CarouselSlider.builder(
                          itemCount: banners.length,
                          options: CarouselOptions(
                            height: 100,
                            autoPlay: true,
                            enlargeCenterPage: true,
                            viewportFraction: 0.85,
                            autoPlayCurve: Curves.easeInOut,
                            autoPlayAnimationDuration: const Duration(
                              milliseconds: 800,
                            ),
                            onPageChanged: (index, reason) {
                              setState(() {
                                currentIndex = index;
                              });
                            },
                          ),
                          itemBuilder: (context, index, realIdx) {
                            final banner = banners[index];
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                banner['image_url'],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.broken_image,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                    ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: banners.asMap().entries.map((entry) {
                            return Container(
                              width: currentIndex == entry.key ? 10 : 6,
                              height: 6,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: currentIndex == entry.key
                                    ? Colors.blueAccent
                                    : Colors.grey[400],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          // 🔹 Categories and Second Carousel
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 4),
              _buildQuickSearch(),
              const SizedBox(height: 4),
              _buildSecondCarousel(),
              const SizedBox(height: 4),
            ]),
          ),
        ],
      ),
    );
  }
}

// 🔹 Auto-Scroll Categories Widget
class _AutoScrollCategories extends StatefulWidget {
  final List<Widget> categories;
  const _AutoScrollCategories({required this.categories});

  @override
  State<_AutoScrollCategories> createState() => _AutoScrollCategoriesState();
}

class _AutoScrollCategoriesState extends State<_AutoScrollCategories> {
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final next = _scrollController.offset + 120;
        if (next >= maxScroll) {
          _scrollController.jumpTo(0);
        } else {
          _scrollController.animateTo(
            next,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: widget.categories,
    );
  }
}

// 🔹 Category Card Widget
class CategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color bgColor;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.title,
    required this.icon,
    required this.bgColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 24, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
