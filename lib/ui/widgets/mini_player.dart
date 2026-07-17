import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/player_controller.dart';
import '../../models/music_models.dart';
import 'artwork.dart';

/// 迷你播放器（底部常驻）
class MiniPlayer extends StatelessWidget {
  final VoidCallback? onTap;

  const MiniPlayer({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerController>(
      builder: (context, player, child) {
        if (!player.hasSong) {
          return const SizedBox.shrink();
        }

        final song = player.currentSong!;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 8),
                // 封面
                ArtworkWidget(
                  url: song.albumPicUrl,
                  size: 48,
                  borderRadius: 8,
                ),
                const SizedBox(width: 12),
                // 歌曲信息
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.name,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        song.artist,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // 上一首
                IconButton(
                  onPressed: () => player.previous(),
                  icon: const Icon(Icons.skip_previous),
                  iconSize: 28,
                ),
                // 播放/暂停
                IconButton(
                  onPressed: () => player.togglePlay(),
                  icon: Icon(
                    player.isPlaying ? Icons.pause : Icons.play_arrow,
                  ),
                  iconSize: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
                // 下一首
                IconButton(
                  onPressed: () => player.next(),
                  icon: const Icon(Icons.skip_next),
                  iconSize: 28,
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 播放进度条
class MiniProgressBar extends StatelessWidget {
  const MiniProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerController>(
      builder: (context, player, child) {
        if (!player.hasSong) return const SizedBox.shrink();

        final progress = player.duration.inMilliseconds > 0
            ? player.position.inMilliseconds / player.duration.inMilliseconds
            : 0.0;

        return LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          minHeight: 2,
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary,
          ),
        );
      },
    );
  }
}
