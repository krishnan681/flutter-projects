// import 'package:celfonephonebookapp/screens/modelpage.dart';
// import 'package:celfonephonebookapp/screens/signin.dart';
// import 'package:celfonephonebookapp/supabase/supabase.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:url_launcher/url_launcher.dart';

// class SearchPage extends StatefulWidget {
//   final String? category;
//   final String? selectedLetter;
//   final List<dynamic>? filteredCompanies;

//   const SearchPage({
//     super.key,
//     this.category,
//     this.selectedLetter,
//     this.filteredCompanies,
//   });

//   @override
//   State<SearchPage> createState() => _SearchPageState();
// }

// class _SearchPageState extends State<SearchPage> {
//   final TextEditingController _firmPersonController = TextEditingController();
//   final TextEditingController _keywordsController = TextEditingController();

//   bool isFirmPersonFocused = false;
//   bool isKeywordsFocused = false;
//   bool isLoading = false;

//   List<dynamic> searchResults = [];

//   @override
//   void initState() {
//     super.initState();

//     // Check if a category is passed
//     if (widget.category != null && widget.category!.isNotEmpty) {
//       // Fill the keywords controller with the category
//       _keywordsController.text = widget.category!;

//       // Perform automatic search using name (instead of keywords)
//       _performCategorySearch(widget.category!);
//     }
//     // Case 1: Pre-fetched companies from HomePage
//     else if (widget.filteredCompanies != null &&
//         widget.filteredCompanies!.isNotEmpty) {
//       searchResults = widget.filteredCompanies!;
//     }
//     // Case 2: Selected letter (A, B, C...)
//     else if (widget.selectedLetter != null &&
//         widget.selectedLetter!.isNotEmpty) {
//       _performSearch(widget.selectedLetter!, searchType: "letter");
//     }
//     // Case 3: Default → fetch all
//     else {
//       _fetchAllCompanies();
//     }
//   }

//   Future<Map<String, List<String>>> fetchRelatedTerms() async {
//     try {
//       final response = await SupabaseService.client
//           .from('related_terms')
//           .select('category, related_keywords');

//       final Map<String, List<String>> relatedTerms = {};
//       for (var row in response) {
//         final String category = row['category'].toString().toLowerCase();
//         final List<dynamic> keywords = row['related_keywords'] ?? [];
//         relatedTerms[category] = keywords
//             .map((e) => e.toString().toLowerCase())
//             .toList();
//       }
//       return relatedTerms;
//     } catch (e) {
//       debugPrint("Error fetching related terms: $e");
//       return {};
//     }
//   }

//   /// Fetch all companies (default view)
//   Future<void> _fetchAllCompanies() async {
//     setState(() => isLoading = true);
//     try {
//       final results = await Supabase.instance.client
//           .from('profiles')
//           .select()
//           .order('is_prime', ascending: false);

//       List<dynamic> sorted = (results as List<dynamic>)
//         ..sort((a, b) {
//           if (a['is_prime'] == true && b['is_prime'] != true) return -1;
//           if (b['is_prime'] == true && a['is_prime'] != true) return 1;
//           if (a['priority'] == true && b['priority'] != true) return -1;
//           if (b['priority'] == true && a['priority'] != true) return 1;
//           return 0;
//         });

//       setState(() => searchResults = sorted);
//     } catch (e) {
//       debugPrint("Fetch error: $e");
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   /// Check login before performing actions
//   Future<void> _checkLoginAndProceed(Function onLoggedIn) async {
//     final prefs = await SharedPreferences.getInstance();
//     final userId = prefs.getString("userId");

//     if (userId == null) {
//       // Not logged in → show alert
//       if (!mounted) return;
//       showDialog(
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//             title: const Text("Login Required"),
//             content: const Text("You need to sign in to use this feature."),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text("Cancel"),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context); // close dialog
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => const SigninPage()),
//                   );
//                 },
//                 child: const Text("Sign In"),
//               ),
//             ],
//           );
//         },
//       );
//     } else {
//       // Logged in → proceed
//       onLoggedIn();
//     }
//   }

//   /// Perform filtered search
//   Future<void> _performSearch(
//     String query, {
//     required String searchType,
//   }) async {
//     if (query.isEmpty) return;

//     setState(() => isLoading = true);
//     try {
//       var request = SupabaseService.client.from('profiles').select();

//       if (searchType == "name") {
//         request = request.or(
//           'business_name.ilike.%$query%,person_name.ilike.%$query%',
//         );
//       } else if (searchType == "keywords") {
//         request = request.ilike('keywords', '%$query%');
//       } else if (searchType == "letter") {
//         request = request.or('business_name.ilike.${query.toUpperCase()}%');
//       }

//       final results = await request.order('is_prime', ascending: false);

//       List<dynamic> sorted = (results as List<dynamic>)
//         ..sort((a, b) {
//           if (a['is_prime'] == true && b['is_prime'] != true) return -1;
//           if (b['is_prime'] == true && a['is_prime'] != true) return 1;
//           if (a['priority'] == true && b['priority'] != true) return -1;
//           if (b['priority'] == true && a['priority'] != true) return 1;
//           return 0;
//         });

//       setState(() => searchResults = sorted);
//     } catch (e) {
//       debugPrint("Search error: $e");
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   /// Enhanced category-based search — matches related terms like gold, jewel, diamond
//   Future<void> _performCategorySearch(String category) async {
//     setState(() => isLoading = true);

