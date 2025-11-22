// import 'package:celfonephonebookapp/screens/RevenueDetailsPage.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class EarningDetailsPage extends StatefulWidget {
//   const EarningDetailsPage({super.key});

//   @override
//   State<EarningDetailsPage> createState() => _EarningDetailsPageState();
// }

// class _EarningDetailsPageState extends State<EarningDetailsPage> {
//   bool isLoading = true;
//   int todayCount = 0;
//   int todayEarnings = 0;

//   List<Map<String, dynamic>> weeklyReports = [];
//   List<Map<String, dynamic>> monthlyReports = [];
//   List<Map<String, dynamic>> customReports = [];

//   String? userId;
//   String? username;

//   @override
//   void initState() {
//     super.initState();
//     _setup();
//   }

//   Future<void> _setup() async {
//     final prefs = await SharedPreferences.getInstance();
//     userId = prefs.getString("userId");
//     username = prefs.getString("username");

//     if (userId == null) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text("User not logged in")));
//       }
//       return;
//     }

//     await fetchEarnings();
//   }

//   Future<void> fetchEarnings() async {
//     try {
//       final now = DateTime.now().toUtc();
//       final todayStart = DateTime.utc(now.year, now.month, now.day, 0, 0, 0);
//       final todayEnd = DateTime.utc(now.year, now.month, now.day, 23, 59, 59);

//       // Today’s Data
//       final todayData = await Supabase.instance.client
//           .from("data_entry_table")
//           .select("count, earnings")
//           .eq("user_id", userId!)
//           .gte("created_at", todayStart.toIso8601String())
//           .lte("created_at", todayEnd.toIso8601String())
//           .maybeSingle();

//       todayCount = todayData?["count"] ?? 0;
//       todayEarnings = todayData?["earnings"] ?? 0;

//       // Weekly Reports (last 7 days)
//       final weekStart = now.subtract(const Duration(days: 7));
//       final weeklyData = await Supabase.instance.client
//           .from("data_entry_table")
//           .select("created_at, count, earnings")
//           .eq("user_id", userId!)
//           .gte("created_at", weekStart.toIso8601String())
//           .order("created_at", ascending: false);
//       weeklyReports = List<Map<String, dynamic>>.from(weeklyData);

//       // Monthly Reports
//       final monthStart = DateTime.utc(now.year, now.month, 1);
//       final monthlyData = await Supabase.instance.client
//           .from("data_entry_table")
//           .select("created_at, count, earnings")
//           .eq("user_id", userId!)
//           .gte("created_at", monthStart.toIso8601String())
//           .order("created_at", ascending: false);
//       monthlyReports = List<Map<String, dynamic>>.from(monthlyData);

//       if (mounted) setState(() => isLoading = false);
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text("Error fetching earnings: $e")));
//       }
//     }
//   }

//   Future<void> fetchCustomReports(DateTime start, DateTime end) async {
//     final data = await Supabase.instance.client
//         .from("data_entry_table")
//         .select("created_at, count, earnings")
//         .eq("user_id", userId!)
//         .gte("created_at", start.toIso8601String())
//         .lte("created_at", end.toIso8601String())
//         .order("created_at", ascending: false);

//     setState(() {
//       customReports = List<Map<String, dynamic>>.from(data);
//     });
//   }

//   void openReportPage(
//     String title,
//     List<Map<String, dynamic>> reports, {
//     bool isCustom = false,
//   }) async {
//     if (isCustom) {
//       // pick custom range
//       final picked = await showDateRangePicker(
//         context: context,
//         firstDate: DateTime(2023, 1, 1),
//         lastDate: DateTime.now(),
//       );
//       if (picked != null) {
//         await fetchCustomReports(picked.start, picked.end);
//         reports = customReports;
//       } else {
//         return;
//       }
//     }

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => ReportListPage(title: title, reports: reports),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Earning Details")),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : RefreshIndicator(
//               onRefresh: fetchEarnings,
//               child: ListView(
//                 padding: const EdgeInsets.all(16),
//                 children: [
//                   // Today’s Card
//                   // Today’s Card
//                   InkWell(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => const RevenueDetailsPage(),
//                         ),
//                       );
//                     },
//                     child: Card(
//                       elevation: 3,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(16),
//                         child: Column(
//                           children: [
//                             Text(
//                               "Hello, $username 👋",
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             const Text(
//                               "Today’s Stats",
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               "Count: $todayCount",
//                               style: const TextStyle(fontSize: 16),
//                             ),
//                             Text(
//                               "Earnings: ₹$todayEarnings",
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 color: Colors.green,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 20),

