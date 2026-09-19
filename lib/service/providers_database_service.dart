import 'package:final_project/models/providers_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProvidersDatabaseService {
  final supabase = Supabase.instance.client;
  Future<List<Providers>> getAllProviders() async {
    final response = await supabase.from('providers').select();
    return (response as List).map((e) => Providers.fromJson(e)).toList();
  }

  Future<List<Providers>> getProvidersByCategory(String category) async {
    final response = await supabase
        .from('providers')
        .select()
        .eq('category', category);
    return (response as List).map((e) => Providers.fromJson(e)).toList();
  }

  Future<List<Providers>> getProvidersByCategories(
    List<String> categories,
  ) async {
    final response = await supabase
        .from('providers')
        .select()
        .inFilter('category', categories);
    return (response as List).map((e) => Providers.fromJson(e)).toList();
  }
}
