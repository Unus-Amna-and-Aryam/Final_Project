import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:final_project/models/favorite_plan.dart';
import 'package:final_project/models/providers_model.dart';

/// Thrown by [FavoritesDatabaseService]'s save methods when there's no
/// signed-in Supabase user to save the favorite under. This happens for
/// anyone who reached onboarding via "تخطي الآن" on the auth screen, which
/// never calls Supabase Auth — favorites can't be tied to "نفس الحساب" for
/// them, so saving is refused rather than silently using a fake id.
class NotSignedInException implements Exception {}

/// Persists favorites (single providers and full recommended plans) to
/// Supabase, scoped to the current signed-in user — see the `favorite_providers`
/// and `favorite_plans` tables (schema in supabase/favorites_schema.sql).
/// Both tables have row-level security restricting each user to their own
/// rows via auth.uid(), so a real signed-in session is required both here
/// and at the database level.
class FavoritesDatabaseService {
  final supabase = Supabase.instance.client;

  String? get _currentUserId => supabase.auth.currentUser?.id;

  // يحفظ مزوداً واحداً بالمفضلة (زر "المفضلة" داخل كل _ServiceCard).
  Future<void> saveFavoriteProvider(Providers provider) async {
    final userId = _currentUserId;
    if (userId == null) throw NotSignedInException();

    await supabase.from('favorite_providers').insert({
      'user_id': userId,
      // The full provider snapshot (including its original `id`), not just
      // name/category/sub_category, so the favorites screen can show and
      // open it exactly as it was at save time without depending on the
      // `providers` row still existing or being unchanged.
      'provider': provider.toJson(),
    });
  }

  // يجيب كل المزودين المفضلين للمستخدم الحالي، الأحدث أولاً.
  Future<List<Providers>> getFavoriteProviders() async {
    final userId = _currentUserId;
    if (userId == null) return [];

    final response = await supabase
        .from('favorite_providers')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (response as List)
        .map((row) => Providers.fromJson(row['provider'] as Map<String, dynamic>))
        .toList();
  }

  // يحفظ خطة كاملة بالمفضلة (زر "اضغط للمفضلة" العام أسفل RecommendedPlanScreen).
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

  // يجيب كل الخطط المفضلة للمستخدم الحالي، الأحدث أولاً.
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
}
