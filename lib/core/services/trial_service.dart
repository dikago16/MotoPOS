import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class TrialService {
  // SharedPreferences keys
  static const String _isTrialActiveKey = 'is_trial_active';
  static const String _trialAiUsageCountKey = 'trial_ai_usage_count';

  // Trial limits
  static const int maxTrialItems = 3;
  static const int maxTrialAiChats = 3;

  /// Start the trial mode
  static Future<void> startTrial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isTrialActiveKey, true);
    // Ensure we don't reset AI count if they already used some before
    if (!prefs.containsKey(_trialAiUsageCountKey)) {
      await prefs.setInt(_trialAiUsageCountKey, 0);
    }
    debugPrint("Trial mode started.");
  }

  /// Check if trial mode is active
  static Future<bool> isTrialActive() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isTrialActiveKey) ?? false;
  }

  /// Check if user can add a new item
  static bool canAddItem(int currentCount) {
    return currentCount < maxTrialItems;
  }

  /// Check if user can use AI chat
  static Future<bool> canUseAiChat() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_trialAiUsageCountKey) ?? 0;
    return count < maxTrialAiChats;
  }

  /// Increment AI usage counter
  static Future<void> incrementAiUsage() async {
    final prefs = await SharedPreferences.getInstance();
    final currentCount = prefs.getInt(_trialAiUsageCountKey) ?? 0;
    await prefs.setInt(_trialAiUsageCountKey, currentCount + 1);
  }

  /// Get current AI usage count
  static Future<int> getAiUsageCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_trialAiUsageCountKey) ?? 0;
  }

  /// Get remaining AI chats
  static Future<int> getRemainingAiChats() async {
    final count = await getAiUsageCount();
    final remaining = maxTrialAiChats - count;
    return remaining < 0 ? 0 : remaining;
  }

  /// Deactivate trial mode and clean up (called after successful license activation)
  static Future<void> deactivateTrial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isTrialActiveKey);
    // Not removing AI usage count so we remember it if they somehow revert to trial
    // but the limits won't apply if trial is not active anyway.
    debugPrint("Trial mode deactivated.");
  }
}