//     try {
//       // Fetch related terms dynamically from Supabase
//       final Map<String, List<String>> relatedTerms = await fetchRelatedTerms();

//       // Determine related keywords for given category
//       final lowerCategory = category.toLowerCase();
//       final List<String> searchTerms = relatedTerms.entries
//           .where((e) => lowerCategory.contains(e.key))
//           .expand((e) => e.value)
//           .toList();

//       // Default fallback
//       if (searchTerms.isEmpty) {
//         searchTerms.add(category);
//       }

//       final orConditions = searchTerms
//           .map(
//             (term) =>
//                 'business_name.ilike.%$term%,person_name.ilike.%$term%,keywords.ilike.%$term%',
//           )
//           .join(',');

//       final results = await SupabaseService.client
//           .from('profiles')
//           .select()
//           .or(orConditions)
//           .order('is_prime', ascending: false);

//       List<dynamic> sorted = (results as List<dynamic>)
//         ..sort((a, b) {
//           if (a['is_prime'] == true && b['is_prime'] != true) return -1;
//           if (b['is_prime'] == true && a['is_prime'] != true) return 1;
//           if (a['priority'] == true && b['priority'] != true) return -1;
//           if (b['priority'] == true && a['priority'] != true) return 1;
//           return 0;
//         });

//       setState(() => searchResults = sorted);
//     } catch (e) {
//       debugPrint("Category search error: $e");
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   Widget keywordHighlight(String text, String query) {
//     if (query.isEmpty || !text.toLowerCase().contains(query.toLowerCase())) {
//       return Text(
//         text,
//         style: const TextStyle(
//           fontSize: 16,
//           // fontWeight: FontWeight.w600,
//           color: Colors.black87,
//         ),
//       );
//     }

//     final lower = text.toLowerCase();
//     final lowerQuery = query.toLowerCase();
//     final startIndex = lower.indexOf(lowerQuery);
//     final endIndex = startIndex + query.length;

//     return RichText(
//       text: TextSpan(
//         children: [
//           TextSpan(
//             text: text.substring(0, startIndex),
//             style: const TextStyle(
//               fontSize: 16,
//               // fontWeight: FontWeight.w600,
//               color: Colors.black87,
//             ),
//           ),
//           TextSpan(
//             text: text.substring(startIndex, endIndex),
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w700,
//               color: Colors.blue,
//             ),
//           ),
//           TextSpan(
//             text: text.substring(endIndex),
//             style: const TextStyle(
//               fontSize: 16,
//               // fontWeight: FontWeight.w600,
//               color: Colors.black87,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   /// Highlight matching text
//   Widget highlightKeywords(String text, String query) {
//     if (query.isEmpty || !text.toLowerCase().contains(query.toLowerCase())) {
//       return Text(
//         text,
//         style: const TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.w600,
//           color: Colors.black87,
//         ),
//       );
//     }

//     final lower = text.toLowerCase();
//     final lowerQuery = query.toLowerCase();
//     final startIndex = lower.indexOf(lowerQuery);
//     final endIndex = startIndex + query.length;

//     return RichText(
//       text: TextSpan(
//         children: [
//           TextSpan(
//             text: text.substring(0, startIndex),
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: Colors.black87,
//             ),
//           ),
//           TextSpan(
//             text: text.substring(startIndex, endIndex),
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w700,
//               color: Colors.blue,
//             ),
//           ),
//           TextSpan(
//             text: text.substring(endIndex),
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: Colors.black87,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   /// Launch phone call
//   Future<void> _makeCall(String mobile) async {
//     final uri = Uri.parse("tel:$mobile");
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri);
//     }
//   }

