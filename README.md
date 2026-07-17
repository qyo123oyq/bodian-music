# 波点音乐第三方安卓应用

基于 Flutter 开发的波点音乐第三方安卓应用，参考酷狗概念版第三方应用架构实现。

## 项目简介

本项目是波点音乐（酷我音乐旗下产品）的第三方客户端，使用 Flutter 跨平台框架开发。项目参考了两个开源项目：
- [BsaLee/bodian_music_api](https://github.com/BsaLee/bodian_music_api) - 波点音乐签到API逆向
- [umr-xiaomai/kgka_Music_hl](https://github.com/umr-xiaomai/kgka_Music_hl) - 酷狗概念版第三方应用架构

## 技术栈

| 技术 | 说明 |
|------|------|
| Flutter 3.x | 跨平台UI框架 |
| Dart | 开发语言 |
| Provider | 状态管理（ChangeNotifier） |
| http + dio | 网络请求 |
| just_audio + audio_service | 音频播放（后台播放、通知栏） |
| shared_preferences | 本地存储 |
| cached_network_image | 图片缓存 |
| MVVM | 架构模式 |

## 项目结构

```
lib/
├── main.dart                    # 应用入口
├── config/
│   └── app_config.dart          # 应用配置（API地址、设备伪装等）
├── core/
│   └── api_client.dart          # API客户端（重试、请求头封装）
├── models/
│   └── music_models.dart        # 数据模型（Song, Playlist, Artist等）
├── services/
│   ├── music_api.dart           # 音乐API服务（搜索、播放、歌词等）
│   ├── music_audio_handler.dart # 音频处理器（audio_service封装）
│   ├── cache_service.dart       # 缓存服务（SWR模式、文件缓存）
│   ├── download_service.dart    # 下载服务（并发控制、进度）
│   ├── desktop_lyrics_service.dart # 桌面歌词服务
│   └── local_storage_service.dart  # 本地存储（搜索历史、收藏等）
├── controllers/
│   ├── player_controller.dart   # 播放控制器（核心状态管理）
│   ├── theme_controller.dart    # 主题控制器（深色模式、主题色）
│   └── auth_controller.dart     # 认证控制器（登录、用户信息）
├── ui/
│   ├── pages/
│   │   ├── app_shell.dart       # 应用外壳（底部导航+迷你播放器）
│   │   ├── home_page.dart       # 首页（推荐、热门）
│   │   ├── search_page.dart     # 搜索页（热搜、历史、结果）
│   │   ├── player_page.dart     # 播放页（封面、歌词、控制）
│   │   ├── playlist_detail_page.dart # 歌单详情页
│   │   ├── library_page.dart    # 我的页面（用户、歌单）
│   │   └── settings_page.dart   # 设置页（主题、下载、关于）
│   └── widgets/
│       ├── artwork.dart         # 封面图组件
│       ├── mini_player.dart     # 迷你播放器
│       └── song_list_item.dart  # 歌曲列表项
└── utils/
    └── utils.dart               # 工具类

android/
└── app/src/main/
    ├── kotlin/com/bodian/bodian_music/
    │   ├── MainActivity.kt      # 主Activity（MethodChannel桥接）
    │   └── DesktopLyricsService.kt # 桌面歌词悬浮窗服务
    └── AndroidManifest.xml      # 清单文件
```

## 功能特性

### 核心功能
- ✅ **歌曲搜索** - 基于酷我音乐搜索API，支持分页加载
- ✅ **在线音乐播放** - just_audio实现，支持多种音质
- ✅ **播放控制** - 播放/暂停、上一首、下一首、进度拖动
- ✅ **播放模式** - 顺序播放、单曲循环、随机播放、列表循环
- ✅ **音质选择** - 标准128K、高品质320K、无损FLAC
- ✅ **歌词显示** - LRC格式歌词解析，当前行高亮
- ✅ **播放列表** - 队列管理，支持添加、删除、清空
- ✅ **迷你播放器** - 底部常驻，点击进入全屏播放页
- ✅ **全屏播放页** - 封面旋转、歌词滚动、操作面板

### 歌单与推荐
- ✅ **推荐歌单** - 首页推荐歌单展示
- ✅ **歌单详情** - 歌单信息、歌曲列表
- ✅ **热门歌曲** - 热门榜单展示

### 个性化
- ✅ **深色模式** - 浅色/深色/跟随系统
- ✅ **主题色** - 8种预设主题色可切换
- ✅ **车机模式** - 大字体、简化界面
- ✅ **搜索历史** - 本地保存搜索记录

### 用户功能
- ✅ **UID登录** - 使用波点音乐用户ID登录
- ✅ **用户信息** - 昵称、头像、VIP状态展示
- ✅ **签到领VIP** - 每日签到领VIP功能

### 下载与缓存
- ✅ **歌曲下载** - 支持多音质下载
- ✅ **播放缓存** - SWR缓存策略，首屏秒开
- ✅ **缓存管理** - 查看缓存大小、清除缓存

### 高级功能
- ✅ **桌面歌词** - 悬浮窗显示歌词（Android原生实现）
- ✅ **均衡器** - 10段均衡器（Android原生）
- ✅ **低音增强** - BassBoost效果
- ✅ **通知栏控制** - audio_service实现

### 待完善
- 🚧 网易云音乐音源支持
- 🚧 本地音乐扫描
- 🚧 云盘功能
- 🚧 评论系统
- 🚧 歌曲分享
- 🚧 睡眠定时器
- 🚧 播放倍速
- 🚧 音量归一化

## API说明

### 酷我音乐API

本项目使用酷我音乐的公开API接口：

| 功能 | 接口地址 | 说明 |
|------|----------|------|
| 歌曲搜索 | `http://search.kuwo.cn/r.s` | 支持搜索歌曲、歌手、歌单 |
| 播放地址 | `https://antiserver.kuwo.cn/anti.s` | 获取歌曲播放URL |
| 歌词获取 | `https://player.kuwo.cn/webmusic/st/getNewMuiseByRid` | 获取歌词（可能加密） |
| 用户信息 | `https://bd-api.kuwo.cn/api/ucenter/users/pub/{uid}` | 波点音乐用户信息 |
| 签到领VIP | `https://bd-api.kuwo.cn/api/ucenter/vip/give/popup` | 波点音乐签到 |

### 备用API

- 星之阁API: `https://api.xingzhige.com/API/Kuwo_BD_new/`

### 设备伪装

请求头模拟波点音乐iOS端：
- 平台: iOS
- 设备: iPhone13,1
- App版本: 3.2.3
- 固定Token: 从逆向项目获取

## 构建说明

### 环境要求
- Flutter SDK >= 3.0.0 (推荐 3.44.6+)
- Android SDK (API 34)
- JDK 17+
- Android Studio (可选)

### 构建步骤

```bash
# 1. 克隆项目
git clone <repository-url>
cd bodian_music

# 2. 安装依赖
flutter pub get

# 3. 运行调试（需要连接Android设备或启动模拟器）
flutter run

# 4. 构建Release APK
flutter build apk --release

# 5. 构建App Bundle
flutter build appbundle --release
```

### 国内镜像加速

如果在国内开发，建议配置镜像：

```bash
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
```

### Android签名配置

生成签名密钥：

```bash
keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key
```

创建 `android/key.properties`：
```properties
storePassword=密码
keyPassword=密码
keyAlias=key
storeFile=密钥文件路径
```

## 参考项目

### 1. 波点音乐API
- **仓库**: [BsaLee/bodian_music_api](https://github.com/BsaLee/bodian_music_api)
- **内容**: 波点音乐签到API逆向，Cloudflare Worker代理
- **借鉴**: API地址、请求头伪装、固定Token

### 2. 酷狗概念版第三方应用
- **仓库**: [umr-xiaomai/kgka_Music_hl](https://github.com/umr-xiaomai/kgka_Music_hl)
- **内容**: 基于Flutter的完整音乐播放器，支持多平台
- **借鉴**: 整体架构设计、播放器实现、UI布局

## 注意事项

1. **API稳定性**: 由于使用第三方API，接口可能随时失效
2. **版权问题**: 所有音乐版权归原作者及平台所有
3. **仅供学习**: 本项目仅供学习研究使用，请勿用于商业用途
4. **设备伪装**: 请求头模拟了波点音乐iOS客户端

## 免责声明

1. 本项目仅供学习研究使用，请勿用于商业用途
2. 所有音乐版权归原作者及平台所有
3. 使用本应用产生的任何问题由使用者自行承担
4. 请支持正版音乐

## License

MIT License