//                   // Report Options
//                   ListTile(
//                     leading: const Icon(Icons.calendar_today),
//                     title: const Text("Weekly Reports"),
//                     trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//                     onTap: () =>
//                         openReportPage("Weekly Reports", weeklyReports),
//                   ),
//                   const Divider(),
//                   ListTile(
//                     leading: const Icon(Icons.calendar_month),
//                     title: const Text("Monthly Reports"),
//                     trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//                     onTap: () =>
//                         openReportPage("Monthly Reports", monthlyReports),
//                   ),
//                   const Divider(),
//                   ListTile(
//                     leading: const Icon(Icons.date_range),
//                     title: const Text("Custom Reports"),
//                     trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//                     onTap: () =>
//                         openReportPage("Custom Reports", [], isCustom: true),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }
// }

// class ReportListPage extends StatelessWidget {
//   final String title;
//   final List<Map<String, dynamic>> reports;

//   const ReportListPage({super.key, required this.title, required this.reports});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(title)),
//       body: reports.isEmpty
//           ? const Center(child: Text("No data available"))
//           : ListView.builder(
//               padding: const EdgeInsets.all(16),
//               itemCount: reports.length,
//               itemBuilder: (context, index) {
//                 final r = reports[index];
//                 final date = DateFormat(
//                   "dd MMM yyyy",
//                 ).format(DateTime.parse(r["created_at"]));
//                 return Card(
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: ListTile(
//                     leading: const Icon(Icons.event),
//                     title: Text("Date: $date"),
//                     subtitle: Text(
//                       "Count: ${r["count"]}, Earnings: ₹${r["earnings"]}",
//                     ),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }

// import 'package:celfonephonebookapp/screens/RevenueDetailsPage.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class EarningDetailsPage extends StatefulWidget {
//   const EarningDetailsPage({super.key});

//   @override
//   State<EarningDetailsPage> createState() => _EarningDetailsPageState();
// }

// class _EarningDetailsPageState extends State<EarningDetailsPage> {
//   bool isLoading = true;
//   int todayCount = 0;
//   int todayEarnings = 0;

//   List<Map<String, dynamic>> weeklyReports = [];
//   List<Map<String, dynamic>> monthlyReports = [];
//   List<Map<String, dynamic>> customReports = [];

//   String? userId;
//   String? username;

//   @override
//   void initState() {
//     super.initState();
//     _setup();
//   }

//   Future<void> _setup() async {
//     final prefs = await SharedPreferences.getInstance();
//     userId = prefs.getString("userId");
//     username = prefs.getString("username");

//     if (userId == null) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text("User not logged in")));
//       }
//       return;
//     }

//     await fetchEarnings();
//   }

//   Future<void> fetchEarnings() async {
//     try {
//       final now = DateTime.now().toUtc();
//       final todayStart = DateTime.utc(now.year, now.month, now.day);
//       final todayEnd = todayStart.add(const Duration(hours: 23, minutes: 59));

//       final todayData = await Supabase.instance.client
//           .from("data_entry_table")
//           .select("count, earnings")
//           .eq("user_id", userId!)
//           .gte("created_at", todayStart.toIso8601String())
//           .lte("created_at", todayEnd.toIso8601String())
//           .maybeSingle();

//       todayCount = todayData?["count"] ?? 0;
//       todayEarnings = todayData?["earnings"] ?? 0;

//       final weekStart = now.subtract(const Duration(days: 7));
//       final weeklyData = await Supabase.instance.client
//           .from("data_entry_table")
//           .select("created_at, count, earnings")
//           .eq("user_id", userId!)
//           .gte("created_at", weekStart.toIso8601String())
//           .order("created_at", ascending: false);
//       weeklyReports = List<Map<String, dynamic>>.from(weeklyData);

//       final monthStart = DateTime.utc(now.year, now.month, 1);
//       final monthlyData = await Supabase.instance.client
//           .from("data_entry_table")
//           .select("created_at, count, earnings")
//           .eq("user_id", userId!)
//           .gte("created_at", monthStart.toIso8601String())
//           .order("created_at", ascending: false);
//       monthlyReports = List<Map<String, dynamic>>.from(monthlyData);

//       if (mounted) setState(() => isLoading = false);
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text("Error fetching earnings: $e")));
//       }
//     }
//   }

