import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/music_models.dart';

/// 搜索历史服务
class SearchHistoryService {
  static const String _key = 'search_history';
  static const int _maxHistory = 20;

  static Future<List<String>> getHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_key) ?? [];
      return history;
    } catch (e) {
      return [];
    }
  }

  static Future<void> addHistory(String keyword) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> history = prefs.getStringList(_key) ?? [];
      
      // 移除已存在的相同关键词
      history.remove(keyword);
      // 添加到开头
      history.insert(0, keyword);
      // 限制数量
      if (history.length > _maxHistory) {
        history = history.sublist(0, _maxHistory);
      }
      
      await prefs.setStringList(_key, history);
    } catch (e) {
      // 忽略错误
    }
  }

  static Future<void> removeHistory(String keyword) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> history = prefs.getStringList(_key) ?? [];
      history.remove(keyword);
      await prefs.setStringList(_key, history);
    } catch (e) {
      // 忽略错误
    }
  }

  static Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (e) {
      // 忽略错误
    }
  }
}

/// 播放历史服务
class PlaybackHistoryService {
  static const String _key = 'playback_history';
  static const int _maxHistory = 100;

  static Future<List<Song>> getHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyStr = prefs.getString(_key);
      if (historyStr != null) {
        final List<dynamic> list = jsonDecode(historyStr);
        return list.map((e) => Song.fromJson(e)).toList();
      }
    } catch (e) {
      // 忽略错误
    }
    return [];
  }

  static Future<void> addToHistory(Song song) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<Song> history = await getHistory();
      
      // 移除已存在的相同歌曲
      history.removeWhere((s) => s.id == song.id);
      // 添加到开头
      history.insert(0, song);
      // 限制数量
      if (history.length > _maxHistory) {
        history = history.sublist(0, _maxHistory);
      }
      
      final jsonList = history.map((s) => s.toJson()).toList();
      await prefs.setString(_key, jsonEncode(jsonList));
    } catch (e) {
      // 忽略错误
    }
  }

  static Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (e) {
      // 忽略错误
    }
  }
}

/// 收藏歌曲服务
class FavoriteService {
  static const String _key = 'favorite_songs';

  static Future<List<Song>> getFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favStr = prefs.getString(_key);
      if (favStr != null) {
        final List<dynamic> list = jsonDecode(favStr);
        return list.map((e) => Song.fromJson(e)).toList();
      }
    } catch (e) {
      // 忽略错误
    }
    return [];
  }

  static Future<bool> isFavorite(String songId) async {
    final favorites = await getFavorites();
    return favorites.any((s) => s.id == songId);
  }

  static Future<void> addFavorite(Song song) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<Song> favorites = await getFavorites();
      
      if (!favorites.any((s) => s.id == song.id)) {
        favorites.insert(0, song);
        final jsonList = favorites.map((s) => s.toJson()).toList();
        await prefs.setString(_key, jsonEncode(jsonList));
      }
    } catch (e) {
      // 忽略错误
    }
  }

  static Future<void> removeFavorite(String songId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<Song> favorites = await getFavorites();
      favorites.removeWhere((s) => s.id == songId);
      final jsonList = favorites.map((s) => s.toJson()).toList();
      await prefs.setString(_key, jsonEncode(jsonList));
    } catch (e) {
      // 忽略错误
    }
  }

  static Future<void> toggleFavorite(Song song) async {
    if (await isFavorite(song.id)) {
      await removeFavorite(song.id);
    } else {
      await addFavorite(song);
    }
  }
}
