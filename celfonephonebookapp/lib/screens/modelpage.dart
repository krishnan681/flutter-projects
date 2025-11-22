// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';

// class ModelPage extends StatefulWidget {
//   final Map<String, dynamic> profile;

//   const ModelPage({super.key, required this.profile});

//   @override
//   State<ModelPage> createState() => _ModelPageState();
// }

// class _ModelPageState extends State<ModelPage>
//     with SingleTickerProviderStateMixin {
//   late PageController _pageController;
//   int _currentPage = 0;

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController();
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   /// Helper to format mobile number
//   String formatMobile(String number) {
//     if (number.length >= 5) {
//       return number.substring(0, 5) + " " + "X" * (number.length - 5);
//     }
//     return number;
//   }

//   /// Launchers
//   Future<void> _makePhoneCall(String number) async {
//     final Uri uri = Uri(scheme: 'tel', path: number);
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri);
//     }
//   }

//   Future<void> _sendEmail(String email) async {
//     final Uri uri = Uri(scheme: 'mailto', path: email);
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri);
//     }
//   }

//   Future<void> _openWhatsApp(String number) async {
//     final Uri uri = Uri.parse("https://wa.me/$number");
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri, mode: LaunchMode.externalApplication);
//     }
//   }

//   Future<void> _sendSMS(String number) async {
//     final Uri uri = Uri(scheme: 'sms', path: number);
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final profile = widget.profile;

//     // Images list
//     List<String> images =
//         (profile["images"] as List?)?.map((e) => e.toString()).toList() ?? [];