//   void showEnquiryPopup(
//     BuildContext context,
//     String name,
//     String mobileNumber,
//   ) {
//     TextEditingController _controller = TextEditingController(
//       text:
//           "I Saw Your Listing in SIGNPOST PHONE BOOK. I am Interested in your Products. Please Send Details/Call Me. (Sent Through Signpost PHONE BOOK)",
//     );
//     int maxChars = 160;

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text('Enquiry to $name'),
//           content: StatefulBuilder(
//             builder: (context, setState) {
//               return Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   TextField(
//                     controller: _controller,
//                     maxLength: maxChars,
//                     maxLines: 3,
//                     decoration: InputDecoration(
//                       border: OutlineInputBorder(),
//                       labelText: 'Your Message',
//                       counterText:
//                           '${_controller.text.length}/$maxChars characters',
//                     ),
//                     onChanged: (val) {
//                       setState(() {});
//                     },
//                   ),
//                   const SizedBox(height: 10),
//                   Wrap(
//                     spacing: 10,
//                     children: [
//                       ElevatedButton.icon(
//                         onPressed: () async {
//                           final uri = Uri.parse(
//                             'sms:$mobileNumber?body=${Uri.encodeComponent(_controller.text)}',
//                           );
//                           if (await canLaunchUrl(uri)) {
//                             launchUrl(uri);
//                           }
//                         },
//                         icon: Icon(Icons.message),
//                         label: Text('SMS'),
//                       ),
//                       ElevatedButton.icon(
//                         onPressed: () async {
//                           final uri = Uri.parse('tel:$mobileNumber');
//                           if (await canLaunchUrl(uri)) {
//                             launchUrl(uri);
//                           }
//                         },
//                         icon: Icon(Icons.call),
//                         label: Text('Call'),
//                       ),
//                       ElevatedButton.icon(
//                         onPressed: () async {
//                           final uri = Uri.parse(
//                             'https://wa.me/$mobileNumber?text=${Uri.encodeComponent(_controller.text)}',
//                           );
//                           if (await canLaunchUrl(uri)) {
//                             launchUrl(uri);
//                           }
//                         },
//                         icon: Icon(Icons.message_rounded),
//                         label: Text('WhatsApp'),
//                       ),
//                       ElevatedButton.icon(
//                         onPressed: () async {
//                           final uri = Uri.parse(
//                             'mailto:?subject=Enquiry&body=${Uri.encodeComponent(_controller.text)}',
//                           );
//                           if (await canLaunchUrl(uri)) {
//                             launchUrl(uri);
//                           }
//                         },
//                         icon: Icon(Icons.email),
//                         label: Text('Email'),
//                       ),
//                     ],
//                   ),
//                 ],
//               );
//             },
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text('Close'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   /// --- Business Card Widget ---
//   Widget _tieredBusinessCard(
//     BuildContext context, {
//     required String name,
//     required String city,
//     required String pincode,
//     required String mobile,
//     required String keywords,
//     required String tier,
//     required String email,
//     required String description,
//     required String business_name,
//     required String landline,
//     required String landline_code,
//     required String address,
//     required String person_name,
//     required String currentSearchType,
//     required String currentQuery,
//   }) {
//     Color stripeColor;
//     Color borderColor;
//     IconData? tierIcon;
//     Color? tierIconColor;

//     if (tier == 'gold') {
//       stripeColor = const Color(0xFFFFC107); // vivid gold
//       borderColor = const Color(0xFFFFB300);
//       tierIcon = Icons.emoji_events; // trophy icon
//       tierIconColor = Colors.amber[700];
//     } else if (tier == 'platinum') {
//       stripeColor = const Color(0xFFB0BEC5); // silver/grey
//       borderColor = const Color(0xFF90A4AE);
//       tierIcon = Icons.star; // star icon
//       tierIconColor = Colors.blueGrey[400];
//     } else {
//       stripeColor = Colors.transparent;
//       borderColor = Colors.grey[300]!;
//     }

//     // Mask mobile number (e.g. 98655 XXXXX)
//     String maskedMobile = mobile.length >= 5
//         ? "${mobile.substring(0, 5)} XXXXX"
//         : mobile;

//     // For keywords search → show keywords instead of city
//     String secondaryText = currentSearchType == "keywords"
//         ? keywords
//         : "$city, $pincode";

//     return InkWell(
//       onTap: () {
//         _checkLoginAndProceed(() {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => ModelPage(
//                 profile: {
//                   "name": name,
//                   "city": city,
//                   "pincode": pincode,
//                   "mobile": mobile,
//                   "keywords": keywords,
//                   "tier": tier,
//                   "email": email,
//                   "address": address,
//                   "description": description,
//                   "landline": landline,
//                   "person_name": person_name,
//                   "business_name": business_name,
//                   "landline_code": landline_code,
//                 },
//               ),
//             ),
//           );
//         });
//       },
//       child: SizedBox(
//         height: 130,
//         child: Stack(
//           children: [
//             if (tier != 'normal')
//               Positioned.fill(
//                 child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: Container(
//                     margin: const EdgeInsets.only(left: 1),
//                     width: 17,
//                     decoration: BoxDecoration(
//                       color: stripeColor,
//                       borderRadius: const BorderRadius.only(
//                         topLeft: Radius.circular(50),
//                         bottomLeft: Radius.circular(50),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),

//             Positioned.fill(
//               left: (tier == 'gold' || tier == 'platinum') ? 10 : 0,
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(
//                     color: borderColor,
//                     width: tier == 'normal' ? 1 : 2.5,
//                   ),
//                   boxShadow: const [
//                     BoxShadow(
//                       color: Colors.black12,
//                       blurRadius: 4,
//                       offset: Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 14,
//                     vertical: 12,
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       // Info section
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: (currentSearchType == "name")
//                                       ? highlightKeywords(name, currentQuery)
//                                       : Text(
//                                           name,
//                                           style: const TextStyle(
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.w600,
//                                             color: Colors.black87,
//                                           ),
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                 ),
//                                 if (tierIcon != null) ...[
//                                   const SizedBox(width: 6),
//                                   Icon(
//                                     tierIcon,
//                                     color: tierIconColor,
//                                     size: 18,
//                                   ),
//                                 ],
//                               ],
//                             ),
//                             const SizedBox(height: 4),
//                             Row(
//                               children: [
//                                 if (currentSearchType != "keywords") ...[
//                                   const Icon(
//                                     Icons.location_on,
//                                     size: 16,
//                                     color: Colors.grey,
//                                   ),
//                                   const SizedBox(width: 4),
//                                 ],
//                                 Flexible(
//                                   child: (currentSearchType == "keywords")
//                                       ? keywordHighlight(
//                                           secondaryText,
//                                           currentQuery,
//                                         )
//                                       : Text(
//                                           secondaryText,
//                                           style: const TextStyle(
//                                             color: Colors.grey,
//                                             fontSize: 14,
//                                           ),
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 4),
//                             Row(
//                               children: [
//                                 const Icon(
//                                   Icons.phone,
//                                   size: 16,
//                                   color: Colors.grey,
//                                 ),
//                                 const SizedBox(width: 4),
//                                 Text(
//                                   maskedMobile,
//                                   style: const TextStyle(
//                                     color: Colors.grey,
//                                     fontSize: 14,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),

