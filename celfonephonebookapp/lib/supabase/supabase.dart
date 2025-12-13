import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;

  /// Cached profiles for the whole app
  static List<Map<String, dynamic>> profilesCache = [];

  static Future<void> init() async {
    await Supabase.initialize(
      url: "https://nryjcdhvqsywptlwdymx.supabase.co",
      anonKey:
          "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5yeWpjZGh2cXN5d3B0bHdkeW14Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUxMDYwNDQsImV4cCI6MjA3MDY4MjA0NH0.nK2ebd_tZcx3XJ_6HnHF-EBbbB3PyHTix7oYa-KIwKo", // Replace with your Anon Key
    );
  }

  /// Fetch all profiles with pagination
  static Future<void> fetchAllProfiles({int pageSize = 1000}) async {
    profilesCache.clear();
    int page = 0;
    bool hasMore = true;

    while (hasMore) {
      try {
        // fetch range of profiles
        final data = await client
            .from('profiles')
            .select()
            .order('is_prime', ascending: false)
            .range(page * pageSize, (page + 1) * pageSize - 1);

        final list = List<Map<String, dynamic>>.from(data as List<dynamic>);
        profilesCache.addAll(list);

        hasMore = list.length == pageSize;
        page++;
      } catch (e) {
        print("Error fetching profiles: $e");
        hasMore = false;
      }
    }
  }

  static List<Map<String, dynamic>> getProfiles() {
    return profilesCache;
  }
}
