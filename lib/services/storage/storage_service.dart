import 'package:cheguei/models/user_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  static const String _boxName = 'cheguei_box';
  static const String _userKey = 'user';
  static const String _favoritesKey = 'favorites';

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
}
