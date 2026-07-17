import 'dart:convert';
import '../config/app_config.dart';
import '../models/music_models.dart';
import '../core/api_client.dart';

class MusicApiService {
  static final MusicApiService _instance = MusicApiService._internal();
  factory MusicApiService() => _instance;
  MusicApiService._internal();

  final ApiClient _api = ApiClient();

  // ============== 搜索相关 ==============

  /// 搜索歌曲
  Future<List<Song>> searchSongs(
    String keyword, {
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      // 使用酷我搜索API
      final url = '${AppConfig.kuwoSearchUrl}/r.s';
      final params = {
        'all': keyword,
        'ft': 'music',
        'itemset': 'web_2013',
        'client': 'kt',
        'pn': page.toString(),
        'rn': pageSize.toString(),
        'rformat': 'json',
        'encoding': 'utf8',
      };

      final response = await _api.get(url, params: params);

      if (response['abslist'] != null) {
        final List<dynamic> list = response['abslist'];
        return list.map((e) => _parseKuwoSong(e)).toList();
      }

      // 备用：使用第三方API
      return _searchSongsBackup(keyword, page: page, pageSize: pageSize);
    } catch (e) {
      // 备用方案
      return _searchSongsBackup(keyword, page: page, pageSize: pageSize);
    }
  }

