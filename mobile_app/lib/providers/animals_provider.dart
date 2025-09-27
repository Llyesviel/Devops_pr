import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/animal.dart';

class AnimalsProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Animal> _animals = [];
  bool _isLoading = false;
  String? _error;

  List<Animal> get animals => _animals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAnimals({
    String? species,
    String? shelterId,
    bool? isAdopted,
    String? search,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      var query = _supabase.from('animals').select('''
        *,
        shelters (
          id,
          name,
          address
        )
      ''');

      if (species != null && species.isNotEmpty) {
        query = query.eq('species', species);
      }
      if (shelterId != null && shelterId.isNotEmpty) {
        query = query.eq('shelter_id', shelterId);
      }
      if (isAdopted != null) {
        query = query.eq('is_adopted', isAdopted);
      }
      if (search != null && search.isNotEmpty) {
        query = query.or('name.ilike.%$search%,description.ilike.%$search%');
      }

      final response = await query.order('created_at', ascending: false);
      
      _animals = response
          .map(Animal.fromJson)
          .toList();
    } on PostgrestException catch (e) {
      _error = e.message;
      debugPrint('Error fetching animals: ${e.message}');
    } on Exception catch (e) {
      _error = e.toString();
      debugPrint('Unexpected error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleFavorite(String animalId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return false;
      }

      // Check if already favorited
      final existing = await _supabase
          .from('user_favorites')
          .select()
          .eq('user_id', user.id)
          .eq('animal_id', animalId)
          .maybeSingle();

      if (existing != null) {
        // Remove from favorites
        await _supabase
            .from('user_favorites')
            .delete()
            .eq('user_id', user.id)
            .eq('animal_id', animalId);
      } else {
        // Add to favorites
        await _supabase.from('user_favorites').insert({
          'user_id': user.id,
          'animal_id': animalId,
        });
      }

      // Refresh animals list
      await fetchAnimals();
      return true;
    } on PostgrestException catch (e) {
      debugPrint('Error toggling favorite: ${e.message}');
      return false;
    } on Exception catch (e) {
      debugPrint('Unexpected error: $e');
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}