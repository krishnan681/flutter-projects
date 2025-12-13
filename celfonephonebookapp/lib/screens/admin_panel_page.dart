// lib/screens/admin_panel_page.dart
import 'dart:async';
import 'dart:ui';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../supabase/supabase.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});
  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  final int pageSize = 50;
  int _page = 0;
  bool _loadingPage = false;
  bool _hasMore = true;

  List<Map<String, dynamic>> profiles = [];

  bool _isLoadingInitial = true;
  String _search = '';
  String _userTypeFilter = 'all';
  String _subscriptionFilter = 'all';
  String _cityFilter = 'all';
  String _prefixFilter = 'all';

  List<String> availableCities = [];
  List<String> availablePrefixes = [];

  int totalAllData = 0;
  int totalBusinesses = 0;
  int totalGoldMembers = 0;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchCtrl = TextEditingController();

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _initLoad();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _initLoad() async {
    setState(() {
      _isLoadingInitial = true;
      profiles = [];
      _page = 0;
      _hasMore = true;
    });

    await _fetchPage(reset: true);
    await _loadFilterOptions();
    await _fetchStats();
    setState(() => _isLoadingInitial = false);
  }

  dynamic _buildQuery({bool countOnly = false}) {
    var query = SupabaseService.client.from('profiles').select();

    final q = _search.trim();
    if (q.isNotEmpty) {
      final escaped = q.replaceAll('%', '').replaceAll("'", '');
      final orCond =
          'business_name.ilike.%$escaped%,person_name.ilike.%$escaped%,mobile_number.ilike.%$escaped%,city.ilike.%$escaped%,keywords.ilike.%$escaped%';
      query = query.or(orCond);
    }

    if (_userTypeFilter != 'all') {
      query = query.eq('user_type', _userTypeFilter);
    }

    if (_subscriptionFilter != 'all') {
      query = query.eq('subscription', _subscriptionFilter);
    }

    if (_cityFilter != 'all') {
      query = query.eq('city', _cityFilter);
    }

    if (_prefixFilter != 'all') {
      final pref = _prefixFilter;
      final orPref = 'business_prefix.eq.$pref,person_prefix.eq.$pref';
      query = query.or(orPref);
    }

    return query;
  }

  Future<void> _fetchPage({bool reset = false}) async {
    if (_loadingPage) return;
    if (!_hasMore && !reset) return;

    setState(() => _loadingPage = true);

    try {
      if (reset) {
        _page = 0;
        profiles = [];
        _hasMore = true;
      }

      final offset = _page * pageSize;
      final upper = offset + pageSize - 1;

      final baseQuery = _buildQuery();
      final response = await baseQuery
          .order('created_at', ascending: false)
          .range(offset, upper);

      final List<Map<String, dynamic>> pageData =
          List<Map<String, dynamic>>.from(response);

      setState(() {
        profiles.addAll(pageData);
        _page++;
        if (pageData.length < pageSize) _hasMore = false;
      });

      _collectFilterOptionsFromPage(pageData);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error loading data: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _loadingPage = false);
    }
  }

  Future<void> _loadFilterOptions() async {
    try {
      final cityResp = await SupabaseService.client
          .from('profiles')
          .select('city')
          .order('city', ascending: true)
          .range(0, 2000);

      final List cityList = cityResp as List;
      final cities =
          cityList
              .map((e) => (e['city'] ?? '').toString().trim())
              .where((s) => s.isNotEmpty)
              .toSet()
              .toList()
            ..sort();
      setState(() => availableCities = ['all', ...cities]);

      final prefResp = await SupabaseService.client
          .from('profiles')
          .select('business_prefix,person_prefix')
          .range(0, 2000);

      final List prefList = prefResp as List;
      final prefs = <String>{};
      for (final r in prefList) {
        final b = (r['business_prefix'] ?? '').toString().trim();
        final p = (r['person_prefix'] ?? '').toString().trim();
        if (b.isNotEmpty) prefs.add(b);
        if (p.isNotEmpty) prefs.add(p);
      }
      final prefSorted = prefs.toList()..sort();
      setState(() => availablePrefixes = ['all', ...prefSorted]);
    } catch (_) {
      setState(() {
        availableCities = ['all'];
        availablePrefixes = ['all'];
      });
    }
  }

  void _collectFilterOptionsFromPage(List<Map<String, dynamic>> page) {
    final cities = <String>{...availableCities.where((c) => c != 'all')};
    final prefs = <String>{...availablePrefixes.where((p) => p != 'all')};

    for (final r in page) {
      final c = (r['city'] ?? '').toString().trim();
      if (c.isNotEmpty) cities.add(c);

      final bp = (r['business_prefix'] ?? '').toString().trim();
      final pp = (r['person_prefix'] ?? '').toString().trim();
      if (bp.isNotEmpty) prefs.add(bp);
      if (pp.isNotEmpty) prefs.add(pp);
    }

    setState(() {
      availableCities = ['all', ...cities.toList()..sort()];
      availablePrefixes = ['all', ...prefs.toList()..sort()];
    });
  }

  Future<void> _fetchStats() async {
    try {
      final totalResp = await SupabaseService.client
          .from('profiles')
          .select()
          .count(CountOption.exact);
      final businessResp = await SupabaseService.client
          .from('profiles')
          .select()
          .eq('user_type', 'business')
          .count(CountOption.exact);
      final goldResp = await SupabaseService.client
          .from('profiles')
          .select()
          .eq('subscription', 'gold')
          .count(CountOption.exact);

      setState(() {
        totalAllData = totalResp.count;
        totalBusinesses = businessResp.count;
        totalGoldMembers = goldResp.count;
      });
    } catch (e) {
      debugPrint("Stats fetch error: $e");
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >
        _scrollController.position.maxScrollExtent - 250) {
      _fetchPage();
    }
  }

  void _onSearchChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _search = v;
      _fetchPage(reset: true);
    });
  }

  Future<void> _toggleGold(String id, bool currentlyGold) async {
    final newSub = currentlyGold ? 'free' : 'gold';
    await SupabaseService.client
        .from('profiles')
        .update({'subscription': newSub})
        .eq('id', id);

    _fetchPage(reset: true);
    await _fetchStats();
  }

  Future<void> _deleteProfile(String id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete profile"),
        content: Text("Delete $name? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await SupabaseService.client.from('profiles').delete().eq('id', id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Deleted"), backgroundColor: Colors.green),
      );
      _fetchPage(reset: true);
      await _fetchStats();
    }
  }

  void _openEdit(Map<String, dynamic> profile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditUserScreen(
          profile: profile,
          onSave: () async {
            await _fetchPage(reset: true);
            await _fetchStats();
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    int count,
    List<Color> gradientColors,
    IconData icon,
  ) {
    final Color primaryColor = gradientColors.first;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 36),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: count),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (_, val, __) => Text(
                NumberFormat.compact().format(val),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 4,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _goldBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.amber.withOpacity(0.3), blurRadius: 8),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.star, color: Colors.white, size: 16),
          SizedBox(width: 6),
          Text(
            "GOLD",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Admin Panel",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: _isLoadingInitial
          ? const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            )
          : RefreshIndicator(
              onRefresh: _initLoad,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                          child: Row(
                            children: [
                              _buildStatCard("Total\nDatas", totalAllData, [
                                const Color(0xFF667eea),
                                const Color(0xFF764ba2),
                              ], Icons.dataset),
                              const SizedBox(width: 12),
                              _buildStatCard(
                                "Business People",
                                totalBusinesses,
                                [
                                  const Color(0xFF11998e),
                                  const Color(0xFF38ef7d),
                                ],
                                Icons.business_center,
                              ),
                              const SizedBox(width: 12),
                              _buildStatCard("Gold Members", totalGoldMembers, [
                                const Color(0xFFFFD700),
                                const Color(0xFFFFA500),
                              ], Icons.star_rate),
                            ],
                          ),
                        ),

                        // Search & Filters
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.12),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 1.4,
                                  ),
                                ),
                                child: TextField(
                                  controller: _searchCtrl,
                                  onChanged: _onSearchChanged,
                                  decoration: InputDecoration(
                                    hintText:
                                        "Search name, mobile, city, keywords...",
                                    prefixIcon: const Icon(Icons.search),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.deepPurple,
                                        width: 1.8,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Fixed Filter Chips
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    const SizedBox(width: 4),

                                    ChoiceChip(
                                      label: const Text("All"),
                                      selected: _userTypeFilter == 'all',
                                      onSelected: (_) {
                                        setState(() => _userTypeFilter = 'all');
                                        _fetchPage(reset: true);
                                      },
                                    ),
                                    const SizedBox(width: 8),

                                    ChoiceChip(
                                      label: const Text("Business"),
                                      selected: _userTypeFilter == 'business',
                                      onSelected: (_) {
                                        setState(
                                          () => _userTypeFilter = 'business',
                                        );
                                        _fetchPage(reset: true);
                                      },
                                    ),
                                    const SizedBox(width: 8),

                                    ChoiceChip(
                                      label: const Text("Person"),
                                      selected: _userTypeFilter == 'person',
                                      onSelected: (_) {
                                        setState(
                                          () => _userTypeFilter = 'person',
                                        );
                                        _fetchPage(reset: true);
                                      },
                                    ),
                                    const SizedBox(width: 12),

                                    FilterChip(
                                      label: const Text("Gold"),
                                      selected: _subscriptionFilter == 'gold',
                                      onSelected: (v) {
                                        setState(
                                          () => _subscriptionFilter = v
                                              ? 'gold'
                                              : 'all',
                                        );
                                        _fetchPage(reset: true);
                                      },
                                    ),
                                    const SizedBox(width: 8),

                                    FilterChip(
                                      label: const Text("Business Plan"),
                                      selected:
                                          _subscriptionFilter == 'business',
                                      onSelected: (v) {
                                        setState(
                                          () => _subscriptionFilter = v
                                              ? 'business'
                                              : 'all',
                                        );
                                        _fetchPage(reset: true);
                                      },
                                    ),
                                    const SizedBox(width: 8),

                                    FilterChip(
                                      label: const Text("Free"),
                                      selected: _subscriptionFilter == 'free',
                                      onSelected: (v) {
                                        setState(
                                          () => _subscriptionFilter = v
                                              ? 'free'
                                              : 'all',
                                        );
                                        _fetchPage(reset: true);
                                      },
                                    ),

                                    const SizedBox(width: 12),

                                    // City & Prefix chips (unchanged)
                                    // ...availableCities.take(12).map((c) {
                                    //   if (c == 'all') return const SizedBox();
                                    //   return Padding(
                                    //     padding: const EdgeInsets.only(
                                    //       right: 8,
                                    //     ),
                                    //     child: ActionChip(
                                    //       label: Text(c),
                                    //       onPressed: () {
                                    //         setState(
                                    //           () => _cityFilter =
                                    //               (_cityFilter == c
                                    //               ? 'all'
                                    //               : c),
                                    //         );
                                    //         _fetchPage(reset: true);
                                    //       },
                                    //       backgroundColor: _cityFilter == c
                                    //           ? Colors.deepPurple.shade50
                                    //           : Colors.grey.shade100,
                                    //       avatar: _cityFilter == c
                                    //           ? const Icon(
                                    //               Icons.check,
                                    //               size: 18,
                                    //             )
                                    //           : null,
                                    //     ),
                                    //   );
                                    // }).toList(),
                                    // ...availablePrefixes.take(8).map((p) {
                                    //   if (p == 'all') return const SizedBox();
                                    //   return Padding(
                                    //     padding: const EdgeInsets.only(
                                    //       right: 8,
                                    //     ),
                                    //     child: ActionChip(
                                    //       label: Text(p),
                                    //       onPressed: () {
                                    //         setState(
                                    //           () => _prefixFilter =
                                    //               (_prefixFilter == p
                                    //               ? 'all'
                                    //               : p),
                                    //         );
                                    //         _fetchPage(reset: true);
                                    //       },
                                    //       backgroundColor: _prefixFilter == p
                                    //           ? Colors.deepPurple.shade50
                                    //           : Colors.grey.shade100,
                                    //       avatar: _prefixFilter == p
                                    //           ? const Icon(
                                    //               Icons.check,
                                    //               size: 18,
                                    //             )
                                    //           : null,
                                    //     ),
                                    //   );
                                    // }).toList(),
                                    const SizedBox(width: 10),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _userTypeFilter = 'all';
                                          _subscriptionFilter = 'all';
                                          _cityFilter = 'all';
                                          _prefixFilter = 'all';
                                          _searchCtrl.clear();
                                          _search = '';
                                        });
                                        _fetchPage(reset: true);
                                      },
                                      child: const Text("Reset filters"),
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

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      // child: Text(
                      //   "Showing: ${profiles.length} results",
                      //   style: const TextStyle(fontWeight: FontWeight.bold),
                      // ),
                    ),
                  ),

                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, i) {
                      final p = profiles[i];
                      final isBusiness = p['user_type'] == 'business';
                      final isGold =
                          (p['subscription'] ?? '').toString() == 'gold';
                      final prefix = isBusiness
                          ? (p['business_prefix'] ?? '')
                          : (p['person_prefix'] ?? '');
                      final name = isBusiness
                          ? (p['business_name'] ?? '')
                          : (p['person_name'] ?? '');
                      final displayName =
                          "${prefix.toString().trim()} ${name.toString().trim()}"
                              .trim();

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 4,
                          child: ListTile(
                            onTap: () => _openEdit(p),
                            leading: CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: p['profile_image'] != null
                                  ? NetworkImage(p['profile_image'])
                                  : null,
                              child: p['profile_image'] == null
                                  ? Icon(
                                      isBusiness
                                          ? Icons.business
                                          : Icons.person,
                                      size: 28,
                                    )
                                  : null,
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    displayName.isEmpty
                                        ? 'No Name'
                                        : displayName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (isGold) _goldBadge(),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 6),
                                Text(
                                  "${p['mobile_number'] ?? '—'} • ${p['city'] ?? '—'}",
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  children: [
                                    Chip(
                                      label: Text(
                                        isBusiness ? "BUSINESS" : "PERSON",
                                      ),
                                      backgroundColor: isBusiness
                                          ? Colors.green.shade100
                                          : Colors.orange.shade100,
                                    ),
                                    if ((p['is_admin'] ?? false) == true)
                                      Chip(
                                        label: const Text("ADMIN"),
                                        backgroundColor: Colors.red.shade400,
                                      ),
                                    Chip(
                                      label: Text(
                                        (p['subscription'] ?? 'free')
                                            .toString()
                                            .toUpperCase(),
                                      ),
                                      backgroundColor: Colors.grey.shade200,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (v) async {
                                if (v == 'edit') _openEdit(p);
                                if (v == 'gold')
                                  await _toggleGold(p['id'], isGold);
                                if (v == 'delete')
                                  await _deleteProfile(p['id'], displayName);
                              },
                              itemBuilder: (_) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text("Edit"),
                                ),
                                PopupMenuItem(
                                  value: 'gold',
                                  child: Text(
                                    isGold ? "Remove Prime" : "Make Prime",
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text(
                                    "Delete",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }, childCount: profiles.length),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: _loadingPage
                            ? const CircularProgressIndicator()
                            : (!_hasMore
                                  ? const Text("No more results")
                                  : const SizedBox.shrink()),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// Edit User Screen — No Prime option
class EditUserScreen extends StatefulWidget {
  final Map<String, dynamic> profile;
  final VoidCallback onSave;
  const EditUserScreen({
    super.key,
    required this.profile,
    required this.onSave,
  });

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  late TextEditingController nameCtrl,
      prefixCtrl,
      mobileCtrl,
      cityCtrl,
      pinCtrl,
      emailCtrl,
      waCtrl,
      webCtrl,
      keyCtrl;
  late String subscription;

  @override
  void initState() {
    super.initState();
    final isBusiness = widget.profile['user_type'] == 'business';
    nameCtrl = TextEditingController(
      text: isBusiness
          ? widget.profile['business_name']
          : widget.profile['person_name'],
    );
    prefixCtrl = TextEditingController(
      text: isBusiness
          ? (widget.profile['business_prefix'] ?? 'M/s.')
          : (widget.profile['person_prefix'] ?? ''),
    );
    mobileCtrl = TextEditingController(text: widget.profile['mobile_number']);
    cityCtrl = TextEditingController(text: widget.profile['city']);
    pinCtrl = TextEditingController(text: widget.profile['pincode']);
    emailCtrl = TextEditingController(text: widget.profile['email']);
    waCtrl = TextEditingController(text: widget.profile['whats_app']);
    webCtrl = TextEditingController(text: widget.profile['web_site']);
    keyCtrl = TextEditingController(text: widget.profile['keywords']);

    subscription =
        ['gold', 'business', 'free'].contains(widget.profile['subscription'])
        ? widget.profile['subscription']
        : 'free';
  }

  @override
  Widget build(BuildContext context) {
    final isBusiness = widget.profile['user_type'] == 'business';
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.deepPurple,
        actions: [
          TextButton(
            onPressed: () async {
              final update = {
                if (isBusiness) 'business_name': nameCtrl.text.trim(),
                if (isBusiness) 'business_prefix': prefixCtrl.text.trim(),
                if (!isBusiness) 'person_name': nameCtrl.text.trim(),
                if (!isBusiness) 'person_prefix': prefixCtrl.text.trim(),
                'mobile_number': mobileCtrl.text.trim(),
                'city': cityCtrl.text.trim(),
                'pincode': pinCtrl.text.trim(),
                'email': emailCtrl.text.isEmpty ? null : emailCtrl.text.trim(),
                'whats_app': waCtrl.text.isEmpty ? null : waCtrl.text.trim(),
                'web_site': webCtrl.text.isEmpty ? null : webCtrl.text.trim(),
                'keywords': keyCtrl.text.isEmpty ? null : keyCtrl.text.trim(),
                'subscription': subscription,
                'updated_at': DateTime.now().toIso8601String(),
              };

              await SupabaseService.client
                  .from('profiles')
                  .update(update)
                  .eq('id', widget.profile['id']);
              widget.onSave();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Saved!"),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text(
              "SAVE",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            TextField(
              controller: prefixCtrl,
              decoration: const InputDecoration(
                labelText: "Prefix",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: mobileCtrl,
              decoration: const InputDecoration(
                labelText: "Mobile",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: cityCtrl,
              decoration: const InputDecoration(
                labelText: "City",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: pinCtrl,
              decoration: const InputDecoration(
                labelText: "Pincode",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: waCtrl,
              decoration: const InputDecoration(
                labelText: "WhatsApp",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: webCtrl,
              decoration: const InputDecoration(
                labelText: "Website",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: keyCtrl,
              decoration: const InputDecoration(
                labelText: "Keywords",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: subscription,
              decoration: const InputDecoration(
                labelText: "Subscription Plan",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'free', child: Text("Free")),
                DropdownMenuItem(value: 'gold', child: Text("Gold")),
                DropdownMenuItem(value: 'business', child: Text("Business")),
              ],
              onChanged: (v) => setState(() => subscription = v!),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    prefixCtrl.dispose();
    mobileCtrl.dispose();
    cityCtrl.dispose();
    pinCtrl.dispose();
    emailCtrl.dispose();
    waCtrl.dispose();
    webCtrl.dispose();
    keyCtrl.dispose();
    super.dispose();
  }
}