//                       // Action buttons → Call + Fav on top, Enquiry below
//                       Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           // Row → Call + Favorite
//                           Row(
//                             children: [
//                               _circleButton(
//                                 context,
//                                 icon: Icons.call,
//                                 bgColor: const Color.fromARGB(255, 9, 178, 23),
//                                 iconColor: Colors.white,
//                                 onTap: () {
//                                   _checkLoginAndProceed(() {
//                                     _makeCall(mobile);
//                                   });
//                                 },
//                               ),
//                               const SizedBox(width: 8),
//                               _circleButton(
//                                 context,
//                                 icon: Icons.favorite_border,
//                                 bgColor: Colors.grey[200]!,
//                                 iconColor: Colors.black54,
//                                 onTap: () {
//                                   _checkLoginAndProceed(() {
//                                     showModalBottomSheet(
//                                       context: context,
//                                       isScrollControlled: true,
//                                       shape: const RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.vertical(
//                                           top: Radius.circular(20),
//                                         ),
//                                       ),
//                                       builder: (context) {
//                                         return FavoriteOptionsModal(
//                                           name: name,
//                                           mobile: mobile,
//                                         );
//                                       },
//                                     );
//                                   });
//                                 },
//                               ),
//                             ],
//                           ),

//                           const SizedBox(height: 8),
//                           // Bigger Enquiry button below
//                           Transform.scale(
//                             scale: 1.05, // slightly bigger
//                             child: Material(
//                               color: Colors.grey[200],
//                               borderRadius: BorderRadius.circular(25),
//                               child: InkWell(
//                                 borderRadius: BorderRadius.circular(25),
//                                 onTap: () {
//                                   _checkLoginAndProceed(() {
//                                     showEnquiryPopup(context, name, mobile);
//                                   });
//                                 },
//                                 child: const Padding(
//                                   padding: EdgeInsets.symmetric(
//                                     horizontal: 14,
//                                     vertical: 8,
//                                   ),
//                                   child: Text(
//                                     "Enquiry",
//                                     style: TextStyle(
//                                       color: Colors.black87,
//                                       fontSize: 13,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _circleButton(
//     BuildContext context, {
//     required IconData icon,
//     required Color bgColor,
//     required Color iconColor,
//     required VoidCallback onTap,
//   }) {
//     return Material(
//       color: bgColor,
//       shape: const CircleBorder(),
//       child: InkWell(
//         customBorder: const CircleBorder(),
//         onTap: onTap,
//         child: Padding(
//           padding: const EdgeInsets.all(10),
//           child: Icon(icon, color: iconColor, size: 20),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//         title: Text(
//           widget.category ?? widget.selectedLetter ?? "Search Page",
//           style: const TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Colors.black87,
//           ),
//         ),
//       ),
//       body: Column(
//         children: [
//           const SizedBox(height: 10),

//           // Dual Search Bars
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Row(
//               children: [
//                 // Firm / Person Search
//                 Expanded(
//                   flex: isFirmPersonFocused ? 8 : 5,
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 300),
//                     margin: const EdgeInsets.only(right: 8),
//                     child: TextField(
//                       controller: _firmPersonController,
//                       onTap: () {
//                         setState(() {
//                           isFirmPersonFocused = true;
//                           isKeywordsFocused = false;
//                           _keywordsController.clear();
//                           _performSearch("", searchType: "name");
//                           _fetchAllCompanies();
//                         });
//                       },
//                       onChanged: (value) {
//                         if (value.length >= 3) {
//                           _performSearch(value, searchType: "name");
//                         } else if (value.isEmpty) {
//                           _fetchAllCompanies();
//                         }
//                       },
//                       decoration: InputDecoration(
//                         hintText: "Firm / Person",
//                         prefixIcon: const Icon(
//                           Icons.search,
//                           color: Colors.black54,
//                         ),
//                         filled: true,
//                         fillColor: Colors.white,
//                         contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 14,
//                         ),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(25),
//                           borderSide: BorderSide.none,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),

//                 // Keywords Search
//                 Expanded(
//                   flex: isKeywordsFocused ? 8 : 5,
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 300),
//                     child: TextField(
//                       controller: _keywordsController,
//                       onTap: () {
//                         setState(() {
//                           isFirmPersonFocused = false;
//                           isKeywordsFocused = true;
//                           _firmPersonController.clear();
//                           _fetchAllCompanies();
//                         });
//                       },
//                       onChanged: (value) {
//                         if (value.length >= 3) {
//                           _performSearch(value, searchType: "keywords");
//                         } else if (value.isEmpty) {
//                           _fetchAllCompanies();
//                         }
//                       },
//                       decoration: InputDecoration(
//                         hintText: "Keywords",
//                         prefixIcon: const Icon(
//                           Icons.search,
//                           color: Colors.black54,
//                         ),
//                         filled: true,
//                         fillColor: Colors.white,
//                         contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 14,
//                         ),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(25),
//                           borderSide: BorderSide.none,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 20),

//           // Results
//           Expanded(
//             child: isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : searchResults.isEmpty
//                 ? const Center(
//                     child: Text(
//                       "No results found",
//                       style: TextStyle(color: Colors.black54, fontSize: 16),
//                     ),
//                   )
//                 : ListView.builder(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     itemCount: searchResults.length,
//                     itemBuilder: (context, index) {
//                       final item = searchResults[index];

