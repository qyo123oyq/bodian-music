import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/music_models.dart';
import '../config/app_config.dart';

/// 缓存服务 - 实现SWR（Stale-While-Revalidate）模式
class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  static const String _cachePrefix = 'cache_';

  /// 获取缓存数据
  Future<Map<String, dynamic>?> getCache(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('$_cachePrefix$key');
      final cachedTime = prefs.getInt('${_cachePrefix}time_$key');

      if (cachedData != null) {
        return {
          'data': jsonDecode(cachedData),
          'cachedTime': cachedTime,
        };
      }
    } catch (e) {
      // 忽略缓存读取错误
    }
    return null;
  }

  /// 设置缓存
  Future<void> setCache(String key, dynamic data, {Duration? ttl}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_cachePrefix$key', jsonEncode(data));
      await prefs.setInt(
        '${_cachePrefix}time_$key',
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      // 忽略缓存写入错误
    }
  }

  /// 检查缓存是否有效
  Future<bool> isCacheValid(String key, Duration ttl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedTime = prefs.getInt('${_cachePrefix}time_$key');
      if (cachedTime != null) {
        final age = DateTime.now().millisecondsSinceEpoch - cachedTime;
        return age < ttl.inMilliseconds;
      }
    } catch (e) {
      // 忽略
    }
    return false;
  }

  /// 清除指定缓存
  Future<void> clearCache(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_cachePrefix$key');
      await prefs.remove('${_cachePrefix}time_$key');
    } catch (e) {
      // 忽略
    }
  }

  /// 清除所有缓存
  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith(_cachePrefix)) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      // 忽略
    }
  }

  // ============ 具体缓存方法 ============

  /// 缓存搜索结果
  Future<void> cacheSearchResult(String keyword, List<Song> songs) async {
    final key = 'search_$keyword';
    final data = songs.map((s) => s.toJson()).toList();
    await setCache(key, data, ttl: const Duration(hours: 1));
  }

  /// 获取缓存的搜索结果
  Future<List<Song>?> getCachedSearchResult(String keyword) async {
    final key = 'search_$keyword';
    final cache = await getCache(key);
    if (cache != null) {
      final List<dynamic> list = cache['data'];
      return list.map((e) => Song.fromJson(e)).toList();
    }
    return null;
  }

  /// 缓存歌单详情
  Future<void> cachePlaylist(String playlistId, Playlist playlist) async {
    final key = 'playlist_$playlistId';
    await setCache(key, playlist, ttl: const Duration(hours: 24));
  }

  /// 获取缓存的歌单
  Future<Playlist?> getCachedPlaylist(String playlistId) async {
    final key = 'playlist_$playlistId';
    final cache = await getCache(key);
    if (cache != null) {
      return Playlist.fromJson(cache['data']);
    }
    return null;
  }

  /// 缓存歌词
  Future<void> cacheLyric(String songId, String lyric) async {
    final key = 'lyric_$songId';
    await setCache(key, {'lyric': lyric}, ttl: const Duration(days: 30));
  }

  /// 获取缓存的歌词
  Future<String?> getCachedLyric(String songId) async {
    final key = 'lyric_$songId';
    final cache = await getCache(key);
    if (cache != null) {
      return cache['data']['lyric'];
    }
    return null;
  }

  /// 缓存推荐歌单
  Future<void> cacheRecommendPlaylists(List<Playlist> playlists) async {
    const key = 'recommend_playlists';
    final data = playlists.map((p) => p.toJson()).toList();
    await setCache(key, data, ttl: const Duration(minutes: 30));
  }

  /// 获取缓存的推荐歌单
  Future<List<Playlist>?> getCachedRecommendPlaylists() async {
    const key = 'recommend_playlists';
    final cache = await getCache(key);
    if (cache != null) {
      final List<dynamic> list = cache['data'];
      return list.map((e) => Playlist.fromJson(e)).toList();
    }
    return null;
  }
}

/// 播放缓存管理（文件级）
class PlaybackCacheManager {
  static final PlaybackCacheManager _instance =
      PlaybackCacheManager._internal();
  factory PlaybackCacheManager() => _instance;
  PlaybackCacheManager._internal();

  Directory? _cacheDir;
  int _maxCacheSize = AppConfig.cacheMaxSize;

  Future<Directory> get cacheDir async {
    if (_cacheDir != null) return _cacheDir!;
    final tempDir = await getTemporaryDirectory();
    _cacheDir = Directory('${tempDir.path}/music_cache');
    if (!await _cacheDir!.exists()) {
      await _cacheDir!.create(recursive: true);
    }
    return _cacheDir!;
  }

  /// 获取缓存文件路径
  Future<String> getCacheFilePath(String songId) async {
    final dir = await cacheDir;
    return '${dir.path}/$songId.mp3';
  }

  /// 检查歌曲是否已缓存
  Future<bool> isCached(String songId) async {
    final path = await getCacheFilePath(songId);
    return File(path).exists();
  }

  /// 获取缓存文件
  Future<File?> getCachedFile(String songId) async {
    final path = await getCacheFilePath(songId);
    final file = File(path);
    if (await file.exists()) {
      return file;
    }
    return null;
  }

  /// 获取当前缓存大小
  Future<int> getCurrentCacheSize() async {
    final dir = await cacheDir;
    if (!await dir.exists()) return 0;

    int totalSize = 0;
    await for (final entity in dir.list()) {
      if (entity is File) {
        totalSize += await entity.length();
      }
    }
    return totalSize;
  }

  /// 清理过期缓存（LRU策略）
  Future<void> cleanupCache() async {
    final dir = await cacheDir;
    if (!await dir.exists()) return;

    final files = <File>[];
    await for (final entity in dir.list()) {
      if (entity is File) {
        files.add(entity);
      }
    }

    // 按修改时间排序（最旧的在前）
    files.sort((a, b) {
      final aTime = a.lastModifiedSync();
      final bTime = b.lastModifiedSync();
      return aTime.compareTo(bTime);
    });

    // 计算当前大小
    int currentSize = 0;
    for (final file in files) {
      currentSize += await file.length();
    }

    // 如果超过最大大小，删除最旧的文件
    while (currentSize > _maxCacheSize && files.isNotEmpty) {
      final oldestFile = files.removeAt(0);
      final fileSize = await oldestFile.length();
      await oldestFile.delete();
      currentSize -= fileSize;
    }
  }

  /// 清除所有缓存
  Future<void> clearAllCache() async {
    final dir = await cacheDir;
    if (await dir.exists()) {
      await dir.delete(recursive: true);
      await dir.create(recursive: true);
    }
  }
}