  /// 备用搜索接口
  Future<List<Song>> _searchSongsBackup(
    String keyword, {
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final url = AppConfig.backupApiUrl;
      final params = {
        'name': keyword,
        'page': page.toString(),
        'pagesize': pageSize.toString(),
        'br': '2', // 320K音质
      };

      final response = await _api.get(url, params: params);

      if (response['data'] != null && response['data'] is List) {
        final List<dynamic> list = response['data'];
        return list.map((e) => Song.fromJson(e)).toList();
      }

      if (response['song'] != null && response['song'] is List) {
        final List<dynamic> list = response['song'];
        return list.map((e) => Song.fromJson(e)).toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// 搜索歌手
  Future<List<Artist>> searchArtists(String keyword) async {
    try {
      final url = '${AppConfig.kuwoSearchUrl}/r.s';
      final params = {
        'all': keyword,
        'ft': 'artist',
        'itemset': 'web_2013',
        'client': 'kt',
        'pn': '1',
        'rn': '20',
        'rformat': 'json',
        'encoding': 'utf8',
      };

      final response = await _api.get(url, params: params);
      final List<dynamic> list = response['abslist'] ?? [];
      return list.map((e) => Artist.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  /// 搜索歌单
  Future<List<Playlist>> searchPlaylists(String keyword) async {
    try {
      final url = '${AppConfig.kuwoSearchUrl}/r.s';
      final params = {
        'all': keyword,
        'ft': 'playlist',
        'itemset': 'web_2013',
        'client': 'kt',
        'pn': '1',
        'rn': '20',
        'rformat': 'json',
        'encoding': 'utf8',
      };

      final response = await _api.get(url, params: params);
      final List<dynamic> list = response['abslist'] ?? [];
      return list.map((e) => Playlist.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  // ============== 播放地址相关 ==============

  /// 获取歌曲播放地址
  Future<String> getSongUrl(
    String rid, {
    int quality = 320,
  }) async {
    try {
      // 方法1：使用酷我anti接口
      final format = quality >= 1000 ? 'flac' : 'mp3';
      final url = '${AppConfig.kuwoAntiUrl}/anti.s';
      final params = {
        'type': 'convert_url',
        'rid': 'MUSIC_$rid',
        'format': format,
        'response': 'url',
      };

      final response = await _api.get(url, params: params);
      if (response['url'] != null && response['url'].toString().isNotEmpty) {
        return response['url'];
      }

      // 备用方法
      return _getSongUrlBackup(rid, quality: quality);
    } catch (e) {
      return _getSongUrlBackup(rid, quality: quality);
    }
  }

  /// 备用获取播放地址
  Future<String> _getSongUrlBackup(
    String rid, {
    int quality = 320,
  }) async {
    try {
      final url = '${AppConfig.kuwoPlayerUrl}/webmusic/st/getNewMuiseByRid';
      final params = {'rid': 'MUSIC_$rid'};
      final response = await _api.get(url, params: params);

      // 解析返回的XML或JSON
      if (response['url'] != null) {
        return response['url'];
      }

      return '';
    } catch (e) {
      return '';
    }
  }

  // ============== 歌词相关 ==============

  /// 获取歌词
  Future<String?> getLyric(String rid) async {
    try {
      final url = '${AppConfig.kuwoPlayerUrl}/webmusic/st/getNewMuiseByRid';
      final params = {'rid': 'MUSIC_$rid'};
      final response = await _api.get(url, params: params);

      if (response['lyric'] != null) {
        // 酷我歌词可能是base64加密的，需要解密
        final lyric = response['lyric'].toString();
        return _decodeKuwoLyric(lyric);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// 解密酷我歌词（base64编码）
  String? _decodeKuwoLyric(String encoded) {
    try {
      // 尝试base64解码
      final decoded = utf8.decode(base64.decode(encoded));
      if (decoded.contains('[ti:') || decoded.contains('[00:')) {
        return decoded;
      }
      return encoded;
    } catch (e) {
      // 如果不是base64，直接返回
      return encoded;
    }
  }

  // ============== 歌单相关 ==============

  /// 获取推荐歌单
  Future<List<Playlist>> getRecommendPlaylists({int page = 1}) async {
    try {
      final url = '${AppConfig.bodianApiUrl}/v1/playlist/recommend';
      final params = {
        'pn': page.toString(),
        'rn': '20',
      };
      final response = await _api.get(url, params: params);

      if (response['data'] != null && response['data']['list'] != null) {
        final List<dynamic> list = response['data']['list'];
        return list.map((e) => Playlist.fromJson(e)).toList();
      }

      return _getMockPlaylists();
    } catch (e) {
      return _getMockPlaylists();
    }
  }

  /// 获取歌单详情
  Future<Playlist?> getPlaylistDetail(String playlistId) async {
    try {
      final url = '${AppConfig.bodianApiUrl}/v1/playlist/detail';
      final params = {'pid': playlistId};
      final response = await _api.get(url, params: params);

      if (response['data'] != null) {
        return Playlist.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取歌单歌曲列表
  Future<List<Song>> getPlaylistSongs(String playlistId) async {
    try {
      final url = '${AppConfig.bodianApiUrl}/v1/playlist/songs';
      final params = {
        'pid': playlistId,
        'pn': '1',
        'rn': '100',
      };
      final response = await _api.get(url, params: params);

      if (response['data'] != null && response['data']['list'] != null) {
        final List<dynamic> list = response['data']['list'];
        return list.map((e) => _parseKuwoSong(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ============== 用户相关 ==============

  /// 获取用户信息
  Future<UserProfile?> getUserInfo(String uid) async {
    try {
      final url = '${AppConfig.bodianApiUrl}/ucenter/users/pub/$uid';
      final params = {
        'fromUid': AppConfig.defaultFromUid,
        'platform': 'ios',
      };
      final response = await _api.get(url, params: params);

      if (response['code'] == 200 && response['data'] != null) {
        final userInfo = response['data']['userInfo'] ?? response['data'];
        return UserProfile.fromJson(userInfo);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 签到领VIP
  Future<bool> checkIn(String uid) async {
    try {
      final url = '${AppConfig.bodianApiUrl}/ucenter/vip/give/popup';
      final params = {
        'action': 'play',
        'uid': uid,
        'token': AppConfig.defaultToken,
      };
      final response = await _api.get(url, params: params);
      return response['code'] == 200;
    } catch (e) {
      return false;
    }
  }

  // ============== 首页推荐相关 ==============

  /// 获取首页数据
  Future<Map<String, dynamic>> getHomeData() async {
    try {
      final playlists = await getRecommendPlaylists();
      final hotSongs = await _getHotSongs();
      return {
        'recommendPlaylists': playlists,
        'hotSongs': hotSongs,
        'banners': _getMockBanners(),
      };
    } catch (e) {
      return {
        'recommendPlaylists': _getMockPlaylists(),
        'hotSongs': <Song>[],
        'banners': _getMockBanners(),
      };
    }
  }

  /// 获取热门歌曲
  Future<List<Song>> _getHotSongs() async {
    try {
      return searchSongs('热门', pageSize: 20);
    } catch (e) {
      return [];
    }
  }

  // ============== 歌手相关 ==============

  /// 获取歌手详情
  Future<Artist?> getArtistDetail(String artistId) async {
    try {
      // 实现歌手详情获取
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取歌手热门歌曲
  Future<List<Song>> getArtistSongs(String artistId) async {
    try {
      return [];
    } catch (e) {
      return [];
    }
  }

  // ============== 专辑相关 ==============

  /// 获取专辑信息
  Future<Playlist?> getAlbumDetail(String albumId) async {
    try {
      return null;
    } catch (e) {
      return null;
    }
  }

  // ============== 辅助方法 ==============

  /// 解析酷我歌曲数据
  Song _parseKuwoSong(Map<String, dynamic> json) {
    final rid = json['MUSICRID']?.toString() ??
        json['rid']?.toString() ??
        json['id']?.toString() ??
        '';
    final cleanRid = rid.replaceAll('MUSIC_', '');

    return Song(
      id: cleanRid,
      rid: cleanRid,
      name: json['SONGNAME']?.toString() ??
          json['name']?.toString() ??
          json['songname']?.toString() ??
          '',
      artist: json['ARTIST']?.toString() ??
          json['artist']?.toString() ??
          json['singername']?.toString() ??
          '',
      artistId: json['ARTISTID']?.toString() ?? '',
      album: json['ALBUM']?.toString() ??
          json['album']?.toString() ??
          json['albumname']?.toString() ??
          '',
      albumId: json['ALBUMID']?.toString() ?? '',
      albumPic: _getAlbumCover(json['ALBUMID']?.toString() ?? ''),
      duration: int.tryParse(json['DURATION']?.toString() ??
              json['duration']?.toString() ??
              '0') ??
          0,
      isVip: json['ISVIP'] == '1' || json['isVip'] == true,
    );
  }

  /// 获取专辑封面URL
  String _getAlbumCover(String albumId) {
    if (albumId.isEmpty) return '';
    return 'https://img4.kuwo.cn/star/albumcover/300/$albumId.jpg';
  }

  // ============== Mock数据 ==============

  List<Playlist> _getMockPlaylists() {
    return [
      Playlist(
        id: '1',
        name: '每日推荐',
        cover: 'https://img4.kuwo.cn/star/albumcover/300/1000.jpg',
        description: '根据你的口味推荐',
        playCount: 999999,
        songCount: 30,
      ),
      Playlist(
        id: '2',
        name: '华语流行',
        cover: 'https://img4.kuwo.cn/star/albumcover/300/2000.jpg',
        description: '最热门的华语流行歌曲',
        playCount: 888888,
        songCount: 50,
      ),
      Playlist(
        id: '3',
        name: '欧美经典',
        cover: 'https://img4.kuwo.cn/star/albumcover/300/3000.jpg',
        description: '欧美乐坛经典之作',
        playCount: 777777,
        songCount: 40,
      ),
      Playlist(
        id: '4',
        name: '轻音乐',
        cover: 'https://img4.kuwo.cn/star/albumcover/300/4000.jpg',
        description: '放松心情的轻音乐',
        playCount: 666666,
        songCount: 35,
      ),
    ];
  }

  List<Map<String, dynamic>> _getMockBanners() {
    return [
      {
        'id': '1',
        'title': '波点音乐',
        'image': 'https://img4.kuwo.cn/star/albumcover/500/banner1.jpg',
        'type': 'playlist',
      },
      {
        'id': '2',
        'title': '新歌首发',
        'image': 'https://img4.kuwo.cn/star/albumcover/500/banner2.jpg',
        'type': 'album',
      },
    ];
  }
}
