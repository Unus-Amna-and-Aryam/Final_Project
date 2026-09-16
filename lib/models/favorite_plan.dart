import 'package:final_project/models/providers_model.dart';

/// A full recommended plan saved to favorites (see [FavoritesDatabaseService]
/// and the `favorite_plans` table) — a snapshot of the onboarding answers
/// that produced it plus every provider that was recommended at save time,
/// not a live reference back to RecommendedPlanScreen's current state.
class FavoritePlan {
  final int? id;
  final String eventType;
  final int guestCount;
  final double budget;
  final List<Providers> providers;

  const FavoritePlan({
    this.id,
    required this.eventType,
    required this.guestCount,
    required this.budget,
    required this.providers,
  });

  factory FavoritePlan.fromJson(Map<String, dynamic> json) {
    final providersJson = json['providers'] as List<dynamic>? ?? const [];
    return FavoritePlan(
      id: json['id'] as int?,
      eventType: json['event_type'] as String? ?? '',
      guestCount: (json['guest_count'] as num?)?.toInt() ?? 0,
      budget: (json['budget'] as num?)?.toDouble() ?? 0,
      providers: providersJson
          .map((p) => Providers.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'event_type': eventType,
        'guest_count': guestCount,
        'budget': budget,
        'providers': providers.map((p) => p.toJson()).toList(),
      };
}
