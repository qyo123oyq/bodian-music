import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/app_config.dart';

/// 桌面歌词服务
class DesktopLyricsService {
  static const MethodChannel _channel = MethodChannel(
    'com.bodian.music/desktop_lyrics',
  );

  bool _isShowing = false;
  bool get isShowing => _isShowing;

  /// 显示桌面歌词
  Future<bool> showLyrics() async {
    try {
      await _channel.invokeMethod('showLyrics');
      _isShowing = true;
      return true;
    } catch (e) {
      debugPrint('显示桌面歌词失败: $e');
      return false;
    }
  }

  /// 隐藏桌面歌词
  Future<bool> hideLyrics() async {
    try {
      await _channel.invokeMethod('hideLyrics');
      _isShowing = false;
      return true;
    } catch (e) {
      debugPrint('隐藏桌面歌词失败: $e');
      return false;
    }
  }

  /// 更新歌词
  Future<void> updateLyric(String lyric, {String? nextLyric}) async {
    try {
      await _channel.invokeMethod('updateLyric', {
        'lyric': lyric,
        'nextLyric': nextLyric ?? '',
      });
    } catch (e) {
      // 忽略错误
    }
  }

  /// 检查权限
  Future<bool> checkPermission() async {
    try {
      final result = await _channel.invokeMethod('checkPermission');
      return result == true;
    } catch (e) {
      return false;
    }
  }

  /// 请求权限
  Future<bool> requestPermission() async {
    try {
      final result = await _channel.invokeMethod('requestPermission');
      return result == true;
    } catch (e) {
      return false;
    }
  }

  /// 切换显示状态
  Future<bool> toggle() async {
    if (_isShowing) {
      return hideLyrics();
    } else {
      final hasPermission = await checkPermission();
      if (!hasPermission) {
        final granted = await requestPermission();
        if (!granted) return false;
      }
      return showLyrics();
    }
  }
}
