import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/player_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../models/music_models.dart';
import '../widgets/artwork.dart';
import '../widgets/song_list_item.dart';

/// 全屏播放页
class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerController>(
      builder: (context, player, child) {
        final song = player.currentSong;
        if (song == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: Text('暂无播放'),
            ),
          );
        }

        return Scaffold(
          body: Stack(
            children: [
              // 背景（封面模糊效果简化版）
              Positioned.fill(
                child: Container(
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
              // 主内容
              SafeArea(
                child: Column(
                  children: [
                    // 顶部栏
                    _buildTopBar(context),
                    // 封面图
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildAlbumCover(context, song),
                          _buildLyricsView(context, player),
                        ],
                      ),
                    ),
                    // 歌曲信息
                    _buildSongInfo(context, song, player),
                    // 进度条
                    _buildProgressBar(context, player),
                    // 控制按钮
                    _buildControls(context, player),
                    // 底部操作栏
                    _buildBottomActions(context, player),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.keyboard_arrow_down),
            iconSize: 32,
          ),
          Column(
            children: [
              Text(
                '正在播放',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz),
            iconSize: 28,
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumCover(BuildContext context, Song song) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: ArtworkWidget(
          url: song.albumPicUrl,
          size: double.infinity,
          borderRadius: 16,
        ),
      ),
    );
  }

  Widget _buildLyricsView(BuildContext context, PlayerController player) {
    if (!player.hasLyrics) {
      return const Center(
        child: Text('暂无歌词'),
      );
    }

    return ListView.builder(
      itemCount: player.lyrics.length,
      controller: ScrollController(),
      itemBuilder: (context, index) {
        final lyric = player.lyrics[index];
        final isCurrent = index == player.currentLyricIndex;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          child: Text(
            lyric.content,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isCurrent ? 18 : 14,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              color: isCurrent
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSongInfo(
      BuildContext context, Song song, PlayerController player) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            song.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '${song.artist} · ${song.album}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, PlayerController player) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Slider(
            value: player.duration.inMilliseconds > 0
                ? player.position.inMilliseconds /
                    player.duration.inMilliseconds
                : 0.0,
            onChanged: (value) {
              final newPosition = Duration(
                milliseconds: (value * player.duration.inMilliseconds).toInt(),
              );
              player.seek(newPosition);
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                player.positionText,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                player.durationText,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControls(BuildContext context, PlayerController player) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 播放模式
          IconButton(
            onPressed: () => player.togglePlaybackMode(),
            icon: Icon(_getPlaybackModeIcon(player.playbackMode)),
            iconSize: 28,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          // 上一首
          IconButton(
            onPressed: () => player.previous(),
            icon: const Icon(Icons.skip_previous),
            iconSize: 40,
          ),
          // 播放/暂停
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () => player.togglePlay(),
              icon: Icon(
                player.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              iconSize: 36,
            ),
          ),
          // 下一首
          IconButton(
            onPressed: () => player.next(),
            icon: const Icon(Icons.skip_next),
            iconSize: 40,
          ),
          // 播放列表
          IconButton(
            onPressed: () => _showPlaylistSheet(context),
            icon: const Icon(Icons.playlist_play),
            iconSize: 28,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(
      BuildContext context, PlayerController player) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.favorite_border),
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.download_outlined),
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.comment_outlined),
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          IconButton(
            onPressed: () => _showQualitySheet(context),
            icon: const Icon(Icons.high_quality_outlined),
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  IconData _getPlaybackModeIcon(PlaybackMode mode) {
    switch (mode) {
      case PlaybackMode.sequence:
        return Icons.repeat;
      case PlaybackMode.repeat:
        return Icons.repeat_one;
      case PlaybackMode.shuffle:
        return Icons.shuffle;
      case PlaybackMode.list:
        return Icons.repeat;
    }
  }

  void _showPlaylistSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Consumer<PlayerController>(
          builder: (context, player, child) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.6,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '播放列表 (${player.playlist.length})',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      IconButton(
                        onPressed: () => player.clearQueue(),
                        icon: const Icon(Icons.delete_sweep_outlined),
                      ),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: player.playlist.length,
                      itemBuilder: (context, index) {
                        final song = player.playlist[index];
                        return SongListItem(
                          song: song,
                          index: index,
                          isPlaying: index == player.currentIndex,
                          onTap: () {
                            player.playSong(song, queue: player.playlist);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showQualitySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Consumer<PlayerController>(
          builder: (context, player, child) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '音质选择',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ...AudioQuality.values.map((quality) {
                    final isSelected = player.audioQuality == quality;
                    return ListTile(
                      title: Text(quality.label),
                      subtitle: Text('${quality.bitrate}kbps'),
                      trailing: isSelected
                          ? Icon(
                              Icons.check,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                      onTap: () {
                        player.setAudioQuality(quality);
                        Navigator.pop(context);
                      },
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
