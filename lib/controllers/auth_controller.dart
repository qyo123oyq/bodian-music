import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/music_models.dart';
import '../services/music_api.dart';
import 'dart:convert';

class AuthController extends ChangeNotifier {
  final MusicApiService _api = MusicApiService();

  UserProfile? _user;
  String? _uid;
  String? _token;
  bool _isLoggedIn = false;
  bool _isLoading = false;

  UserProfile? get user => _user;
  String? get uid => _uid;
  String? get token => _token;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;

  AuthController() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _uid = prefs.getString('uid');
    _token = prefs.getString('token');
    final userJson = prefs.getString('user');
    if (userJson != null) {
      _user = UserProfile.fromJson(jsonDecode(userJson));
    }
    _isLoggedIn = _uid != null && _uid!.isNotEmpty;
    notifyListeners();
  }

  /// 使用UID登录（波点音乐用户ID）
  Future<bool> loginWithUid(String uid) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _api.getUserInfo(uid);
      if (user != null) {
        _uid = uid;
        _user = user;
        _isLoggedIn = true;
        _token = _token ?? '';

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('uid', uid);
        await prefs.setString('user', jsonEncode(user.toJson()));

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('登录失败: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// 刷新用户信息
  Future<void> refreshUserInfo() async {
    if (_uid == null) return;

    try {
      final user = await _api.getUserInfo(_uid!);
      if (user != null) {
        _user = user;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(user.toJson()));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('刷新用户信息失败: $e');
    }
  }

  /// 签到
  Future<bool> checkIn() async {
    if (_uid == null) return false;

    try {
      final success = await _api.checkIn(_uid!);
      if (success) {
        await refreshUserInfo();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  /// 登出
  Future<void> logout() async {
    _uid = null;
    _token = null;
    _user = null;
    _isLoggedIn = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('uid');
    await prefs.remove('token');
    await prefs.remove('user');

    notifyListeners();
  }
}

// 扩展UserProfile的toJson方法
extension UserProfileJson on UserProfile {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'avatar': avatar,
      'signature': signature,
      'isVip': isVip,
      'level': level,
    };
  }
}
