import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:celfonephonebookapp/supabase/supabase.dart';

class FindNumberPage extends StatefulWidget {
  const FindNumberPage({super.key});

  @override
  State<FindNumberPage> createState() => _FindNumberPageState();
}

class _FindNumberPageState extends State<FindNumberPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _isLoading = false;

  Future<void> _handleSearch() async {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      setState(() => _results = []);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await SupabaseService.client
          .from('profiles')
          .select('''
            id,
            user_type,
            mobile_number,
            person_name,
            person_prefix,
            business_name,
            business_prefix,
            keywords,
            city,
            pincode,
            email,
            profile_image
            ''')
          .or(
            'mobile_number.ilike.%$query%,'
            'person_name.ilike.%$query%,'
            'business_name.ilike.%$query%,'
            'keywords.ilike.%$query%,'
            'city.ilike.%$query%,'
            'pincode.ilike.%$query%,'
            'email.ilike.%$query%',
          )
          .limit(25);

      setState(() {
        _results = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Search error: $e")));
      setState(() => _results = []);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Find Number"),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildSearchBox(),
            const SizedBox(height: 30),
            _buildResults(),
            const SizedBox(height: 40),
            _buildFeatures(),
          ],
        ),
      ),
    );
  }

  // ---------- UI SECTIONS ----------

  Widget _buildHeader() {
    return Column(
      children: [
        const Text(
          "Phone Number Checker",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          "Instantly verify phone numbers and stay protected",
          style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSearchBox() {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          const Text(
            "Search Directory",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onSubmitted: (_) => _handleSearch(),
                  decoration: InputDecoration(
                    hintText: "Name, number, city, email...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSearch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 16,
                  ),
                ),
                child: Text(
                  _isLoading ? "Checking..." : "Check",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_results.isEmpty && _searchController.text.isNotEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text(
            "No results found",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }

    if (_results.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Search Results",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ..._results.map(_buildProfileTile),
        ],
      ),
    );
  }

  Widget _buildProfileTile(Map<String, dynamic> profile) {
    final isPerson = profile['user_type'] == 'person';

    final name = isPerson
        ? profile['person_name'] ?? 'Unknown'
        : '${profile['business_prefix'] ?? ''} ${profile['business_name'] ?? 'Unknown'}';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Icon(
            isPerson ? Icons.person : Icons.business,
            color: Colors.blue.shade700,
          ),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Mobile: ${profile['mobile_number']}"),
            if (profile['city'] != null || profile['pincode'] != null)
              Text(
                "${profile['city'] ?? ''}${profile['city'] != null && profile['pincode'] != null ? ', ' : ''}${profile['pincode'] ?? ''}",
              ),
            if (profile['email'] != null) Text(profile['email']),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Why Use Our Tool?",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            _feature(Icons.lock, Colors.blue, "Secure & Reliable"),
            const SizedBox(width: 12),
            _feature(Icons.book, Colors.pink, "Online Directory"),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _feature(Icons.location_on, Colors.orange, "Local Database"),
            const SizedBox(width: 12),
            _feature(Icons.public, Colors.green, "99.9% Accuracy"),
          ],
        ),
      ],
    );
  }

  Widget _feature(IconData icon, Color color, String title) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10),
      ],
    );
  }
}
