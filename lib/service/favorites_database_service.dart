import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:final_project/models/favorite_plan.dart';
import 'package:final_project/models/providers_model.dart';

class NotSignedInException implements Exception {}

class FavoriteProviderEntry {
  final int id;
  final Providers provider;

  const FavoriteProviderEntry({required this.id, required this.provider});
}

class FavoritesDatabaseService {
  final supabase = Supabase.instance.client;

  String? get _currentUserId => supabase.auth.currentUser?.id;
  Future<void> saveFavoriteProvider(Providers provider) async {
    final userId = _currentUserId;
    if (userId == null) throw NotSignedInException();

    await supabase.from('favorite_providers').insert({
      'user_id': userId,
      'provider': provider.toJson(),
    });
  }

  Future<List<FavoriteProviderEntry>> getFavoriteProviders() async {
    final userId = _currentUserId;
    if (userId == null) return [];

    final response = await supabase
        .from('favorite_providers')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (response as List)
        .map(
          (row) => FavoriteProviderEntry(
            id: row['id'] as int,
            provider: Providers.fromJson(
              row['provider'] as Map<String, dynamic>,
            ),
          ),
        )
        .toList();
  }

  Future<void> deleteFavoriteProvider(int id) async {
    final userId = _currentUserId;
    if (userId == null) throw NotSignedInException();

    await supabase
        .from('favorite_providers')
        .delete()
        .eq('id', id)
        .eq('user_id', userId);
  }

  Future<void> saveFavoritePlan({
    required String eventType,
    required int guestCount,
    required double budget,
    required List<Providers> providers,
  }) async {
    final userId = _currentUserId;
    if (userId == null) throw NotSignedInException();

    await supabase.from('favorite_plans').insert({
      'user_id': userId,
      'event_type': eventType,
      'guest_count': guestCount,
      'budget': budget,
      'providers': providers.map((p) => p.toJson()).toList(),
    });
  }

  Future<List<FavoritePlan>> getFavoritePlans() async {
    final userId = _currentUserId;
    if (userId == null) return [];

    final response = await supabase
        .from('favorite_plans')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (response as List)
        .map((row) => FavoritePlan.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteFavoritePlan(int id) async {
    final userId = _currentUserId;
    if (userId == null) throw NotSignedInException();

    await supabase
        .from('favorite_plans')
        .delete()
        .eq('id', id)
        .eq('user_id', userId);
  }
}
