import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider for finance name
final financeProvider = StateNotifierProvider<FinanceNotifier, String>((ref) {
  return FinanceNotifier();
});

class FinanceNotifier extends StateNotifier<String> {
  FinanceNotifier() : super('') {
    loadFinanceName();
  }

  Future<void> loadFinanceName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    state = prefs.getString('financeName') ?? '';
  }

  Future<void> saveFinanceName(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    state = name;
    await prefs.setString('financeName', name);
  }
}

// Provider for current line name
final currentLineNameProvider = StateProvider<String?>((ref) => null);

class CurrentLineNameNotifier extends StateNotifier<String> {
  CurrentLineNameNotifier() : super('') {
    loadCurrentLineName();
  }

  Future<void> loadCurrentLineName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    state = prefs.getString('currentLineName') ?? '';
  }

  Future<void> saveCurrentLineName(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    state = name;
    await prefs.setString('currentLineName', name);
  }
}

// Provider for current party name
final currentPartyNameProvider = StateProvider<String?>((ref) => null);

class CurrentPartyNameNotifier extends StateNotifier<String> {
  CurrentPartyNameNotifier() : super('') {
    loadCurrentPartyName();
  }

  Future<void> loadCurrentPartyName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    state = prefs.getString('currentPartyName') ?? '';
  }

  Future<void> saveCurrentPartyName(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    state = name;
    await prefs.setString('currentPartyName', name);
  }
}

// Provider for LenId
final lenIdProvider = StateNotifierProvider<LenIdNotifier, int?>((ref) {
  return LenIdNotifier();
});

class LenIdNotifier extends StateNotifier<int?> {
  LenIdNotifier() : super(null) {
    loadLenId();
  }

  Future<void> loadLenId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    state = prefs.getInt('lenId');
  }

  Future<void> saveLenId(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    state = id;
    await prefs.setInt('lenId', id);
  }
}

// Provider for LenStatus
// Provider for LenStatus
final lenStatusProvider =
    StateNotifierProvider<LenStatusNotifier, String>((ref) {
  return LenStatusNotifier();
});

class LenStatusNotifier extends StateNotifier<String> {
  LenStatusNotifier() : super('') {
    loadLenStatus();
  }

  Future<void> loadLenStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    state = prefs.getString('lenStatus') ?? '';
  }

  Future<void> saveLenStatus(String status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    state = status;
    await prefs.setString('lenStatus', status);
  }

  Future<void> updateLenStatus(String newStatus) async {
    state = newStatus;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('lenStatus', newStatus);
  }
}

final financeNameProvider = StateProvider<String>((ref) {
  return 'Default Finance Name';
});