//   Future<void> fetchCustomReports(DateTime start, DateTime end) async {
//     final data = await Supabase.instance.client
//         .from("data_entry_table")
//         .select("created_at, count, earnings")
//         .eq("user_id", userId!)
//         .gte("created_at", start.toIso8601String())
//         .lte("created_at", end.toIso8601String())
//         .order("created_at", ascending: false);

//     setState(() {
//       customReports = List<Map<String, dynamic>>.from(data);
//     });
//   }

//   void openReportPage(
//     String title,
//     List<Map<String, dynamic>> reports, {
//     bool isCustom = false,
//   }) async {
//     if (isCustom) {
//       final picked = await showDateRangePicker(
//         context: context,
//         firstDate: DateTime(2023, 1, 1),
//         lastDate: DateTime.now(),
//       );
//       if (picked != null) {
//         await fetchCustomReports(picked.start, picked.end);
//         reports = customReports;
//       } else {
//         return;
//       }
//     }

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => ReportListPage(title: title, reports: reports),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Scaffold(
//       backgroundColor: const Color(0xFFF6F8FB),
//       appBar: AppBar(
//         title: const Text("Earning Details"),
//         backgroundColor: Colors.green[700],
//         foregroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : RefreshIndicator(
//               onRefresh: fetchEarnings,
//               child: ListView(
//                 padding: const EdgeInsets.all(16),
//                 children: [
//                   // HEADER CARD
//                   Container(
//                     padding: const EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(20),
//                       gradient: const LinearGradient(
//                         colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.1),
//                           blurRadius: 8,
//                           offset: const Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "Welcome, $username 👋",
//                           style: const TextStyle(
//                             fontSize: 18,
//                             color: Colors.white,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         const Text(
//                           "Today's Overview",
//                           style: TextStyle(
//                             fontSize: 22,
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             _statBox(
//                               "Entries",
//                               "$todayCount",
//                               Icons.list_alt,
//                               Colors.white,
//                             ),
//                             _statBox(
//                               "Earnings",
//                               "₹$todayEarnings",
//                               Icons.currency_rupee,
//                               Colors.white,
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 12),
//                         Center(
//                           child: ElevatedButton.icon(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.white,
//                               foregroundColor: Colors.green[700],
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                             ),
//                             icon: const Icon(Icons.bar_chart),
//                             label: const Text("View Revenue Details"),
//                             onPressed: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (_) => const RevenueDetailsPage(),
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 25),

//                   // REPORT SECTIONS
//                   Text(
//                     "Reports",
//                     style: theme.textTheme.titleLarge?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   const SizedBox(height: 10),

//                   _reportTile(
//                     icon: Icons.calendar_today,
//                     title: "Weekly Reports",
//                     color: Colors.orangeAccent,
//                     onTap: () =>
//                         openReportPage("Weekly Reports", weeklyReports),
//                   ),
//                   _reportTile(
//                     icon: Icons.calendar_month,
//                     title: "Monthly Reports",
//                     color: Colors.blueAccent,
//                     onTap: () =>
//                         openReportPage("Monthly Reports", monthlyReports),
//                   ),
//                   _reportTile(
//                     icon: Icons.date_range,
//                     title: "Custom Reports",
//                     color: Colors.purpleAccent,
//                     onTap: () =>
//                         openReportPage("Custom Reports", [], isCustom: true),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }

