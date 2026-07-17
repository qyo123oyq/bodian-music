import 'dart:math';

/// 工具类
class Utils {
  /// 格式化播放数量
  static String formatPlayCount(int count) {
    if (count >= 100000000) {
      return '${(count / 100000000).toStringAsFixed(1)}亿';
    } else if (count >= 10000) {
      return '${(count / 10000).toStringAsFixed(1)}万';
    }
    return count.toString();
  }

  /// 格式化时长（秒）
  static String formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// 格式化文件大小
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// 格式化日期
  static String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// 格式化时间
  static String formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// 生成随机ID
  static String generateId() {
    final random = Random();
    return DateTime.now().millisecondsSinceEpoch.toString() +
        random.nextInt(9999).toString().padLeft(4, '0');
  }

  /// 去除HTML标签
  static String stripHtml(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  /// 截断文本
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// 解析LRC歌词时间
  static Duration? parseLrcTime(String timeStr) {
    final match = RegExp(r'(\d{2}):(\d{2})\.(\d{2,3})').firstMatch(timeStr);
    if (match != null) {
      final minutes = int.parse(match.group(1)!);
      final seconds = int.parse(match.group(2)!);
      final msStr = match.group(3)!.padRight(3, '0');
      final milliseconds = int.parse(msStr);
      return Duration(
        minutes: minutes,
        seconds: seconds,
        milliseconds: milliseconds,
      );
    }
    return null;
  }
}
