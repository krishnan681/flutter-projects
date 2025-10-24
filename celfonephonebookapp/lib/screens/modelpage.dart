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

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

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

  /// Helper to format mobile number
  String formatMobile(String number) {
    if (number.length >= 5) {
      return number.substring(0, 5) + " " + "X" * (number.length - 5);
    }
    return number;
  }

  /// Launchers
  Future<void> _makePhoneCall(String number) async {
    final Uri uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWhatsApp(String number) async {
    final Uri uri = Uri.parse("https://wa.me/$number");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _sendSMS(String number) async {
    final Uri uri = Uri(scheme: 'sms', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  /// Custom Info Tile for Gold Tier
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

  /// Info Row for Normal Tier
  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.black54, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final tier = profile["tier"]?.toString().toLowerCase() ?? "normal";

    // Images list
    List<String> images =
        (profile["images"] as List?)?.map((e) => e.toString()).toList() ?? [];

    final mobile = profile["mobile"] ?? "";
    final email = profile["email"] ?? "";
    final keywords = profile["keywords"];
    final address = profile["address"] ?? "";
    final description = profile["description"] ?? "";
    final city = profile["city"] ?? "";
    final pincode = profile["pincode"] ?? "";
    final person_name = profile["person_name"] ?? "";
    final business_name = profile["business_name"] ?? "";
    final landline = profile["landline"] ?? "";
    final landline_code = profile["landline_code"] ?? "";

    // Handle keywords as either a List or String
    final List<String> productList = keywords != null
        ? (keywords is String
              ? keywords.split(',').map((e) => e.trim()).toList()
              : keywords is List
              ? keywords.map((e) => e.toString().trim()).toList()
              : [])
        : [];

    if (tier == "gold") {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              /// ---------- Top Image Carousel ----------
              SizedBox(
                height: 200,
                child: Stack(
                  children: [
                    if (images.isNotEmpty)
                      PageView.builder(
                        controller: _pageController,
                        itemCount: images.length,
                        onPageChanged: (index) {
                          setState(() => _currentPage = index);
                        },
                        itemBuilder: (context, index) {
                          return Image.network(
                            images[index],
                            width: double.infinity,
                            fit: BoxFit.cover,
                          );
                        },
                      )
                    else
                      Container(
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(
                            Icons.camera_alt,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      ),

                    /// Back Button
                    Positioned(
                      top: 16,
                      left: 16,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),

                    /// Favorite Button
                    Positioned(
                      top: 16,
                      right: 16,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: const Icon(Icons.favorite_border),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Favorite functionality not implemented",
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    /// Dots Indicator
                    if (images.isNotEmpty)
                      Positioned(
                        bottom: 8,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            images.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: _currentPage == index ? 10 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: _currentPage == index
                                    ? Colors.blue
                                    : Colors.grey[400],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              /// ---------- Content ----------
              Expanded(
                child: Column(
                  children: [
                    /// Profile Header
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.blue.shade100,
                            child: Text(
                              (() {
                                final name =
                                    (business_name.isNotEmpty
                                            ? business_name
                                            : person_name.isNotEmpty
                                            ? person_name
                                            : "UK")
                                        .trim();
                                return name.isNotEmpty
                                    ? name.substring(0, 1).toUpperCase()
                                    : "UK";
                              })(),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  business_name.isNotEmpty
                                      ? business_name
                                      : person_name.isNotEmpty
                                      ? person_name
                                      : "",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (person_name.isNotEmpty &&
                                    business_name.isNotEmpty)
                                  Text(
                                    person_name,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.verified,
                                color: Color.fromARGB(255, 5, 198, 28),
                                size: 25,
                              ),
                              const SizedBox(width: 4),
                            ],
                          ),
                        ],
                      ),
                    ),

                    /// Tabs
                    TabBar(
                      controller: _tabController,
                      labelColor: Colors.blue,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.blue,
                      tabs: const [
                        Tab(text: "About"),
                        Tab(text: "Products"),
                      ],
                    ),

                    /// Tab Views
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          /// About Tab
                          SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "About Me",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                /// Info Tiles
                                if (address.isNotEmpty ||
                                    city.isNotEmpty ||
                                    pincode.isNotEmpty)
                                  _infoTile(
                                    Icons.location_on,
                                    "Address",
                                    "${address.isNotEmpty ? '$address, ' : ''}${city.isNotEmpty ? city : ''}${pincode.isNotEmpty ? ', $pincode' : ''}",
                                    Colors.redAccent,
                                  ),
                                if (mobile.isNotEmpty)
                                  _infoTile(
                                    Icons.phone,
                                    "Phone",
                                    formatMobile(mobile),
                                    Colors.green,
                                  ),
                                if (landline.isNotEmpty)
                                  _infoTile(
                                    Icons.phone,
                                    "Landline",
                                    landline_code.isNotEmpty
                                        ? "$landline_code $landline"
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
                                if (keywords != null &&
                                    keywords is String &&
                                    keywords.isNotEmpty)
                                  _infoTile(
                                    Icons.category,
                                    "Products",
                                    keywords,
                                    const Color.fromARGB(255, 243, 33, 212),
                                  ),

                                const SizedBox(height: 18),

                                /// Description
                                if (description.isNotEmpty) ...[
                                  const Text(
                                    "Description",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    description,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                ],

                                /// Address Box
                                if (address.isNotEmpty ||
                                    city.isNotEmpty ||
                                    pincode.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "${address.isNotEmpty ? '$address, ' : ''}${city.isNotEmpty ? city : ''}${pincode.isNotEmpty ? ', $pincode' : ''}",
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black87,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        const Icon(
                                          Icons.send,
                                          color: Color.fromARGB(
                                            255,
                                            82,
                                            128,
                                            255,
                                          ),
                                          size: 26,
                                        ),
                                      ],
                                    ),
                                  ),

                                const SizedBox(height: 30),

                                /// Action Buttons
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: mobile.isNotEmpty
                                            ? () => _makePhoneCall(mobile)
                                            : null,
                                        icon: const Icon(
                                          Icons.call,
                                          color: Colors.white,
                                        ),
                                        label: const Text(
                                          "Call",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: mobile.isNotEmpty
                                            ? () => _sendSMS(mobile)
                                            : null,
                                        icon: const FaIcon(
                                          FontAwesomeIcons.commentDots,
                                          color: Colors.white,
                                        ),
                                        label: const Text(
                                          "SMS",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: mobile.isNotEmpty
                                            ? () => _openWhatsApp(mobile)
                                            : null,
                                        icon: const FaIcon(
                                          FontAwesomeIcons.whatsapp,
                                          color: Colors.white,
                                        ),
                                        label: const Text(
                                          "What's App",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                            255,
                                            21,
                                            115,
                                            25,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: email.isNotEmpty
                                            ? () => _sendEmail(email)
                                            : null,
                                        icon: const FaIcon(
                                          FontAwesomeIcons.envelope,
                                          color: Colors.white,
                                        ),
                                        label: const Text(
                                          "E-mail",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                            255,
                                            243,
                                            47,
                                            33,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          /// Products Tab
                          SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Our Products",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                if (productList.isEmpty)
                                  const Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 50,
                                      ),
                                      child: Text(
                                        "No products available",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  Column(
                                    children: productList.asMap().entries.map((
                                      entry,
                                    ) {
                                      final index = entry.key;
                                      final product = entry.value;

                                      return Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(
                                                0.1,
                                              ),
                                              blurRadius: 6,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Theme(
                                          data: Theme.of(context).copyWith(
                                            dividerColor: Colors
                                                .transparent, // Removes default line
                                            splashColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                          ),
                                          child: ExpansionTile(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            collapsedShape:
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                            tilePadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 6,
                                                ),
                                            title: Text(
                                              product,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            leading: Container(
                                              height: 40,
                                              width: 40,
                                              decoration: BoxDecoration(
                                                color: Colors.purple.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: const Icon(
                                                Icons.inventory_2_rounded,
                                                color: Colors.purple,
                                                size: 22,
                                              ),
                                            ),
                                            childrenPadding:
                                                const EdgeInsets.only(
                                                  left: 16,
                                                  right: 16,
                                                  bottom: 12,
                                                ),
                                            children: [
                                              Container(
                                                width: double.infinity,
                                                padding: const EdgeInsets.all(
                                                  12,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: Colors.grey.shade200,
                                                  ),
                                                ),
                                                child: const Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Description:",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                    SizedBox(height: 6),
                                                    Text(
                                                      "Add product description here in the future.",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.black54,
                                                        height: 1.4,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Normal tier
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.favorite_border, color: Colors.black87),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Favorite functionality not implemented"),
                  ),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        person_name.isNotEmpty ? person_name : "",
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                business_name.isNotEmpty ? business_name : "No Business Name",
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  keywords != null && keywords is String
                      ? keywords.split(',').first.trim()
                      : "Unknown Category",
                  style: const TextStyle(color: Colors.black87, fontSize: 14),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow(
                      Icons.location_on_rounded,
                      "${address.isNotEmpty ? '$address, ' : ''}${city.isNotEmpty ? city : ''}${pincode.isNotEmpty ? ', $pincode' : ''}",
                    ),
                    _infoRow(
                      Icons.phone_rounded,
                      mobile.isNotEmpty ? formatMobile(mobile) : "N/A",
                    ),
                    _infoRow(
                      Icons.email_rounded,
                      email.isNotEmpty ? email : "N/A",
                    ),
                    _infoRow(
                      Icons.category_rounded,
                      keywords != null && keywords is String
                          ? keywords
                          : "No Keywords",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: mobile.isNotEmpty
                          ? () => _makePhoneCall(mobile)
                          : null,
                      icon: const Icon(Icons.call, color: Colors.white),
                      label: const Text(
                        "Call",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: mobile.isNotEmpty
                          ? () => _sendSMS(mobile)
                          : null,
                      icon: const FaIcon(
                        FontAwesomeIcons.commentDots,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "SMS",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: mobile.isNotEmpty
                          ? () => _openWhatsApp(mobile)
                          : null,
                      icon: const FaIcon(
                        FontAwesomeIcons.whatsapp,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "What's App",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 21, 115, 25),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: email.isNotEmpty
                          ? () => _sendEmail(email)
                          : null,
                      icon: const FaIcon(
                        FontAwesomeIcons.envelope,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "E-mail",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 243, 47, 33),
                        padding: const EdgeInsets.symmetric(vertical: 14),
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
      );
    }
  }
}