//   Widget _statBox(String label, String value, IconData icon, Color color) {
//     return Container(
//       width: 130,
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.2),
//         borderRadius: BorderRadius.circular(14),
//       ),
//       child: Column(
//         children: [
//           Icon(icon, color: color, size: 28),
//           const SizedBox(height: 8),
//           Text(
//             value,
//             style: TextStyle(
//               color: color,
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             label,
//             style: TextStyle(color: color.withOpacity(0.9), fontSize: 14),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _reportTile({
//     required IconData icon,
//     required String title,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: ListTile(
//         leading: CircleAvatar(
//           backgroundColor: color.withOpacity(0.15),
//           child: Icon(icon, color: color),
//         ),
//         title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
//         trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//         onTap: onTap,
//       ),
//     );
//   }
// }

// class ReportListPage extends StatelessWidget {
//   final String title;
//   final List<Map<String, dynamic>> reports;

//   const ReportListPage({super.key, required this.title, required this.reports});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(title),
//         backgroundColor: Colors.green[700],
//         foregroundColor: Colors.white,
//       ),
//       backgroundColor: const Color(0xFFF7F9FC),
//       body: reports.isEmpty
//           ? const Center(
//               child: Text(
//                 "No data available",
//                 style: TextStyle(fontSize: 16, color: Colors.grey),
//               ),
//             )
//           : ListView.builder(
//               padding: const EdgeInsets.all(16),
//               itemCount: reports.length,
//               itemBuilder: (context, index) {
//                 final r = reports[index];
//                 final date = DateFormat(
//                   "dd MMM yyyy",
//                 ).format(DateTime.parse(r["created_at"]));
//                 return Card(
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   elevation: 3,
//                   margin: const EdgeInsets.only(bottom: 12),
//                   child: ListTile(
//                     contentPadding: const EdgeInsets.symmetric(
//                       vertical: 10,
//                       horizontal: 16,
//                     ),
//                     leading: const Icon(Icons.event, color: Colors.green),
//                     title: Text(
//                       date,
//                       style: const TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     subtitle: Padding(
//                       padding: const EdgeInsets.only(top: 6),
//                       child: Text(
//                         "Count: ${r["count"]}\nEarnings: ₹${r["earnings"]}",
//                         style: const TextStyle(height: 1.4),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }
import 'package:celfonephonebookapp/screens/RevenueDetailsPage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EarningDetailsPage extends StatefulWidget {
  const EarningDetailsPage({super.key});

  @override
  State<EarningDetailsPage> createState() => _EarningDetailsPageState();
}

