// import 'package:celfonephonebookapp/screens/earningDetailsPage.dart';
// import 'package:celfonephonebookapp/screens/media_partner_signup.dart';
// import 'package:flutter/material.dart';

// class OptionMenuPage extends StatelessWidget {
//   const OptionMenuPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final List<Map<String, dynamic>> menuItems = [
//       {
//         "title": "Data Entry",
//         "icon": Icons.edit_note,
//         "onTap": () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) =>
//                   const MediaPartnerSignupPage(), // <- add your page here
//             ),
//           );
//         },
//       },
//       {
//         "title": "Earning Details",
//         "icon": Icons.account_balance_wallet,
//         "onTap": () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) =>
//                   const EarningDetailsPage(), // <- add your page here
//             ),
//           );
//         },
//       },
//     ];

//     return Scaffold(
//       appBar: AppBar(title: const Text("Option Menu")),
//       body: ListView.separated(
//         itemCount: menuItems.length,
//         separatorBuilder: (_, __) => const Divider(height: 1),
//         itemBuilder: (context, index) {
//           final item = menuItems[index];
//           return ListTile(
//             leading: Icon(item["icon"], color: Colors.blue),
//             title: Text(item["title"]),
//             trailing: const Icon(Icons.chevron_right),
//             onTap: item["onTap"],
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:celfonephonebookapp/screens/earningDetailsPage.dart';
import 'package:celfonephonebookapp/screens/media_partner_signup.dart';
import 'package:flutter/material.dart';

class OptionMenuPage extends StatelessWidget {
  const OptionMenuPage({super.key});

  // ------------------- MENU ITEMS WITH DESCRIPTIONS -------------------
  static final List<Map<String, dynamic>> menuItems = [
    {
      "title": "Data Entry",
      "icon": Icons.edit_note,
      "color": const Color(0xFF1E88E5), // Blue
      "description":
          "Submit business listings, contacts, and media partner details to grow the directory.",
      "infoNote": "Earn ₹10 per verified entry. Payouts weekly.",
      "onTap": (BuildContext context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MediaPartnerSignupPage()),
        );
      },
    },
    {
      "title": "Earning Details",
      "icon": Icons.account_balance_wallet,
      "color": const Color(0xFF43A047), // Green
      "description":
          "Your payout history shows recent transactions, cleared earnings, and pending amounts..",
      "infoNote":
          "View your total earnings, pending payouts, and detailed transaction history.",
      "onTap": (BuildContext context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EarningDetailsPage()),
        );
      },
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Options"),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.separated(
          itemCount: menuItems.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final item = menuItems[index];
            return _buildMenuCard(context, item);
          },
        ),
      ),
    );
  }

  // ------------------- CARD BUILDER -------------------
  Widget _buildMenuCard(BuildContext context, Map<String, dynamic> item) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => item["onTap"](context),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Icon + Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: item["color"].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item["icon"], color: item["color"], size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      item["title"],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),

              const SizedBox(height: 12),

              // Description
              Text(
                item["description"],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 12),

              // Information Note (iMessage-style bubble)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: item["color"].withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: item["color"].withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: item["color"]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item["infoNote"],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: item["color"],
                        ),
                      ),
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
}