//                       // Determine current query based on focused search bar
//                       final currentQuery = isKeywordsFocused
//                           ? _keywordsController.text
//                           : _firmPersonController.text;

//                       // Determine name to display
//                       final String name;
//                       if (item['business_name']?.toString().isNotEmpty ==
//                               true &&
//                           item['business_name']
//                               .toString()
//                               .toLowerCase()
//                               .contains(currentQuery.toLowerCase())) {
//                         name = item['business_name'];
//                       } else if (item['person_name']?.toString().isNotEmpty ==
//                               true &&
//                           item['person_name'].toString().toLowerCase().contains(
//                             currentQuery.toLowerCase(),
//                           )) {
//                         name = item['person_name'];
//                       } else {
//                         name =
//                             item['business_name']?.toString().isNotEmpty == true
//                             ? item['business_name']
//                             : (item['person_name'] ?? "No Name");
//                       }

//                       final city = item['city'] ?? "Unknown City";
//                       final mobile = item['mobile_number'] ?? "N/A";
//                       final keywords = item['keywords'] ?? "";

//                       String tier = "normal";
//                       if (item['is_prime'] == true) {
//                         tier = "gold";
//                       } else if (item['priority'] == true) {
//                         tier = "platinum";
//                       }
//                       final email = item['email'] ?? "";
//                       final description = item['description'] ?? "";
//                       final person_name = item['person_name'] ?? "";
//                       final business_name = item['business_name'] ?? "";
//                       final landline = item['landline'] ?? "";
//                       final landline_code = item['landline_code'] ?? "";
//                       final address = item['address'] ?? "";

//                       return Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 8.0),
//                         child: _tieredBusinessCard(
//                           context,
//                           name: name,
//                           city: city,
//                           pincode: item['pincode'] ?? "",
//                           mobile: mobile,
//                           keywords: keywords,
//                           email: email,
//                           description: description,
//                           person_name: person_name,
//                           business_name: business_name,
//                           landline: landline,
//                           landline_code: landline_code,
//                           address: address,

//                           tier: tier,
//                           currentSearchType: isKeywordsFocused
//                               ? "keywords"
//                               : "name",
//                           currentQuery: isKeywordsFocused
//                               ? _keywordsController.text
//                               : _firmPersonController.text,
//                         ),
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// /// Modal Widget for Favorites
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

// class _FavoriteOptionsModalState extends State<FavoriteOptionsModal> {
//   String? selectedOption;

//   final List<String> options = [
//     "My Buyers",
//     "My Sellers",
//     "Family & Friends",
//     "My List",
//   ];

//   bool isLoading = false;

//   /// Save member into group
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

//       // Step 1: Check if group already exists
//       final existingGroups = await SupabaseService.client
//           .from("favorites_groups")
//           .select()
//           .eq("group_name", selectedOption!)
//           .eq("user_id", userId);

//       dynamic groupId;

//       if (existingGroups.isNotEmpty) {
//         groupId = existingGroups[0]['id'];
//       } else {
//         // Create new group
//         final inserted = await SupabaseService.client
//             .from("favorites_groups")
//             .insert({"group_name": selectedOption, "user_id": userId})
//             .select()
//             .single();
//         groupId = inserted['id'];
//       }

//       // Step 2: Check for duplicate member in this group
//       final existingMember = await SupabaseService.client
//           .from("group_members")
//           .select()
//           .eq("group_id", groupId)
//           .eq("mobile_number", widget.mobile);

//       if (existingMember.isNotEmpty) {
//         // Already exists
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               "${widget.name} (${widget.mobile}) is already in $selectedOption",
//             ),
//           ),
//         );
//       } else {
//         // Step 3: Insert member
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
//       debugPrint("Error saving favorite: $e");
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Error: $e")));
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

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

//           // Options
//           ...options.map((option) {
//             return CheckboxListTile(
//               title: Text(option),
//               value: selectedOption == option,
//               onChanged: (val) {
//                 setState(() {
//                   selectedOption = option;
//                 });
//               },
//             );
//           }).toList(),

//           const SizedBox(height: 16),

//           // Buttons
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.redAccent,
//                 ),
//                 onPressed: () {
//                   setState(() {
//                     selectedOption = null;
//                   });
//                 },
//                 child: const Text("Clear"),
//               ),
//               ElevatedButton(
//                 onPressed: isLoading ? null : _saveFavorite,
//                 child: isLoading
//                     ? const SizedBox(
//                         height: 16,
//                         width: 16,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           color: Colors.white,
//                         ),
//                       )
//                     : const Text("Save"),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
//
//   /// new

import 'package:celfonephonebookapp/screens/modelpage.dart';
import 'package:celfonephonebookapp/screens/signin.dart';
import 'package:celfonephonebookapp/supabase/supabase.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:animations/animations.dart';

class SearchPage extends StatefulWidget {
  final String? initialFilter;
  final List<dynamic>? filteredCompanies;
  final bool forceGeneralSearch;
  final String? subcategoryContext;