//     final mobile = profile["mobile"] ?? "";
//     final email = profile["email"];
//     final keywords = profile["keywords"];
//     final address = profile["address"];
//     final description = profile['description'];
//     final city = profile["city"];
//     final pincode = profile["pincode"];
//     final person_name = profile["person_name"];
//     final landline = profile['landline'];

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Column(
//           children: [
//             /// ---------- Top Image Section ----------
//             SizedBox(
//               height: 260,
//               child: Stack(
//                 children: [
//                   if (images.isNotEmpty)
//                     PageView.builder(
//                       controller: _pageController,
//                       itemCount: images.length,
//                       onPageChanged: (index) {
//                         setState(() => _currentPage = index);
//                       },
//                       itemBuilder: (context, index) {
//                         return Image.network(
//                           images[index],
//                           width: double.infinity,
//                           fit: BoxFit.cover,
//                         );
//                       },
//                     )
//                   else
//                     Container(
//                       width: double.infinity,
//                       color: Colors.grey[200],
//                       child: const Center(
//                         child: Icon(Icons.camera_alt,
//                             size: 50, color: Colors.grey),
//                       ),
//                     ),

//                   /// Back button
//                   Positioned(
//                     top: 16,
//                     left: 16,
//                     child: CircleAvatar(
//                       backgroundColor: Colors.white,
//                       child: IconButton(
//                         icon: const Icon(Icons.arrow_back),
//                         onPressed: () => Navigator.pop(context),
//                       ),
//                     ),
//                   ),

//                   /// Page Dots
//                   if (images.isNotEmpty)
//                     Positioned(
//                       bottom: 8,
//                       left: 0,
//                       right: 0,
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: List.generate(
//                           images.length,
//                               (index) => AnimatedContainer(
//                             duration: const Duration(milliseconds: 300),
//                             margin: const EdgeInsets.symmetric(horizontal: 4),
//                             width: _currentPage == index ? 10 : 6,
//                             height: 6,
//                             decoration: BoxDecoration(
//                               color: _currentPage == index
//                                   ? Colors.blue
//                                   : Colors.grey[400],
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),

//             /// ---------- Content ----------
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     /// Profile Header
//                     Padding(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 5,
//                         vertical: 8,
//                       ),
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           CircleAvatar(
//                             radius: 30,
//                             backgroundColor: Colors.blue.shade100,
//                             child: Text(
//                               (() {
//                                 // Get the name
//                                 final name = (profile["business_name"] ?? profile["person_name"] ?? "UK").toString().trim();
//                                 // Return first character if not empty, else "U"
//                                 return name.isNotEmpty ? name.substring(0, 1).toUpperCase() : "UK";
//                               })(),
//                               style: const TextStyle(
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.blue,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 14),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   profile["business_name"] ?? profile["person_name"] ?? "No Name",
//                                   style: const TextStyle(
//                                     fontSize: 20,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 if (profile["keywords"] != null)
//                                   Text(
//                                     profile["keywords"],
//                                     style: TextStyle(
//                                       fontSize: 14,
//                                       color: Colors.grey[600],
//                                     ),
//                                   ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     //Person name
//                     if (person_name.isNotEmpty) ...[
//                       Row(
//                         children: [
//                           const Icon(Icons.person, color: Colors.grey),
//                           const SizedBox(width: 8),
//                           Text(
//                             person_name,
//                             style: const TextStyle(fontSize: 16),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 12),
//                     ],

//                     /// Mobile
//                     if (mobile.isNotEmpty) ...[
//                       Row(
//                         children: [
//                           const Icon(Icons.phone, color: Colors.grey),
//                           const SizedBox(width: 8),
//                           Text(
//                             formatMobile(mobile),
//                             style: const TextStyle(fontSize: 16),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 12),
//                     ],

//                     /// Keywords
//                     if (keywords.isNotEmpty) ...[
//                       Row(
//                         children: [
//                           const Icon(Icons.label, color: Colors.grey),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: Text(
//                               keywords,
//                               style: const TextStyle(fontSize: 16),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 12),
//                     ],

//                     //description
//                     if (description.isNotEmpty) ...[
//                       Row(
//                         children: [
//                           const Icon(Icons.note_add, color: Colors.grey),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: Text(
//                               description,
//                               style: const TextStyle(fontSize: 16),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 12),
//                     ],
//                     /// Address
//                     if (address != null || city != null || pincode != null) ...[
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Icon(Icons.location_on, color: Colors.grey),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: Text(
//                               "${address ?? ""}, ${city ?? ""}, ${pincode ?? ""}",
//                               style: const TextStyle(fontSize: 16),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 20),
//                     ],

//                     /// Buttons: Call, Email, WhatsApp, SMS
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceAround,
//                       children: [
//                         IconButton(
//                           icon: const Icon(Icons.call, color: Colors.green),
//                           onPressed: () => _makePhoneCall(mobile),
//                           tooltip: "Call",
//                         ),
//                         if (email.isNotEmpty)
//                           IconButton(
//                             icon: const Icon(Icons.email,
//                                 color: Colors.redAccent),
//                             onPressed: () => _sendEmail(email),
//                             tooltip: "Email",
//                           ),
//                         if (mobile.isNotEmpty)
//                           IconButton(
//                             icon: const Icon(Icons.message_sharp,
//                                 color: Colors.green),
//                             onPressed: () => _openWhatsApp(mobile),
//                             tooltip: "WhatsApp",
//                           ),
//                         if (mobile.isNotEmpty)
//                           IconButton(
//                             icon: const Icon(Icons.sms, color: Colors.blue),
//                             onPressed: () => _sendSMS(mobile),
//                             tooltip: "SMS",
//                           ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//new

// modelpage.dart - FINAL VERSION (Business = Pink, Products in About = Comma separated)
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ModelPage extends StatefulWidget {
  final Map<String, dynamic> profile;
  const ModelPage({super.key, required this.profile});
  @override
  State<ModelPage> createState() => _ModelPageState();
}

class _ModelPageState extends State<ModelPage>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late TabController _tabController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  String formatMobile(String number) {
    if (number.length >= 5) return "${number.substring(0, 5)} XXXXX";
    return number;
  }

  Future<void> _makePhoneCall(String number) async =>
      await launchUrl(Uri(scheme: 'tel', path: number));
  Future<void> _openWhatsApp(String number) async => await launchUrl(
    Uri.parse("https://wa.me/$number"),
    mode: LaunchMode.externalApplication,
  );
  Future<void> _sendSMS(String number) async =>
      await launchUrl(Uri(scheme: 'sms', path: number));
  Future<void> _sendEmail(String email) async =>
      await launchUrl(Uri(scheme: 'mailto', path: email));

  Widget _infoTile(IconData icon, String title, String value, Color iconColor) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circularActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }

  void _showFavoriteModal(String name, String mobile) {
    if (mobile.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mobile number not available")),
      );
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

  Widget _premiumProductCard(
    String title,
    String? description,
    Color primaryColor,
  ) {
    return Card(
      elevation: 0,
      color: primaryColor.withOpacity(0.08),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: primaryColor,
          child: const Icon(Icons.inventory_2, color: Colors.white, size: 18),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15.5,
            color: Colors.black87,
          ),
        ),
        children: description != null && description.isNotEmpty
            ? [
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.black87,
                    height: 1.5,
                    fontSize: 14,
                  ),
                ),
              ]
            : [],
      ),
    );
  }

  Widget _productsSummaryTile(
    List<Map<String, String>> products,
    Color iconColor,
  ) {
    final productNames = products.map((p) => p["name"]!).join(", ");
    return _infoTile(Icons.inventory_2, "Products", productNames, iconColor);
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;

    final bool isPrime = profile['is_prime'] == true;
    final String subscription = (profile['subscription'] ?? '')
        .toString()
        .toLowerCase();
    final String tier = isPrime || subscription == 'gold'
        ? 'gold'
        : subscription == 'business'
        ? 'business'
        : 'normal';

    final Color primaryColor = tier == 'gold'
        ? Colors.amber[700]!
        : Colors.pink;
    final Color lightColor = tier == 'gold' ? Colors.amber : Colors.pink;

    final String mobile = profile["mobile_number"]?.toString() ?? "";
    final String whatsApp = profile["whats_app"]?.toString() ?? mobile;
    final String email = profile["email"]?.toString() ?? "";
    final String personName = profile["person_name"]?.toString() ?? "";
    final String businessName = profile["business_name"]?.toString() ?? "";
    final String displayName = businessName.isNotEmpty
        ? businessName
        : personName.isNotEmpty
        ? personName
        : "User";

    List<String> images = [];
    if (profile["product_images"] is List)
      images = (profile["product_images"] as List)
          .map((e) => e.toString())
          .toList();
    else if (profile["images"] is List)
      images = (profile["images"] as List).map((e) => e.toString()).toList();

    final address = profile["address"]?.toString() ?? "";
    final description = profile["description"]?.toString() ?? "";
    final city = profile["city"]?.toString() ?? "";
    final pincode = profile["pincode"]?.toString() ?? "";
    final landline = profile["landline"]?.toString() ?? "";
    final landlineCode = profile["landline_code"]?.toString() ?? "";

    List<Map<String, String>> productList = [];
    final keywords = profile["keywords"];
    if (keywords != null) {
      if (keywords is List) {
        for (var item in keywords) {
          if (item is Map) {
            productList.add({
              "name": (item["name"] ?? item["title"] ?? "Product").toString(),
              "description": (item["description"] ?? item["desc"] ?? "")
                  .toString(),
            });
          } else {
            productList.add({"name": item.toString(), "description": ""});
          }
        }
      } else if (keywords is String) {
        if (keywords.contains(":")) {
          for (var line in keywords.split(',')) {
            if (line.contains(':')) {
              final parts = line.split(':');
              productList.add({
                "name": parts[0].trim(),
                "description": parts.sublist(1).join(":").trim(),
              });
            } else {
              productList.add({"name": line.trim(), "description": ""});
            }
          }
        } else {
          productList = keywords
              .split(',')
              .map(
                (e) =>
                    {"name": e.trim(), "description": ""}
                        as Map<String, String>,
              )
              .toList();
        }
      }
    }

    Widget actionButtons = Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _circularActionButton(
            icon: Icons.call,
            color: Colors.green,
            onPressed: mobile.isNotEmpty ? () => _makePhoneCall(mobile) : null,
          ),
          _circularActionButton(
            icon: FontAwesomeIcons.whatsapp,
            color: const Color(0xFF25D366),
            onPressed: whatsApp.isNotEmpty
                ? () => _openWhatsApp(whatsApp)
                : null,
          ),
          _circularActionButton(
            icon: FontAwesomeIcons.commentDots,
            color: Colors.blue,
            onPressed: mobile.isNotEmpty ? () => _sendSMS(mobile) : null,
          ),
          _circularActionButton(
            icon: FontAwesomeIcons.envelope,
            color: Colors.orange[700]!,
            onPressed: email.isNotEmpty ? () => _sendEmail(email) : null,
          ),
        ],
      ),
    );

    // PREMIUM HEADER — WITH BACK + FAVORITE + CENTERED CAMERA
    Widget premiumHeader = SizedBox(
      height: 220,
      child: Stack(
        children: [
          // Background images or light tint
          if (images.isNotEmpty)
            PageView.builder(
              controller: _pageController,
              itemCount: images.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (_, i) => Image.network(
                images[i],
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            )
          else
            Container(color: primaryColor.withOpacity(0.12)),

          // Centered camera icon when no images
          if (images.isEmpty)
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
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(Icons.photo_camera, color: primaryColor, size: 56),
              ),
            ),

          // Back Button
          Positioned(
            top: 16,
            left: 16,
            child: CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white.withOpacity(0.9),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.black87,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Favorite Button
          Positioned(
            top: 16,
            right: 16,
            child: CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white.withOpacity(0.9),
              child: IconButton(
                icon: const Icon(
                  Icons.favorite_border,
                  color: Colors.pink,
                  size: 24,
                ),
                onPressed: () => _showFavoriteModal(displayName, mobile),
              ),
            ),
          ),

          // Dots indicator
          if (images.isNotEmpty)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
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

    // GOLD & BUSINESS USERS
    if (tier == "gold" || tier == "business") {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              premiumHeader,
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
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
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (personName.isNotEmpty && businessName.isNotEmpty)
                            Text(
                              personName,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryColor, primaryColor.withOpacity(0.7)],
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.verified, color: Colors.white, size: 20),
                          SizedBox(width: 6),
                          Text(
                            "Verified",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              TabBar(
                controller: _tabController,
                labelColor: primaryColor,
                indicatorColor: primaryColor,
                tabs: const [
                  Tab(text: "About"),
                  Tab(text: "Products"),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (address.isNotEmpty ||
                              city.isNotEmpty ||
                              pincode.isNotEmpty)
                            _infoTile(
                              Icons.location_on,
                              "Address",
                              "$address, $city, $pincode",
                              Colors.redAccent,
                            ),
                          if (mobile.isNotEmpty)
                            _infoTile(
                              Icons.phone,
                              "Mobile",
                              formatMobile(mobile),
                              Colors.green,
                            ),
                          if (landline.isNotEmpty)
                            _infoTile(
                              Icons.phone,
                              "Landline",
                              landlineCode.isNotEmpty
                                  ? "$landlineCode $landline"
                                  : landline,
                              Colors.green,
                            ),
                          if (email.isNotEmpty)
                            _infoTile(
                              Icons.email,
                              "Email",
                              email,
                              Colors.orange,
                            ),
                          if (productList.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            _productsSummaryTile(productList, lightColor),
                          ],
                          if (description.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            const Text(
                              "Description",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              description,
                              style: const TextStyle(height: 1.5),
                            ),
                          ],
                          actionButtons,
                        ],
                      ),
                    ),
                    productList.isEmpty
                        ? const Center(
                            child: Text(
                              "No products listed",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: productList.length,
                            itemBuilder: (_, i) => _premiumProductCard(
                              productList[i]["name"]!,
                              productList[i]["description"]!.isNotEmpty
                                  ? productList[i]["description"]
                                  : null,
                              primaryColor,
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

    // FREE USERS (unchanged)
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, size: 28),
            onPressed: () => _showFavoriteModal(displayName, mobile),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              displayName,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            if (address.isNotEmpty || city.isNotEmpty || pincode.isNotEmpty)
              _infoTile(
                Icons.location_on,
                "Address",
                "$address, $city, $pincode",
                Colors.redAccent,
              ),
            if (mobile.isNotEmpty)
              _infoTile(
                Icons.phone,
                "Mobile",
                formatMobile(mobile),
                Colors.green,
              ),
            if (landline.isNotEmpty)
              _infoTile(
                Icons.phone,
                "Landline",
                landlineCode.isNotEmpty ? "$landlineCode $landline" : landline,
                Colors.green,
              ),
            if (email.isNotEmpty)
              _infoTile(Icons.email, "Email", email, Colors.orange),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                "Description",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(height: 1.5, fontSize: 15),
              ),
            ],
            if (productList.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                "Products",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                productList.map((p) => p["name"]!).join(", "),
                style: const TextStyle(fontSize: 15),
              ),
            ],
            const SizedBox(height: 40),
            actionButtons,
          ],
        ),
      ),
    );
  }
}

// FavoriteOptionsModal — unchanged (perfect)
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
