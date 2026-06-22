import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';

class SubscriptionService extends ChangeNotifier {
  SubscriptionService._();

  bool _isActive = false;
  DateTime? _trialStart;
  DateTime? _expiryDate;

  bool get isActive => _isActive;
  bool get hasSubscription => _isActive && (_expiryDate?.isAfter(DateTime.now()) ?? false);
  DateTime? get trialStart => _trialStart;
  DateTime? get expiryDate => _expiryDate;

  bool get isTrialAvailable => _trialStart == null && !_isActive;

  static final SubscriptionService _instance = SubscriptionService._();
  static SubscriptionService get instance => _instance;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isActive = prefs.getBool('sub_active') ?? false;
    final trialStr = prefs.getString('sub_trial_start');
    final expiryStr = prefs.getString('sub_expiry');
    _trialStart = trialStr != null ? DateTime.parse(trialStr) : null;
    _expiryDate = expiryStr != null ? DateTime.parse(expiryStr) : null;

    if (_isActive && _expiryDate != null && _expiryDate!.isBefore(DateTime.now())) {
      _isActive = false;
      _expiryDate = null;
      await _save();
    }

    notifyListeners();
  }

  Future<void> startTrial() async {
    _trialStart = DateTime.now();
    _expiryDate = DateTime.now().add(const Duration(days: AppConstants.trialDays));
    _isActive = true;
    await _save();
    notifyListeners();
  }

  Future<void> purchase({String? store, String? orderId}) async {
    _isActive = true;
    _expiryDate = DateTime.now().add(const Duration(days: 30));
    await _save();
    notifyListeners();
  }

  Future<void> restorePurchase() async {
    final prefs = await SharedPreferences.getInstance();
    final restored = prefs.getBool('sub_active') ?? false;
    if (restored) {
      _isActive = true;
      _expiryDate = _expiryDate ?? DateTime.now().add(const Duration(days: 30));
      notifyListeners();
    }
  }

  int get trialDaysLeft {
    if (_trialStart == null) return 0;
    final elapsed = DateTime.now().difference(_trialStart!);
    final left = AppConstants.trialDays - elapsed.inDays;
    return left > 0 ? left : 0;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sub_active', _isActive);
    if (_trialStart != null) {
      await prefs.setString('sub_trial_start', _trialStart!.toIso8601String());
    }
    if (_expiryDate != null) {
      await prefs.setString('sub_expiry', _expiryDate!.toIso8601String());
    }
  }
}
