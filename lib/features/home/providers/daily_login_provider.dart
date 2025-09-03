import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro_flutter_new/shared/providers/shared_preferences_provider.dart';
import '../domain/models/level_system.dart';

class DailyLoginState {
  final DateTime? lastLoginDate;
  final int consecutiveDays;
  final int totalXpEarned;
  final bool bonusClaimedToday;
  
  DailyLoginState({
    this.lastLoginDate,
    this.consecutiveDays = 0,
    this.totalXpEarned = 0,
    this.bonusClaimedToday = false,
  });
  
  DailyLoginState copyWith({
    DateTime? lastLoginDate,
    int? consecutiveDays,
    int? totalXpEarned,
    bool? bonusClaimedToday,
  }) {
    return DailyLoginState(
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      consecutiveDays: consecutiveDays ?? this.consecutiveDays,
      totalXpEarned: totalXpEarned ?? this.totalXpEarned,
      bonusClaimedToday: bonusClaimedToday ?? this.bonusClaimedToday,
    );
  }
}

class DailyLoginNotifier extends StateNotifier<DailyLoginState> {
  final SharedPreferences _prefs;
  
  static const String _lastLoginKey = 'last_login_date';
  static const String _consecutiveDaysKey = 'consecutive_login_days';
  static const String _totalXpKey = 'total_login_xp';
  static const String _lastBonusDateKey = 'last_bonus_claim_date';
  
  DailyLoginNotifier(this._prefs) : super(DailyLoginState()) {
    _loadState();
  }
  
  void _loadState() {
    final lastLoginStr = _prefs.getString(_lastLoginKey);
    final lastBonusStr = _prefs.getString(_lastBonusDateKey);
    final consecutiveDays = _prefs.getInt(_consecutiveDaysKey) ?? 0;
    final totalXp = _prefs.getInt(_totalXpKey) ?? 0;
    
    DateTime? lastLogin;
    if (lastLoginStr != null) {
      lastLogin = DateTime.parse(lastLoginStr);
    }
    
    bool bonusClaimedToday = false;
    if (lastBonusStr != null) {
      final lastBonusDate = DateTime.parse(lastBonusStr);
      final today = DateTime.now();
      bonusClaimedToday = _isSameDay(lastBonusDate, today);
    }
    
    state = DailyLoginState(
      lastLoginDate: lastLogin,
      consecutiveDays: consecutiveDays,
      totalXpEarned: totalXp,
      bonusClaimedToday: bonusClaimedToday,
    );
  }
  
  // Controlla e aggiorna il login streak
  Future<int> checkDailyLogin() async {
    final now = DateTime.now();
    final lastLogin = state.lastLoginDate;
    
    if (lastLogin == null) {
      // Primo login in assoluto
      return await _updateLoginStreak(now, 1);
    }
    
    if (_isSameDay(lastLogin, now)) {
      // Già loggato oggi, ritorna il bonus corrente se non ancora reclamato
      if (!state.bonusClaimedToday) {
        return LevelSystem.calculateDailyLoginBonus(state.consecutiveDays);
      }
      return 0;
    }
    
    if (_isYesterday(lastLogin, now)) {
      // Login consecutivo - incrementa streak
      final newStreak = state.consecutiveDays + 1;
      return await _updateLoginStreak(now, newStreak);
    }
    
    // Streak interrotto - ricomincia da 1
    return await _updateLoginStreak(now, 1);
  }
  
  // Reclama il bonus XP giornaliero
  Future<bool> claimDailyBonus() async {
    if (state.bonusClaimedToday) {
      return false; // Già reclamato oggi
    }
    
    final bonusXp = await checkDailyLogin();
    if (bonusXp > 0) {
      final newTotalXp = state.totalXpEarned + bonusXp;
      
      state = state.copyWith(
        totalXpEarned: newTotalXp,
        bonusClaimedToday: true,
      );
      
      await _prefs.setInt(_totalXpKey, newTotalXp);
      await _prefs.setString(_lastBonusDateKey, DateTime.now().toIso8601String());
      
      // TODO: Qui andrebbe aggiornato anche il provider degli XP totali dell'utente
      // ref.read(userXpProvider.notifier).addXp(bonusXp);
      
      return true;
    }
    
    return false;
  }
  
  // Ottieni info sul bonus corrente
  DailyLoginBonusInfo getBonusInfo() {
    return LevelSystem.getDailyLoginBonusInfo(state.consecutiveDays);
  }
  
  // Helper: aggiorna lo streak
  Future<int> _updateLoginStreak(DateTime loginDate, int newStreak) async {
    state = state.copyWith(
      lastLoginDate: loginDate,
      consecutiveDays: newStreak,
      bonusClaimedToday: false, // Reset per il nuovo giorno
    );
    
    await _prefs.setString(_lastLoginKey, loginDate.toIso8601String());
    await _prefs.setInt(_consecutiveDaysKey, newStreak);
    
    return LevelSystem.calculateDailyLoginBonus(newStreak);
  }
  
  // Helper: controlla se due date sono lo stesso giorno
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
  
  // Helper: controlla se date1 è ieri rispetto a date2
  bool _isYesterday(DateTime date1, DateTime date2) {
    final yesterday = date2.subtract(const Duration(days: 1));
    return _isSameDay(date1, yesterday);
  }
  
  // Reset manuale dello streak (per testing o admin)
  Future<void> resetStreak() async {
    state = DailyLoginState();
    await _prefs.remove(_lastLoginKey);
    await _prefs.remove(_consecutiveDaysKey);
    await _prefs.remove(_totalXpKey);
    await _prefs.remove(_lastBonusDateKey);
  }
}

final dailyLoginProvider = StateNotifierProvider<DailyLoginNotifier, DailyLoginState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return DailyLoginNotifier(prefs);
});