  const SearchPage({
    super.key,
    this.initialFilter,
    this.filteredCompanies,
    this.forceGeneralSearch = false,
    this.subcategoryContext,
    required String category,
    required String selectedLetter,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _firmPersonController = TextEditingController();
  final TextEditingController _keywordsController = TextEditingController();

  bool isFirmPersonFocused = false;
  bool isKeywordsFocused = false;
  bool isLoading = false;
  List<dynamic> searchResults = [];

  @override
  void initState() {
    super.initState();

    final filter = widget.initialFilter?.trim();

    if (widget.filteredCompanies != null &&
        widget.filteredCompanies!.isNotEmpty) {
      searchResults = widget.filteredCompanies!;
      _sortResults();
      setState(() {});
      return;
    }

    if (filter == null || filter.isEmpty) {
      _fetchAllCompanies();
      return;
    }

    if (filter.length == 1 && RegExp(r'^[A-Z]$').hasMatch(filter)) {
      _firmPersonController.clear();
      _keywordsController.clear();
      _performSearch(filter, searchType: "letter");
      return;
    }

    if (widget.forceGeneralSearch) {
      _firmPersonController.text = filter;
      _keywordsController.clear();
      isFirmPersonFocused = true;
      isKeywordsFocused = false;
      _performCategorySearch(filter);
      return;
    }

    _keywordsController.text = filter;
    isKeywordsFocused = true;
    isFirmPersonFocused = false;
    _performCategorySearch(filter);
  }

  void _sortResults() {
    searchResults.sort((a, b) {
      final bool primeA = a['is_prime'] == true;
      final bool primeB = b['is_prime'] == true;
      final bool prioA = a['priority'] == true;
      final bool prioB = b['priority'] == true;

      if (primeA && !primeB) return -1;
      if (!primeA && primeB) return 1;
      if (prioA && !prioB) return -1;
      if (!prioA && prioB) return 1;

      final subA = (a['subscription'] ?? '').toString().toLowerCase();
      final subB = (b['subscription'] ?? '').toString().toLowerCase();

      final order = ['gold', 'business', 'normal_business', 'free'];
      final indexA = order.indexOf(subA);
      final indexB = order.indexOf(subB);

      if (indexA != indexB) return indexA.compareTo(indexB);
      return 0;
    });
  }

  Future<void> _fetchAllCompanies() async {
    setState(() => isLoading = true);
    try {
      final results = await Supabase.instance.client
          .from('profiles')
          .select()
          .order('is_prime', ascending: false);

      setState(() {
        searchResults = results;
        _sortResults();
      });
    } catch (e) {
      debugPrint("Fetch error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _checkLoginAndProceed(Function onLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("userId");
    if (userId == null) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Login Required"),
          content: const Text("You need to sign in to use this feature."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
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
    } else {
      onLoggedIn();
    }
  }

  Future<void> _performSearch(
    String query, {
    required String searchType,
  }) async {
    if (query.isEmpty) return;
    setState(() => isLoading = true);
    try {
      var request = SupabaseService.client.from('profiles').select();
      if (searchType == "name") {
        request = request.or(
          'business_name.ilike.%$query%,person_name.ilike.%$query%',
        );
      } else if (searchType == "keywords") {
        request = request.ilike('keywords', '%$query%');
      } else if (searchType == "letter") {
        request = request.ilike('business_name', '${query.toUpperCase()}%');
      }
      final results = await request.order('is_prime', ascending: false);

      setState(() {
        searchResults = results;
        _sortResults();
      });
    } catch (e) {
      debugPrint("Search error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _performCategorySearch(String category) async {
    setState(() => isLoading = true);
    try {
      final query = category.trim();
      if (query.isEmpty) {
        await _fetchAllCompanies();
        return;
      }

      var request = SupabaseService.client.from('profiles').select();

      if (widget.subcategoryContext != null) {
        final context = widget.subcategoryContext!.toLowerCase();
        String boostConditions = '';

        if (context == 'college') {
          boostConditions =
              'keywords.ilike.%college%,keywords.ilike.%institute%,keywords.ilike.%university%,keywords.ilike.%school%,business_name.ilike.%college%,business_name.ilike.%institute%';
        } else if (context == 'doctor') {
          boostConditions =
              'keywords.ilike.%doctor%,keywords.ilike.%clinic%,keywords.ilike.%hospital%,keywords.ilike.%physician%,business_name.ilike.%dr.%,business_name.ilike.%clinic%';
        } else if (context == 'hospital') {
          boostConditions =
              'keywords.ilike.%hospital%,keywords.ilike.%clinic%,keywords.ilike.%medical centre%,business_name.ilike.%hospital%';
        } else if (context == 'hotel') {
          boostConditions =
              'keywords.ilike.%hotel%,keywords.ilike.%resort%,keywords.ilike.%lodge%,business_name.ilike.%hotel%,business_name.ilike.%resort%';
        } else if (context == 'travel') {
          boostConditions =
              'keywords.ilike.%travel%,keywords.ilike.%tours%,keywords.ilike.%cab%,keywords.ilike.%bus%,keywords.ilike.%visa%';
        } else if (context == 'shop') {
          boostConditions =
              'keywords.ilike.%shop%,keywords.ilike.%store%,keywords.ilike.%mart%,keywords.ilike.%super market%';
        } else if (context == 'parlour') {
          boostConditions =
              'keywords.ilike.%parlour%,keywords.ilike.%salon%,keywords.ilike.%spa%,keywords.ilike.%beauty%';
        }

        if (boostConditions.isNotEmpty) {
          request = request.or(boostConditions);
        }
      }

      request = request.or(
        'business_name.ilike.%$query%,person_name.ilike.%$query%,keywords.ilike.%$query%',
      );

      final words = query.split(' ').where((w) => w.length >= 2).toList();
      if (words.isNotEmpty) {
        final wordConditions = words
            .map(
              (w) =>
                  'business_name.ilike.%$w%,person_name.ilike.%$w%,keywords.ilike.%$w%',
            )
            .join(',');
        request = request.or(wordConditions);
      }

      final results = await request
          .order('is_prime', ascending: false)
          .order('priority', ascending: false);

      setState(() {
        searchResults = results;
        _sortResults();
      });
    } catch (e) {
      debugPrint("Category search error: $e");
      await _fetchAllCompanies();
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showEnquiryPopup(BuildContext context, String name, String mobile) {
    final controller = TextEditingController(
      text:
          "I Saw Your Listing in SIGNPOST PHONE BOOK. I am Interested in your Products. Please Send Details/Call Me.",
    );
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Enquiry to $name'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              maxLines: 3,
              maxLength: 160,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Your Message',
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.message),
                  label: const Text("SMS"),
                  onPressed: () => launchUrl(
                    Uri.parse(
                      'sms:$mobile?body=${Uri.encodeComponent(controller.text)}',
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.call),
                  label: const Text("Call"),
                  onPressed: () => launchUrl(Uri.parse('tel:$mobile')),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.message_rounded),
                  label: const Text("WhatsApp"),
                  onPressed: () => launchUrl(
                    Uri.parse(
                      'https://wa.me/$mobile?text=${Uri.encodeComponent(controller.text)}',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  String _getKeywordsString(dynamic k) {
    if (k == null) return "No products";
    if (k is String) {
      return k.split(',').map((e) => e.split(':').first.trim()).join(', ');
    }
    if (k is List) {
      return k
          .map((e) => e is Map ? (e['name'] ?? e['title'] ?? "") : e.toString())
          .where((e) => e.isNotEmpty)
          .join(', ');
    }
    return "No products";
  }

  // Helper: Truncate name to first 1-2 words + "..."
  String _trimName(String fullName) {
    if (fullName.isEmpty) return "User";
    final words = fullName.trim().split(' ');
    if (words.length <= 2) return fullName;
    return '${words[0]} ${words.length > 1 ? words[1] : ''}...'.trim();
  }

  Widget _goldTierCard(Map<String, dynamic> item, String fullName) {
    final truncatedName = _trimName(fullName);
    final goldGradient = const LinearGradient(
      colors: [Color(0xFFb87333), Color(0xFFFFD700)],
    );
    final mobile = item['mobile_number'] ?? "";
    final maskedMobile = mobile.length >= 5
        ? "${mobile.substring(0, 5)} XXXXX"
        : mobile;
    final keywordsStr = _getKeywordsString(item['keywords']);

    return OpenContainer(
      transitionDuration: const Duration(milliseconds: 450),
      closedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      closedBuilder: (context, openContainer) => InkWell(
        onTap: () => _checkLoginAndProceed(openContainer),
        child: Container(
          decoration: BoxDecoration(
            gradient: goldGradient,
            border: Border.all(color: Colors.amber, width: 5),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(12),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                truncatedName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.workspace_premium,
                                color: Colors.amber,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified,
                                color: Colors.green,
                                size: 18,
                              ),
                              const Spacer(),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _checkLoginAndProceed(
                            () => launchUrl(Uri.parse("tel:$mobile")),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: Icon(
                              Icons.call,
                              color: Colors.green,
                              size: 28,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => _checkLoginAndProceed(() {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                              ),
                              builder: (_) => FavoriteOptionsModal(
                                name: fullName,
                                mobile: mobile,
                              ),
                            );
                          }),
                          child: const Icon(
                            Icons.favorite_border,
                            color: Colors.pink,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          isKeywordsFocused
                              ? Icons.inventory_2
                              : Icons.location_on,
                          color: Colors.grey,
                          size: 14,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            isKeywordsFocused
                                ? keywordsStr
                                : "${item['city'] ?? ""}, ${item['pincode'] ?? ""}",
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.phone, color: Colors.grey, size: 14),
                        const SizedBox(width: 5),
                        Text(
                          maskedMobile,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => _checkLoginAndProceed(
                      () => showEnquiryPopup(context, fullName, mobile),
                    ),
                    child: Container(
                      width: 100,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: goldGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          "Enquire",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      openBuilder: (_, __) => ModelPage(profile: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.initialFilter?.length == 1 &&
                  RegExp(r'^[A-Z]$').hasMatch(widget.initialFilter!)
              ? "Starts with ${widget.initialFilter}"
              : widget.initialFilter ?? "Search Results",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  flex: isFirmPersonFocused ? 8 : 5,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(right: 8),
                    child: TextField(
                      controller: _firmPersonController,
                      onTap: () {
                        setState(() {
                          isFirmPersonFocused = true;
                          isKeywordsFocused = false;
                          _keywordsController.clear();
                          _fetchAllCompanies();
                        });
                      },
                      onChanged: (value) {
                        if (value.length >= 3) {
                          _performSearch(value, searchType: "name");
                        } else if (value.isEmpty) {
                          _fetchAllCompanies();
                        }
                      },
                      decoration: InputDecoration(
                        hintText: "Firm / Person",
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.black54,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: isKeywordsFocused ? 8 : 5,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    child: TextField(
                      controller: _keywordsController,
                      onTap: () {
                        setState(() {
                          isFirmPersonFocused = false;
                          isKeywordsFocused = true;
                          _firmPersonController.clear();
                          _fetchAllCompanies();
                        });
                      },
                      onChanged: (value) {
                        if (value.length >= 3) {
                          _performSearch(value, searchType: "keywords");
                        } else if (value.isEmpty) {
                          _fetchAllCompanies();
                        }
                      },
                      decoration: InputDecoration(
                        hintText: "Keywords",
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.black54,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : searchResults.isEmpty
                ? const Center(
                    child: Text(
                      "No results found",
                      style: TextStyle(color: Colors.black54, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final item = searchResults[index];
                      final sub = (item['subscription'] ?? '')
                          .toString()
                          .toLowerCase();
                      final bool isGold =
                          item['is_prime'] == true || sub == 'gold';
                      final String fullName =
                          item['business_name']?.toString().isNotEmpty == true
                          ? item['business_name']
                          : item['person_name'] ?? "User";
                      final String mobile =
                          item['mobile_number']?.toString() ?? "";
                      final String maskedMobile = mobile.length >= 5
                          ? "${mobile.substring(0, 5)} XXXXX"
                          : mobile;
                      final String keywordsStr = _getKeywordsString(
                        item['keywords'],
                      );
                      final String displayText = isKeywordsFocused
                          ? keywordsStr
                          : "${item['city'] ?? ''}, ${item['pincode'] ?? ''}";

                      if (isGold) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: _goldTierCard(item, fullName),
                        );
                      }

                      final String tier = sub == 'business'
                          ? 'business'
                          : sub == 'normal_business' || sub == 'normal business'
                          ? 'normal_business'
                          : 'free';

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: TieredBusinessCard(
                          fullName: fullName,
                          displayText: displayText,
                          displayIcon: isKeywordsFocused
                              ? Icons.inventory_2
                              : Icons.location_on_outlined,
                          mobile: maskedMobile,
                          tier: tier,
                          priority: item['priority'] == true,
                          onTap: () => _checkLoginAndProceed(
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ModelPage(profile: item),
                              ),
                            ),
                          ),
                          onCall: () => _checkLoginAndProceed(
                            () => launchUrl(Uri.parse("tel:$mobile")),
                          ),
                          onEnquiry: () => _checkLoginAndProceed(
                            () => showEnquiryPopup(context, fullName, mobile),
                          ),
                          onFavorite: () => _checkLoginAndProceed(
                            () => showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                              ),
                              builder: (_) => FavoriteOptionsModal(
                                name: fullName,
                                mobile: mobile,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class TieredBusinessCard extends StatelessWidget {
  final String fullName;
  final String displayText, mobile, tier;
  final IconData displayIcon;
  final bool priority;
  final VoidCallback onTap, onCall, onEnquiry, onFavorite;

  const TieredBusinessCard({
    super.key,
    required this.fullName,
    required this.displayText,
    required this.displayIcon,
    required this.mobile,
    required this.tier,
    required this.priority,
    required this.onTap,
    required this.onCall,
    required this.onEnquiry,
    required this.onFavorite,
  });

  String _trimName(String name) {
    final words = name.trim().split(' ');
    if (words.length <= 2) return name;
    return '${words[0]} ${words.length > 1 ? words[1] : ''}...'.trim();
  }

  @override
  Widget build(BuildContext context) {
    final truncatedName = _trimName(fullName);

    Color primaryColor;
    Color buttonColor;

    if (tier == 'business') {
      primaryColor = const Color(0xFFE91E63);
      buttonColor = primaryColor;
    } else if (tier == 'normal_business') {
      primaryColor = const Color(0xFF8B5CF6);
      buttonColor = primaryColor;
    } else {
      primaryColor = Colors.grey.shade700;
      buttonColor = Colors.grey.shade700;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: tier == 'free' ? Colors.grey.shade400 : primaryColor,
            width: tier == 'free' ? 1.5 : 4.0,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            truncatedName,
                            style: TextStyle(
                              fontSize: 17.5,
                              fontWeight: tier == 'free'
                                  ? FontWeight.w600
                                  : FontWeight.w800,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 6),
                          if (tier != 'free')
                            const Icon(
                              Icons.verified,
                              color: Colors.green,
                              size: 20,
                            ),
                          if (priority)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade700,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  "Featured",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          const Spacer(),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: onCall,
                      child: const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Icon(Icons.call, color: Colors.green, size: 28),
                      ),
                    ),
                    InkWell(
                      onTap: onFavorite,
                      child: Icon(
                        Icons.favorite_border,
                        color: primaryColor,
                        size: 28,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(displayIcon, size: 16, color: Colors.grey[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        displayText,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.phone, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      mobile,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: onEnquiry,
                child: Container(
                  width: 100,
                  height: 44,
                  decoration: BoxDecoration(
                    color: buttonColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      "Enquire",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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

      final existingGroups = await SupabaseService.client
          .from("favorites_groups")
          .select()
          .eq("group_name", selectedOption!)
          .eq("user_id", userId);

      dynamic groupId;
      if (existingGroups.isNotEmpty) {
        groupId = existingGroups[0]['id'];
      } else {
        final inserted = await SupabaseService.client
            .from("favorites_groups")
            .insert({"group_name": selectedOption!, "user_id": userId})
            .select()
            .single();
        groupId = inserted['id'];
      }

      final existingMember = await SupabaseService.client
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
            (o) => CheckboxListTile(
              title: Text(o),
              value: selectedOption == o,
              onChanged: (_) => setState(() => selectedOption = o),
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
