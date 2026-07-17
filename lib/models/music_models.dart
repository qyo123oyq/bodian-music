/// 歌曲模型
class Song {
  final String id;
  final String rid;
  final String name;
  final String artist;
  final String artistId;
  final String album;
  final String albumId;
  final String albumPic;
  final int duration;
  final String songUrl;
  final int quality;
  final String? lyric;
  final List<Artist>? artists;
  final bool isVip;

  const Song({
    required this.id,
    required this.rid,
    required this.name,
    required this.artist,
    this.artistId = '',
    this.album = '',
    this.albumId = '',
    this.albumPic = '',
    this.duration = 0,
    this.songUrl = '',
    this.quality = 128,
    this.lyric,
    this.artists,
    this.isVip = false,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id']?.toString() ?? json['rid']?.toString() ?? '',
      rid: json['rid']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['songname']?.toString() ?? '',
      artist: json['artist']?.toString() ?? json['singername']?.toString() ?? '',
      artistId: json['artistid']?.toString() ?? '',
      album: json['album']?.toString() ?? json['albumname']?.toString() ?? '',
      albumId: json['albumid']?.toString() ?? '',
      albumPic: json['albumPic']?.toString() ??
          json['pic']?.toString() ??
          json['img']?.toString() ??
          '',
      duration: (json['duration'] ?? json['songtime'] ?? 0) is String
          ? int.tryParse(json['duration'] ?? json['songtime'] ?? '0') ?? 0
          : (json['duration'] ?? json['songtime'] ?? 0).toInt(),
      songUrl: json['url']?.toString() ?? '',
      quality: json['quality'] ?? 128,
      lyric: json['lyric']?.toString(),
      isVip: json['isVip'] ?? json['isvip'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rid': rid,
      'name': name,
      'artist': artist,
      'artistId': artistId,
      'album': album,
      'albumId': albumId,
      'albumPic': albumPic,
      'duration': duration,
      'songUrl': songUrl,
      'quality': quality,
      'lyric': lyric,
      'isVip': isVip,
    };
  }

  Song copyWith({
    String? id,
    String? rid,
    String? name,
    String? artist,
    String? artistId,
    String? album,
    String? albumId,
    String? albumPic,
    int? duration,
    String? songUrl,
    int? quality,
    String? lyric,
    bool? isVip,
  }) {
    return Song(
      id: id ?? this.id,
      rid: rid ?? this.rid,
      name: name ?? this.name,
      artist: artist ?? this.artist,
      artistId: artistId ?? this.artistId,
      album: album ?? this.album,
      albumId: albumId ?? this.albumId,
      albumPic: albumPic ?? this.albumPic,
      duration: duration ?? this.duration,
      songUrl: songUrl ?? this.songUrl,
      quality: quality ?? this.quality,
      lyric: lyric ?? this.lyric,
      isVip: isVip ?? this.isVip,
    );
  }

  String get displayName => name;
  String get displayArtist => artist;
  String get displayAlbum => album;
  String get albumPicUrl => albumPic.isNotEmpty
      ? albumPic
      : 'https://img4.kuwo.cn/star/albumcover/300/0/0.jpg';

  String formatDuration() {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Song && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// 歌手模型
class Artist {
  final String id;
  final String name;
  final String avatar;
  final String description;

  const Artist({
    required this.id,
    required this.name,
    this.avatar = '',
    this.description = '',
  });

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      avatar: json['avatar']?.toString() ?? json['pic']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }
}

/// 歌单模型
class Playlist {
  final String id;
  final String name;
  final String cover;
  final String description;
  final int playCount;
  final int songCount;
  final String creator;
  final String creatorAvatar;
  final List<Song> songs;

  const Playlist({
    required this.id,
    required this.name,
    this.cover = '',
    this.description = '',
    this.playCount = 0,
    this.songCount = 0,
    this.creator = '',
    this.creatorAvatar = '',
    this.songs = const [],
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id']?.toString() ?? json['pid']?.toString() ?? '',
      name: json['name']?.toString() ?? json['title']?.toString() ?? '',
      cover: json['cover']?.toString() ??
          json['pic']?.toString() ??
          json['img']?.toString() ??
          '',
      description: json['description']?.toString() ?? json['desc']?.toString() ?? '',
      playCount: json['playCount'] ?? json['play_count'] ?? 0,
      songCount: json['songCount'] ?? json['song_count'] ?? 0,
      creator: json['creator']?.toString() ?? json['nickname']?.toString() ?? '',
      creatorAvatar:
          json['creatorAvatar']?.toString() ?? json['avatar']?.toString() ?? '',
      songs: (json['songs'] as List<dynamic>?)
              ?.map((e) => Song.fromJson(e))
              .toList() ??
          [],
    );
  }

  Playlist copyWith({
    String? id,
    String? name,
    String? cover,
    String? description,
    int? playCount,
    int? songCount,
    String? creator,
    String? creatorAvatar,
    List<Song>? songs,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      cover: cover ?? this.cover,
      description: description ?? this.description,
      playCount: playCount ?? this.playCount,
      songCount: songCount ?? this.songCount,
      creator: creator ?? this.creator,
      creatorAvatar: creatorAvatar ?? this.creatorAvatar,
      songs: songs ?? this.songs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cover': cover,
      'description': description,
      'playCount': playCount,
      'songCount': songCount,
      'creator': creator,
      'creatorAvatar': creatorAvatar,
      'songs': songs.map((s) => s.toJson()).toList(),
    };
  }
}

/// 歌词行模型
class LyricLine {
  final Duration startTime;
  final String content;
  final List<LyricWord>? words;

  const LyricLine({
    required this.startTime,
    required this.content,
    this.words,
  });

  factory LyricLine.fromLrc(String lrcLine) {
    final timeMatch = RegExp(r'\[(\d{2}):(\d{2})\.(\d{2,3})\]').firstMatch(lrcLine);
    if (timeMatch != null) {
      final minutes = int.parse(timeMatch.group(1)!);
      final seconds = int.parse(timeMatch.group(2)!);
      final milliseconds = int.parse(timeMatch.group(3)!.padRight(3, '0'));
      final content = lrcLine.replaceFirst(RegExp(r'\[.*?\]'), '').trim();
      return LyricLine(
        startTime: Duration(
          minutes: minutes,
          seconds: seconds,
          milliseconds: milliseconds,
        ),
        content: content,
      );
    }
    return LyricLine(startTime: Duration.zero, content: lrcLine);
  }
}

class LyricWord {
  final Duration startTime;
  final Duration duration;
  final String word;

  const LyricWord({
    required this.startTime,
    required this.duration,
    required this.word,
  });
}

/// 用户模型
class UserProfile {
  final String id;
  final String nickname;
  final String avatar;
  final String signature;
  final bool isVip;
  final DateTime? vipExpireTime;
  final int level;

  const UserProfile({
    required this.id,
    required this.nickname,
    this.avatar = '',
    this.signature = '',
    this.isVip = false,
    this.vipExpireTime,
    this.level = 0,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? json['uid']?.toString() ?? '',
      nickname:
          json['nickname']?.toString() ?? json['name']?.toString() ?? '',
      avatar: json['avatar']?.toString() ??
          json['headImg']?.toString() ??
          json['pic']?.toString() ??
          '',
      signature: json['signature']?.toString() ?? '',
      isVip: json['isVip'] ?? json['vip'] ?? false,
      level: json['level'] ?? 0,
    );
  }
}

/// 搜索结果模型
class SearchResult {
  final List<Song> songs;
  final List<Artist> artists;
  final List<Playlist> playlists;
  final int total;

  const SearchResult({
    this.songs = const [],
    this.artists = const [],
    this.playlists = const [],
    this.total = 0,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      songs: (json['songs'] as List<dynamic>?)
              ?.map((e) => Song.fromJson(e))
              .toList() ??
          [],
      artists: (json['artists'] as List<dynamic>?)
              ?.map((e) => Artist.fromJson(e))
              .toList() ??
          [],
      playlists: (json['playlists'] as List<dynamic>?)
              ?.map((e) => Playlist.fromJson(e))
              .toList() ??
          [],
      total: json['total'] ?? 0,
    );
  }
}

/// 评论模型
class MusicComment {
  final String id;
  final String content;
  final String userName;
  final String userAvatar;
  final DateTime createTime;
  final int likeCount;
  final bool liked;

  const MusicComment({
    required this.id,
    required this.content,
    required this.userName,
    this.userAvatar = '',
    required this.createTime,
    this.likeCount = 0,
    this.liked = false,
  });
}

/// 播放模式
enum PlaybackMode {
  sequence, // 顺序播放
  repeat, // 单曲循环
  shuffle, // 随机播放
  list, // 列表循环
}

/// 音质等级
enum AudioQuality {
  standard, // 标准 128K
  high, // 高品质 320K
  lossless, // 无损 FLAC
}

extension AudioQualityExtension on AudioQuality {
  int get bitrate {
    switch (this) {
      case AudioQuality.standard:
        return 128;
      case AudioQuality.high:
        return 320;
      case AudioQuality.lossless:
        return 1000;
    }
  }

  String get label {
    switch (this) {
      case AudioQuality.standard:
        return '标准';
      case AudioQuality.high:
        return '高品质';
      case AudioQuality.lossless:
        return '无损';
    }
  }
}