class _EarningDetailsPageState extends State<EarningDetailsPage>
    with TickerProviderStateMixin {
  bool isLoading = true;
  int todayCount = 0;
  int todayEarnings = 0;

  List<Map<String, dynamic>> weeklyReports = [];
  List<Map<String, dynamic>> monthlyReports = [];
  List<Map<String, dynamic>> customReports = [];

  String? userId;
  String displayName = "Partner";

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _setup();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _setup() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString("userId");

    if (userId == null) {
      _showSnackBar("User not logged in");
      return;
    }

    final savedPerson = prefs.getString("person_name");
    final savedBusiness = prefs.getString("business_name");

    if (savedPerson != null && savedPerson.trim().isNotEmpty) {
      displayName = savedPerson.trim();
    } else if (savedBusiness != null && savedBusiness.trim().isNotEmpty) {
      displayName = savedBusiness.trim();
    } else {
      await _fetchNameFromMobile(prefs);
    }

    setState(() {});
    await fetchEarnings();
  }

  Future<void> _fetchNameFromMobile(SharedPreferences prefs) async {
    final mobile = prefs.getString("mobile_number");
    if (mobile == null || mobile.isEmpty) {
      displayName = "Partner";
      return;
    }

    try {
      final profile = await Supabase.instance.client
          .from('profiles')
          .select('business_name, person_name')
          .eq('mobile_number', mobile)
          .maybeSingle();

      if (profile != null && mounted) {
        final business = (profile['business_name'] as String?)?.trim();
        final person = (profile['person_name'] as String?)?.trim();

        final name = (business?.isNotEmpty == true)
            ? business!
            : (person?.isNotEmpty == true)
            ? person!
            : "Partner";

        setState(() => displayName = name);

        if (business?.isNotEmpty == true) {
          prefs.setString("business_name", business!);
        } else if (person?.isNotEmpty == true) {
          prefs.setString("person_name", person!);
        }
      }
    } catch (e) {
      if (mounted) displayName = "Partner";
    }
  }

  Future<void> fetchEarnings() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final now = DateTime.now().toUtc();
      final todayStart = DateTime.utc(now.year, now.month, now.day);
      final todayEnd = todayStart
          .add(const Duration(days: 1))
          .subtract(const Duration(seconds: 1));

      final todayData = await Supabase.instance.client
          .from("data_entry_table")
          .select("count, earnings")
          .eq("user_id", userId!)
          .gte("created_at", todayStart.toIso8601String())
          .lte("created_at", todayEnd.toIso8601String())
          .maybeSingle();

      todayCount = todayData?["count"] ?? 0;
      todayEarnings = todayData?["earnings"] ?? 0;

      final weekStart = now.subtract(const Duration(days: 7));
      final weeklyData = await Supabase.instance.client
          .from("data_entry_table")
          .select("created_at, count, earnings")
          .eq("user_id", userId!)
          .gte("created_at", weekStart.toIso8601String())
          .order("created_at", ascending: false);
      weeklyReports = List.from(weeklyData);

      final monthStart = DateTime.utc(now.year, now.month, 1);
      final monthlyData = await Supabase.instance.client
          .from("data_entry_table")
          .select("created_at, count, earnings")
          .eq("user_id", userId!)
          .gte("created_at", monthStart.toIso8601String())
          .order("created_at", ascending: false);
      monthlyReports = List.from(monthlyData);

      if (mounted) setState(() => isLoading = false);
    } catch (e) {
      _showSnackBar("Error: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> fetchCustomReports(DateTime start, DateTime end) async {
    try {
      final data = await Supabase.instance.client
          .from("data_entry_table")
          .select("created_at, count, earnings")
          .eq("user_id", userId!)
          .gte("created_at", start.toIso8601String())
          .lte("created_at", end.toIso8601String())
          .order("created_at", ascending: false);

      if (mounted) {
        setState(() => customReports = List.from(data));
      }
    } catch (e) {
      _showSnackBar("Failed to load custom reports: $e");
    }
  }

  void _showSnackBar(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _openReportPage(String title, List<Map<String, dynamic>> reports) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportListPage(title: title, reports: reports),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F0),
      body: RefreshIndicator(
        onRefresh: fetchEarnings,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 160,
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsets.zero,
                title: Container(
                  padding: const EdgeInsets.only(left: 20, bottom: 16),
                  alignment: Alignment.bottomLeft,
                  child: const Text(
                    "Earning Details",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF00C0A3), Color(0xFF43A047)],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 70,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "Hello, $displayName",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.right,
                            ),
                            const Text(
                              "Keep growing!",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF43A047),
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        const SizedBox(height: 16),
                        _buildTodayPerformanceBoxes(),
                        const SizedBox(height: 24),
                        _buildTabBar(),
                        const SizedBox(height: 32),
                        SizedBox(
                          height: 400,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildReportList(
                                weeklyReports,
                                "No weekly data yet",
                                onTap: () => _openReportPage(
                                  "Weekly Reports",
                                  weeklyReports,
                                ),
                              ),
                              _buildReportList(
                                monthlyReports,
                                "No monthly data yet",
                                onTap: () => _openReportPage(
                                  "Monthly Reports",
                                  monthlyReports,
                                ),
                              ),
                              _buildCustomTab(),
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
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F8),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          color: Color(0xFF1E88E5),
        ),
        tabs: const [
          Tab(text: "Weekly"),
          Tab(text: "Monthly"),
          Tab(text: "Custom"),
        ],
      ),
    );
  }

  Widget _buildTodayPerformanceBoxes() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RevenueDetailsPage()),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Today's Performance",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _performanceBox(
                    "Entries",
                    Icons.format_list_numbered,
                    todayCount,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _performanceBox(
                    "Earnings",
                    Icons.currency_rupee,
                    todayEarnings,
                    prefix: "₹",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Great progress today!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Icon(Icons.trending_up, color: Colors.white, size: 32),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _performanceBox(
    String label,
    IconData icon,
    int value, {
    String prefix = "",
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
          AnimatedCounter(
            value: value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            prefix: prefix,
          ),
        ],
      ),
    );
  }

  Widget _buildReportList(
    List<Map<String, dynamic>> reports,
    String emptyMsg, {
    VoidCallback? onTap,
  }) {
    if (reports.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emptyMsg,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            if (onTap != null) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.refresh),
                label: const Text("Refresh"),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: reports.length,
      itemBuilder: (context, i) {
        final r = reports[i];
        final date = DateFormat(
          "dd MMM yyyy",
        ).format(DateTime.parse(r["created_at"]));
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          child: ListTile(
            onTap: onTap,
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF1E88E5),
              child: Text(
                date.split(' ')[0],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              date,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              "Entries: ${r["count"]}  •  Earnings: ₹${r["earnings"]}",
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          ),
        );
      },
    );
  }

  Widget _buildCustomTab() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton.icon(
            onPressed: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2023),
                lastDate: DateTime.now(),
                builder: (context, child) => Theme(
                  data: ThemeData.light().copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xFF1E88E5),
                    ),
                    buttonTheme: const ButtonThemeData(
                      textTheme: ButtonTextTheme.primary,
                    ),
                  ),
                  child: child!,
                ),
              );
              if (picked != null && mounted) {
                await fetchCustomReports(picked.start, picked.end);
                _tabController.animateTo(2);
              }
            },
            icon: const Icon(Icons.date_range, size: 20),
            label: const Text(
              "Pick Date Range",
              style: TextStyle(fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 4,
            ),
          ),
          const SizedBox(height: 20),
          if (customReports.isNotEmpty)
            Expanded(
              child: _buildReportList(
                customReports,
                "No data in selected range",
                onTap: () => _openReportPage("Custom Reports", customReports),
              ),
            )
          else if (customReports.isEmpty && !isLoading)
            const Text(
              "Pick a date range to view reports",
              style: TextStyle(color: Colors.grey),
            ),
        ],
      ),
    );
  }
}

class AnimatedCounter extends StatelessWidget {
  final int value;
  final TextStyle style;
  final String prefix;
  const AnimatedCounter({
    super.key,
    required this.value,
    required this.style,
    this.prefix = "",
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: IntTween(begin: 0, end: value),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
      builder: (context, val, _) => Text("$prefix$val", style: style),
    );
  }
}

class ReportListPage extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> reports;
  const ReportListPage({super.key, required this.title, required this.reports});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF43A047),
        foregroundColor: Colors.white,
      ),
      body: reports.isEmpty
          ? const Center(child: Text("No data available"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reports.length,
              itemBuilder: (context, i) {
                final r = reports[i];
                final date = DateFormat(
                  "dd MMM yyyy",
                ).format(DateTime.parse(r["created_at"]));
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF1E88E5),
                      child: Text(
                        date.split(' ')[0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      date,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      "Entries: ${r["count"]}  •  Earnings: ₹${r["earnings"]}",
                    ),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                );
              },
            ),
    );
  }
}
