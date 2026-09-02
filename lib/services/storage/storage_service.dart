import 'package:cheguei/models/user_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  static const String _boxName = 'cheguei_box';
  static const String _userKey = 'user';
  static const String _favoritesKey = 'favorites';
  static const String _historyKey = 'history';
  static const String _homeAddressKey = 'home_address';
  static const String _workAddressKey = 'work_address';
  static const String _collegeAddressKey = 'college_address';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
  }

  static Box get _box => Hive.box(_boxName);

  static Future<void> saveUser(UserModel user) async {
    await _box.put(_userKey, user.toMap());
  }

  static Future<void> updateUser(UserModel user) async {
    await _box.put(_userKey, user.toMap());
  }

  static UserModel? getUser() {
    final data = _box.get(_userKey);

    if (data == null) return null;

    return UserModel.fromMap(Map<dynamic, dynamic>.from(data));
  }

  static bool hasUser() {
    return _box.containsKey(_userKey);
  }

  static Future<void> deleteUser() async {
    await _box.delete(_userKey);
  }

  static List<String> getFavorites() {
    final data = _box.get(_favoritesKey);

    if (data == null) {
      return [];
    }

    return List<String>.from(data);
  }

  static Future<void> saveFavorite(String destination) async {
    final favorites = getFavorites();

    if (!favorites.contains(destination)) {
      favorites.add(destination);
      await _box.put(_favoritesKey, favorites);
    }
  }

  static Future<void> removeFavorite(String destination) async {
    final favorites = getFavorites();

    favorites.remove(destination);

    await _box.put(_favoritesKey, favorites);
  }

  static List<String> getHistory() {
    final data = _box.get(_historyKey);

    if (data == null) {
      return [];
    }

    return List<String>.from(data);
  }

  static Future<void> saveHistory(String destination) async {
    final history = getHistory();

    history.insert(0, destination);

    await _box.put(_historyKey, history);
  }

  static Future<void> saveHomeAddress(String address) async {
    await _box.put(_homeAddressKey, address);
  }

  static String? getHomeAddress() {
    return _box.get(_homeAddressKey) as String?;
  }

  static Future<void> saveWorkAddress(String address) async {
    await _box.put(_workAddressKey, address);
  }

  static String? getWorkAddress() {
    return _box.get(_workAddressKey) as String?;
  }

  static Future<void> saveCollegeAddress(String address) async {
    await _box.put(_collegeAddressKey, address);
  }

  static String? getCollegeAddress() {
    return _box.get(_collegeAddressKey) as String?;
  }
}
