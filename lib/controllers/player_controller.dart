import 'package:flutter/foundation.dart';
import '../models/music_models.dart';
import '../services/music_api.dart';
import '../services/music_audio_handler.dart';
import 'dart:async';

class PlayerController extends ChangeNotifier {
  final MusicApiService _api = MusicApiService();

  MusicAudioHandler? _audioHandler;
  List<Song> _playlist = [];
  int _currentIndex = -1;
  Song? _currentSong;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  Duration _bufferedPosition = Duration.zero;
  PlaybackMode _playbackMode = PlaybackMode.sequence;
  AudioQuality _audioQuality = AudioQuality.high;
  double _volume = 1.0;
  double _speed = 1.0;
  List<LyricLine> _lyrics = [];
  int _currentLyricIndex = 0;
  bool _isLoading = false;
  String? _errorMessage;

  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _durationSubscription;
  Timer? _lyricTimer;

  // Getters
  List<Song> get playlist => List.unmodifiable(_playlist);
  int get currentIndex => _currentIndex;
  Song? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;
  Duration get bufferedPosition => _bufferedPosition;
  PlaybackMode get playbackMode => _playbackMode;
  AudioQuality get audioQuality => _audioQuality;
  double get volume => _volume;
  double get speed => _speed;
  List<LyricLine> get lyrics => List.unmodifiable(_lyrics);
  int get currentLyricIndex => _currentLyricIndex;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  MusicAudioHandler? get audioHandler => _audioHandler;

  bool get hasSong => _currentSong != null;
  bool get hasLyrics => _lyrics.isNotEmpty;
  String get positionText => _formatDuration(_position);
  String get durationText => _formatDuration(_duration);

  // 初始化音频处理器
  Future<void> initAudioHandler() async {
    _audioHandler = MusicAudioHandler();
    _setupListeners();
  }

  void _setupListeners() {
    if (_audioHandler == null) return;

    // 监听位置变化
    _positionSubscription = _audioHandler!.player.positionStream.listen((pos) {
      _position = pos;
      _updateCurrentLyric();
      notifyListeners();
    });

    // 监听播放状态
    _playerStateSubscription =
        _audioHandler!.player.playingStream.listen((playing) {
      _isPlaying = playing;
      notifyListeners();
    });

    // 监听时长变化
    _durationSubscription =
        _audioHandler!.player.durationStream.listen((dur) {
      _duration = dur ?? Duration.zero;
      notifyListeners();
    });

    // 监听缓冲位置
    _audioHandler!.player.bufferedPositionStream.listen((buffered) {
      _bufferedPosition = buffered;
      notifyListeners();
    });

    // 监听当前歌曲变化
    _audioHandler!.player.currentIndexStream.listen((index) {
      if (index != null && index >= 0 && index < _playlist.length) {
        _currentIndex = index;
        _currentSong = _playlist[index];
        _loadLyrics(_playlist[index]);
        notifyListeners();
      }
    });
  }

