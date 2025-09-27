import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/donation.dart';

class DonationsProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Donation> _donations = [];
  bool _isLoading = false;
  String? _error;
  double _totalDonated = 0;

  List<Donation> get donations => _donations;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get totalDonated => _totalDonated;

  Future<void> fetchDonations({String? userId}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      var query = _supabase.from('donations').select('''
        *,
        users (
          id,
          full_name,
          email
        ),
        shelters (
          id,
          name
        )
      ''');

      if (userId != null) {
        query = query.eq('user_id', userId);
      }

      final response = await query.order('created_at', ascending: false);
      
      _donations = response
          .map(Donation.fromJson)
          .toList();

      // Calculate total donated
      _totalDonated = _donations
          .where((d) => d.status == 'completed')
          .fold(0, (sum, donation) => sum + donation.amount);

    } on PostgrestException catch (e) {
      _error = e.message;
      debugPrint('Error fetching donations: ${e.message}');
    } on Exception catch (e) {
      _error = e.toString();
      debugPrint('Error fetching donations: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createDonation({
    required double amount,
    required String shelterId,
    String? message,
    bool isAnonymous = false,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return false;
      }

      _isLoading = true;
      notifyListeners();

      final donation = {
        'user_id': user.id,
        'shelter_id': shelterId,
        'amount': amount,
        'message': message,
        'is_anonymous': isAnonymous,
        'status': 'pending',
        'payment_method': 'card',
      };

      final response = await _supabase
          .from('donations')
          .insert(donation)
          .select()
          .single();

      final newDonation = Donation.fromJson(response);
      _donations.insert(0, newDonation);
      
      return true;
    } on Exception catch (e) {
      _error = e.toString();
      debugPrint('Error creating donation: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateDonationStatus(String donationId, String status) async {
    try {
      await _supabase
          .from('donations')
          .update({'status': status})
          .eq('id', donationId);

      // Update local state
      final index = _donations.indexWhere((d) => d.id == donationId);
      if (index != -1) {
        _donations[index] = _donations[index].copyWith(status: status);
        
        // Recalculate total if status changed to completed
        if (status == 'completed') {
          _totalDonated = _donations
              .where((d) => d.status == 'completed')
              .fold(0, (sum, donation) => sum + donation.amount);
        }
        
        notifyListeners();
      }

      return true;
    } on Exception catch (e) {
      _error = e.toString();
      debugPrint('Error updating donation status: $e');
      return false;
    }
  }

  Future<Map<String, double>> getDonationStats() async {
    try {
      final response = await _supabase
          .from('donations')
          .select('amount, status')
          .eq('status', 'completed');

      final donations = response;
      final total = donations.fold<double>(
        0,
        (sum, donation) => sum + (donation['amount'] as num).toDouble(),
      );

      final thisMonth = DateTime.now();
      final startOfMonth = DateTime(thisMonth.year, thisMonth.month);
      
      final monthlyResponse = await _supabase
          .from('donations')
          .select('amount')
          .eq('status', 'completed')
          .gte('created_at', startOfMonth.toIso8601String());

      final monthlyDonations = monthlyResponse;
      final monthlyTotal = monthlyDonations.fold<double>(
        0,
        (sum, donation) => sum + (donation['amount'] as num).toDouble(),
      );

      return {
        'total': total,
        'monthly': monthlyTotal,
        'count': donations.length.toDouble(),
      };
    } on PostgrestException catch (e) {
      debugPrint('Error getting donation stats: ${e.message}');
      return {'total': 0.0, 'monthly': 0.0, 'count': 0.0};
    } on Exception catch (e) {
      debugPrint('Error getting donation stats: $e');
      return {'total': 0.0, 'monthly': 0.0, 'count': 0.0};
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}