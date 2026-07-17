import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../models/music_models.dart';
import 'music_api.dart';

/// 下载任务状态
enum DownloadStatus {
  pending,
  downloading,
  paused,
  completed,
  failed,
  canceled,
}

/// 下载任务
class DownloadTask {
  final Song song;
  final String quality;
  DownloadStatus status;
  double progress;
  String? filePath;
  String? error;
  CancelToken? cancelToken;

  DownloadTask({
    required this.song,
    required this.quality,
    this.status = DownloadStatus.pending,
    this.progress = 0,
    this.filePath,
    this.error,
    this.cancelToken,
  });

  String get fileName => '${song.artist} - ${song.name}.mp3';
}

/// 下载服务
class DownloadService {
  static final DownloadService _instance = DownloadService._internal();
  factory DownloadService() => _instance;
  DownloadService._internal();

  final Dio _dio = Dio();
  final List<DownloadTask> _tasks = [];
  int _maxConcurrent = 3;
  int _activeDownloads = 0;

  List<DownloadTask> get tasks => List.unmodifiable(_tasks);
  int get activeCount => _activeDownloads;
  int get completedCount =>
      _tasks.where((t) => t.status == DownloadStatus.completed).length;

  /// 获取下载目录
  Future<String> getDownloadDir() async {
    try {
      final dir = await getExternalStorageDirectory();
      final downloadDir = Directory('${dir?.path ?? ''}/BodianMusic');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }
      return downloadDir.path;
    } catch (e) {
      // 备用：使用应用文档目录
      final dir = await getApplicationDocumentsDirectory();
      final downloadDir = Directory('${dir.path}/downloads');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }
      return downloadDir.path;
    }
  }

  /// 添加下载任务
  Future<DownloadTask> addDownload(Song song, {String quality = '320k'}) async {
    // 检查是否已存在
    final existing = _tasks.firstWhere(
      (t) => t.song.id == song.id,
      orElse: () => DownloadTask(song: song, quality: quality),
    );

    if (existing.status == DownloadStatus.completed) {
      return existing;
    }

    if (_tasks.any((t) => t.song.id == song.id)) {
      return existing;
    }

    final task = DownloadTask(song: song, quality: quality);
    _tasks.add(task);

    // 启动下载
    _startNextDownload();

    return task;
  }

  /// 启动下一个下载任务
  Future<void> _startNextDownload() async {
    if (_activeDownloads >= _maxConcurrent) return;

    final pendingTask = _tasks.firstWhere(
      (t) => t.status == DownloadStatus.pending,
      orElse: () => _tasks.first,
    );

    if (pendingTask.status != DownloadStatus.pending) return;

    _activeDownloads++;
    pendingTask.status = DownloadStatus.downloading;

    try {
      await _downloadSong(pendingTask);
    } catch (e) {
      pendingTask.status = DownloadStatus.failed;
      pendingTask.error = e.toString();
    } finally {
      _activeDownloads--;
      _startNextDownload();
    }
  }

  /// 下载歌曲
  Future<void> _downloadSong(DownloadTask task) async {
    final song = task.song;

    // 获取播放地址
    String playUrl = song.songUrl;
    if (playUrl.isEmpty) {
      playUrl = await MusicApiService().getSongUrl(
        song.rid,
        quality: task.quality == '无损' ? 1000 : 320,
      );
    }

    if (playUrl.isEmpty) {
      throw Exception('无法获取播放地址');
    }

    // 构建文件路径
    final downloadDir = await getDownloadDir();
    final fileName = _sanitizeFileName('${song.artist} - ${song.name}');
    final ext = task.quality == '无损' ? 'flac' : 'mp3';
    final filePath = '$downloadDir/$fileName.$ext';

    task.filePath = filePath;
    task.cancelToken = CancelToken();

    // 执行下载
    await _dio.download(
      playUrl,
      filePath,
      cancelToken: task.cancelToken,
      onReceiveProgress: (received, total) {
        if (total > 0) {
          task.progress = received / total;
        }
      },
    );

    task.status = DownloadStatus.completed;
    task.progress = 1.0;
  }

  /// 暂停下载
  void pauseDownload(DownloadTask task) {
    if (task.status == DownloadStatus.downloading) {
      task.cancelToken?.cancel();
      task.status = DownloadStatus.paused;
    }
  }

  /// 恢复下载
  void resumeDownload(DownloadTask task) {
    if (task.status == DownloadStatus.paused) {
      task.status = DownloadStatus.pending;
      _startNextDownload();
    }
  }

  /// 取消下载
  void cancelDownload(DownloadTask task) {
    task.cancelToken?.cancel();
    task.status = DownloadStatus.canceled;
    _tasks.remove(task);
  }

  /// 删除已下载的文件
  Future<void> deleteDownload(DownloadTask task) async {
    if (task.filePath != null) {
      final file = File(task.filePath!);
      if (await file.exists()) {
        await file.delete();
      }
    }
    _tasks.remove(task);
  }

  /// 检查歌曲是否已下载
  Future<bool> isDownloaded(String songId) async {
    final task = _tasks.firstWhere(
      (t) => t.song.id == songId,
      orElse: () => DownloadTask(
        song: Song(id: songId, rid: '', name: '', artist: ''),
        quality: '',
      ),
    );

    if (task.status == DownloadStatus.completed && task.filePath != null) {
      return File(task.filePath!).exists();
    }

    return false;
  }

  /// 获取已下载歌曲列表
  List<Song> getDownloadedSongs() {
    return _tasks
        .where((t) => t.status == DownloadStatus.completed)
        .map((t) => t.song)
        .toList();
  }

  /// 清理文件名中的非法字符
  String _sanitizeFileName(String name) {
    return name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
  }

  /// 销毁
  void dispose() {
    for (final task in _tasks) {
      task.cancelToken?.cancel();
    }
    _dio.close();
  }
}