  // 播放歌曲
  Future<void> playSong(Song song, {List<Song>? queue}) async {
    if (_audioHandler == null) {
      await initAudioHandler();
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 如果提供了队列，使用队列
      if (queue != null && queue.isNotEmpty) {
        _playlist = List.from(queue);
        _currentIndex = queue.indexWhere((s) => s.id == song.id);
        if (_currentIndex < 0) _currentIndex = 0;
      } else {
        // 单曲播放
        _playlist = [song];
        _currentIndex = 0;
      }

      _currentSong = song;

      // 获取播放地址
      final playUrl = await _api.getSongUrl(
        song.rid,
        quality: _audioQuality.bitrate,
      );

      if (playUrl.isEmpty) {
        throw Exception('无法获取播放地址');
      }

      // 更新歌曲的播放地址
      final updatedSong = song.copyWith(songUrl: playUrl);
      if (queue != null && queue.isNotEmpty) {
        _playlist[_currentIndex] = updatedSong;
      } else {
        _playlist[0] = updatedSong;
      }
      _currentSong = updatedSong;

      // 加载歌词
      await _loadLyrics(updatedSong);

      // 播放
      await _audioHandler!.playSong(updatedSong, queue: _playlist);
      _isPlaying = true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('播放失败: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 播放/暂停
  Future<void> togglePlay() async {
    if (_audioHandler == null) return;

    if (_isPlaying) {
      await _audioHandler!.pause();
    } else {
      await _audioHandler!.play();
    }
  }

  // 上一首
  Future<void> previous() async {
    if (_audioHandler == null || _playlist.isEmpty) return;

    if (_position.inSeconds > 3) {
      // 如果播放超过3秒，重新开始当前歌曲
      await seek(Duration.zero);
    } else {
      // 播放上一首
      int newIndex;
      switch (_playbackMode) {
        case PlaybackMode.shuffle:
          newIndex = _getRandomIndex();
          break;
        default:
          newIndex = _currentIndex - 1;
          if (newIndex < 0) {
            newIndex = _playlist.length - 1;
          }
      }

      if (newIndex >= 0 && newIndex < _playlist.length) {
        await playSong(_playlist[newIndex], queue: _playlist);
      }
    }
  }

  // 下一首
  Future<void> next() async {
    if (_audioHandler == null || _playlist.isEmpty) return;

    int newIndex;
    switch (_playbackMode) {
      case PlaybackMode.shuffle:
        newIndex = _getRandomIndex();
        break;
      case PlaybackMode.repeat:
        newIndex = _currentIndex;
        break;
      default:
        newIndex = _currentIndex + 1;
        if (newIndex >= _playlist.length) {
          if (_playbackMode == PlaybackMode.list) {
            newIndex = 0;
          } else {
            return; // 顺序播放到最后就停止
          }
        }
    }

    if (newIndex >= 0 && newIndex < _playlist.length) {
      await playSong(_playlist[newIndex], queue: _playlist);
    }
  }

  // 跳转到指定位置
  Future<void> seek(Duration position) async {
    if (_audioHandler == null) return;
    await _audioHandler!.seek(position);
  }

  // 设置播放模式
  void setPlaybackMode(PlaybackMode mode) {
    _playbackMode = mode;
    notifyListeners();
  }

  // 切换播放模式
  void togglePlaybackMode() {
    final modes = PlaybackMode.values;
    final currentIndex = modes.indexOf(_playbackMode);
    _playbackMode = modes[(currentIndex + 1) % modes.length];
    notifyListeners();
  }

  // 设置音质
  void setAudioQuality(AudioQuality quality) {
    _audioQuality = quality;
    notifyListeners();
  }

  // 设置音量
  Future<void> setVolume(double volume) async {
    _volume = volume;
    await _audioHandler?.player.setVolume(volume);
    notifyListeners();
  }

  // 设置播放速度
  Future<void> setSpeed(double speed) async {
    _speed = speed;
    await _audioHandler?.player.setSpeed(speed);
    notifyListeners();
  }

  // 添加到播放队列
  void addToQueue(Song song) {
    if (!_playlist.any((s) => s.id == song.id)) {
      _playlist.add(song);
      notifyListeners();
    }
  }

  // 从队列移除
  void removeFromQueue(int index) {
    if (index >= 0 && index < _playlist.length) {
      _playlist.removeAt(index);
      if (_currentIndex > index) {
        _currentIndex--;
      } else if (_currentIndex == index) {
        _currentSong = null;
      }
      notifyListeners();
    }
  }

  // 清空队列
  void clearQueue() {
    _playlist.clear();
    _currentIndex = -1;
    _currentSong = null;
    _lyrics.clear();
    _currentLyricIndex = 0;
    _audioHandler?.clearQueue();
    notifyListeners();
  }

  // 加载歌词
  Future<void> _loadLyrics(Song song) async {
    _lyrics.clear();
    _currentLyricIndex = 0;

    try {
      final lyricText = await _api.getLyric(song.rid);
      if (lyricText != null && lyricText.isNotEmpty) {
        _lyrics = _parseLyrics(lyricText);
      }
    } catch (e) {
      debugPrint('加载歌词失败: $e');
    }

    notifyListeners();
  }

  // 解析LRC歌词
  List<LyricLine> _parseLyrics(String lrcText) {
    final lines = <LyricLine>[];
    final regex = RegExp(r'\[(\d{2}):(\d{2})\.(\d{2,3})\](.*)');

    for (final line in lrcText.split('\n')) {
      final match = regex.firstMatch(line);
      if (match != null) {
        final minutes = int.parse(match.group(1)!);
        final seconds = int.parse(match.group(2)!);
        final msStr = match.group(3)!.padRight(3, '0');
        final milliseconds = int.parse(msStr);
        final content = match.group(4)!.trim();

        if (content.isNotEmpty) {
          lines.add(LyricLine(
            startTime: Duration(
              minutes: minutes,
              seconds: seconds,
              milliseconds: milliseconds,
            ),
            content: content,
          ));
        }
      }
    }

    lines.sort((a, b) => a.startTime.compareTo(b.startTime));
    return lines;
  }

  // 更新当前歌词索引
  void _updateCurrentLyric() {
    if (_lyrics.isEmpty) return;

    for (int i = _lyrics.length - 1; i >= 0; i--) {
      if (_position >= _lyrics[i].startTime) {
        if (_currentLyricIndex != i) {
          _currentLyricIndex = i;
        }
        break;
      }
    }
  }

  // 获取随机索引
  int _getRandomIndex() {
    if (_playlist.length <= 1) return 0;
    int newIndex;
    do {
      newIndex = DateTime.now().millisecondsSinceEpoch % _playlist.length;
    } while (newIndex == _currentIndex && _playlist.length > 1);
    return newIndex;
  }

  // 格式化时长
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _durationSubscription?.cancel();
    _lyricTimer?.cancel();
    _audioHandler?.dispose();
    super.dispose();
  }
}
