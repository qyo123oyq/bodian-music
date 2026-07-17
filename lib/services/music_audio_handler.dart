import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import '../models/music_models.dart';
import 'music_api.dart';

/// 音频处理器，整合just_audio和audio_service
class MusicAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  final List<Song> _queue = [];
  int _currentIndex = 0;

  AudioPlayer get player => _player;
  List<Song> get queueSongs => _queue;
  int get currentIndex => _currentIndex;

  MusicAudioHandler() {
    _init();
  }

  Future<void> _init() async {
    // 监听播放状态变化
    _player.playbackEventStream.listen((event) {
      _broadcastState();
    });

    // 监听当前索引变化
    _player.currentIndexStream.listen((index) {
      if (index != null && index < _queue.length) {
        _currentIndex = index;
        _updateMediaItem();
      }
    });

    // 监听位置变化
    _player.positionStream.listen((position) {
      _broadcastState();
    });
  }

  /// 加载歌曲到队列并播放
  Future<void> loadSongs(List<Song> songs, {int initialIndex = 0}) async {
    if (songs.isEmpty) return;

    _queue.clear();
    _queue.addAll(songs);
    _currentIndex = initialIndex;

    // 创建播放列表
    final playlist = ConcatenatingAudioSource(
      children: songs.map((song) {
        return AudioSource.uri(
          Uri.parse(song.songUrl.isNotEmpty
              ? song.songUrl
              : 'https://example.com/placeholder.mp3'),
          tag: MediaItem(
            id: song.id,
            album: song.album,
            title: song.name,
            artist: song.artist,
            artUri: Uri.parse(song.albumPicUrl),
            duration: Duration(seconds: song.duration),
          ),
        );
      }).toList(),
    );

    try {
      await _player.setAudioSource(
        playlist,
        initialIndex: initialIndex,
        initialPosition: Duration.zero,
      );
      _updateQueue();
      _updateMediaItem();
    } catch (e) {
      // 处理加载失败
    }
  }

  /// 播放指定歌曲
  Future<void> playSong(Song song, {List<Song>? queue}) async {
    if (queue != null && queue.isNotEmpty) {
      final index = queue.indexWhere((s) => s.id == song.id);
      await loadSongs(queue, initialIndex: index >= 0 ? index : 0);
    } else {
      _queue.clear();
      _queue.add(song);
      _currentIndex = 0;

      try {
        // 先获取播放地址
        final playUrl = await MusicApiService().getSongUrl(song.rid);
        if (playUrl.isNotEmpty) {
          await _player.setAudioSource(
            AudioSource.uri(
              Uri.parse(playUrl),
              tag: MediaItem(
                id: song.id,
                album: song.album,
                title: song.name,
                artist: song.artist,
                artUri: Uri.parse(song.albumPicUrl),
                duration: Duration(seconds: song.duration),
              ),
            ),
          );
          _updateQueue();
          _updateMediaItem();
        }
      } catch (e) {
        // 处理错误
      }
    }
  }

  /// 添加歌曲到队列
  void addSong(Song song) {
    _queue.add(song);
    _updateQueue();
  }

  /// 从队列移除歌曲
  void removeSongAt(int index) {
    if (index >= 0 && index < _queue.length) {
      _queue.removeAt(index);
      _updateQueue();
    }
  }

  /// 清空队列
  void clearQueue() {
    _queue.clear();
    _updateQueue();
  }

  /// 获取当前歌曲
  Song? get currentSong {
    if (_currentIndex >= 0 && _currentIndex < _queue.length) {
      return _queue[_currentIndex];
    }
    return null;
  }

  // ============ audio_service 方法 ============

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    if (_currentIndex < _queue.length - 1) {
      await _player.seekToNext();
    } else {
      // 循环到第一首
      await _player.seek(Duration.zero, index: 0);
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_currentIndex > 0) {
      await _player.seekToPrevious();
    } else {
      // 循环到最后一首
      await _player.seek(Duration.zero, index: _queue.length - 1);
    }
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        _player.setLoopMode(LoopMode.off);
        break;
      case AudioServiceRepeatMode.one:
        _player.setLoopMode(LoopMode.one);
        break;
      case AudioServiceRepeatMode.all:
        _player.setLoopMode(LoopMode.all);
        break;
      case AudioServiceRepeatMode.group:
        _player.setLoopMode(LoopMode.all);
        break;
    }
    await super.setRepeatMode(repeatMode);
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    final enable = shuffleMode != AudioServiceShuffleMode.none;
    await _player.setShuffleModeEnabled(enable);
    await super.setShuffleMode(shuffleMode);
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index >= 0 && index < _queue.length) {
      await _player.seek(Duration.zero, index: index);
    }
  }

  // ============ 辅助方法 ============

  void _updateQueue() {
    queue.add(_queue
        .map((song) => MediaItem(
              id: song.id,
              album: song.album,
              title: song.name,
              artist: song.artist,
              artUri: Uri.parse(song.albumPicUrl),
              duration: Duration(seconds: song.duration),
            ))
        .toList());
  }

  void _updateMediaItem() {
    final song = currentSong;
    if (song != null) {
      mediaItem.add(MediaItem(
        id: song.id,
        album: song.album,
        title: song.name,
        artist: song.artist,
        artUri: Uri.parse(song.albumPicUrl),
        duration: Duration(seconds: song.duration),
      ));
    }
  }

  void _broadcastState() {
    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
        MediaControl.stop,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: _getProcessingState(),
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: _currentIndex,
    ));
  }

  AudioProcessingState _getProcessingState() {
    switch (_player.processingState) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
