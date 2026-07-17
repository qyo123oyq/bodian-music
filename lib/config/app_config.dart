class AppConfig {
  static const String appName = '波点音乐';
  static const String appVersion = '1.0.0';
  static const String packageName = 'com.bodian.music';

  // 酷我音乐API基础地址
  static const String kuwoBaseUrl = 'https://bd-api.kuwo.cn';
  static const String kuwoSearchUrl = 'http://search.kuwo.cn';
  static const String kuwoPlayerUrl = 'https://player.kuwo.cn';
  static const String kuwoAntiUrl = 'https://antiserver.kuwo.cn';

  // 波点音乐API
  static const String bodianApiUrl = 'https://bd-api.kuwo.cn/api';

  // 备用API（第三方聚合）
  static const String backupApiUrl = 'https://api.xingzhige.com/API/Kuwo_BD_new';

  // 设备信息伪装（波点音乐iOS端）
  static const Map<String, String> deviceHeaders = {
    'plat': 'ip',
    'channel': 'appstore',
    'brand': 'iPhone13,1',
    'devid': '7A03C7BC-26F2-4482-9031-E14CFC11CF33',
    'ver': '3.2.3',
    'User-Agent':
        'Mozilla/5.0 (iPhone; CPU iPhone OS 15_4_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 BoDianMusic',
    'Referer': 'https://h5app.kuwo.cn/',
    'Accept-Language': 'zh-CN,zh-Hans;q=0.9',
    'Origin': 'https://h5app.kuwo.cn',
  };

  // 固定Token（从逆向项目获取）
  static const String defaultToken = '137acd3e6d0276020741da2ef35a316b';
  static const String defaultFromUid = '19374293';

  // 音质等级
  static const int qualityStandard = 128;
  static const int qualityHigh = 320;
  static const int qualityLossless = 1000;

  // 缓存配置
  static const int cacheMaxSize = 300 * 1024 * 1024; // 300MB
  static const Duration cacheDuration = Duration(days: 30);

  // 播放配置
  static const int preloadNextThreshold = 30; // 剩余30秒预加载下一首
}
